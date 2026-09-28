import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/horloge.dart';
import '../auth/auth_providers.dart';
import 'data/agenda_repository.dart';
import 'domain/evenement.dart';

final agendaRepositoryProvider = Provider<AgendaRepository>(
  (ref) => AgendaRepository(ref.watch(firestoreProvider)),
);

DateTime _aujourdhui(Ref ref) {
  final n = ref.watch(horlogeProvider)();
  return DateTime(n.year, n.month, n.day);
}

/// Événements à venir visibles par la personne.
final evenementsProvider = StreamProvider<List<Evenement>>((ref) {
  final membre = ref.watch(profilProvider).value != null;
  return ref
      .watch(agendaRepositoryProvider)
      .aVenir(membre: membre, depuis: _aujourdhui(ref));
});

/// Secrétariat : tous les événements à venir, brouillons compris.
final tousEvenementsProvider = StreamProvider<List<Evenement>>(
  (ref) => ref.watch(agendaRepositoryProvider).tous(depuis: _aujourdhui(ref)),
);

final evenementProvider = StreamProvider.family<Evenement?, String>(
  (ref, id) => ref.watch(agendaRepositoryProvider).un(id),
);

final monInscriptionProvider = StreamProvider.family<Inscription?, String>((
  ref,
  id,
) {
  final uid = ref.watch(utilisateurFirebaseProvider).value?.uid;
  if (uid == null) return Stream.value(null);
  return ref.watch(agendaRepositoryProvider).monInscription(id, uid);
});

final inscriptionsProvider = StreamProvider.family<List<Inscription>, String>(
  (ref, id) => ref.watch(agendaRepositoryProvider).inscriptions(id),
);
