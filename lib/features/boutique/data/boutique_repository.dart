import 'package:cloud_firestore/cloud_firestore.dart';

import '../domain/boutique.dart';

class BoutiqueRepository {
  BoutiqueRepository(this.firestore);

  final FirebaseFirestore firestore;

  CollectionReference<Map<String, dynamic>> get _livres =>
      firestore.collection('livres');
  CollectionReference<Map<String, dynamic>> get _commandes =>
      firestore.collection('commandes');

  List<Commande> _trier(QuerySnapshot<Map<String, dynamic>> s) =>
      s.docs.map(Commande.depuisFirestore).toList()..sort(Commande.parDate);

  Stream<List<Livre>> livres() => _livres.snapshots().map(
    (s) => s.docs.map(Livre.depuisFirestore).toList()..sort(Livre.parTitre),
  );

  Stream<Livre?> livre(String id) => _livres
      .doc(id)
      .snapshots()
      .map((d) => d.exists ? Livre.depuisFirestore(d) : null);

  Future<Livre?> lireLivre(String id) async {
    final d = await _livres.doc(id).get();
    return d.exists ? Livre.depuisFirestore(d) : null;
  }

  String nouveauLivreId() => _livres.doc().id;

  Future<void> enregistrerLivre(Livre l) =>
      _livres.doc(l.id).set(l.versFirestore());

  Future<void> supprimerLivre(String id) => _livres.doc(id).delete();

  Stream<List<Commande>> mesCommandes(String uid) =>
      _commandes.where('uid', isEqualTo: uid).snapshots().map(_trier);

  Stream<Commande?> commande(String id) => _commandes
      .doc(id)
      .snapshots()
      .map((d) => d.exists ? Commande.depuisFirestore(d) : null);

  /// Trésorier, secrétariat.
  Stream<List<Commande>> toutesCommandes() => _commandes
      .orderBy('createdAt', descending: true)
      .limit(300)
      .snapshots()
      .map(_trier);

  Future<void> changerStatut(
    String id,
    StatutCommande statut, {
    required String par,
  }) => _commandes.doc(id).update({
    'statut': statut.code,
    'majLe': FieldValue.serverTimestamp(),
    'majPar': par,
  });

  /// L'acheteur annule une commande par virement pas encore payée.
  Future<void> annulerMaCommande(String id) =>
      _commandes.doc(id).update({'statut': StatutCommande.annulee.code});
}
