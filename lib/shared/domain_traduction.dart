/// Textes traduits `{ fr, nl? }` : le français sert de secours.
abstract final class Traduction {
  static Map<String, String> lire(Object? v) => {
    if (v is Map)
      for (final e in v.entries)
        if (e.value is String && (e.value as String).isNotEmpty)
          e.key.toString(): e.value as String,
  };

  static String dans(Map<String, String> textes, String langue) =>
      textes[langue] ?? textes['fr'] ?? (textes.values.firstOrNull ?? '');

  /// Pour l'écriture : le néerlandais n'est gardé que s'il est rempli.
  static Map<String, String> ecrire(String fr, String nl) => {
    'fr': fr.trim(),
    if (nl.trim().isNotEmpty) 'nl': nl.trim(),
  };
}
