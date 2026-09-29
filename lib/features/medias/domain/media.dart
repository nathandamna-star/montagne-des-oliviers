import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../shared/domain_traduction.dart';
import '../../actualites/domain/actualite.dart';

enum TypeMedia { audio, video, direct }

/// Rubrique d'un média : prédications (par thème), enseignements
/// (mariage, délivrance, baptême…) ou podcasts.
enum Rubrique {
  predication,
  enseignement,
  podcast;

  static Rubrique depuis(Object? v) =>
      values.firstWhere((r) => r.name == v, orElse: () => predication);

  /// Thèmes proposés dans la rubrique (aucun pour les podcasts).
  List<ThemeMedia> get themes => switch (this) {
    predication => const [
      ThemeMedia.repentance,
      ThemeMedia.delivrance,
      ThemeMedia.guerison,
      ThemeMedia.combatSpirituel,
      ThemeMedia.liensFamille,
      ThemeMedia.foi,
      ThemeMedia.priere,
      ThemeMedia.autre,
    ],
    enseignement => const [
      ThemeMedia.mariage,
      ThemeMedia.delivrance,
      ThemeMedia.bapteme,
      ThemeMedia.autre,
    ],
    podcast => const [],
  };
}

enum ThemeMedia {
  repentance,
  delivrance,
  guerison,
  combatSpirituel,
  liensFamille,
  foi,
  priere,
  mariage,
  bapteme,
  autre;

  static ThemeMedia? depuis(Object? v) =>
      values.where((t) => t.name == v).firstOrNull;
}

/// Prédication, exhortation ou direct (`medias/{id}`).
class Media {
  const Media({
    required this.id,
    required this.type,
    required this.titre,
    required this.date,
    this.description = const {},
    this.predicateur = '',
    this.url,
    this.visibilite = Visibilite.public,
    this.publie = false,
    this.notifier = false,
    this.rubrique = Rubrique.predication,
    this.theme,
  });

  final String id;
  final TypeMedia type;
  final Map<String, String> titre;
  final Map<String, String> description;
  final String predicateur;
  final DateTime date;

  /// Fichier dans Storage, ou lien YouTube / Facebook (direct, vidéo).
  final String? url;
  final Visibilite visibilite;
  final bool publie;
  final bool notifier;
  final Rubrique rubrique;
  final ThemeMedia? theme;

  /// Lien YouTube ou Facebook : ouvert dans l'app correspondante.
  bool get lienExterne {
    final h = Uri.tryParse(url ?? '')?.host ?? '';
    return h.contains('youtube.com') ||
        h.contains('youtu.be') ||
        h.contains('facebook.com') ||
        h.contains('fb.watch');
  }

  factory Media.depuisFirestore(DocumentSnapshot<Map<String, dynamic>> d) {
    final m = d.data() ?? const {};
    return Media(
      id: d.id,
      type: TypeMedia.values.firstWhere(
        (t) => t.name == m['type'],
        orElse: () => TypeMedia.audio,
      ),
      titre: Traduction.lire(m['titre']),
      description: Traduction.lire(m['description']),
      predicateur: m['predicateur'] as String? ?? '',
      date: (m['date'] as Timestamp?)?.toDate() ?? DateTime(2000),
      url: (m['url'] as String?)?.isEmpty ?? true ? null : m['url'] as String,
      visibilite: m['visibilite'] == 'membres'
          ? Visibilite.membres
          : Visibilite.public,
      publie: m['publie'] == true,
      notifier: m['notifier'] == true,
      rubrique: Rubrique.depuis(m['rubrique']),
      theme: ThemeMedia.depuis(m['theme']),
    );
  }

  Map<String, dynamic> versFirestore() => {
    'type': type.name,
    'titre': titre,
    'description': description,
    'predicateur': predicateur.trim(),
    'date': Timestamp.fromDate(date),
    'url': url,
    'visibilite': visibilite.name,
    'publie': publie,
    'notifier': notifier,
    'rubrique': rubrique.name,
    'theme': theme?.name,
  };
}

/// Verset du jour (`versets/{id}`).
class Verset {
  const Verset({
    required this.id,
    required this.reference,
    required this.texte,
    required this.ordre,
  });

  final String id;
  final String reference;
  final Map<String, String> texte;
  final int ordre;

  factory Verset.depuisFirestore(DocumentSnapshot<Map<String, dynamic>> d) {
    final m = d.data() ?? const {};
    return Verset(
      id: d.id,
      reference: m['reference'] as String? ?? '',
      texte: Traduction.lire(m['texte']),
      ordre: (m['ordre'] as num?)?.toInt() ?? 0,
    );
  }
}

/// Un verset par jour, dans l'ordre choisi, en boucle.
Verset? versetDuJour(List<Verset> versets, DateTime jour) {
  if (versets.isEmpty) return null;
  final tries = [...versets]..sort((a, b) => a.ordre.compareTo(b.ordre));
  final numeroJour =
      DateTime.utc(jour.year, jour.month, jour.day).millisecondsSinceEpoch ~/
      86400000;
  return tries[numeroJour % tries.length];
}

/// Adresse de la page web publique d'un média (partage WhatsApp).
Uri pageWebMedia(String id) =>
    Uri.parse('https://montagne-des-oliviers.web.app/m/$id');
