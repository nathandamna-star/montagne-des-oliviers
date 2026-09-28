import 'package:cloud_firestore/cloud_firestore.dart';

import '../domain/evenement.dart';

class AgendaRepository {
  AgendaRepository(this.firestore);

  final FirebaseFirestore firestore;

  CollectionReference<Map<String, dynamic>> get _col =>
      firestore.collection('evenements');

  /// Événements publiés qui ne sont pas encore terminés, du plus proche au
  /// plus lointain.
  Stream<List<Evenement>> aVenir({
    required bool membre,
    required DateTime depuis,
  }) => _col
      .where('publie', isEqualTo: true)
      .where('visibilite', whereIn: membre ? ['public', 'membres'] : ['public'])
      .where('fin', isGreaterThanOrEqualTo: Timestamp.fromDate(depuis))
      .orderBy('fin')
      .limit(100)
      .snapshots()
      .map(
        (s) =>
            s.docs.map(Evenement.depuisFirestore).toList()
              ..sort((a, b) => a.debut.compareTo(b.debut)),
      );

  /// Tous les événements depuis [depuis], brouillons compris (secrétariat).
  Stream<List<Evenement>> tous({required DateTime depuis}) => _col
      .where('fin', isGreaterThanOrEqualTo: Timestamp.fromDate(depuis))
      .orderBy('fin')
      .limit(300)
      .snapshots()
      .map(
        (s) =>
            s.docs.map(Evenement.depuisFirestore).toList()
              ..sort((a, b) => a.debut.compareTo(b.debut)),
      );

  Stream<Evenement?> un(String id) => _col
      .doc(id)
      .snapshots()
      .map((d) => d.exists ? Evenement.depuisFirestore(d) : null);

  Future<Evenement?> lire(String id) async {
    final d = await _col.doc(id).get();
    return d.exists ? Evenement.depuisFirestore(d) : null;
  }

  String nouvelId() => _col.doc().id;

  Future<void> enregistrer(Evenement e) => _col.doc(e.id).set({
    ...e.versFirestore(),
    'modifieLe': FieldValue.serverTimestamp(),
  }, SetOptions(merge: true));

  Future<void> supprimer(String id) => _col.doc(id).delete();

  // ----- Inscriptions -----

  DocumentReference<Map<String, dynamic>> _inscription(String id, String uid) =>
      _col.doc(id).collection('inscriptions').doc(uid);

  Stream<Inscription?> monInscription(String id, String uid) =>
      _inscription(id, uid).snapshots().map(
        (d) => d.exists
            ? Inscription(
                uid: uid,
                nom: d.data()?['nom'] as String? ?? '',
                personnes: (d.data()?['personnes'] as num?)?.toInt() ?? 1,
              )
            : null,
      );

  Future<void> sInscrire(
    String id, {
    required String uid,
    required String nom,
    required int personnes,
  }) => _inscription(id, uid).set({
    'nom': nom,
    'personnes': personnes,
    'createdAt': FieldValue.serverTimestamp(),
  });

  Future<void> seDesinscrire(String id, String uid) =>
      _inscription(id, uid).delete();

  Stream<List<Inscription>> inscriptions(String id) => _col
      .doc(id)
      .collection('inscriptions')
      .orderBy('nom')
      .snapshots()
      .map(
        (s) => [
          for (final d in s.docs)
            Inscription(
              uid: d.id,
              nom: d.data()['nom'] as String? ?? '',
              personnes: (d.data()['personnes'] as num?)?.toInt() ?? 1,
            ),
        ],
      );
}
