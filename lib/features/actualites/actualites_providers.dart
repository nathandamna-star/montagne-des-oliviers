import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../shared/data/envoi_photos.dart';
import '../auth/auth_providers.dart';
import 'data/actualites_repository.dart';
import 'domain/actualite.dart';

final actualitesRepositoryProvider = Provider<ActualitesRepository>(
  (ref) => ActualitesRepository(ref.watch(firestoreProvider)),
);

final envoiPhotosProvider = Provider<EnvoiPhotos>(
  (ref) => EnvoiPhotosFirebase(FirebaseStorage.instance),
);

/// Annonces visibles par la personne (visiteur ou membre connecté).
final actualitesProvider = StreamProvider<List<Actualite>>((ref) {
  final membre = ref.watch(profilProvider).value != null;
  return ref.watch(actualitesRepositoryProvider).publiees(membre: membre);
});

final actualiteProvider = StreamProvider.family<Actualite?, String>(
  (ref, id) => ref.watch(actualitesRepositoryProvider).une(id),
);

/// Secrétariat : toutes les annonces, brouillons compris.
final toutesActualitesProvider = StreamProvider<List<Actualite>>(
  (ref) => ref.watch(actualitesRepositoryProvider).toutes(),
);
