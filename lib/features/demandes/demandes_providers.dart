import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../auth/auth_providers.dart';
import 'data/demandes_repository.dart';
import 'domain/demande.dart';

final demandesRepositoryProvider = Provider<DemandesRepository>(
  (ref) => DemandesRepository(ref.watch(firestoreProvider)),
);

final mesDemandesProvider = StreamProvider<List<Demande>>((ref) {
  final uid = ref.watch(utilisateurFirebaseProvider).value?.uid;
  if (uid == null) return Stream.value(const []);
  return ref.watch(demandesRepositoryProvider).mesDemandes(uid);
});

final toutesDemandesProvider = StreamProvider<List<Demande>>(
  (ref) => ref.watch(demandesRepositoryProvider).toutes(),
);

final demandeProvider = StreamProvider.family<Demande?, String>(
  (ref, id) => ref.watch(demandesRepositoryProvider).demande(id),
);
