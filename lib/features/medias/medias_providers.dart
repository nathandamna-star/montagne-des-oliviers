import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/horloge.dart';
import '../auth/auth_providers.dart';
import 'data/medias_repository.dart';
import 'diffusion_whatsapp.dart';
import 'domain/media.dart';

final mediasRepositoryProvider = Provider<MediasRepository>(
  (ref) => MediasRepository(ref.watch(firestoreProvider)),
);

final mediasProvider = StreamProvider<List<Media>>((ref) {
  final membre = ref.watch(profilProvider).value != null;
  return ref.watch(mediasRepositoryProvider).publies(membre: membre);
});

final tousMediasProvider = StreamProvider<List<Media>>(
  (ref) => ref.watch(mediasRepositoryProvider).tous(),
);

final mediaProvider = StreamProvider.family<Media?, String>(
  (ref, id) => ref.watch(mediasRepositoryProvider).media(id),
);

final versetsProvider = StreamProvider<List<Verset>>(
  (ref) => ref.watch(mediasRepositoryProvider).versets(),
);

final versetDuJourProvider = Provider<Verset?>((ref) {
  final versets = ref.watch(versetsProvider).value ?? const [];
  return versetDuJour(versets, ref.watch(horlogeProvider)());
});

final diffusionWhatsAppProvider = Provider<DiffusionWhatsApp>(
  (ref) => DiffusionParLien(ref),
);
