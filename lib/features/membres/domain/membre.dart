import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../shared/domain/sans_accents.dart';

export '../../../shared/domain/sans_accents.dart';

enum StatutMembre { visiteur, membre, actif }

/// Fiche du fichier des membres (`membres/{id}`). Données sensibles :
/// secrétariat et pasteurs seulement (et la personne pour sa propre fiche).
class Membre {
  const Membre({
    required this.id,
    required this.nom,
    this.prenom = '',
    this.email = '',
    this.telephone = '',
    this.rue = '',
    this.codePostal = '',
    this.ville = '',
    this.dateNaissance,
    this.familleId,
    this.baptemeLe,
    this.presentationLe,
    this.mariageLe,
    this.arriveeLe,
    this.statut = StatutMembre.membre,
    this.uid,
    this.services = const [],
    this.notes = '',
  });

  final String id;
  final String nom;
  final String prenom;
  final String email;
  final String telephone;
  final String rue;
  final String codePostal;
  final String ville;
  final DateTime? dateNaissance;
  final String? familleId;
  final DateTime? baptemeLe;
  final DateTime? presentationLe;
  final DateTime? mariageLe;
  final DateTime? arriveeLe;
  final StatutMembre statut;

  /// Compte de l'app lié à la fiche (la personne peut alors lire sa fiche).
  final String? uid;

  /// Services exercés (louange, accueil, sono…).
  final List<String> services;
  final String notes;

  String get nomComplet => [prenom, nom].where((s) => s.isNotEmpty).join(' ');

  /// Pour le tri et la recherche : « nom prénom » sans accents ni majuscules.
  String get cle => sansAccents('$nom $prenom $email $telephone $ville');

  static DateTime? _date(Object? v) => (v as Timestamp?)?.toDate();
  static Timestamp? _ts(DateTime? d) =>
      d == null ? null : Timestamp.fromDate(d);

  factory Membre.depuisFirestore(DocumentSnapshot<Map<String, dynamic>> d) {
    final m = d.data() ?? const {};
    return Membre(
      id: d.id,
      nom: m['nom'] as String? ?? '',
      prenom: m['prenom'] as String? ?? '',
      email: m['email'] as String? ?? '',
      telephone: m['telephone'] as String? ?? '',
      rue: m['rue'] as String? ?? '',
      codePostal: m['codePostal'] as String? ?? '',
      ville: m['ville'] as String? ?? '',
      dateNaissance: _date(m['dateNaissance']),
      familleId: m['familleId'] as String?,
      baptemeLe: _date(m['baptemeLe']),
      presentationLe: _date(m['presentationLe']),
      mariageLe: _date(m['mariageLe']),
      arriveeLe: _date(m['arriveeLe']),
      statut: StatutMembre.values.firstWhere(
        (s) => s.name == m['statut'],
        orElse: () => StatutMembre.membre,
      ),
      uid: m['uid'] as String?,
      services: [for (final s in m['services'] as List? ?? const []) '$s'],
      notes: m['notes'] as String? ?? '',
    );
  }

  Map<String, dynamic> versFirestore() => {
    'nom': nom.trim(),
    'prenom': prenom.trim(),
    'email': email.trim(),
    'telephone': telephone.trim(),
    'rue': rue.trim(),
    'codePostal': codePostal.trim(),
    'ville': ville.trim(),
    'dateNaissance': _ts(dateNaissance),
    'familleId': familleId,
    'baptemeLe': _ts(baptemeLe),
    'presentationLe': _ts(presentationLe),
    'mariageLe': _ts(mariageLe),
    'arriveeLe': _ts(arriveeLe),
    'statut': statut.name,
    'uid': uid,
    'services': services,
    'notes': notes.trim(),
  };

  static int parNom(Membre a, Membre b) => a.cle.compareTo(b.cle);
}

/// Famille (`familles/{id}`) : ses membres ont `familleId` = id.
class Famille {
  const Famille({required this.id, required this.nom});

  final String id;
  final String nom;
}
