import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/roles.dart';
import '../../shared/data/envoi_fichiers.dart';
import '../auth/auth_providers.dart';
import 'data/preparations_repository.dart';
import 'domain/preparation.dart';

final preparationsRepositoryProvider = Provider<PreparationsRepository>(
  (ref) => PreparationsRepository(ref.watch(firestoreProvider)),
);

final envoiFichiersProvider = Provider<EnvoiFichiers>(
  (ref) => EnvoiFichiersFirebase(FirebaseStorage.instance),
);

/// Pasteurs : toutes les préparations ; membres : celles qui sont publiées.
final preparationsProvider = StreamProvider<List<Preparation>>((ref) {
  if (ref.watch(profilProvider).value == null) return Stream.value(const []);
  final repo = ref.watch(preparationsRepositoryProvider);
  return ref.watch(estAdminProvider) ? repo.toutes() : repo.publiees();
});

final preparationProvider = StreamProvider.family<Preparation?, String>(
  (ref, id) => ref.watch(preparationsRepositoryProvider).preparation(id),
);

/// Mon inscription à une préparation (null : pas inscrit).
final monInscritProvider = StreamProvider.family<Inscrit?, String>((ref, id) {
  final uid = ref.watch(utilisateurFirebaseProvider).value?.uid;
  if (uid == null) return Stream.value(null);
  return ref.watch(preparationsRepositoryProvider).inscrit(id, uid);
});

final inscritProvider = StreamProvider.family<Inscrit?, (String, String)>(
  (ref, ids) =>
      ref.watch(preparationsRepositoryProvider).inscrit(ids.$1, ids.$2),
);

/// Leçons visibles : toutes pour les pasteurs et les inscrits, sinon les publiques.
final leconsProvider = StreamProvider.family<List<Lecon>, String>((ref, id) {
  final pasteur = ref.watch(estAdminProvider);
  final inscrit = ref.watch(monInscritProvider(id));
  if (!pasteur && inscrit.isLoading) return const Stream.empty();
  return ref
      .watch(preparationsRepositoryProvider)
      .lecons(id, toutes: pasteur || inscrit.value != null);
});

final leconProvider = StreamProvider.family<Lecon?, (String, String)>(
  (ref, ids) => ref.watch(preparationsRepositoryProvider).lecon(ids.$1, ids.$2),
);

final inscritsProvider = StreamProvider.family<List<Inscrit>, String>(
  (ref, id) => ref.watch(preparationsRepositoryProvider).inscrits(id),
);

final questionsProvider =
    StreamProvider.family<List<QuestionCandidat>, (String, String)>(
      (ref, ids) =>
          ref.watch(preparationsRepositoryProvider).questions(ids.$1, ids.$2),
    );
