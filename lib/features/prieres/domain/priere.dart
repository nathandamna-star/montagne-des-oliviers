import 'package:cloud_firestore/cloud_firestore.dart';

enum PartagePriere { pasteurs, intercession }

/// Sujet de prière (`prieres/{id}`). Confidentiel (pasteurs) ou partagé avec
/// le groupe d'intercession de l'église.
class Priere {
  const Priere({
    required this.id,
    required this.uid,
    required this.nom,
    required this.texte,
    this.anonyme = false,
    this.partage = PartagePriere.pasteurs,
    this.groupeId,
    this.exaucee = false,
    this.temoignage = '',
    this.nbPrieres = 0,
    this.createdAt,
  });

  final String id;
  final String uid;
  final String nom;
  final String texte;

  /// Nom caché à l'équipe d'intercession (les pasteurs le voient).
  final bool anonyme;
  final PartagePriere partage;
  final String? groupeId;
  final bool exaucee;
  final String temoignage;

  /// Nombre de « J'ai prié » (tenu par le serveur).
  final int nbPrieres;
  final DateTime? createdAt;

  factory Priere.depuisFirestore(DocumentSnapshot<Map<String, dynamic>> d) {
    final m = d.data() ?? const {};
    return Priere(
      id: d.id,
      uid: m['uid'] as String? ?? '',
      nom: m['nom'] as String? ?? '',
      texte: m['texte'] as String? ?? '',
      anonyme: m['anonyme'] == true,
      partage: m['partage'] == 'intercession'
          ? PartagePriere.intercession
          : PartagePriere.pasteurs,
      groupeId: m['groupeId'] as String?,
      exaucee: m['statut'] == 'exaucee',
      temoignage: m['temoignage'] as String? ?? '',
      nbPrieres: (m['nbPrieres'] as num?)?.toInt() ?? 0,
      createdAt: (m['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  static int parDate(Priere a, Priere b) =>
      (b.createdAt ?? DateTime(3000)).compareTo(a.createdAt ?? DateTime(3000));
}
