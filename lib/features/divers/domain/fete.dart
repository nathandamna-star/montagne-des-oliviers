import 'package:cloud_firestore/cloud_firestore.dart';

enum TypeFete { anniversaire, naissance, mariage, fete, autre }

/// Ce qu'on apporte à une fête.
enum Apport { nourriture, gateau, boisson, autre }

/// Anniversaire, naissance, fête… annoncé par un membre (`fetes/{id}`).
class Fete {
  const Fete({
    required this.id,
    required this.titre,
    required this.type,
    required this.date,
    required this.uid,
    required this.nom,
    this.lieu = '',
    this.description = '',
  });

  final String id;
  final String titre;
  final TypeFete type;
  final DateTime date;
  final String lieu;
  final String description;

  /// Qui l'a annoncée.
  final String uid;
  final String nom;

  factory Fete.depuisFirestore(DocumentSnapshot<Map<String, dynamic>> d) {
    final m = d.data() ?? const {};
    return Fete(
      id: d.id,
      titre: m['titre'] as String? ?? '',
      type: TypeFete.values.firstWhere(
        (t) => t.name == m['type'],
        orElse: () => TypeFete.autre,
      ),
      date: (m['date'] as Timestamp?)?.toDate() ?? DateTime(2000),
      lieu: m['lieu'] as String? ?? '',
      description: m['description'] as String? ?? '',
      uid: m['uid'] as String? ?? '',
      nom: m['nom'] as String? ?? '',
    );
  }
}

/// Ce qu'un membre apporte à une fête (`fetes/{id}/apports/{uid}`), pour
/// informer les responsables cuisine.
class Contribution {
  const Contribution({
    required this.uid,
    required this.nom,
    this.apporte = const {},
    this.precision = '',
  });

  final String uid;
  final String nom;
  final Set<Apport> apporte;

  /// Précision libre (« 2 bouteilles de jus », « un gâteau au chocolat »…).
  final String precision;

  factory Contribution.depuisFirestore(
    DocumentSnapshot<Map<String, dynamic>> d,
  ) {
    final m = d.data() ?? const {};
    return Contribution(
      uid: d.id,
      nom: m['nom'] as String? ?? '',
      apporte: {
        for (final a in m['apporte'] as List? ?? const [])
          ...Apport.values.where((x) => x.name == a),
      },
      precision: m['precision'] as String? ?? '',
    );
  }
}
