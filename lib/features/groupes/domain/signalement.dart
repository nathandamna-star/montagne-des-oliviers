import 'package:cloud_firestore/cloud_firestore.dart';

/// Message de groupe signalé par un membre (règle 1.2 de l'App Store), traité
/// par le secrétariat et les pasteurs : `signalements/{id}`.
class Signalement {
  const Signalement({
    required this.id,
    required this.groupeId,
    required this.groupeNom,
    required this.messageId,
    required this.auteur,
    required this.auteurNom,
    required this.extrait,
    required this.motif,
    required this.signalePar,
    this.createdAt,
  });

  final String id;
  final String groupeId;
  final String groupeNom;
  final String messageId;

  /// Auteur du message signalé.
  final String auteur;
  final String auteurNom;

  /// Début du texte (ou « [photo] »), pour décider sans ouvrir le groupe.
  final String extrait;
  final String motif;
  final String signalePar;
  final DateTime? createdAt;

  factory Signalement.depuisFirestore(
    DocumentSnapshot<Map<String, dynamic>> d,
  ) {
    final m = d.data() ?? const {};
    return Signalement(
      id: d.id,
      groupeId: m['groupeId'] as String? ?? '',
      groupeNom: m['groupeNom'] as String? ?? '',
      messageId: m['messageId'] as String? ?? '',
      auteur: m['auteur'] as String? ?? '',
      auteurNom: m['auteurNom'] as String? ?? '',
      extrait: m['extrait'] as String? ?? '',
      motif: m['motif'] as String? ?? '',
      signalePar: m['signalePar'] as String? ?? '',
      createdAt: (m['createdAt'] as Timestamp?)?.toDate(),
    );
  }
}
