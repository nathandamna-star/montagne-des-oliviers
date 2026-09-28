import 'dart:math';

/// Communication structurée belge : 10 chiffres + 2 chiffres de contrôle
/// (reste de la division par 97 ; 97 si le reste vaut 0). Renvoie les 12
/// chiffres sans mise en forme (c'est aussi l'identifiant du paiement).
String genererCommunication([Random? hasard]) {
  final r = hasard ?? Random.secure();
  // Premier chiffre non nul : le nombre garde bien 10 chiffres.
  final base = [
    1 + r.nextInt(9),
    for (var i = 0; i < 9; i++) r.nextInt(10),
  ].join();
  return base + _controle(base);
}

String _controle(String base) {
  final reste = int.parse(base) % 97;
  return (reste == 0 ? 97 : reste).toString().padLeft(2, '0');
}

bool communicationValide(String chiffres) =>
    RegExp(r'^\d{12}$').hasMatch(chiffres) &&
    _controle(chiffres.substring(0, 10)) == chiffres.substring(10);

/// `+++123/4567/89002+++`
String formaterCommunication(String c) =>
    '+++${c.substring(0, 3)}/${c.substring(3, 7)}/${c.substring(7)}+++';

/// IBAN sans espaces, en majuscules.
String nettoyerIban(String iban) =>
    iban.replaceAll(RegExp(r'\s'), '').toUpperCase();

/// Vérifie la clé de contrôle de l'IBAN (ISO 13616, modulo 97).
bool ibanValide(String saisie) {
  final iban = nettoyerIban(saisie);
  if (!RegExp(r'^[A-Z]{2}\d{2}[A-Z0-9]{10,30}$').hasMatch(iban)) return false;
  final reorganise = iban.substring(4) + iban.substring(0, 4);
  var reste = 0;
  for (final c in reorganise.codeUnits) {
    final valeur = c >= 65 ? '${c - 55}' : String.fromCharCode(c);
    for (final chiffre in valeur.codeUnits) {
      reste = (reste * 10 + chiffre - 48) % 97;
    }
  }
  return reste == 1;
}

/// `BE71 0961 2345 6769`
String formaterIban(String iban) =>
    nettoyerIban(iban)
        .replaceAllMapped(RegExp(r'.{4}(?!$)'), (m) => '${m[0]} ');

/// Contenu du QR code de virement européen (EPC069-12, version 002),
/// lu par les applications bancaires. La communication structurée est
/// placée dans la communication libre au format `+++…+++`, que les banques
/// belges reconnaissent.
String codeEpc({
  required String titulaire,
  required String iban,
  String bic = '',
  required double montant,
  required String communication,
}) => [
  'BCD',
  '002',
  '1',
  'SCT',
  bic.trim().toUpperCase(),
  _limiter(titulaire.trim(), 70),
  nettoyerIban(iban),
  'EUR${montant.toStringAsFixed(2)}',
  '',
  '',
  formaterCommunication(communication),
].join('\n');

String _limiter(String t, int max) => t.length <= max ? t : t.substring(0, max);
