import 'package:cloud_firestore/cloud_firestore.dart';

import '../domain/media.dart';

class MediasRepository {
  MediasRepository(this.firestore);

  final FirebaseFirestore firestore;

  CollectionReference<Map<String, dynamic>> get _col =>
      firestore.collection('medias');
  CollectionReference<Map<String, dynamic>> get _versets =>
      firestore.collection('versets');

  /// Publiés : publics pour les visiteurs, aussi ceux des membres une fois connecté.
  Stream<List<Media>> publies({required bool membre}) => _col
      .where('publie', isEqualTo: true)
      .where('visibilite', whereIn: membre ? ['public', 'membres'] : ['public'])
      .orderBy('date', descending: true)
      .limit(100)
      .snapshots()
      .map((s) => s.docs.map(Media.depuisFirestore).toList());

  /// Secrétariat : tous, brouillons compris.
  Stream<List<Media>> tous() => _col
      .orderBy('date', descending: true)
      .limit(300)
      .snapshots()
      .map((s) => s.docs.map(Media.depuisFirestore).toList());

  Stream<Media?> media(String id) => _col
      .doc(id)
      .snapshots()
      .map((d) => d.exists ? Media.depuisFirestore(d) : null);

  Future<Media?> lire(String id) async {
    final d = await _col.doc(id).get();
    return d.exists ? Media.depuisFirestore(d) : null;
  }

  String nouvelId() => _col.doc().id;

  Future<void> enregistrer(Media m) => _col.doc(m.id).set({
    ...m.versFirestore(),
    'modifieLe': FieldValue.serverTimestamp(),
  }, SetOptions(merge: true));

  Future<void> supprimer(String id) => _col.doc(id).delete();

  // ----- Versets du jour -----

  Stream<List<Verset>> versets() => _versets.snapshots().map(
    (s) =>
        s.docs.map(Verset.depuisFirestore).toList()
          ..sort((a, b) => a.ordre.compareTo(b.ordre)),
  );

  Future<void> ajouterVerset({
    required String reference,
    required Map<String, String> texte,
    required int ordre,
  }) => _versets.add({
    'reference': reference.trim(),
    'texte': texte,
    'ordre': ordre,
  });

  Future<void> supprimerVerset(String id) => _versets.doc(id).delete();
}
