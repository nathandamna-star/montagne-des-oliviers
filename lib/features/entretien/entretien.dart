import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/horloge.dart';
import '../auth/auth_providers.dart';

/// Séance de nettoyage de la salle (`nettoyages/{id}`).
class Nettoyage {
  const Nettoyage({
    required this.id,
    required this.titre,
    required this.date,
    this.description = '',
    this.places,
    this.nbInscrits = 0,
  });

  final String id;
  final String titre;
  final DateTime date;
  final String description;

  /// Nombre de personnes souhaité (null : pas de limite).
  final int? places;

  /// Tenu par le serveur.
  final int nbInscrits;

  bool get complet => places != null && nbInscrits >= places!;

  factory Nettoyage.depuisFirestore(DocumentSnapshot<Map<String, dynamic>> d) {
    final m = d.data() ?? const {};
    return Nettoyage(
      id: d.id,
      titre: m['titre'] as String? ?? '',
      date: (m['date'] as Timestamp?)?.toDate() ?? DateTime(2000),
      description: m['description'] as String? ?? '',
      places: (m['places'] as num?)?.toInt(),
      nbInscrits: (m['nbInscrits'] as num?)?.toInt() ?? 0,
    );
  }
}

class EntretienRepository {
  EntretienRepository(this.firestore);

  final FirebaseFirestore firestore;

  CollectionReference<Map<String, dynamic>> get _col =>
      firestore.collection('nettoyages');

  Stream<List<Nettoyage>> aVenir(DateTime depuis) => _col
      .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(depuis))
      .orderBy('date')
      .limit(50)
      .snapshots()
      .map((s) => s.docs.map(Nettoyage.depuisFirestore).toList());

  Future<void> creer({
    required String titre,
    required DateTime date,
    required String description,
    int? places,
  }) => _col.add({
    'titre': titre.trim(),
    'date': Timestamp.fromDate(date),
    'description': description.trim(),
    'places': places,
  });

  Future<void> supprimer(String id) => _col.doc(id).delete();

  /// uid → nom des inscrits.
  Stream<Map<String, String>> inscrits(String id) => _col
      .doc(id)
      .collection('inscrits')
      .snapshots()
      .map(
        (s) => {for (final d in s.docs) d.id: d.data()['nom'] as String? ?? ''},
      );

  Future<void> sInscrire(String id, String uid, String nom) => _col
      .doc(id)
      .collection('inscrits')
      .doc(uid)
      .set({'nom': nom, 'createdAt': FieldValue.serverTimestamp()});

  Future<void> seDesinscrire(String id, String uid) =>
      _col.doc(id).collection('inscrits').doc(uid).delete();
}

final entretienRepositoryProvider = Provider<EntretienRepository>(
  (ref) => EntretienRepository(ref.watch(firestoreProvider)),
);

final nettoyagesProvider = StreamProvider<List<Nettoyage>>((ref) {
  if (ref.watch(profilProvider).value == null) return Stream.value(const []);
  final n = ref.watch(horlogeProvider)();
  return ref
      .watch(entretienRepositoryProvider)
      .aVenir(DateTime(n.year, n.month, n.day));
});

final inscritsNettoyageProvider =
    StreamProvider.family<Map<String, String>, String>(
      (ref, id) => ref.watch(entretienRepositoryProvider).inscrits(id),
    );
