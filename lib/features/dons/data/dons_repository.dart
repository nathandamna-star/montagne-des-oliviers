import 'package:cloud_firestore/cloud_firestore.dart';

import '../domain/don.dart';

class DonsRepository {
  DonsRepository(this.firestore);

  final FirebaseFirestore firestore;

  CollectionReference<Map<String, dynamic>> get _col =>
      firestore.collection('dons');

  List<Don> _trier(QuerySnapshot<Map<String, dynamic>> s) =>
      s.docs.map(Don.depuisFirestore).toList()..sort(Don.parDate);

  Stream<List<Don>> mesDons(String uid) =>
      _col.where('uid', isEqualTo: uid).snapshots().map(_trier);

  Stream<Don?> don(String id) => _col
      .doc(id)
      .snapshots()
      .map((d) => d.exists ? Don.depuisFirestore(d) : null);

  Stream<List<DonMensuel>> mesDonsMensuels(String uid) => firestore
      .collection('donsMensuels')
      .where('uid', isEqualTo: uid)
      .snapshots()
      .map((s) => s.docs.map(DonMensuel.depuisFirestore).toList());

  /// Trésorier : virements annoncés, pas encore confirmés.
  Stream<List<Don>> enAttente() => _col
      .where('statut', isEqualTo: StatutDon.enAttente.code)
      .snapshots()
      .map(_trier);

  /// Trésorier : tous les dons d'une année.
  Stream<List<Don>> deLAnnee(int annee) => _col
      .where('createdAt', isGreaterThanOrEqualTo: DateTime(annee))
      .where('createdAt', isLessThan: DateTime(annee + 1))
      .snapshots()
      .map(_trier);

  /// Trésorier : dons mensuels en cours.
  Stream<List<DonMensuel>> donsMensuelsActifs() => firestore
      .collection('donsMensuels')
      .where('actif', isEqualTo: true)
      .snapshots()
      .map((s) => s.docs.map(DonMensuel.depuisFirestore).toList());

  /// Le membre annonce un virement ; [communication] en est l'identifiant.
  Future<void> annoncerVirement({
    required String communication,
    required String uid,
    required String nom,
    required double montant,
    required Affectation affectation,
  }) => _col.doc(communication).set({
    'uid': uid,
    'nom': nom,
    'montant': montant,
    'devise': 'EUR',
    'affectation': affectation.name,
    'mode': ModeDon.virement.code,
    'statut': StatutDon.enAttente.code,
    'createdAt': FieldValue.serverTimestamp(),
  });

  /// Le donateur renonce à un virement annoncé.
  Future<void> renoncer(String id) =>
      _col.doc(id).update({'statut': StatutDon.annule.code});

  /// Trésorier : virement reçu sur le compte (ou annulé).
  Future<void> confirmer(
    String id, {
    required bool recu,
    required String par,
  }) => _col.doc(id).update({
    'statut': (recu ? StatutDon.recu : StatutDon.annule).code,
    'confirmeLe': FieldValue.serverTimestamp(),
    'confirmePar': par,
  });
}
