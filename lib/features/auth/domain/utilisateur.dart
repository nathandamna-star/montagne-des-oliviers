import 'package:cloud_firestore/cloud_firestore.dart';

/// Profil `users/{uid}`, créé à la première connexion avec le consentement.
class Utilisateur {
  const Utilisateur({
    required this.uid,
    required this.nom,
    required this.email,
    required this.langue,
    this.consentementLe,
    this.photoUrl,
  });

  final String uid;
  final String nom;
  final String email;
  final String langue;

  /// Date du consentement au traitement des données (appartenance à l'église :
  /// donnée sensible, article 9 RGPD).
  final DateTime? consentementLe;
  final String? photoUrl;

  factory Utilisateur.depuisFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final d = doc.data() ?? const {};
    return Utilisateur(
      uid: doc.id,
      nom: d['nom'] as String? ?? '',
      email: d['email'] as String? ?? '',
      langue: d['langue'] as String? ?? 'fr',
      consentementLe: (d['consentementLe'] as Timestamp?)?.toDate(),
      photoUrl: d['photoUrl'] as String?,
    );
  }
}
