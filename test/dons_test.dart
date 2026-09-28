import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:montagne_des_oliviers/features/auth/domain/role.dart';
import 'package:montagne_des_oliviers/features/dons/domain/don.dart';

import 'helpers.dart';

const grand = Size(1080, 6000);

Map<String, dynamic> don(
  String uid,
  String nom,
  double montant, {
  String affectation = 'dime',
  String mode = 'virement',
  String statut = 'recu',
  DateTime? le,
}) => {
  'uid': uid,
  'nom': nom,
  'montant': montant,
  'devise': 'EUR',
  'affectation': affectation,
  'mode': mode,
  'statut': statut,
  'createdAt': Timestamp.fromDate(le ?? DateTime(2026, 9, 6)),
};

Future<Banc> banc({
  Set<Role> roles = const {},
  bool iban = true,
  bool iPhone = false,
}) async {
  final b = Banc(connecte: true, roles: roles, iPhone: iPhone);
  await b.avecProfil();
  if (iban) {
    await b.firestore.doc('parametres/eglise').set({
      'titulaire': 'ASBL Montagne des Oliviers',
      'iban': 'BE71096123456769',
      'bic': 'GKCCBEBB',
    });
  }
  return b;
}

Future<void> ouvrirDons(WidgetTester tester) async {
  await tester.tap(find.text('Donner'));
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  test('totaux par affectation, par donateur, tableur', () {
    final dons = [
      Don(
        id: '100000000034',
        uid: 'u1',
        nom: 'Marie',
        montant: 50,
        affectation: Affectation.dime,
        statut: StatutDon.recu,
        createdAt: DateTime(2026, 1, 4),
      ),
      Don(
        id: 'cs_1',
        uid: 'u2',
        nom: 'Paul',
        montant: 20,
        affectation: Affectation.mission,
        mode: ModeDon.enLigne,
        statut: StatutDon.recu,
        createdAt: DateTime(2026, 3, 1),
      ),
      Don(
        id: 'in_1',
        uid: 'u1',
        nom: 'Marie',
        montant: 10,
        affectation: Affectation.dime,
        mode: ModeDon.mensuel,
        statut: StatutDon.recu,
        createdAt: DateTime(2026, 2, 1),
      ),
      Don(
        id: '200000000068',
        uid: 'u1',
        nom: 'Marie',
        montant: 99,
        affectation: Affectation.dime,
        createdAt: DateTime(2026, 2, 1),
      ),
      Don(
        id: 'in_0',
        uid: 'u1',
        nom: 'Marie',
        montant: 10,
        affectation: Affectation.dime,
        statut: StatutDon.recu,
        createdAt: DateTime(2025, 12, 1),
      ),
    ];
    final recus = recusEn(dons, 2026);
    expect(recus.map((d) => d.id), ['100000000034', 'in_1', 'cs_1']);
    expect(totalDons(recus), 80);
    expect(totauxParAffectation(recus), {
      Affectation.dime: 60,
      Affectation.mission: 20,
    });
    expect(totauxParDonateur(recus).first, ('u1', 'Marie', 60.0));
    final csv = exporterDonsCsv(
      recus,
      entetes: [
        'Date',
        'Nom',
        'Affectation',
        'Mode',
        'Montant',
        'Communication',
      ],
      libelleAffectation: (a) => a.name,
      libelleMode: (m) => m.code,
    );
    expect(
      csv.split('\r\n')[1],
      '2026-01-04;Marie;dime;virement;50,00;100000000034',
    );
    expect(csv.split('\r\n')[3], '2026-03-01;Paul;mission;en_ligne;20,00;');
  });

  testWidgets('don par virement : QR code, communication, renoncement', (
    tester,
  ) async {
    final b = await banc();
    await lancer(tester, banc: b, taille: grand);
    await ouvrirDons(tester);
    await tester.tap(find.widgetWithText(ChoiceChip, eur('50 €')));
    await tester.tap(find.widgetWithText(ChoiceChip, 'Mission'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Virement (QR code)'));
    await tester.pumpAndSettle();
    final d = (await b.firestore.collection('dons').get()).docs.single;
    expect(d.id, matches(RegExp(r'^[1-9]\d{11}$')));
    expect(d['montant'], 50);
    expect(d['affectation'], 'mission');
    expect(d['statut'], 'en_attente');
    expect(find.text('BE71 0961 2345 6769'), findsOneWidget);
    expect(
      find.text(
        '+++${d.id.substring(0, 3)}/${d.id.substring(3, 7)}/${d.id.substring(7)}+++',
      ),
      findsOneWidget,
    );
    await tester.tap(find.text('Je renonce à ce don'));
    await tester.pumpAndSettle();
    expect((await b.firestore.doc('dons/${d.id}').get())['statut'], 'annule');
  });

  testWidgets('en ligne : autre montant, don mensuel, arrêt', (tester) async {
    final b = await banc();
    await b.firestore.doc('donsMensuels/sub_1').set({
      'uid': 'u1',
      'nom': 'Marie',
      'montant': 25,
      'affectation': 'dime',
      'actif': true,
    });
    await lancer(tester, banc: b, taille: grand);
    await ouvrirDons(tester);
    await tester.tap(find.widgetWithText(ChoiceChip, 'Autre montant'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextField, 'Montant en euros'),
      '0,5',
    );
    await tester.tap(find.text('Bancontact ou carte'));
    await tester.pumpAndSettle();
    expect(
      find.text('Indiquez un montant entre 1 et 10 000 €.'),
      findsOneWidget,
    );
    await tester.enterText(
      find.widgetWithText(TextField, 'Montant en euros'),
      '12,50',
    );
    await tester.tap(find.text('Bancontact ou carte'));
    await tester.pumpAndSettle();
    expect(b.paiements.appels, ['don 12.5 dime']);
    expect(b.lanceur.ouverts.single.toString(), 'https://stripe.test/don');

    await tester.tap(find.text('Chaque mois'));
    await tester.pumpAndSettle();
    expect(find.text('Virement (QR code)'), findsNothing);
    await tester.tap(find.text('Donner chaque mois par carte'));
    await tester.pumpAndSettle();
    expect(b.paiements.appels.last, 'don 12.5 dime mensuel');

    expect(find.text(eur('25 € par mois')), findsOneWidget);
    await tester.tap(find.text('Arrêter'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Arrêter'));
    await tester.pumpAndSettle();
    expect(b.paiements.appels.last, 'arreter sub_1');
    expect(find.text(eur('25 € par mois')), findsNothing);
  });

  testWidgets('iPhone : les dons se font sur le site ; relevé annuel', (
    tester,
  ) async {
    final b = await banc(iPhone: true);
    await b.firestore
        .doc('dons/cs_1')
        .set(
          don('u1', 'Marie', 30, mode: 'en_ligne', le: DateTime(2026, 3, 1)),
        );
    await b.firestore
        .doc('dons/in_1')
        .set(don('u1', 'Marie', 20, affectation: 'mission', mode: 'mensuel'));
    await b.firestore
        .doc('dons/100000000034')
        .set(don('u1', 'Marie', 99, statut: 'en_attente'));
    await b.firestore
        .doc('dons/in_0')
        .set(don('u1', 'Marie', 7, le: DateTime(2025, 6, 1)));
    await lancer(tester, banc: b, taille: grand);
    await ouvrirDons(tester);
    expect(find.text('Bancontact ou carte'), findsNothing);
    await tester.tap(find.text('Donner sur le site de l\'église'));
    expect(
      b.lanceur.ouverts.single.toString(),
      'https://montagne-des-oliviers.web.app/#/accueil/dons',
    );

    await tester.tap(find.byTooltip('Relevé annuel'));
    await tester.pumpAndSettle();
    expect(find.text(eur('50 €')), findsOneWidget);
    await tester.tap(find.byTooltip('Partager'));
    await tester.pumpAndSettle();
    final (nom, contenu) = b.partage.fichiers.single;
    expect(nom, 'releve-dons-2026.txt');
    expect(contenu, contains(eur('Total : 50 €')));
    expect(contenu, contains('pas une attestation fiscale'));
    await tester.tap(find.byTooltip('Année précédente'));
    await tester.pumpAndSettle();
    expect(find.text(eur('7 €')), findsWidgets);
  });

  testWidgets(
    'trésorier : compte bancaire, virement reçu, dons de l\'année, export',
    (tester) async {
      final b = await banc(roles: {Role.tresorier}, iban: false);
      await b.firestore
          .doc('dons/100000000034')
          .set(don('u2', 'Paul', 40, statut: 'en_attente'));
      await b.firestore
          .doc('dons/200000000068')
          .set(don('u3', 'Jean', 15, statut: 'en_attente'));
      await b.firestore
          .doc('dons/cs_1')
          .set(
            don(
              'u3',
              'Jean',
              60,
              mode: 'en_ligne',
              affectation: 'construction',
            ),
          );
      await lancer(tester, banc: b, taille: grand);
      await tester.tap(find.text('Responsables'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Trésorerie'));
      await tester.pumpAndSettle();

      // Compte bancaire : IBAN vérifié.
      await tester.tap(find.text('Compléter'));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Titulaire du compte'),
        'ASBL Montagne des Oliviers',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'IBAN'),
        'BE71 0961 2345 6760',
      );
      await tester.tap(find.text('Enregistrer'));
      await tester.pumpAndSettle();
      expect(find.text('IBAN invalide.'), findsOneWidget);
      await tester.enterText(
        find.widgetWithText(TextFormField, 'IBAN'),
        'be71 0961 2345 6769',
      );
      await tester.tap(find.text('Enregistrer'));
      await tester.pumpAndSettle();
      expect(
        (await b.firestore.doc('parametres/eglise').get())['iban'],
        'BE71096123456769',
      );

      // Retrouver le virement par sa communication, puis le marquer reçu.
      await tester.enterText(
        find.widgetWithText(TextField, 'Communication ou nom'),
        '+++100/0000/00034+++',
      );
      await tester.pumpAndSettle();
      expect(find.textContaining('Jean'), findsNothing);
      await tester.tap(find.widgetWithText(FilledButton, 'Reçu'));
      await tester.pumpAndSettle();
      final d = await b.firestore.doc('dons/100000000034').get();
      expect(d['statut'], 'recu');
      expect(d['confirmePar'], 'u1');

      await tester.tap(find.text('Dons de l\'année'));
      await tester.pumpAndSettle();
      expect(find.text(eur('100 €')), findsOneWidget);
      expect(find.text('2 dons'), findsOneWidget);
      await tester.tap(find.text('Exporter (tableur CSV)'));
      await tester.pumpAndSettle();
      final (nom, csv) = b.partage.fichiers.single;
      expect(nom, 'dons-2026.csv');
      expect(csv, contains('Paul;Dîme;virement;40,00;100000000034'));
    },
  );
}
