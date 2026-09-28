import 'package:cloud_firestore/cloud_firestore.dart';

enum TypeDemande { bapteme, presentation, mariage, rendezvous, visite }

enum StatutDemande {
  nouvelle,
  enCours,
  acceptee,
  refusee,
  terminee;

  /// Valeur enregistrée dans Firestore (« en_cours »).
  String get code => this == enCours ? 'en_cours' : name;

  static StatutDemande depuis(Object? code) =>
      values.firstWhere((s) => s.code == code, orElse: () => nouvelle);
}

/// Demande d'un membre (`demandes/{id}`) : baptême, présentation d'enfant,
/// mariage, rendez-vous pastoral, visite.
class Demande {
  const Demande({
    required this.id,
    required this.uid,
    required this.nom,
    required this.type,
    this.message = '',
    this.statut = StatutDemande.nouvelle,
    this.reponse = '',
    this.createdAt,
  });

  final String id;
  final String uid;
  final String nom;
  final TypeDemande type;
  final String message;
  final StatutDemande statut;

  /// Réponse du secrétariat ou du pasteur (visible par la personne).
  final String reponse;
  final DateTime? createdAt;

  bool get enCours =>
      statut == StatutDemande.nouvelle || statut == StatutDemande.enCours;

  factory Demande.depuisFirestore(DocumentSnapshot<Map<String, dynamic>> d) {
    final m = d.data() ?? const {};
    return Demande(
      id: d.id,
      uid: m['uid'] as String? ?? '',
      nom: m['nom'] as String? ?? '',
      type: TypeDemande.values.firstWhere(
        (t) => t.name == m['type'],
        orElse: () => TypeDemande.rendezvous,
      ),
      message: m['message'] as String? ?? '',
      statut: StatutDemande.depuis(m['statut']),
      reponse: m['reponse'] as String? ?? '',
      createdAt: (m['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  /// Les plus récentes d'abord.
  static int parDate(Demande a, Demande b) =>
      (b.createdAt ?? DateTime(3000)).compareTo(a.createdAt ?? DateTime(3000));
}
