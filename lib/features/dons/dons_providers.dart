import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../auth/auth_providers.dart';
import 'data/dons_repository.dart';
import 'domain/don.dart';

final donsRepositoryProvider = Provider<DonsRepository>(
  (ref) => DonsRepository(ref.watch(firestoreProvider)),
);

final mesDonsProvider = StreamProvider<List<Don>>((ref) {
  final uid = ref.watch(utilisateurFirebaseProvider).value?.uid;
  if (uid == null) return Stream.value(const []);
  return ref.watch(donsRepositoryProvider).mesDons(uid);
});

final mesDonsMensuelsProvider = StreamProvider<List<DonMensuel>>((ref) {
  final uid = ref.watch(utilisateurFirebaseProvider).value?.uid;
  if (uid == null) return Stream.value(const []);
  return ref.watch(donsRepositoryProvider).mesDonsMensuels(uid);
});

final donProvider = StreamProvider.family<Don?, String>(
  (ref, id) => ref.watch(donsRepositoryProvider).don(id),
);

final donsEnAttenteProvider = StreamProvider<List<Don>>(
  (ref) => ref.watch(donsRepositoryProvider).enAttente(),
);

final donsDeLAnneeProvider = StreamProvider.family<List<Don>, int>(
  (ref, annee) => ref.watch(donsRepositoryProvider).deLAnnee(annee),
);

final donsMensuelsActifsProvider = StreamProvider<List<DonMensuel>>(
  (ref) => ref.watch(donsRepositoryProvider).donsMensuelsActifs(),
);
