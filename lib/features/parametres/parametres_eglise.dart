import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../shared/domain/virement.dart';
import '../../shared/domain_traduction.dart';
import '../auth/auth_providers.dart';

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

  bool get virementPossible => titulaire.isNotEmpty && ibanValide(iban);

  factory ParametresEglise.depuis(Map<String, dynamic>? m) => ParametresEglise(
    groupeIntercessionId: m?['groupeIntercessionId'] as String?,
    groupeCuisineId: m?['groupeCuisineId'] as String?,
    facebookUrl: m?['facebookUrl'] as String? ?? '',
    youtubeUrl: m?['youtubeUrl'] as String? ?? '',
    titulaire: m?['titulaire'] as String? ?? '',
    iban: m?['iban'] as String? ?? '',
    bic: m?['bic'] as String? ?? '',
    emailContact: m?['emailContact'] as String? ?? '',
    tiktokUrl: m?['tiktokUrl'] as String? ?? '',
    instagramUrl: m?['instagramUrl'] as String? ?? '',
    pasteurNom: m?['pasteurNom'] as String? ?? '',
    pasteurPhotoUrl: m?['pasteurPhotoUrl'] as String?,
    pasteurPresentation: Traduction.lire(m?['pasteurPresentation']),
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
