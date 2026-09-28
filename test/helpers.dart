import 'dart:async';

import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:montagne_des_oliviers/app.dart';
import 'package:montagne_des_oliviers/core/horloge.dart';
import 'package:montagne_des_oliviers/features/actualites/actualites_providers.dart';
import 'package:montagne_des_oliviers/features/notifications/notifications_providers.dart';
import 'package:montagne_des_oliviers/features/notifications/notifications_service.dart';
import 'package:montagne_des_oliviers/shared/data/envoi_photos.dart';
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
}

/// Heure fixe des tests : lundi 5 octobre 2026, 9 h.
final maintenant = DateTime(2026, 10, 5, 9);

/// Environnement de test : faux Firebase et fausses fonctions.
class Banc {
  Banc({bool connecte = false, this.roles = const {}})
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
  final firestore = FakeFirebaseFirestore();
  final fonctions = FaussesFonctionsRoles();
  final notifications = FaussesNotifications();
  final photos = FauxEnvoiPhotos();
  final partage = FauxPartage();

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
  final b = banc ?? Banc();
  tester.view.physicalSize = taille;
  tester.view.devicePixelRatio = 2.5;
  addTearDown(tester.view.reset);
  tester.platformDispatcher.localesTestValue = [locale];
  addTearDown(tester.platformDispatcher.clearLocalesTestValue);
  await tester.pumpWidget(
    ProviderScope(
      overrides: b.overrides,
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
