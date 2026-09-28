import 'package:cloud_firestore/cloud_firestore.dart';

import '../domain/fete.dart';

class DiversRepository {
  DiversRepository(this.firestore);

  final FirebaseFirestore firestore;

  CollectionReference<Map<String, dynamic>> get _col =>
      firestore.collection('fetes');

  Stream<List<Fete>> aVenir(DateTime depuis) => _col
      .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(depuis))
      .orderBy('date')
      .limit(100)
      .snapshots()
      .map((s) => s.docs.map(Fete.depuisFirestore).toList());

  Stream<Fete?> fete(String id) => _col
      .doc(id)
      .snapshots()
      .map((d) => d.exists ? Fete.depuisFirestore(d) : null);

  Future<Fete?> lire(String id) async {
    final d = await _col.doc(id).get();
    return d.exists ? Fete.depuisFirestore(d) : null;
  }

  String nouvelId() => _col.doc().id;

  Future<void> creer(Fete f) => _col.doc(f.id).set({
    'titre': f.titre.trim(),
    'type': f.type.name,
    'date': Timestamp.fromDate(f.date),
    'lieu': f.lieu.trim(),
    'description': f.description.trim(),
    'uid': f.uid,
    'nom': f.nom,
    'createdAt': FieldValue.serverTimestamp(),
  });

  Future<void> modifier(Fete f) => _col.doc(f.id).update({
    'titre': f.titre.trim(),
    'type': f.type.name,
    'date': Timestamp.fromDate(f.date),
    'lieu': f.lieu.trim(),
    'description': f.description.trim(),
  });

  Future<void> supprimer(String id) => _col.doc(id).delete();

  DocumentReference<Map<String, dynamic>> _apport(String id, String uid) =>
      _col.doc(id).collection('apports').doc(uid);

  /// Ce que la personne apporte (elle seule, la cuisine et le secrétariat le voient).
  Stream<Contribution?> maContribution(String id, String uid) => _apport(
    id,
    uid,
  ).snapshots().map((d) => d.exists ? Contribution.depuisFirestore(d) : null);

  /// Responsables cuisine et secrétariat : tout ce qui est apporté.
  Stream<List<Contribution>> contributions(String id) => _col
      .doc(id)
      .collection('apports')
      .snapshots()
      .map(
        (s) => s.docs.map(Contribution.depuisFirestore).toList()
          ..sort((a, b) => a.nom.toLowerCase().compareTo(b.nom.toLowerCase())),
      );

  Future<void> apporter(String id, Contribution c) => _apport(id, c.uid).set({
    'nom': c.nom,
    'apporte': [
      for (final a in Apport.values)
        if (c.apporte.contains(a)) a.name,
    ],
    'precision': c.precision.trim(),
    'updatedAt': FieldValue.serverTimestamp(),
  });

  Future<void> retirerContribution(String id, String uid) =>
      _apport(id, uid).delete();
}
