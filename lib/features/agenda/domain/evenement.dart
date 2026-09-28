import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../shared/domain_traduction.dart';
import '../../actualites/domain/actualite.dart';

enum TypeEvenement { culte, priere, jeune, cellule, evenement, conference }

/// Culte, réunion ou événement du calendrier (`evenements/{id}`).
class Evenement {
  const Evenement({
    required this.id,
    required this.titre,
    required this.type,
    required this.debut,
    required this.fin,
    this.description = const {},
    this.lieu = '',
    this.visibilite = Visibilite.public,
    this.publie = false,
    this.notifier = false,
    this.inscription = false,
    this.placesMax,
    this.inscrits = 0,
  });

  final String id;
  final Map<String, String> titre;
  final Map<String, String> description;
  final TypeEvenement type;
  final DateTime debut;
  final DateTime fin;
  final String lieu;
  final Visibilite visibilite;
  final bool publie;
  final bool notifier;
  final bool inscription;
  final int? placesMax;

  /// Nombre de personnes inscrites (tenu par le serveur).
  final int inscrits;

  bool get complet => placesMax != null && inscrits >= placesMax!;

  factory Evenement.depuisFirestore(DocumentSnapshot<Map<String, dynamic>> d) {
    final m = d.data() ?? const {};
    final debut = (m['debut'] as Timestamp?)?.toDate() ?? DateTime(2000);
    return Evenement(
      id: d.id,
      titre: Traduction.lire(m['titre']),
      description: Traduction.lire(m['description']),
      type: TypeEvenement.values.firstWhere(
        (t) => t.name == m['type'],
        orElse: () => TypeEvenement.evenement,
      ),
      debut: debut,
      fin: (m['fin'] as Timestamp?)?.toDate() ?? debut,
      lieu: m['lieu'] as String? ?? '',
      visibilite: m['visibilite'] == 'membres'
          ? Visibilite.membres
          : Visibilite.public,
      publie: m['publie'] == true,
      notifier: m['notifier'] == true,
      inscription: m['inscription'] == true,
      placesMax: (m['placesMax'] as num?)?.toInt(),
      inscrits: (m['inscrits'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> versFirestore() => {
    'titre': titre,
    'description': description,
    'type': type.name,
    'debut': Timestamp.fromDate(debut),
    'fin': Timestamp.fromDate(fin),
    'lieu': lieu,
    'visibilite': visibilite.name,
    'publie': publie,
    'notifier': notifier,
    'inscription': inscription,
    'placesMax': placesMax,
  };
}

/// Inscription d'une personne à un événement.
class Inscription {
  const Inscription({
    required this.uid,
    required this.nom,
    required this.personnes,
  });

  final String uid;
  final String nom;
  final int personnes;
}
