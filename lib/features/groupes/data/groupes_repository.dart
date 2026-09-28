import 'package:cloud_firestore/cloud_firestore.dart';

import '../domain/groupe.dart';
import '../domain/rencontre.dart';

class GroupesRepository {
  GroupesRepository(this.firestore);

  final FirebaseFirestore firestore;

  CollectionReference<Map<String, dynamic>> get _col =>
      firestore.collection('groupes');

  Stream<List<Groupe>> _liste(Query<Map<String, dynamic>> q) =>
      q.snapshots().map(
        (s) => s.docs.map(Groupe.depuisFirestore).toList()..sort(Groupe.parNom),
      );

  /// Les groupes dont la personne est membre.
  Stream<List<Groupe>> mesGroupes(String uid) =>
      _liste(_col.where('membres', arrayContains: uid));

  /// Groupes ouverts (visibles par tous les membres de l'église).
  Stream<List<Groupe>> ouverts() =>
      _liste(_col.where('prive', isEqualTo: false));

  /// Tous les groupes (secrétariat).
  Stream<List<Groupe>> tous() => _liste(_col);

  Stream<Groupe?> groupe(String id) => _col
      .doc(id)
      .snapshots()
      .map((d) => d.exists ? Groupe.depuisFirestore(d) : null);

  Future<Groupe?> lire(String id) async {
    final d = await _col.doc(id).get();
    return d.exists ? Groupe.depuisFirestore(d) : null;
  }

  String nouvelId() => _col.doc().id;

  /// Création (secrétariat) : les administrateurs sont aussi membres.
  Future<void> creer({
    required String id,
    required String nom,
    required TypeGroupe type,
    required String description,
    required bool prive,
    required List<String> admins,
    required String lienAppel,
  }) => _col.doc(id).set({
    'nom': nom.trim(),
    'type': type.name,
    'description': description.trim(),
    'prive': prive,
    'membres': admins,
    'admins': admins,
    'lienAppel': lienAppel.trim(),
    'createdAt': FieldValue.serverTimestamp(),
  });

  /// Modification par un administrateur du groupe ou le secrétariat.
  Future<void> modifier(
    String id, {
    required String nom,
    required String description,
    required String lienAppel,
    TypeGroupe? type,
    bool? prive,
  }) => _col.doc(id).update({
    'nom': nom.trim(),
    'description': description.trim(),
    'lienAppel': lienAppel.trim(),
    'type': ?type?.name,
    'prive': ?prive,
    'updatedAt': FieldValue.serverTimestamp(),
  });

  Future<void> ajouterMembres(String id, List<String> uids) =>
      _col.doc(id).update({'membres': FieldValue.arrayUnion(uids)});

  /// Retire un membre (et son rôle d'administrateur du groupe).
  Future<void> retirerMembre(String id, String uid) => _col.doc(id).update({
    'membres': FieldValue.arrayRemove([uid]),
    'admins': FieldValue.arrayRemove([uid]),
  });

  Future<void> definirAdmin(String id, String uid, {required bool admin}) =>
      _col.doc(id).update({
        'admins': admin
            ? FieldValue.arrayUnion([uid])
            : FieldValue.arrayRemove([uid]),
      });

  /// Quitter le groupe soi-même (membre non administrateur).
  Future<void> quitter(String id, String uid) => _col.doc(id).update({
    'membres': FieldValue.arrayRemove([uid]),
  });

  Future<void> supprimer(String id) => _col.doc(id).delete();

  // ----- Discussion -----

  CollectionReference<Map<String, dynamic>> _messages(String id) =>
      _col.doc(id).collection('messages');

  Stream<List<MessageGroupe>> messages(String id) =>
      _messages(id)
          .orderBy('createdAt', descending: true)
          .limit(300)
          .snapshots()
          .map((s) => s.docs.map(MessageGroupe.depuisFirestore).toList());

  Future<void> envoyer(
    String id, {
    required String uid,
    required String nom,
    String texte = '',
    String? fichierUrl,
  }) => _messages(id).add({
    'auteur': uid,
    'nom': nom,
    'texte': texte.trim(),
    'fichierUrl': ?fichierUrl,
    'createdAt': FieldValue.serverTimestamp(),
  });

  Future<void> effacerMessage(String id, String messageId) =>
      _messages(id).doc(messageId).delete();

  // ----- Calendrier du groupe -----

  CollectionReference<Map<String, dynamic>> _rencontres(String id) =>
      _col.doc(id).collection('rencontres');

  /// Rendez-vous à venir (depuis [depuis]).
  Stream<List<Rencontre>> rencontres(String id, {required DateTime depuis}) =>
      _rencontres(id)
          .where('debut', isGreaterThanOrEqualTo: Timestamp.fromDate(depuis))
          .orderBy('debut')
          .limit(100)
          .snapshots()
          .map(
            (s) => [for (final d in s.docs) Rencontre.depuisFirestore(id, d)],
          );

  Stream<Rencontre?> rencontre(String id, String rid) =>
      _rencontres(id)
          .doc(rid)
          .snapshots()
          .map((d) => d.exists ? Rencontre.depuisFirestore(id, d) : null);

  Future<Rencontre?> lireRencontre(String id, String rid) async {
    final d = await _rencontres(id).doc(rid).get();
    return d.exists ? Rencontre.depuisFirestore(id, d) : null;
  }

  String nouvelleRencontreId(String id) => _rencontres(id).doc().id;

  /// Enregistre (fusion : le rappel déjà envoyé par le serveur est conservé,
  /// sauf si la date change).
  Future<void> enregistrerRencontre(Rencontre r, {required bool dateChangee}) =>
      _rencontres(r.groupeId).doc(r.id).set({
        ...r.versFirestore(),
        if (dateChangee) 'rappelEnvoye': false,
      }, SetOptions(merge: true));

  Future<void> supprimerRencontre(String id, String rid) =>
      _rencontres(id).doc(rid).delete();

  /// Modérateur prévu : demander (ou annuler) un remplacement.
  Future<void> demanderRemplacement(
    String id,
    String rid,
    String uid, {
    required bool demande,
  }) => _rencontres(id).doc(rid).update({
    'moderateur': uid,
    'remplacement': demande ? 'demande' : 'aucun',
  });

  /// Un autre membre reprend la modération.
  Future<void> remplacer(String id, String rid, String uid) =>
      _rencontres(id)
          .doc(rid)
          .update({'moderateur': uid, 'remplacement': 'aucun'});

  Stream<Map<String, Reponse>> presences(String id, String rid) =>
      _rencontres(id)
          .doc(rid)
          .collection('presences')
          .snapshots()
          .map(
            (s) => {
              for (final d in s.docs)
                d.id: Reponse.values.firstWhere(
                  (r) => r.name == d.data()['reponse'],
                  orElse: () => Reponse.peutetre,
                ),
            },
          );

  Future<void> repondre(
    String id,
    String rid, {
    required String uid,
    required String nom,
    required Reponse reponse,
  }) => _rencontres(id).doc(rid).collection('presences').doc(uid).set({
    'reponse': reponse.name,
    'nom': nom,
    'updatedAt': FieldValue.serverTimestamp(),
  });

  // ----- Annuaire (nom des comptes, lisible par les membres de l'église) -----

  Stream<Map<String, String>> annuaire() => firestore
      .collection('annuaire')
      .snapshots()
      .map(
        (s) => {for (final d in s.docs) d.id: d.data()['nom'] as String? ?? ''},
      );
}
