import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/horloge.dart';
import '../auth/auth_providers.dart';
import 'data/planning_repository.dart';
import 'domain/planning.dart';

final planningRepositoryProvider = Provider<PlanningRepository>(
  (ref) => PlanningRepository(ref.watch(firestoreProvider)),
);

DateTime _aujourdhui(Ref ref) {
  final n = ref.watch(horlogeProvider)();
  return DateTime(n.year, n.month, n.day);
}

final equipesProvider = StreamProvider<List<Equipe>>((ref) {
  if (ref.watch(profilProvider).value == null) return Stream.value(const []);
  return ref.watch(planningRepositoryProvider).equipes();
});

final equipeProvider = StreamProvider.family<Equipe?, String>(
  (ref, id) => ref.watch(planningRepositoryProvider).equipe(id),
);

final affectationsProvider = StreamProvider.family<List<Affectation>, String>(
  (ref, eid) => ref
      .watch(planningRepositoryProvider)
      .affectations(eid, depuis: _aujourdhui(ref)),
);

final mesAffectationsProvider = StreamProvider<List<Affectation>>((ref) {
  final uid = ref.watch(utilisateurFirebaseProvider).value?.uid;
  if (uid == null) return Stream.value(const []);
  return ref
      .watch(planningRepositoryProvider)
      .mesAffectations(uid, depuis: _aujourdhui(ref));
});
