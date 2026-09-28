import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

/// Notifications push.
///
/// Annonces et événements : « sujets » par langue, `annonces_fr` / `annonces_nl`
/// pour tous (même sans compte) et `membres_fr` / `membres_nl` pour les
/// personnes connectées. Le jeton du téléphone est aussi gardé dans le profil
/// pour les notifications personnelles (groupes, demandes…).
abstract interface class NotificationsService {
  /// Demande l'autorisation et s'abonne aux sujets de la [langue].
  Future<void> activer({required String langue, String? uid});

  /// À la déconnexion : quitte les sujets des membres et oublie le jeton.
  Future<void> desactiver(String uid);

  /// Données des notifications touchées (`type`, `id`).
  Stream<Map<String, dynamic>> get notificationsTouchees;
}

class NotificationsFirebase implements NotificationsService {
  NotificationsFirebase({required this.messaging, required this.firestore});

  final FirebaseMessaging messaging;
  final FirebaseFirestore firestore;
  StreamSubscription<String>? _renouvellement;

  static const _langues = ['fr', 'nl'];

  // Les sujets n'existent pas sur le web.
  bool get _disponible => !kIsWeb;

  @override
  Future<void> activer({required String langue, String? uid}) async {
    if (!_disponible) return;
    try {
      final autorisation = await messaging.requestPermission();
      if (autorisation.authorizationStatus == AuthorizationStatus.denied) {
        return;
      }
      for (final l in _langues) {
        if (l == langue) {
          await messaging.subscribeToTopic('annonces_$l');
          if (uid != null) await messaging.subscribeToTopic('membres_$l');
        } else {
          await messaging.unsubscribeFromTopic('annonces_$l');
          await messaging.unsubscribeFromTopic('membres_$l');
        }
      }
      if (uid == null) return;
      final jeton = await messaging.getToken();
      if (jeton != null) await _enregistrer(uid, jeton);
      await _renouvellement?.cancel();
      _renouvellement = messaging.onTokenRefresh.listen(
        (j) => _enregistrer(uid, j),
      );
    } catch (_) {
      // Sur iPhone sans configuration Apple (APNs), pas de jeton : l'app
      // fonctionne normalement, sans notifications.
    }
  }

  Future<void> _enregistrer(String uid, String jeton) =>
      firestore.collection('users').doc(uid).update({
        'jetonsNotif': FieldValue.arrayUnion([jeton]),
        'decalageMin': DateTime.now().timeZoneOffset.inMinutes,
      });

  @override
  Future<void> desactiver(String uid) async {
    if (!_disponible) return;
    await _renouvellement?.cancel();
    _renouvellement = null;
    try {
      for (final l in _langues) {
        await messaging.unsubscribeFromTopic('membres_$l');
      }
      final jeton = await messaging.getToken();
      if (jeton != null) {
        await firestore.collection('users').doc(uid).update({
          'jetonsNotif': FieldValue.arrayRemove([jeton]),
        });
      }
    } catch (_) {
      // Pas de jeton sur ce téléphone : rien à oublier.
    }
  }

  @override
  Stream<Map<String, dynamic>> get notificationsTouchees async* {
    if (!_disponible) return;
    final initiale = await messaging.getInitialMessage();
    if (initiale != null) yield initiale.data;
    yield* FirebaseMessaging.onMessageOpenedApp.map((m) => m.data);
  }
}
