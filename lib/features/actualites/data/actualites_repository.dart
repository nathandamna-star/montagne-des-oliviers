import 'package:cloud_firestore/cloud_firestore.dart';

import '../domain/actualite.dart';

class ActualitesRepository {
  ActualitesRepository(this.firestore);

  final FirebaseFirestore firestore;

  CollectionReference<Map<String, dynamic>> get _col =>
      firestore.collection('actualites');

  /// Annonces publiées : publiques pour les visiteurs, aussi celles des
  /// membres pour les personnes connectées (la requête suit les règles).
  Stream<List<Actualite>> publiees({required bool membre}) => _col
      .where('publie', isEqualTo: true)
      .where('visibilite', whereIn: membre ? ['public', 'membres'] : ['public'])
      .orderBy('publieLe', descending: true)
      .limit(50)
      .snapshots()
      .map(
        (s) =>
            s.docs.map(Actualite.depuisFirestore).toList()
              ..sort(Actualite.ordre),
      );

  /// Toutes, brouillons compris (secrétariat).
  Stream<List<Actualite>> toutes() => _col
      .orderBy('modifieLe', descending: true)
      .limit(200)
      .snapshots()
      .map((s) => s.docs.map(Actualite.depuisFirestore).toList());

  Stream<Actualite?> une(String id) => _col
      .doc(id)
      .snapshots()
      .map((d) => d.exists ? Actualite.depuisFirestore(d) : null);

  Future<Actualite?> lire(String id) async {
    final d = await _col.doc(id).get();
    return d.exists ? Actualite.depuisFirestore(d) : null;
  }

  String nouvelId() => _col.doc().id;

  /// Enregistre ; la date de publication est fixée à la première publication.
  Future<void> enregistrer(Actualite a, {required bool dejaPubliee}) =>
      _col.doc(a.id).set({
        ...a.versFirestore(),
        'modifieLe': FieldValue.serverTimestamp(),
        if (a.publie && !dejaPubliee) 'publieLe': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

  Future<void> supprimer(String id) => _col.doc(id).delete();
}
