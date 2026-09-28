import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/horloge.dart';
import '../auth/auth_providers.dart';

/// Salle de l'église (`salles/{id}`).
class Salle {
  const Salle({
    required this.id,
    required this.nom,
    this.capacite,
    this.description = '',
  });

  final String id;
  final String nom;
  final int? capacite;
  final String description;

  factory Salle.depuisFirestore(DocumentSnapshot<Map<String, dynamic>> d) {
    final m = d.data() ?? const {};
    return Salle(
      id: d.id,
      nom: m['nom'] as String? ?? '',
      capacite: (m['capacite'] as num?)?.toInt(),
      description: m['description'] as String? ?? '',
    );
  }
}

enum StatutReservation { demandee, validee, refusee, annulee }

/// Réservation d'une salle (`reservations/{id}`).
class Reservation {
  const Reservation({
    required this.id,
    required this.uid,
    required this.nom,
    required this.salleId,
    required this.salleNom,
    required this.debut,
    required this.fin,
    required this.motif,
    this.statut = StatutReservation.demandee,
    this.reponse = '',
  });

  final String id;
  final String uid;
  final String nom;
  final String salleId;
  final String salleNom;
  final DateTime debut;
  final DateTime fin;
  final String motif;
  final StatutReservation statut;
  final String reponse;

  bool chevauche(Reservation autre) =>
      autre.id != id &&
      autre.salleId == salleId &&
      chevauchement(debut, fin, autre.debut, autre.fin);

  factory Reservation.depuisFirestore(
    DocumentSnapshot<Map<String, dynamic>> d,
  ) {
    final m = d.data() ?? const {};
    final debut = (m['debut'] as Timestamp?)?.toDate() ?? DateTime(2000);
    return Reservation(
      id: d.id,
      uid: m['uid'] as String? ?? '',
      nom: m['nom'] as String? ?? '',
      salleId: m['salleId'] as String? ?? '',
      salleNom: m['salleNom'] as String? ?? '',
      debut: debut,
      fin: (m['fin'] as Timestamp?)?.toDate() ?? debut,
      motif: m['motif'] as String? ?? '',
      statut: StatutReservation.values.firstWhere(
        (s) => s.name == m['statut'],
        orElse: () => StatutReservation.demandee,
      ),
      reponse: m['reponse'] as String? ?? '',
    );
  }
}

/// Deux créneaux se chevauchent (les bords qui se touchent ne comptent pas :
/// 10 h–12 h puis 12 h–14 h, c'est possible).
bool chevauchement(DateTime d1, DateTime f1, DateTime d2, DateTime f2) =>
    d1.isBefore(f2) && d2.isBefore(f1);

/// Réservations validées de la liste qui empêchent ce créneau.
List<Reservation> conflits(
  String salleId,
  DateTime debut,
  DateTime fin,
  Iterable<Reservation> validees, {
  String? sauf,
}) => [
  for (final r in validees)
    if (r.id != sauf &&
        r.salleId == salleId &&
        r.statut == StatutReservation.validee &&
        chevauchement(debut, fin, r.debut, r.fin))
      r,
];

class SallesRepository {
  SallesRepository(this.firestore);

  final FirebaseFirestore firestore;

  CollectionReference<Map<String, dynamic>> get _salles =>
      firestore.collection('salles');
  CollectionReference<Map<String, dynamic>> get _resas =>
      firestore.collection('reservations');

  List<Reservation> _trier(QuerySnapshot<Map<String, dynamic>> s) =>
      s.docs.map(Reservation.depuisFirestore).toList()
        ..sort((a, b) => a.debut.compareTo(b.debut));

  Stream<List<Salle>> salles() => _salles.snapshots().map(
    (s) =>
        s.docs.map(Salle.depuisFirestore).toList()
          ..sort((a, b) => a.nom.toLowerCase().compareTo(b.nom.toLowerCase())),
  );

  Future<void> enregistrerSalle({
    String? id,
    required String nom,
    int? capacite,
    String description = '',
  }) => (id == null ? _salles.doc() : _salles.doc(id)).set({
    'nom': nom.trim(),
    'capacite': capacite,
    'description': description.trim(),
  });

  Future<void> supprimerSalle(String id) => _salles.doc(id).delete();

  /// Créneaux occupés (réservations validées), visibles par les membres.
  Stream<List<Reservation>> validees() =>
      _resas.where('statut', isEqualTo: 'validee').snapshots().map(_trier);

  Stream<List<Reservation>> mesReservations(String uid) =>
      _resas.where('uid', isEqualTo: uid).snapshots().map(_trier);

  /// Secrétariat : les demandes à traiter.
  Stream<List<Reservation>> aValider() =>
      _resas.where('statut', isEqualTo: 'demandee').snapshots().map(_trier);

  Future<void> demander({
    required String uid,
    required String nom,
    required Salle salle,
    required DateTime debut,
    required DateTime fin,
    required String motif,
  }) => _resas.add({
    'uid': uid,
    'nom': nom,
    'salleId': salle.id,
    'salleNom': salle.nom,
    'debut': Timestamp.fromDate(debut),
    'fin': Timestamp.fromDate(fin),
    'motif': motif.trim(),
    'statut': 'demandee',
    'createdAt': FieldValue.serverTimestamp(),
  });

  Future<void> decider(
    String id,
    StatutReservation statut, {
    String reponse = '',
  }) => _resas.doc(id).update({
    'statut': statut.name,
    'reponse': reponse.trim(),
    'updatedAt': FieldValue.serverTimestamp(),
  });

  Future<void> annuler(String id) => _resas.doc(id).update({
    'statut': 'annulee',
    'updatedAt': FieldValue.serverTimestamp(),
  });
}

final sallesRepositoryProvider = Provider<SallesRepository>(
  (ref) => SallesRepository(ref.watch(firestoreProvider)),
);

final sallesProvider = StreamProvider<List<Salle>>((ref) {
  if (ref.watch(profilProvider).value == null) return Stream.value(const []);
  return ref.watch(sallesRepositoryProvider).salles();
});

DateTime _aujourdhui(Ref ref) {
  final n = ref.watch(horlogeProvider)();
  return DateTime(n.year, n.month, n.day);
}

/// Réservations validées à venir (toutes salles).
final reservationsValideesProvider = StreamProvider<List<Reservation>>((ref) {
  if (ref.watch(profilProvider).value == null) return Stream.value(const []);
  final depuis = _aujourdhui(ref);
  return ref
      .watch(sallesRepositoryProvider)
      .validees()
      .map(
        (l) => [
          for (final r in l)
            if (!r.fin.isBefore(depuis)) r,
        ],
      );
});

final mesReservationsProvider = StreamProvider<List<Reservation>>((ref) {
  final uid = ref.watch(utilisateurFirebaseProvider).value?.uid;
  if (uid == null) return Stream.value(const []);
  final depuis = _aujourdhui(ref);
  return ref
      .watch(sallesRepositoryProvider)
      .mesReservations(uid)
      .map(
        (l) => [
          for (final r in l)
            if (!r.fin.isBefore(depuis)) r,
        ],
      );
});

final reservationsAValiderProvider = StreamProvider<List<Reservation>>(
  (ref) => ref.watch(sallesRepositoryProvider).aValider(),
);
