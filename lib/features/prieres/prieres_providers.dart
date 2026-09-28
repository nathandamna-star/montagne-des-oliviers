import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../auth/auth_providers.dart';
import 'data/prieres_repository.dart';
import 'domain/priere.dart';

final prieresRepositoryProvider = Provider<PrieresRepository>(
  (ref) => PrieresRepository(ref.watch(firestoreProvider)),
);

final mesPrieresProvider = StreamProvider<List<Priere>>((ref) {
  final uid = ref.watch(utilisateurFirebaseProvider).value?.uid;
  if (uid == null) return Stream.value(const []);
  return ref.watch(prieresRepositoryProvider).mesPrieres(uid);
});

final prieresGroupeProvider = StreamProvider.family<List<Priere>, String>(
  (ref, gid) => ref.watch(prieresRepositoryProvider).duGroupe(gid),
);

final toutesPrieresProvider = StreamProvider<List<Priere>>(
  (ref) => ref.watch(prieresRepositoryProvider).toutes(),
);

final priereProvider = StreamProvider.family<Priere?, String>(
  (ref, id) => ref.watch(prieresRepositoryProvider).priere(id),
);

final aiPrieProvider = StreamProvider.family<bool, String>((ref, id) {
  final uid = ref.watch(utilisateurFirebaseProvider).value?.uid;
  if (uid == null) return Stream.value(false);
  return ref.watch(prieresRepositoryProvider).aiPrie(id, uid);
});
