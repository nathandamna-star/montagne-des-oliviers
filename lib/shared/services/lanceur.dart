import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

/// Ouverture de liens externes (Meet, Zoom, WhatsApp, sites…). Remplacé dans les tests.
abstract interface class Lanceur {
  Future<bool> ouvrir(Uri url);
}

class LanceurNatif implements Lanceur {
  const LanceurNatif();

  @override
  Future<bool> ouvrir(Uri url) =>
      launchUrl(url, mode: LaunchMode.externalApplication);
}

final lanceurProvider = Provider<Lanceur>((ref) => const LanceurNatif());
