import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../shared/domain/virement.dart';
import '../../shared/domain_traduction.dart';
import '../auth/auth_providers.dart';

/// Pages Facebook et YouTube de l'église (valeurs de départ).
const facebookEglise =
    'https://www.facebook.com/share/1JGvbmGdQk/?mibextid=wwXIfret';
const youtubeEglise = 'https://www.youtube.com/@montagnedesolivierstienen';

/// « 20:00 », « 9:30 ».
bool heureValide(String h) =>
    RegExp(r'^([01]?\d|2[0-3]):[0-5]\d$').hasMatch(h.trim());

/// Paramètres de l'église (`parametres/eglise`), lisibles par tous.
class ParametresEglise {
  const ParametresEglise({
    this.groupeIntercessionId,
    this.groupeCuisineId,
    this.facebookUrl = '',
    this.youtubeUrl = '',
    this.titulaire = '',
    this.iban = '',
    this.bic = '',
    this.emailContact = '',
    this.tiktokUrl = '',
    this.instagramUrl = '',
    this.pasteurNom = '',
    this.pasteurPhotoUrl,
    this.pasteurPresentation = const {},
    this.eglisePresentation = const {},
    this.interactionJour,
    this.interactionHeure = '',
    this.interactionLien = '',
    this.interactionDescription = const {},
    this.liensCommunaute = const [],
  });

  /// Groupe qui reçoit les sujets de prière « partagés avec l'intercession ».
  final String? groupeIntercessionId;

  /// Groupe des responsables cuisine (informés de ce que chacun apporte).
  final String? groupeCuisineId;
  final String facebookUrl;
  final String youtubeUrl;

  /// Compte bancaire de l'église (dons et livres par virement), saisi par le
  /// trésorier dans l'app.
  final String titulaire;
  final String iban;
  final String bic;

  /// Adresse de contact affichée dans les pages légales.
  final String emailContact;
  final String tiktokUrl;
  final String instagramUrl;

  /// Présentation du pasteur principal (page « Notre pasteur »).
  final String pasteurNom;
  final String? pasteurPhotoUrl;
  final Map<String, String> pasteurPresentation;

  /// Présentation de l'église (page « Notre église ») ; texte par défaut si vide.
  final Map<String, String> eglisePresentation;

  /// Rencontre en direct chaque semaine : jour (1 = lundi … 7 = dimanche),
  /// heure « 20:00 », lien (YouTube, Zoom, WhatsApp…), description.
  final int? interactionJour;
  final String interactionHeure;
  final String interactionLien;
  final Map<String, String> interactionDescription;

  /// Liens de la communauté WhatsApp : (titre, lien).
  final List<(String, String)> liensCommunaute;

  bool get interactionPrevue =>
      interactionJour != null && heureValide(interactionHeure);

  /// Prochaine rencontre en direct à partir de [maintenant].
  DateTime? prochaineInteraction(DateTime maintenant) {
    if (!interactionPrevue) return null;
    final [h, m] = interactionHeure.split(':').map(int.parse).toList();
    var jour = DateTime(
      maintenant.year,
      maintenant.month,
      maintenant.day,
      h,
      m,
    );
    while (jour.weekday != interactionJour ||
        jour.isBefore(maintenant.subtract(const Duration(hours: 2)))) {
      jour = DateTime(jour.year, jour.month, jour.day + 1, h, m);
    }
    return jour;
  }

  bool get virementPossible => titulaire.isNotEmpty && ibanValide(iban);

  factory ParametresEglise.depuis(Map<String, dynamic>? m) => ParametresEglise(
    groupeIntercessionId: m?['groupeIntercessionId'] as String?,
    groupeCuisineId: m?['groupeCuisineId'] as String?,
    // Comptes de l'église, tant que l'administrateur n'a rien changé.
    facebookUrl: m?['facebookUrl'] as String? ?? facebookEglise,
    youtubeUrl: m?['youtubeUrl'] as String? ?? youtubeEglise,
    titulaire: m?['titulaire'] as String? ?? '',
    iban: m?['iban'] as String? ?? '',
    bic: m?['bic'] as String? ?? '',
    emailContact: m?['emailContact'] as String? ?? '',
    tiktokUrl: m?['tiktokUrl'] as String? ?? '',
    instagramUrl: m?['instagramUrl'] as String? ?? '',
    pasteurNom: m?['pasteurNom'] as String? ?? '',
    pasteurPhotoUrl: m?['pasteurPhotoUrl'] as String?,
    pasteurPresentation: Traduction.lire(m?['pasteurPresentation']),
    eglisePresentation: Traduction.lire(m?['eglisePresentation']),
    interactionJour: (m?['interactionJour'] as num?)?.toInt(),
    interactionHeure: m?['interactionHeure'] as String? ?? '',
    interactionLien: m?['interactionLien'] as String? ?? '',
    interactionDescription: Traduction.lire(m?['interactionDescription']),
    liensCommunaute: [
      for (final l in (m?['liensCommunaute'] as List? ?? const []))
        if (l is Map && l['url'] is String)
          ((l['titre'] as String?) ?? '', l['url'] as String),
    ],
  );
}

final parametresEgliseProvider = StreamProvider<ParametresEglise>(
  (ref) => ref
      .watch(firestoreProvider)
      .doc('parametres/eglise')
      .snapshots()
      .map((d) => ParametresEglise.depuis(d.data())),
);

Future<void> enregistrerParametresEglise(
  FirebaseFirestore db, {
  required String? groupeIntercessionId,
  required String? groupeCuisineId,
  required String facebookUrl,
  required String youtubeUrl,
  required String emailContact,
  required String tiktokUrl,
  required String instagramUrl,
}) => db.doc('parametres/eglise').set({
  'tiktokUrl': tiktokUrl.trim(),
  'instagramUrl': instagramUrl.trim(),
  'emailContact': emailContact.trim(),
  'groupeIntercessionId': groupeIntercessionId,
  'groupeCuisineId': groupeCuisineId,
  'facebookUrl': facebookUrl.trim(),
  'youtubeUrl': youtubeUrl.trim(),
}, SetOptions(merge: true));

/// Trésorier : coordonnées bancaires de l'église.
Future<void> enregistrerCoordonnees(
  FirebaseFirestore db, {
  required String titulaire,
  required String iban,
  required String bic,
}) => db.doc('parametres/eglise').set({
  'titulaire': titulaire.trim(),
  'iban': nettoyerIban(iban),
  'bic': bic.trim().toUpperCase(),
}, SetOptions(merge: true));

/// Administrateur : présentation du pasteur principal.
Future<void> enregistrerPasteur(
  FirebaseFirestore db, {
  required String nom,
  required String? photoUrl,
  required Map<String, String> presentation,
}) => db.doc('parametres/eglise').set({
  'pasteurNom': nom.trim(),
  'pasteurPhotoUrl': photoUrl,
  'pasteurPresentation': presentation,
}, SetOptions(merge: true));

/// Administrateur : présentation de l'église, rencontre en direct, communauté.
Future<void> enregistrerRubriques(
  FirebaseFirestore db, {
  required Map<String, String> eglisePresentation,
  required int? interactionJour,
  required String interactionHeure,
  required String interactionLien,
  required Map<String, String> interactionDescription,
  required List<(String, String)> liensCommunaute,
}) => db.doc('parametres/eglise').set({
  'eglisePresentation': eglisePresentation,
  'interactionJour': interactionJour,
  'interactionHeure': interactionHeure.trim(),
  'interactionLien': interactionLien.trim(),
  'interactionDescription': interactionDescription,
  'liensCommunaute': [
    for (final (titre, url) in liensCommunaute)
      {'titre': titre.trim(), 'url': url.trim()},
  ],
}, SetOptions(merge: true));
