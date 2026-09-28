import 'package:cloud_firestore/cloud_firestore.dart';

import '../domain/priere.dart';

class PrieresRepository {
  PrieresRepository(this.firestore);

  final FirebaseFirestore firestore;

  CollectionReference<Map<String, dynamic>> get _col =>
      firestore.collection('prieres');

  List<Priere> _trier(QuerySnapshot<Map<String, dynamic>> s) =>
      s.docs.map(Priere.depuisFirestore).toList()..sort(Priere.parDate);

  Stream<List<Priere>> mesPrieres(String uid) =>
      _col.where('uid', isEqualTo: uid).snapshots().map(_trier);

  /// Sujets partagés avec un groupe d'intercession (ses membres).
  Stream<List<Priere>> duGroupe(String groupeId) => _col
      .where('partage', isEqualTo: 'intercession')
      .where('groupeId', isEqualTo: groupeId)
      .snapshots()
      .map(_trier);

  /// Pasteurs : tous les sujets.
  Stream<List<Priere>> toutes() => _col
      .orderBy('createdAt', descending: true)
      .limit(300)
      .snapshots()
      .map(_trier);

  Stream<Priere?> priere(String id) => _col
      .doc(id)
      .snapshots()
      .map((d) => d.exists ? Priere.depuisFirestore(d) : null);

  Future<void> creer({
    required String uid,
    required String nom,
    required String texte,
    required bool anonyme,
    required PartagePriere partage,
    String? groupeId,
  }) => _col.add({
    'uid': uid,
    'nom': nom,
    'anonyme': anonyme,
    'texte': texte.trim(),
    'partage': partage.name,
    'groupeId': partage == PartagePriere.intercession ? groupeId : null,
    'statut': 'ouverte',
    'createdAt': FieldValue.serverTimestamp(),
  });

  /// Prière exaucée, avec un témoignage (ou retour à « en prière »).
  Future<void> exaucee(
    String id, {
    required bool oui,
    String temoignage = '',
  }) => _col.doc(id).update({
    'statut': oui ? 'exaucee' : 'ouverte',
    'temoignage': temoignage.trim(),
    'updatedAt': FieldValue.serverTimestamp(),
  });

  Future<void> supprimer(String id) => _col.doc(id).delete();

  // « J'ai prié »
  DocumentReference<Map<String, dynamic>> _priant(String id, String uid) =>
      _col.doc(id).collection('priants').doc(uid);

  Stream<bool> aiPrie(String id, String uid) =>
      _priant(id, uid).snapshots().map((d) => d.exists);

  Future<void> jaiPrie(String id, String uid) =>
      _priant(id, uid).set({'le': FieldValue.serverTimestamp()});
}
