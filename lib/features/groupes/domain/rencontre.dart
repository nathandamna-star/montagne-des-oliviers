import 'package:cloud_firestore/cloud_firestore.dart';

import 'groupe.dart';

enum TypeRencontre { reunion, repetition, moderation, appel }

enum Reponse { oui, non, peutetre }

/// Chant à préparer (répétition de louange).
class Chant {
  const Chant({required this.titre, this.lien = ''});

  final String titre;

  /// Audio, partition ou paroles (https), facultatif.
  final String lien;

  Map<String, dynamic> versFirestore() => {'titre': titre, 'lien': lien};
}

/// Rendez-vous du calendrier d'un groupe
/// (`groupes/{gid}/rencontres/{rid}`).
class Rencontre {
  const Rencontre({
    required this.id,
    required this.groupeId,
    required this.type,
    required this.titre,
    required this.debut,
    this.fin,
    this.lieu = '',
    this.notes = '',
    this.chants = const [],
    this.roles = const {},
    this.moderateur,
    this.remplacementDemande = false,
    this.deroule = const [],
    this.modeAppel = 'aucun',
  });

  final String id;
  final String groupeId;
  final TypeRencontre type;
  final String titre;
  final DateTime debut;
  final DateTime? fin;
  final String lieu;
  final String notes;

  /// Louange : chants à préparer et qui joue quoi (uid → instrument).
  final List<Chant> chants;
  final Map<String, String> roles;

  /// Modération : qui conduit le culte, remplacement demandé, déroulé.
  final String? moderateur;
  final bool remplacementDemande;
  final List<String> deroule;

  /// Appel programmé : « app » (dans l'application) ou « externe » (lien du groupe).
  final String modeAppel;

  factory Rencontre.depuisFirestore(
    String groupeId,
    DocumentSnapshot<Map<String, dynamic>> d,
  ) {
    final m = d.data() ?? const {};
    final debut = (m['debut'] as Timestamp?)?.toDate() ?? DateTime(2000);
    return Rencontre(
      id: d.id,
      groupeId: groupeId,
      type: TypeRencontre.values.firstWhere(
        (t) => t.name == m['type'],
        orElse: () => TypeRencontre.reunion,
      ),
      titre: m['titre'] as String? ?? '',
      debut: debut,
      fin: (m['fin'] as Timestamp?)?.toDate(),
      lieu: m['lieu'] as String? ?? '',
      notes: m['notes'] as String? ?? '',
      chants: [
        for (final c in m['chants'] as List? ?? const [])
          if (c is Map)
            Chant(titre: '${c['titre'] ?? ''}', lien: '${c['lien'] ?? ''}'),
      ],
      roles: {
        for (final e in (m['roles'] as Map? ?? const {}).entries)
          '${e.key}': '${e.value}',
      },
      moderateur: m['moderateur'] as String?,
      remplacementDemande: m['remplacement'] == 'demande',
      deroule: [for (final e in m['deroule'] as List? ?? const []) '$e'],
      modeAppel: m['modeAppel'] as String? ?? 'aucun',
    );
  }

  Map<String, dynamic> versFirestore() => {
    'type': type.name,
    'titre': titre.trim(),
    'debut': Timestamp.fromDate(debut),
    'fin': fin == null ? null : Timestamp.fromDate(fin!),
    'lieu': lieu.trim(),
    'notes': notes.trim(),
    'chants': [for (final c in chants) c.versFirestore()],
    'roles': roles,
    'moderateur': moderateur,
    'remplacement': remplacementDemande ? 'demande' : 'aucun',
    'deroule': deroule,
    'modeAppel': modeAppel,
  };
}

/// Type de rendez-vous proposé par défaut selon le groupe.
TypeRencontre typeParDefaut(TypeGroupe g) => switch (g) {
  TypeGroupe.louange => TypeRencontre.repetition,
  TypeGroupe.moderation => TypeRencontre.moderation,
  _ => TypeRencontre.reunion,
};

/// Déroulé habituel d'un culte (modifiable).
const derouleCulte = [
  'Accueil',
  'Louange et adoration',
  'Prière',
  'Annonces',
  'Offrande',
  'Prédication',
  'Bénédiction',
];
