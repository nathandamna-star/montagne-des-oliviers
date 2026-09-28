import 'package:shared_preferences/shared_preferences.dart';

/// Reprise de lecture : position enregistrée par contenu et par langue.
class PositionLecture {
  PositionLecture(this.preferences);

  final SharedPreferences preferences;

  static String _cle(String id) => 'position:$id';

  Duration lire(String id) =>
      Duration(seconds: preferences.getInt(_cle(id)) ?? 0);

  Future<void> ecrire(String id, Duration position, Duration? duree) {
    // Terminé (à 5 s près) : la prochaine fois, on reprend au début.
    final fini =
        duree != null &&
        duree > Duration.zero &&
        duree - position < const Duration(seconds: 5);
    return preferences.setInt(_cle(id), fini ? 0 : position.inSeconds);
  }
}
