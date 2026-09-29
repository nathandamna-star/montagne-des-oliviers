import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../auth/auth_providers.dart';

enum SujetContact {
  priere,
  delivrance,
  guerison,
  accompagnement,
  question,
  autre,
}

/// Message envoyé par « Nous contacter » (`contacts/{id}`), lu par les pasteurs.
class MessageContact {
  const MessageContact({
    required this.id,
    required this.nom,
    required this.email,
    required this.telephone,
    required this.sujet,
    required this.message,
    this.traite = false,
    this.createdAt,
  });

  final String id;
  final String nom;
  final String email;
  final String telephone;
  final SujetContact sujet;
  final String message;
  final bool traite;
  final DateTime? createdAt;

  factory MessageContact.depuisFirestore(
    DocumentSnapshot<Map<String, dynamic>> d,
  ) {
    final m = d.data() ?? const {};
    return MessageContact(
      id: d.id,
      nom: m['nom'] as String? ?? '',
      email: m['email'] as String? ?? '',
      telephone: m['telephone'] as String? ?? '',
      sujet: SujetContact.values.firstWhere(
        (s) => s.name == m['sujet'],
        orElse: () => SujetContact.autre,
      ),
      message: m['message'] as String? ?? '',
      traite: m['traite'] == true,
      createdAt: (m['createdAt'] as Timestamp?)?.toDate(),
    );
  }
}

class ContactRepository {
  ContactRepository(this.firestore);

  final FirebaseFirestore firestore;

  CollectionReference<Map<String, dynamic>> get _col =>
      firestore.collection('contacts');

  Future<void> envoyer({
    required String nom,
    required String email,
    required String telephone,
    required SujetContact sujet,
    required String message,
    String? uid,
  }) => _col.add({
    'nom': nom.trim(),
    'email': email.trim(),
    'telephone': telephone.trim(),
    'sujet': sujet.name,
    'message': message.trim(),
    'consentement': true,
    'uid': ?uid,
    'traite': false,
    'createdAt': FieldValue.serverTimestamp(),
  });

  /// Pasteurs : les messages, les plus récents d'abord.
  Stream<List<MessageContact>> tous() => _col
      .orderBy('createdAt', descending: true)
      .limit(300)
      .snapshots()
      .map((s) => s.docs.map(MessageContact.depuisFirestore).toList());

  Future<void> marquerTraite(
    String id, {
    required bool traite,
    required String par,
  }) => _col.doc(id).update({
    'traite': traite,
    'traitePar': par,
    'traiteLe': FieldValue.serverTimestamp(),
  });
}

final contactRepositoryProvider = Provider<ContactRepository>(
  (ref) => ContactRepository(ref.watch(firestoreProvider)),
);

final messagesContactProvider = StreamProvider<List<MessageContact>>(
  (ref) => ref.watch(contactRepositoryProvider).tous(),
);
