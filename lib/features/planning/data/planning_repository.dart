import 'package:cloud_firestore/cloud_firestore.dart';

import '../domain/planning.dart';

class PlanningRepository {
  PlanningRepository(this.firestore);

  final FirebaseFirestore firestore;

  CollectionReference<Map<String, dynamic>> get _equipes =>
      firestore.collection('equipes');

  Stream<List<Equipe>> equipes() => _equipes.snapshots().map(
    (s) =>
        s.docs.map(Equipe.depuisFirestore).toList()
          ..sort((a, b) => a.nom.toLowerCase().compareTo(b.nom.toLowerCase())),
  );

  Stream<Equipe?> equipe(String id) => _equipes
      .doc(id)
      .snapshots()
      .map((d) => d.exists ? Equipe.depuisFirestore(d) : null);

  Future<Equipe?> lireEquipe(String id) async {
    final d = await _equipes.doc(id).get();
    return d.exists ? Equipe.depuisFirestore(d) : null;
  }

  String nouvelleEquipeId() => _equipes.doc().id;

  Future<void> enregistrerEquipe(Equipe e) =>
      _equipes.doc(e.id).set(e.versFirestore());

  Future<void> supprimerEquipe(String id) => _equipes.doc(id).delete();

  /// Responsable d'équipe : ajoute ou retire des membres.
  Future<void> modifierMembres(String id, List<String> membres) => _equipes
      .doc(id)
      .update({'membres': membres, 'updatedAt': FieldValue.serverTimestamp()});

  // ----- Affectations -----

  CollectionReference<Map<String, dynamic>> _affectations(String eid) =>
      _equipes.doc(eid).collection('affectations');

  List<Affectation> _trier(
    Iterable<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
  ) =>
      docs.map(Affectation.depuisFirestore).toList()
        ..sort((a, b) => a.date.compareTo(b.date));

  /// Planning à venir d'une équipe.
  Stream<List<Affectation>> affectations(
    String eid, {
    required DateTime depuis,
  }) =>
      _affectations(eid)
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(depuis))
          .orderBy('date')
          .limit(200)
          .snapshots()
          .map((s) => _trier(s.docs));

  /// Mes services à venir, toutes équipes confondues.
  Stream<List<Affectation>> mesAffectations(
    String uid, {
    required DateTime depuis,
  }) => firestore
      .collectionGroup('affectations')
      .where('uid', isEqualTo: uid)
      .snapshots()
      .map(
        (s) => _trier(s.docs).where((a) => !a.date.isBefore(depuis)).toList(),
      );

  Future<Affectation?> lireAffectation(String eid, String id) async {
    final d = await _affectations(eid).doc(id).get();
    return d.exists ? Affectation.depuisFirestore(d) : null;
  }

  String nouvelleAffectationId(String eid) => _affectations(eid).doc().id;

  /// Responsables : créer ou modifier (le rappel est renvoyé si la date change).
  Future<void> enregistrerAffectation(
    Affectation a, {
    required bool dateChangee,
  }) => _affectations(a.equipeId).doc(a.id).set({
    ...a.versFirestore(),
    if (dateChangee) 'rappelEnvoye': false,
  }, SetOptions(merge: true));

  Future<void> supprimerAffectation(String eid, String id) =>
      _affectations(eid).doc(id).delete();

  /// La personne prévue confirme, se dit indisponible ou demande un remplaçant.
  Future<void> changerStatut(String eid, String id, StatutService statut) =>
      _affectations(eid).doc(id).update({'statut': statut.name});

  /// Un autre membre de l'équipe reprend le service.
  Future<void> reprendre(
    Affectation a, {
    required String uid,
    required String nom,
  }) => _affectations(a.equipeId).doc(a.id).update({
    'uid': uid,
    'nom': nom,
    'statut': StatutService.confirme.name,
    'remplace': a.nom,
  });
}
