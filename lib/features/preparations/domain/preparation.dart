import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../shared/domain_traduction.dart';

enum TypePreparation { mariage, bapteme }

/// Parcours de préparation (`preparations/{id}`), créé par les pasteurs.
class Preparation {
  const Preparation({
    required this.id,
    required this.type,
    required this.titre,
    this.description = const {},
    this.publie = false,
  });

  final String id;
  final TypePreparation type;
  final Map<String, String> titre;
  final Map<String, String> description;

  /// Visible par tous les membres (les leçons restent réservées aux inscrits,
  /// sauf les leçons publiques).
  final bool publie;

  factory Preparation.depuisFirestore(
    DocumentSnapshot<Map<String, dynamic>> d,
  ) {
    final m = d.data() ?? const {};
    return Preparation(
      id: d.id,
      type: m['type'] == 'mariage'
          ? TypePreparation.mariage
          : TypePreparation.bapteme,
      titre: Traduction.lire(m['titre']),
      description: Traduction.lire(m['description']),
      publie: m['publie'] == true,
    );
  }

  Map<String, dynamic> versFirestore() => {
    'type': type.name,
    'titre': titre,
    'description': description,
    'publie': publie,
  };
}

/// Leçon d'une préparation : texte, audio, vidéo, document.
class Lecon {
  const Lecon({
    required this.id,
    required this.titre,
    required this.ordre,
    this.texte = const {},
    this.publique = false,
    this.audioUrl,
    this.videoUrl,
    this.documentUrl,
  });

  final String id;
  final Map<String, String> titre;
  final Map<String, String> texte;
  final int ordre;

  /// Visible par tous (sinon : inscrits et pasteurs seulement).
  final bool publique;
  final String? audioUrl;
  final String? videoUrl;
  final String? documentUrl;

  static String? _url(Object? v) => v is String && v.isNotEmpty ? v : null;

  factory Lecon.depuisFirestore(DocumentSnapshot<Map<String, dynamic>> d) {
    final m = d.data() ?? const {};
    return Lecon(
      id: d.id,
      titre: Traduction.lire(m['titre']),
      texte: Traduction.lire(m['texte']),
      ordre: (m['ordre'] as num?)?.toInt() ?? 0,
      publique: m['publique'] == true,
      audioUrl: _url(m['audioUrl']),
      videoUrl: _url(m['videoUrl']),
      documentUrl: _url(m['documentUrl']),
    );
  }

  Map<String, dynamic> versFirestore() => {
    'titre': titre,
    'texte': texte,
    'ordre': ordre,
    'publique': publique,
    'audioUrl': audioUrl,
    'videoUrl': videoUrl,
    'documentUrl': documentUrl,
  };
}

/// Rencontre avec le pasteur (entretien, date du baptême ou du mariage).
class RencontrePastorale {
  const RencontrePastorale({required this.titre, required this.date});

  final String titre;
  final DateTime date;

  Map<String, dynamic> versFirestore() => {
    'titre': titre,
    'date': Timestamp.fromDate(date),
  };
}

/// Candidat inscrit par un pasteur (`preparations/{id}/inscrits/{uid}`).
class Inscrit {
  const Inscrit({
    required this.uid,
    required this.nom,
    this.faites = const {},
    this.rencontres = const [],
    this.demandeId,
  });

  final String uid;
  final String nom;

  /// Leçons marquées comme faites.
  final Set<String> faites;
  final List<RencontrePastorale> rencontres;
  final String? demandeId;

  factory Inscrit.depuisFirestore(DocumentSnapshot<Map<String, dynamic>> d) {
    final m = d.data() ?? const {};
    return Inscrit(
      uid: d.id,
      nom: m['nom'] as String? ?? '',
      faites: {for (final f in m['faites'] as List? ?? const []) '$f'},
      rencontres: [
        for (final r in m['rencontres'] as List? ?? const [])
          if (r is Map && r['date'] is Timestamp)
            RencontrePastorale(
              titre: '${r['titre'] ?? ''}',
              date: (r['date'] as Timestamp).toDate(),
            ),
      ]..sort((a, b) => a.date.compareTo(b.date)),
      demandeId: m['demandeId'] as String?,
    );
  }
}

/// Question d'un candidat au pasteur.
class QuestionCandidat {
  const QuestionCandidat({
    required this.id,
    required this.texte,
    this.leconId,
    this.reponse = '',
    this.createdAt,
  });

  final String id;
  final String texte;
  final String? leconId;
  final String reponse;
  final DateTime? createdAt;

  factory QuestionCandidat.depuisFirestore(
    DocumentSnapshot<Map<String, dynamic>> d,
  ) {
    final m = d.data() ?? const {};
    return QuestionCandidat(
      id: d.id,
      texte: m['texte'] as String? ?? '',
      leconId: m['leconId'] as String?,
      reponse: m['reponse'] as String? ?? '',
      createdAt: (m['createdAt'] as Timestamp?)?.toDate(),
    );
  }
}
