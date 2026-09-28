import 'package:cloud_firestore/cloud_firestore.dart';

import '../domain/demande.dart';

class DemandesRepository {
  DemandesRepository(this.firestore);

  final FirebaseFirestore firestore;

  CollectionReference<Map<String, dynamic>> get _col =>
      firestore.collection('demandes');

  List<Demande> _trier(QuerySnapshot<Map<String, dynamic>> s) =>
      s.docs.map(Demande.depuisFirestore).toList()..sort(Demande.parDate);

  Stream<List<Demande>> mesDemandes(String uid) =>
      _col.where('uid', isEqualTo: uid).snapshots().map(_trier);

  /// Secrétariat et pasteurs.
  Stream<List<Demande>> toutes() => _col
      .orderBy('createdAt', descending: true)
      .limit(300)
      .snapshots()
      .map(_trier);

  Stream<Demande?> demande(String id) => _col
      .doc(id)
      .snapshots()
      .map((d) => d.exists ? Demande.depuisFirestore(d) : null);

  Future<void> creer({
    required String uid,
    required String nom,
    required TypeDemande type,
    required String message,
  }) => _col.add({
    'uid': uid,
    'nom': nom,
    'type': type.name,
    'message': message.trim(),
    'statut': StatutDemande.nouvelle.code,
    'createdAt': FieldValue.serverTimestamp(),
  });

  /// Réponse et suivi (secrétariat, pasteurs).
  Future<void> repondre(
    String id, {
    required StatutDemande statut,
    required String reponse,
    required String par,
  }) => _col.doc(id).update({
    'statut': statut.code,
    'reponse': reponse.trim(),
    'traiteePar': par,
    'updatedAt': FieldValue.serverTimestamp(),
  });

  Future<void> retirer(String id) => _col.doc(id).delete();
}
