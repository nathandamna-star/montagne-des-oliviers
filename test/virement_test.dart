import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:montagne_des_oliviers/shared/domain/virement.dart';

void main() {
  test('communication structurée : 12 chiffres, contrôle modulo 97', () {
    final hasard = Random(1);
    for (var i = 0; i < 200; i++) {
      final c = genererCommunication(hasard);
      expect(c, hasLength(12));
      expect(communicationValide(c), isTrue, reason: c);
    }
    // 0100000000 % 97 = 81 ; 9700000000 % 97 = 0 → contrôle 97.
    expect(communicationValide('010000000081'), isTrue);
    expect(communicationValide('970000000097'), isTrue);
    expect(communicationValide('970000000000'), isFalse);
    expect(communicationValide('010000000082'), isFalse);
    expect(formaterCommunication('123456789002'), '+++123/4567/89002+++');
  });

  test('IBAN : clé de contrôle et mise en forme', () {
    expect(ibanValide('BE71 0961 2345 6769'), isTrue);
    expect(ibanValide('be71096123456769'), isTrue);
    expect(ibanValide('FR14 2004 1010 0505 0001 3M02 606'), isTrue);
    expect(ibanValide('BE72 0961 2345 6769'), isFalse);
    expect(ibanValide('BE71'), isFalse);
    expect(formaterIban('be71096123456769'), 'BE71 0961 2345 6769');
  });

  test('QR code EPC', () {
    expect(
      codeEpc(
        titulaire: 'Nathan Damna',
        iban: 'BE71 0961 2345 6769',
        bic: 'gkccbebb',
        montant: 120,
        communication: '123456789002',
      ),
      'BCD\n002\n1\nSCT\nGKCCBEBB\nNathan Damna\nBE71096123456769\n'
      'EUR120.00\n\n\n+++123/4567/89002+++',
    );
  });
}
