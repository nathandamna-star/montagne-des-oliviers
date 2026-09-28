import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/horloge.dart';
import '../auth/auth_providers.dart';
import 'data/divers_repository.dart';
import 'domain/fete.dart';

final diversRepositoryProvider = Provider<DiversRepository>(
  (ref) => DiversRepository(ref.watch(firestoreProvider)),
);

final fetesProvider = StreamProvider<List<Fete>>((ref) {
  if (ref.watch(profilProvider).value == null) return Stream.value(const []);
  final n = ref.watch(horlogeProvider)();
  return ref
      .watch(diversRepositoryProvider)
      .aVenir(DateTime(n.year, n.month, n.day));
});

final feteProvider = StreamProvider.family<Fete?, String>(
  (ref, id) => ref.watch(diversRepositoryProvider).fete(id),
);

final maContributionProvider = StreamProvider.family<Contribution?, String>((
  ref,
  id,
) {
  final uid = ref.watch(utilisateurFirebaseProvider).value?.uid;
  if (uid == null) return Stream.value(null);
  return ref.watch(diversRepositoryProvider).maContribution(id, uid);
});

final contributionsProvider = StreamProvider.family<List<Contribution>, String>(
  (ref, id) => ref.watch(diversRepositoryProvider).contributions(id),
);
