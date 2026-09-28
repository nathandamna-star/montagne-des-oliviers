import 'package:cloud_firestore/cloud_firestore.dart';

import '../domain/membre.dart';

/// Compte de l'app (pour lier une fiche ou créer une fiche depuis un compte).
class CompteApp {
  const CompteApp({
    required this.uid,
    required this.nom,
    required this.email,
    this.roles = const [],
  });

  final String uid;
  final String nom;
  final String email;
  final List<String> roles;
}

class MembresRepository {
  MembresRepository(this.firestore);

  final FirebaseFirestore firestore;

  CollectionReference<Map<String, dynamic>> get _membres =>
      firestore.collection('membres');
  CollectionReference<Map<String, dynamic>> get _familles =>
      firestore.collection('familles');

  Stream<List<Membre>> membres() => _membres
      .limit(3000)
      .snapshots()
      .map(
        (s) => s.docs.map(Membre.depuisFirestore).toList()..sort(Membre.parNom),
      );

  Stream<Membre?> membre(String id) => _membres
      .doc(id)
      .snapshots()
      .map((d) => d.exists ? Membre.depuisFirestore(d) : null);

  Future<Membre?> lire(String id) async {
    final d = await _membres.doc(id).get();
    return d.exists ? Membre.depuisFirestore(d) : null;
  }

  String nouvelId() => _membres.doc().id;

  Future<void> enregistrer(Membre m) => _membres.doc(m.id).set({
    ...m.versFirestore(),
    'modifieLe': FieldValue.serverTimestamp(),
  });

  Future<void> supprimer(String id) => _membres.doc(id).delete();

  /// Rattache une fiche à une famille (ou l'en retire avec null).
  Future<void> rattacher(String membreId, String? familleId) =>
      _membres.doc(membreId).update({
        'familleId': familleId,
        'modifieLe': FieldValue.serverTimestamp(),
      });

  Stream<List<Famille>> familles() => _familles.snapshots().map(
    (s) => [
      for (final d in s.docs)
        Famille(id: d.id, nom: d.data()['nom'] as String? ?? ''),
    ]..sort((a, b) => sansAccents(a.nom).compareTo(sansAccents(b.nom))),
  );

  /// Crée une famille et renvoie son identifiant.
  Future<String> creerFamille(String nom) async {
    final ref = _familles.doc();
    await ref.set({'nom': nom.trim()});
    return ref.id;
  }

  Future<void> renommerFamille(String id, String nom) =>
      _familles.doc(id).set({'nom': nom.trim()});

  /// Supprime la famille ; ses membres n'y sont plus rattachés.
  Future<void> supprimerFamille(String id) async {
    final lot = firestore.batch();
    final membres = await _membres.where('familleId', isEqualTo: id).get();
    for (final d in membres.docs) {
      lot.update(d.reference, {'familleId': null});
    }
    lot.delete(_familles.doc(id));
    await lot.commit();
  }

  /// Comptes de l'app (secrétariat) : pour lier une fiche à un compte.
  Stream<List<CompteApp>> comptes() => firestore
      .collection('users')
      .limit(3000)
      .snapshots()
      .map(
        (s) => [
          for (final d in s.docs)
            CompteApp(
              uid: d.id,
              nom: d.data()['nom'] as String? ?? '',
              email: d.data()['email'] as String? ?? '',
              roles: [
                for (final r in d.data()['roles'] as List? ?? const []) '$r',
              ],
            ),
        ]..sort((a, b) => sansAccents(a.nom).compareTo(sansAccents(b.nom))),
      );
}
