import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'preferences.dart';

/// Langue de l'app choisie dans le profil ('fr' ou 'nl') ; null : celle du
/// téléphone. Gardée sur le téléphone.
class LangueApp extends Notifier<String?> {
  static const _cle = 'langue';

  @override
  String? build() => ref.watch(sharedPreferencesProvider).getString(_cle);

  Future<void> choisir(String? langue) async {
    final prefs = ref.read(sharedPreferencesProvider);
    if (langue == null) {
      await prefs.remove(_cle);
    } else {
      await prefs.setString(_cle, langue);
    }
    state = langue;
  }
}

final langueAppProvider = NotifierProvider<LangueApp, String?>(LangueApp.new);
