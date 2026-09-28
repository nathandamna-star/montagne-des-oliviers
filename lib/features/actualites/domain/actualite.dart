import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../shared/domain_traduction.dart';

enum Visibilite { public, membres }

/// Annonce de l'église (`actualites/{id}`).
class Actualite {
  const Actualite({
    required this.id,
    required this.titre,
    required this.texte,
    this.photoUrl,
    this.epingle = false,
    this.visibilite = Visibilite.public,
    this.publie = false,
    this.notifier = false,
    this.publieLe,
  });

  final String id;
  final Map<String, String> titre;
  final Map<String, String> texte;
  final String? photoUrl;
  final bool epingle;
  final Visibilite visibilite;
  final bool publie;
  final bool notifier;
  final DateTime? publieLe;

  factory Actualite.depuisFirestore(DocumentSnapshot<Map<String, dynamic>> d) {
    final m = d.data() ?? const {};
    return Actualite(
      id: d.id,
      titre: Traduction.lire(m['titre']),
      texte: Traduction.lire(m['texte']),
      photoUrl: (m['photoUrl'] as String?)?.isEmpty ?? true
          ? null
          : m['photoUrl'] as String,
      epingle: m['epingle'] == true,
      visibilite: m['visibilite'] == 'membres'
          ? Visibilite.membres
          : Visibilite.public,
      publie: m['publie'] == true,
      notifier: m['notifier'] == true,
      publieLe: (m['publieLe'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> versFirestore() => {
    'titre': titre,
    'texte': texte,
    'photoUrl': photoUrl,
    'epingle': epingle,
    'visibilite': visibilite.name,
    'publie': publie,
    'notifier': notifier,
  };

  /// Épinglées d'abord, puis les plus récentes.
  static int ordre(Actualite a, Actualite b) {
    if (a.epingle != b.epingle) return a.epingle ? -1 : 1;
    final da = a.publieLe ?? DateTime(3000);
    final db = b.publieLe ?? DateTime(3000);
    return db.compareTo(da);
  }
}
