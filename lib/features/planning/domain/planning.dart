import 'package:cloud_firestore/cloud_firestore.dart';

/// Équipe de service (`equipes/{id}`) : sono, accueil, école du dimanche…
class Equipe {
  const Equipe({
    required this.id,
    required this.nom,
    this.description = '',
    this.membres = const [],
    this.responsables = const [],
  });

  final String id;
  final String nom;
  final String description;
  final List<String> membres;

  /// Responsables de l'équipe : ils font le planning et gèrent les membres.
  final List<String> responsables;

  bool estMembre(String? uid) => uid != null && membres.contains(uid);
  bool estResponsable(String? uid) => uid != null && responsables.contains(uid);

  factory Equipe.depuisFirestore(DocumentSnapshot<Map<String, dynamic>> d) {
    final m = d.data() ?? const {};
    return Equipe(
      id: d.id,
      nom: m['nom'] as String? ?? '',
      description: m['description'] as String? ?? '',
      membres: [for (final u in m['membres'] as List? ?? const []) '$u'],
      responsables: [
        for (final u in m['responsables'] as List? ?? const []) '$u',
      ],
    );
  }

  Map<String, dynamic> versFirestore() => {
    'nom': nom.trim(),
    'description': description.trim(),
    'membres': membres,
    'responsables': responsables,
  };
}

enum StatutService { prevu, confirme, indisponible, remplacement }

/// Qui sert à quel culte (`equipes/{eid}/affectations/{id}`).
class Affectation {
  const Affectation({
    required this.id,
    required this.equipeId,
    required this.uid,
    required this.nom,
    required this.date,
    required this.titre,
    this.role = '',
    this.statut = StatutService.prevu,
    this.remplace = '',
  });

  final String id;
  final String equipeId;
  final String uid;
  final String nom;
  final DateTime date;

  /// Le culte ou l'événement (« Culte du dimanche »).
  final String titre;

  /// Le poste (« Table de mixage », « Accueil à la porte »…).
  final String role;
  final StatutService statut;

  /// Nom de la personne remplacée, le cas échéant.
  final String remplace;

  /// Un remplaçant est recherché.
  bool get aRemplacer =>
      statut == StatutService.indisponible ||
      statut == StatutService.remplacement;

  factory Affectation.depuisFirestore(
    DocumentSnapshot<Map<String, dynamic>> d,
  ) {
    final m = d.data() ?? const {};
    return Affectation(
      id: d.id,
      equipeId: d.reference.parent.parent?.id ?? '',
      uid: m['uid'] as String? ?? '',
      nom: m['nom'] as String? ?? '',
      date: (m['date'] as Timestamp?)?.toDate() ?? DateTime(2000),
      titre: m['titre'] as String? ?? '',
      role: m['role'] as String? ?? '',
      statut: StatutService.values.firstWhere(
        (s) => s.name == m['statut'],
        orElse: () => StatutService.prevu,
      ),
      remplace: m['remplace'] as String? ?? '',
    );
  }

  Map<String, dynamic> versFirestore() => {
    'uid': uid,
    'nom': nom,
    'date': Timestamp.fromDate(date),
    'titre': titre.trim(),
    'role': role.trim(),
    'statut': statut.name,
  };
}
