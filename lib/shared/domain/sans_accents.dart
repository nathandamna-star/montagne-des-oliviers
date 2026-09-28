/// Minuscules sans accents, pour chercher « Hélène » en tapant « helene ».
String sansAccents(String s) {
  const avec = 'àâäáãåçéèêëíìîïñóòôöõúùûüýÿœæ';
  const sans = 'aaaaaaceeeeiiiinooooouuuuyyoa';
  final b = StringBuffer();
  for (final c in s.toLowerCase().split('')) {
    final i = avec.indexOf(c);
    b.write(i < 0 ? c : sans[i]);
  }
  return b.toString();
}
