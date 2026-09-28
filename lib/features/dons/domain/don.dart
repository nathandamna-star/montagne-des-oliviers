import 'package:cloud_firestore/cloud_firestore.dart';

/// Affectation d'un don. « construction » : projet d'achat du bâtiment.
enum Affectation { dime, offrande, mission, construction, loyer, entraide }

enum StatutDon {
  enAttente,
  recu,
  annule;

  /// Valeur enregistrée dans Firestore (« en_attente »).
  String get code => this == enAttente ? 'en_attente' : name;

  static StatutDon depuis(Object? code) =>
      values.firstWhere((s) => s.code == code, orElse: () => enAttente);
}

/// Virement (annoncé dans l'app, confirmé par le trésorier), paiement en
/// ligne (carte ou Bancontact) ou versement d'un don mensuel.
enum ModeDon {
  virement,
  enLigne,
  mensuel;

  String get code => this == enLigne ? 'en_ligne' : name;

  static ModeDon depuis(Object? code) =>
      values.firstWhere((s) => s.code == code, orElse: () => virement);
}

/// Un don (`dons/{id}`). Par virement, l'identifiant est la communication
/// structurée.
class Don {
  const Don({
    required this.id,
    required this.uid,
    required this.nom,
    required this.montant,
    required this.affectation,
    this.mode = ModeDon.virement,
    this.statut = StatutDon.enAttente,
    this.createdAt,
  });

  final String id;
  final String uid;
  final String nom;
  final double montant;
  final Affectation affectation;
  final ModeDon mode;
  final StatutDon statut;
  final DateTime? createdAt;

  factory Don.depuisFirestore(DocumentSnapshot<Map<String, dynamic>> d) {
    final m = d.data() ?? const {};
    return Don(
      id: d.id,
      uid: m['uid'] as String? ?? '',
      nom: m['nom'] as String? ?? '',
      montant: (m['montant'] as num? ?? 0).toDouble(),
      affectation: Affectation.values.firstWhere(
        (a) => a.name == m['affectation'],
        orElse: () => Affectation.offrande,
      ),
      mode: ModeDon.depuis(m['mode']),
      statut: StatutDon.depuis(m['statut']),
      createdAt: (m['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  /// Les plus récents d'abord.
  static int parDate(Don a, Don b) =>
      (b.createdAt ?? DateTime(3000)).compareTo(a.createdAt ?? DateTime(3000));
}

/// Don mensuel par carte (`donsMensuels/{abonnement Stripe}`).
class DonMensuel {
  const DonMensuel({
    required this.id,
    required this.uid,
    required this.nom,
    required this.montant,
    required this.affectation,
    required this.actif,
  });

  final String id;
  final String uid;
  final String nom;
  final double montant;
  final Affectation affectation;
  final bool actif;

  factory DonMensuel.depuisFirestore(DocumentSnapshot<Map<String, dynamic>> d) {
    final m = d.data() ?? const {};
    return DonMensuel(
      id: d.id,
      uid: m['uid'] as String? ?? '',
      nom: m['nom'] as String? ?? '',
      montant: (m['montant'] as num? ?? 0).toDouble(),
      affectation: Affectation.values.firstWhere(
        (a) => a.name == m['affectation'],
        orElse: () => Affectation.offrande,
      ),
      actif: m['actif'] as bool? ?? false,
    );
  }
}

/// Dons reçus pendant l'année [annee], du plus ancien au plus récent.
List<Don> recusEn(Iterable<Don> dons, int annee) =>
    dons
        .where((d) => d.statut == StatutDon.recu && d.createdAt?.year == annee)
        .toList()
      ..sort((a, b) => a.createdAt!.compareTo(b.createdAt!));

/// Total par affectation (dans l'ordre des affectations), sans les zéros.
Map<Affectation, double> totauxParAffectation(Iterable<Don> dons) => {
  for (final a in Affectation.values)
    if (dons.any((d) => d.affectation == a))
      a: dons
          .where((d) => d.affectation == a)
          .fold(0.0, (s, d) => s + d.montant),
};

double totalDons(Iterable<Don> dons) => dons.fold(0.0, (s, d) => s + d.montant);

/// Total par donateur (uid → nom, total), du plus grand au plus petit.
List<(String, String, double)> totauxParDonateur(Iterable<Don> dons) {
  final noms = <String, String>{};
  final totaux = <String, double>{};
  for (final d in dons) {
    noms[d.uid] = d.nom;
    totaux[d.uid] = (totaux[d.uid] ?? 0) + d.montant;
  }
  return [for (final e in totaux.entries) (e.key, noms[e.key]!, e.value)]
    ..sort((a, b) => b.$3.compareTo(a.$3));
}

String _cellule(String v) {
  final t = v.replaceAll('\r', ' ').replaceAll('\n', ' ');
  return t.contains(';') || t.contains('"')
      ? '"${t.replaceAll('"', '""')}"'
      : t;
}

String _date(DateTime? d) => d == null
    ? ''
    : '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

/// Tableur des dons (point-virgule et BOM : s'ouvre dans Excel en Belgique).
String exporterDonsCsv(
  List<Don> dons, {
  required List<String> entetes,
  required String Function(Affectation) libelleAffectation,
  required String Function(ModeDon) libelleMode,
}) {
  final lignes = [
    entetes.map(_cellule).join(';'),
    for (final d in dons)
      [
        _date(d.createdAt),
        d.nom,
        libelleAffectation(d.affectation),
        libelleMode(d.mode),
        d.montant.toStringAsFixed(2).replaceAll('.', ','),
        d.mode == ModeDon.virement ? d.id : '',
      ].map(_cellule).join(';'),
  ];
  return '﻿${lignes.join('\r\n')}\r\n';
}
