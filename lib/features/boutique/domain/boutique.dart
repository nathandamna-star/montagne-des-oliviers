import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../shared/domain/sans_accents.dart';
import '../../../shared/domain_traduction.dart';

/// Livre de la boutique (`livres/{id}`).
class Livre {
  const Livre({
    required this.id,
    required this.titre,
    this.auteur = '',
    this.description = const {},
    required this.prix,
    this.photoUrl,
    this.disponible = true,
  });

  final String id;
  final String titre;
  final String auteur;
  final Map<String, String> description;
  final double prix;
  final String? photoUrl;

  /// Faux : épuisé, n'apparaît plus dans la boutique.
  final bool disponible;

  factory Livre.depuisFirestore(DocumentSnapshot<Map<String, dynamic>> d) {
    final m = d.data() ?? const {};
    return Livre(
      id: d.id,
      titre: m['titre'] as String? ?? '',
      auteur: m['auteur'] as String? ?? '',
      description: Traduction.lire(m['description']),
      prix: (m['prix'] as num? ?? 0).toDouble(),
      photoUrl: m['photoUrl'] as String?,
      disponible: m['disponible'] as bool? ?? false,
    );
  }

  Map<String, dynamic> versFirestore() => {
    'titre': titre.trim(),
    'auteur': auteur.trim(),
    'description': description.isEmpty ? null : description,
    'prix': prix,
    'photoUrl': photoUrl,
    'disponible': disponible,
    'updatedAt': FieldValue.serverTimestamp(),
  };

  static int parTitre(Livre a, Livre b) =>
      sansAccents(a.titre).compareTo(sansAccents(b.titre));
}

enum StatutCommande {
  enAttente,
  payee,
  remise,
  annulee;

  String get code => this == enAttente ? 'en_attente' : name;

  static StatutCommande depuis(Object? code) =>
      values.firstWhere((s) => s.code == code, orElse: () => enAttente);
}

class LigneCommande {
  const LigneCommande({
    required this.livreId,
    required this.titre,
    required this.prix,
    required this.quantite,
  });

  final String livreId;
  final String titre;
  final double prix;
  final int quantite;
}

/// Commande de livres (`commandes/{id}`), créée par le serveur. Par virement,
/// l'identifiant est la communication structurée. Retrait à l'église.
class Commande {
  const Commande({
    required this.id,
    required this.uid,
    required this.nom,
    required this.lignes,
    required this.total,
    required this.parVirement,
    this.statut = StatutCommande.enAttente,
    this.createdAt,
  });

  final String id;
  final String uid;
  final String nom;
  final List<LigneCommande> lignes;
  final double total;
  final bool parVirement;
  final StatutCommande statut;
  final DateTime? createdAt;

  int get nombreLivres => lignes.fold(0, (s, l) => s + l.quantite);

  factory Commande.depuisFirestore(DocumentSnapshot<Map<String, dynamic>> d) {
    final m = d.data() ?? const {};
    return Commande(
      id: d.id,
      uid: m['uid'] as String? ?? '',
      nom: m['nom'] as String? ?? '',
      lignes: [
        for (final l in (m['lignes'] as List? ?? const []).whereType<Map>())
          LigneCommande(
            livreId: l['livreId'] as String? ?? '',
            titre: l['titre'] as String? ?? '',
            prix: (l['prix'] as num? ?? 0).toDouble(),
            quantite: (l['quantite'] as num? ?? 1).toInt(),
          ),
      ],
      total: (m['total'] as num? ?? 0).toDouble(),
      parVirement: m['mode'] == 'virement',
      statut: StatutCommande.depuis(m['statut']),
      createdAt: (m['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  static int parDate(Commande a, Commande b) =>
      (b.createdAt ?? DateTime(3000)).compareTo(a.createdAt ?? DateTime(3000));
}

/// Total du panier (livre → quantité) avec les prix du catalogue.
double totalPanier(Map<String, int> panier, Map<String, Livre> livres) => panier
    .entries
    .fold(0.0, (s, e) => s + (livres[e.key]?.prix ?? 0) * e.value);
