import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'lecteur_audio.dart';
import 'lecteur_video.dart';

/// Fabrique des lecteurs (remplacée dans les tests : pas de lecteur natif).
abstract interface class FabriqueLecteurs {
  Widget audio({required String url, required String cle});
  Widget video({required String url, required String cle});
}

class LecteursNatifs implements FabriqueLecteurs {
  const LecteursNatifs();

  @override
  Widget audio({required String url, required String cle}) =>
      LecteurAudio(url: url, cle: cle);

  @override
  Widget video({required String url, required String cle}) =>
      LecteurVideo(url: url, cle: cle);
}

final fabriqueLecteursProvider = Provider<FabriqueLecteurs>(
  (ref) => const LecteursNatifs(),
);

String formatDuree(Duration d) {
  final h = d.inHours;
  final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
  final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
  return h > 0 ? '$h:$m:$s' : '$m:$s';
}
