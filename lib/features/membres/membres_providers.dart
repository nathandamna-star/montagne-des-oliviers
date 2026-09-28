import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../auth/auth_providers.dart';
import 'data/membres_repository.dart';
import 'domain/membre.dart';

final membresRepositoryProvider = Provider<MembresRepository>(
  (ref) => MembresRepository(ref.watch(firestoreProvider)),
);

final membresProvider = StreamProvider<List<Membre>>(
  (ref) => ref.watch(membresRepositoryProvider).membres(),
);

final membreProvider = StreamProvider.family<Membre?, String>(
  (ref, id) => ref.watch(membresRepositoryProvider).membre(id),
);

final famillesProvider = StreamProvider<List<Famille>>(
  (ref) => ref.watch(membresRepositoryProvider).familles(),
);

final comptesProvider = StreamProvider<List<CompteApp>>(
  (ref) => ref.watch(membresRepositoryProvider).comptes(),
);

/// Comptes de l'app qui n'ont pas encore de fiche.
final comptesSansFicheProvider = Provider<List<CompteApp>>((ref) {
  final lies = {
    for (final m in ref.watch(membresProvider).value ?? const <Membre>[])
      if (m.uid != null) m.uid,
  };
  return [
    for (final c in ref.watch(comptesProvider).value ?? const <CompteApp>[])
      if (!lies.contains(c.uid)) c,
  ];
});
