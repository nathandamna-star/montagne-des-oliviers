import 'package:cloud_firestore/cloud_firestore.dart';

import '../domain/preparation.dart';

class PreparationsRepository {
  PreparationsRepository(this.firestore);

  final FirebaseFirestore firestore;

  CollectionReference<Map<String, dynamic>> get _col =>
      firestore.collection('preparations');

  List<Preparation> _liste(QuerySnapshot<Map<String, dynamic>> s) =>
      s.docs.map(Preparation.depuisFirestore).toList()
        ..sort((a, b) => a.type.index.compareTo(b.type.index));

  /// Membres : les préparations publiées.
  Stream<List<Preparation>> publiees() =>
      _col.where('publie', isEqualTo: true).snapshots().map(_liste);

  /// Pasteurs : toutes.
  Stream<List<Preparation>> toutes() => _col.snapshots().map(_liste);

  Stream<Preparation?> preparation(String id) => _col
      .doc(id)
      .snapshots()
      .map((d) => d.exists ? Preparation.depuisFirestore(d) : null);

  Future<Preparation?> lire(String id) async {
    final d = await _col.doc(id).get();
    return d.exists ? Preparation.depuisFirestore(d) : null;
  }

  String nouvelId() => _col.doc().id;

  Future<void> enregistrer(Preparation p) =>
      _col.doc(p.id).set(p.versFirestore(), SetOptions(merge: true));

  Future<void> supprimer(String id) => _col.doc(id).delete();

  // ----- Leçons -----

  CollectionReference<Map<String, dynamic>> _lecons(String id) =>
      _col.doc(id).collection('lecons');

  /// [toutes] : pasteurs et inscrits ; sinon, les leçons publiques seulement.
  Stream<List<Lecon>> lecons(String id, {required bool toutes}) =>
      (toutes ? _lecons(id) : _lecons(id).where('publique', isEqualTo: true))
          .snapshots()
          .map(
            (s) =>
                s.docs.map(Lecon.depuisFirestore).toList()
                  ..sort((a, b) => a.ordre.compareTo(b.ordre)),
          );

  Stream<Lecon?> lecon(String id, String lid) =>
      _lecons(id)
          .doc(lid)
          .snapshots()
          .map((d) => d.exists ? Lecon.depuisFirestore(d) : null);

  Future<Lecon?> lireLecon(String id, String lid) async {
    final d = await _lecons(id).doc(lid).get();
    return d.exists ? Lecon.depuisFirestore(d) : null;
  }

  String nouvelleLeconId(String id) => _lecons(id).doc().id;

  Future<void> enregistrerLecon(String id, Lecon l) =>
      _lecons(id).doc(l.id).set(l.versFirestore());

  Future<void> supprimerLecon(String id, String lid) =>
      _lecons(id).doc(lid).delete();

  /// Échange l'ordre de deux leçons.
  Future<void> echanger(String id, Lecon a, Lecon b) {
    final lot = firestore.batch();
    lot.update(_lecons(id).doc(a.id), {'ordre': b.ordre});
    lot.update(_lecons(id).doc(b.id), {'ordre': a.ordre});
    return lot.commit();
  }

  // ----- Candidats -----

  CollectionReference<Map<String, dynamic>> _inscrits(String id) =>
      _col.doc(id).collection('inscrits');

  Stream<Inscrit?> inscrit(String id, String uid) =>
      _inscrits(id)
          .doc(uid)
          .snapshots()
          .map((d) => d.exists ? Inscrit.depuisFirestore(d) : null);

  Stream<List<Inscrit>> inscrits(String id) => _inscrits(id).snapshots().map(
    (s) =>
        s.docs.map(Inscrit.depuisFirestore).toList()
          ..sort((a, b) => a.nom.toLowerCase().compareTo(b.nom.toLowerCase())),
  );

  Future<void> inscrire(
    String id, {
    required String uid,
    required String nom,
    String? demandeId,
  }) => _inscrits(id).doc(uid).set({
    'nom': nom,
    'faites': <String>[],
    'rencontres': <Map<String, dynamic>>[],
    'demandeId': ?demandeId,
    'createdAt': FieldValue.serverTimestamp(),
  });

  Future<void> desinscrire(String id, String uid) =>
      _inscrits(id).doc(uid).delete();

  /// Le candidat coche (ou décoche) une leçon.
  Future<void> marquerFaite(
    String id,
    String uid,
    String lid, {
    required bool faite,
  }) => _inscrits(id).doc(uid).update({
    'faites': faite
        ? FieldValue.arrayUnion([lid])
        : FieldValue.arrayRemove([lid]),
    'updatedAt': FieldValue.serverTimestamp(),
  });

  Future<void> definirRencontres(
    String id,
    String uid,
    List<RencontrePastorale> r,
  ) => _inscrits(id).doc(uid).update({
    'rencontres': [for (final x in r) x.versFirestore()],
  });

  // ----- Questions au pasteur -----

  CollectionReference<Map<String, dynamic>> _questions(String id, String uid) =>
      _inscrits(id).doc(uid).collection('questions');

  Stream<List<QuestionCandidat>> questions(String id, String uid) =>
      _questions(id, uid).snapshots().map(
        (s) => s.docs.map(QuestionCandidat.depuisFirestore).toList()
          ..sort(
            (a, b) => (a.createdAt ?? DateTime(3000)).compareTo(
              b.createdAt ?? DateTime(3000),
            ),
          ),
      );

  Future<void> poserQuestion(
    String id,
    String uid, {
    required String texte,
    String? leconId,
  }) => _questions(id, uid).add({
    'texte': texte.trim(),
    'leconId': leconId,
    'createdAt': FieldValue.serverTimestamp(),
  });

  Future<void> repondre(String id, String uid, String qid, String reponse) =>
      _questions(id, uid).doc(qid).update({
        'reponse': reponse.trim(),
        'reponduLe': FieldValue.serverTimestamp(),
      });
}
