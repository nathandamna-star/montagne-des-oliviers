import 'dart:async';
import 'dart:typed_data';

import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:montagne_des_oliviers/app.dart';
import 'package:montagne_des_oliviers/core/horloge.dart';
import 'package:montagne_des_oliviers/features/actualites/actualites_providers.dart';
import 'package:montagne_des_oliviers/features/notifications/notifications_providers.dart';
import 'package:montagne_des_oliviers/features/notifications/notifications_service.dart';
import 'package:montagne_des_oliviers/core/preferences.dart';
import 'package:montagne_des_oliviers/features/preparations/preparations_providers.dart';
import 'package:montagne_des_oliviers/features/profil/data/fonctions_compte.dart';
import 'package:montagne_des_oliviers/shared/data/envoi_fichiers.dart';
import 'package:montagne_des_oliviers/shared/data/envoi_photos.dart';
import 'package:montagne_des_oliviers/shared/lecteurs/lecteurs.dart';
import 'package:montagne_des_oliviers/shared/services/lanceur.dart';
import 'package:montagne_des_oliviers/shared/services/paiements_en_ligne.dart';
import 'package:montagne_des_oliviers/shared/services/partage.dart';
import 'package:montagne_des_oliviers/features/auth/auth_providers.dart';
import 'package:montagne_des_oliviers/features/auth/data/connexion_google.dart';
import 'package:montagne_des_oliviers/features/auth/data/fonctions_roles.dart';
import 'package:montagne_des_oliviers/features/auth/domain/role.dart';

/// Google / Apple simulés : connecte le compte fourni par [MockFirebaseAuth].
class FauxFournisseurs implements ConnexionFournisseurs {
  @override
  Future<UserCredential> google(FirebaseAuth auth) =>
      auth.signInWithCredential(GoogleAuthProvider.credential(idToken: 'x'));

  @override
  Future<UserCredential> apple(FirebaseAuth auth) =>
      auth.signInWithProvider(AppleAuthProvider());

  @override
  Future<void> deconnecterGoogle() async {}
}

/// Cloud Functions des rôles simulées : garde la trace des appels.
class FaussesFonctionsRoles implements FonctionsRoles {
  final appels = <String>[];
  ErreurRoles? erreur;

  @override
  Future<void> revendiquerAdmin() async {
    appels.add('revendiquerAdmin');
    if (erreur != null) throw erreur!;
  }

  @override
  Future<void> reconstruireAnnuaire() async =>
      appels.add('reconstruireAnnuaire');

  @override
  Future<void> definirRoles(String email, Set<Role> roles) async {
    appels.add('definirRoles $email ${roles.map((r) => r.name).join(',')}');
    if (erreur != null) throw erreur!;
  }
}

/// Notifications simulées : garde la trace des abonnements.
class FaussesNotifications implements NotificationsService {
  final appels = <String>[];
  final touchees = StreamController<Map<String, dynamic>>.broadcast();

  @override
  Future<void> activer({required String langue, String? uid}) async =>
      appels.add('activer $langue ${uid ?? '-'}');

  @override
  Future<void> desactiver(String uid) async => appels.add('desactiver $uid');

  @override
  Stream<Map<String, dynamic>> get notificationsTouchees => touchees.stream;
}

/// Photo simulée : renvoie une adresse sans rien envoyer.
class FauxEnvoiPhotos implements EnvoiPhotos {
  final chemins = <String>[];

  @override
  Future<String?> choisirEtEnvoyer(String chemin) async {
    chemins.add(chemin);
    return 'https://exemple.be/$chemin';
  }
}

/// Partage simulé : garde les fichiers « partagés ».
class FauxPartage implements Partage {
  final fichiers = <(String, String)>[];

  @override
  Future<void> partagerFichier({
    required String nom,
    required String contenu,
    required String typeMime,
  }) async => fichiers.add((nom, contenu));

  @override
  Future<void> partagerOctets({
    required String nom,
    required Uint8List octets,
    required String typeMime,
  }) async => fichiers.add((nom, String.fromCharCodes(octets.take(5))));
}

/// Liens externes simulés.
class FauxLanceur implements Lanceur {
  final ouverts = <Uri>[];

  @override
  Future<bool> ouvrir(Uri url) async {
    ouverts.add(url);
    return true;
  }
}

/// Lecteurs simulés (pas de lecteur natif dans les tests).
class FauxLecteurs implements FabriqueLecteurs {
  @override
  Widget audio({required String url, required String cle}) =>
      Text('audio:$url');

  @override
  Widget video({required String url, required String cle}) =>
      Text('video:$url');
}

/// Envoi de fichiers simulé : renvoie une adresse sans rien envoyer.
class FauxEnvoiFichiers implements EnvoiFichiers {
  final envois = <String>[];

  @override
  Future<String?> choisirEtEnvoyer({
    required String dossier,
    required GenreFichier genre,
    void Function(double)? progression,
  }) async {
    envois.add('$dossier/${genre.name}');
    progression?.call(1);
    return 'https://exemple.be/$dossier/${genre.name}';
  }
}

/// Paiements simulés : la commande est écrite comme le ferait le serveur.
class FauxPaiements implements PaiementsEnLigne {
  FauxPaiements(this.firestore);

  final FakeFirebaseFirestore firestore;
  final appels = <String>[];

  @override
  Future<Uri> payerDon({
    required double montant,
    required String affectation,
    required bool mensuel,
  }) async {
    appels.add('don $montant $affectation${mensuel ? ' mensuel' : ''}');
    return Uri.parse('https://stripe.test/don');
  }

  @override
  Future<CommandePassee> passerCommande({
    required Map<String, int> lignes,
    required String mode,
  }) async {
    appels.add('commande $mode');
    final id = mode == 'virement' ? '100000000034' : 'c-en-ligne';
    final details = <Map<String, dynamic>>[];
    var total = 0.0;
    for (final e in lignes.entries) {
      final l = (await firestore.doc('livres/${e.key}').get()).data()!;
      details.add({
        'livreId': e.key,
        'titre': l['titre'],
        'prix': l['prix'],
        'quantite': e.value,
      });
      total += (l['prix'] as num) * e.value;
    }
    await firestore.doc('commandes/$id').set({
      'uid': 'u1',
      'nom': 'Marie',
      'lignes': details,
      'total': total,
      'devise': 'EUR',
      'mode': mode,
      'statut': 'en_attente',
      'createdAt': maintenant,
    });
    return (
      id: id,
      url: mode == 'virement' ? null : Uri.parse('https://stripe.test/$id'),
    );
  }

  @override
  Future<void> arreterDonMensuel(String id) async {
    appels.add('arreter $id');
    await firestore.doc('donsMensuels/$id').update({'actif': false});
  }
}

/// Export et suppression du compte simulés.
class FaussesFonctionsCompte implements FonctionsCompte {
  final appels = <String>[];
  ErreurCompte? erreur;

  @override
  Future<String> exporterMesDonnees() async {
    appels.add('exporter');
    return '{"profil": {"nom": "Marie"}}';
  }

  @override
  Future<void> supprimerMonCompte() async {
    appels.add('supprimer');
    if (erreur != null) throw erreur!;
  }
}

/// Heure fixe des tests : lundi 5 octobre 2026, 9 h.
final maintenant = DateTime(2026, 10, 5, 9);

/// Environnement de test : faux Firebase et fausses fonctions.
class Banc {
  Banc({bool connecte = false, this.roles = const {}, this.iPhone = false})
    : auth = MockFirebaseAuth(
        signedIn: connecte,
        mockUser: MockUser(
          uid: 'u1',
          email: 'marie@exemple.be',
          displayName: 'Marie',
        ),
      );

  final MockFirebaseAuth auth;
  final Set<Role> roles;

  /// Dons sur le site de l'église (règle d'Apple sur iPhone).
  final bool iPhone;
  final firestore = FakeFirebaseFirestore();
  final fonctions = FaussesFonctionsRoles();
  final notifications = FaussesNotifications();
  final photos = FauxEnvoiPhotos();
  final partage = FauxPartage();
  final lanceur = FauxLanceur();
  final fichiers = FauxEnvoiFichiers();
  late final paiements = FauxPaiements(firestore);
  final compte = FaussesFonctionsCompte();

  /// Crée le profil (consentement déjà donné).
  Future<void> avecProfil([String nom = 'Marie']) =>
      firestore.collection('users').doc('u1').set({
        'nom': nom,
        'email': 'marie@exemple.be',
        'langue': 'fr',
        'consentementLe': DateTime(2026),
      });

  List<Override> get overrides => [
    firebaseAuthProvider.overrideWithValue(auth),
    firestoreProvider.overrideWithValue(firestore),
    connexionFournisseursProvider.overrideWithValue(FauxFournisseurs()),
    fonctionsRolesProvider.overrideWithValue(fonctions),
    notificationsServiceProvider.overrideWithValue(notifications),
    envoiPhotosProvider.overrideWithValue(photos),
    partageProvider.overrideWithValue(partage),
    lanceurProvider.overrideWithValue(lanceur),
    fabriqueLecteursProvider.overrideWithValue(FauxLecteurs()),
    envoiFichiersProvider.overrideWithValue(fichiers),
    paiementsEnLigneProvider.overrideWithValue(paiements),
    fonctionsCompteProvider.overrideWithValue(compte),
    donsDansLeNavigateurProvider.overrideWithValue(iPhone),
    horlogeProvider.overrideWithValue(() => maintenant),
    rolesFutureProvider.overrideWith((ref) async {
      final user = ref.watch(utilisateurFirebaseProvider).value;
      return user == null ? const <Role>{} : roles;
    }),
  ];
}

/// Lance l'app dans une taille d'écran donnée (téléphone par défaut).
Future<Banc> lancer(
  WidgetTester tester, {
  Banc? banc,
  Locale locale = const Locale('fr'),
  Size taille = const Size(1080, 2400),
}) async {
  SharedPreferences.setMockInitialValues({});
  final preferences = await SharedPreferences.getInstance();
  final b = banc ?? Banc();
  tester.view.physicalSize = taille;
  tester.view.devicePixelRatio = 2.5;
  addTearDown(tester.view.reset);
  tester.platformDispatcher.localesTestValue = [locale];
  addTearDown(tester.platformDispatcher.clearLocalesTestValue);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        ...b.overrides,
        sharedPreferencesProvider.overrideWithValue(preferences),
      ],
      child: const MontagneDesOliviersApp(),
    ),
  );
  await tester.pumpAndSettle();
  return b;
}

/// Banc d'un responsable connecté avec profil.
Future<Banc> responsable([Set<Role> roles = const {Role.admin}]) async {
  final b = Banc(connecte: true, roles: roles);
  await b.avecProfil();
  return b;
}

/// Montant tel que l'app l'affiche (espace insécable avant « € »).
String eur(String montant) => montant.replaceAll(' €', ' €');
