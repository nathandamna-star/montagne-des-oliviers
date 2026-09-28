import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../auth/auth_providers.dart';

/// Paramètres de l'église (`parametres/eglise`), lisibles par tous.
class ParametresEglise {
  const ParametresEglise({
    this.groupeIntercessionId,
    this.groupeCuisineId,
    this.facebookUrl = '',
    this.youtubeUrl = '',
  });

  /// Groupe qui reçoit les sujets de prière « partagés avec l'intercession ».
  final String? groupeIntercessionId;

  /// Groupe des responsables cuisine (informés de ce que chacun apporte).
  final String? groupeCuisineId;
  final String facebookUrl;
  final String youtubeUrl;

  factory ParametresEglise.depuis(Map<String, dynamic>? m) => ParametresEglise(
    groupeIntercessionId: m?['groupeIntercessionId'] as String?,
    groupeCuisineId: m?['groupeCuisineId'] as String?,
    facebookUrl: m?['facebookUrl'] as String? ?? '',
    youtubeUrl: m?['youtubeUrl'] as String? ?? '',
  );
}

final parametresEgliseProvider = StreamProvider<ParametresEglise>(
  (ref) => ref
      .watch(firestoreProvider)
      .doc('parametres/eglise')
      .snapshots()
      .map((d) => ParametresEglise.depuis(d.data())),
);

Future<void> enregistrerParametresEglise(
  FirebaseFirestore db, {
  required String? groupeIntercessionId,
  required String? groupeCuisineId,
  required String facebookUrl,
  required String youtubeUrl,
}) => db.doc('parametres/eglise').set({
  'groupeIntercessionId': groupeIntercessionId,
  'groupeCuisineId': groupeCuisineId,
  'facebookUrl': facebookUrl.trim(),
  'youtubeUrl': youtubeUrl.trim(),
}, SetOptions(merge: true));
