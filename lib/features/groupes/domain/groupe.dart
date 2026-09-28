import 'package:cloud_firestore/cloud_firestore.dart';

enum TypeGroupe {
  cellule,
  intercession,
  jeunes,
  femmes,
  hommes,
  louange,
  moderation,
  media,
  cuisine,
  entraide,
  autre,
}

/// Dernier message d'un groupe (écrit par le serveur).
class DernierMessage {
  const DernierMessage({
    required this.auteur,
    required this.nom,
    required this.texte,
    required this.le,
  });

  final String auteur;
  final String nom;
  final String texte;
  final DateTime le;
}

/// Groupe de l'église (`groupes/{id}`).
class Groupe {
  const Groupe({
    required this.id,
    required this.nom,
    required this.type,
    this.description = '',
    this.prive = true,
    this.membres = const [],
    this.admins = const [],
    this.lienAppel = '',
    this.dernierMessage,
  });

  final String id;
  final String nom;
  final TypeGroupe type;
  final String description;
  final bool prive;
  final List<String> membres;

  /// Administrateurs du groupe (toujours membres).
  final List<String> admins;

  /// Lien d'appel externe facultatif (Meet, Zoom, WhatsApp…), en https.
  final String lienAppel;
  final DernierMessage? dernierMessage;

  bool estMembre(String? uid) => uid != null && membres.contains(uid);
  bool estAdmin(String? uid) => uid != null && admins.contains(uid);

  factory Groupe.depuisFirestore(DocumentSnapshot<Map<String, dynamic>> d) {
    final m = d.data() ?? const {};
    final dm = m['dernierMessage'];
    return Groupe(
      id: d.id,
      nom: m['nom'] as String? ?? '',
      type: TypeGroupe.values.firstWhere(
        (t) => t.name == m['type'],
        orElse: () => TypeGroupe.autre,
      ),
      description: m['description'] as String? ?? '',
      prive: m['prive'] != false,
      membres: [for (final u in m['membres'] as List? ?? const []) '$u'],
      admins: [for (final u in m['admins'] as List? ?? const []) '$u'],
      lienAppel: m['lienAppel'] as String? ?? '',
      dernierMessage: dm is Map && dm['le'] is Timestamp
          ? DernierMessage(
              auteur: dm['auteur'] as String? ?? '',
              nom: dm['nom'] as String? ?? '',
              texte: dm['texte'] as String? ?? '',
              le: (dm['le'] as Timestamp).toDate(),
            )
          : null,
    );
  }

  static int parNom(Groupe a, Groupe b) =>
      a.nom.toLowerCase().compareTo(b.nom.toLowerCase());
}

/// Message de la discussion d'un groupe.
class MessageGroupe {
  const MessageGroupe({
    required this.id,
    required this.auteur,
    required this.nom,
    this.texte = '',
    this.fichierUrl,
    this.createdAt,
  });

  final String id;
  final String auteur;
  final String nom;
  final String texte;
  final String? fichierUrl;
  final DateTime? createdAt;

  factory MessageGroupe.depuisFirestore(
    DocumentSnapshot<Map<String, dynamic>> d,
  ) {
    final m = d.data() ?? const {};
    return MessageGroupe(
      id: d.id,
      auteur: m['auteur'] as String? ?? '',
      nom: m['nom'] as String? ?? '',
      texte: m['texte'] as String? ?? '',
      fichierUrl: m['fichierUrl'] as String?,
      createdAt: (m['createdAt'] as Timestamp?)?.toDate(),
    );
  }
}

/// Un lien d'appel est accepté s'il est vide ou en https.
bool lienAppelValide(String v) {
  final t = v.trim();
  if (t.isEmpty) return true;
  final uri = Uri.tryParse(t);
  return uri != null && uri.scheme == 'https' && uri.host.isNotEmpty;
}
