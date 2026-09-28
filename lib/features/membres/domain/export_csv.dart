import 'membre.dart';

/// Fichier CSV du fichier des membres (point-virgule : s'ouvre directement
/// dans Excel en Belgique ; BOM pour les accents).
String exporterCsv(
  List<Membre> membres, {
  required Map<String, String> familles,
  required List<String> entetes,
  required String Function(StatutMembre) libelleStatut,
}) {
  String date(DateTime? d) => d == null
      ? ''
      : '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  String cellule(String v) {
    final t = v.replaceAll('\r', ' ').replaceAll('\n', ' ');
    return t.contains(';') || t.contains('"')
        ? '"${t.replaceAll('"', '""')}"'
        : t;
  }

  final lignes = [
    entetes.map(cellule).join(';'),
    for (final m in membres)
      [
        m.nom,
        m.prenom,
        libelleStatut(m.statut),
        m.email,
        m.telephone,
        m.rue,
        m.codePostal,
        m.ville,
        date(m.dateNaissance),
        familles[m.familleId] ?? '',
        date(m.arriveeLe),
        date(m.baptemeLe),
        date(m.presentationLe),
        date(m.mariageLe),
        m.services.join(', '),
        m.notes,
      ].map(cellule).join(';'),
  ];
  return '﻿${lignes.join('\r\n')}\r\n';
}
