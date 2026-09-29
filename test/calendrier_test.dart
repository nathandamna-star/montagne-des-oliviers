import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:montagne_des_oliviers/features/groupes/domain/rencontre.dart';

import 'helpers.dart';

const grand = Size(1080, 14000);

/// Marie (u1) administre « Louange » et « Modération » ; Paul (u2) est membre.
Future<Banc> banc({String uid = 'u1'}) async {
  final b = Banc(connecte: true);
  await b.avecProfil();
  final db = b.firestore;
  for (final (u, nom) in [('u1', 'Marie'), ('u2', 'Paul'), ('u3', 'Hélène')]) {
    await db.doc('annuaire/$u').set({'nom': nom});
  }
  await db.doc('groupes/louange').set({
    'nom': 'Louange',
    'type': 'louange',
    'prive': true,
    'membres': ['u1', 'u2', 'u3'],
    'admins': ['u1'],
  });
  await db.doc('groupes/mod').set({
    'nom': 'Modération',
    'type': 'moderation',
    'prive': true,
    'membres': ['u1', 'u2'],
    'admins': ['u2'],
  });
  return b;
}

Future<void> ouvrir(WidgetTester tester, String groupe) async {
  await tester.tap(find.text('Groupes').last);
  await tester.pumpAndSettle();
  await tester.tap(find.text(groupe).first);
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  testWidgets(
    'louange : répétition avec chants et qui joue quoi, puis présence',
    (tester) async {
      final b = await banc();
      await lancer(tester, banc: b, taille: grand);
      await ouvrir(tester, 'Louange');
      expect(find.text('Aucun rendez-vous prévu.'), findsOneWidget);
      await tester.tap(find.text('Tout voir'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Ajouter un rendez-vous'));
      await tester.pumpAndSettle();

      // Type proposé pour un groupe de louange, demain 19 h.
      expect(find.widgetWithText(TextFormField, 'Répétition'), findsOneWidget);
      expect(find.text('mardi 6 octobre 2026, 19:00'), findsOneWidget);
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Lieu'),
        'Salle du bas',
      );
      await tester.tap(find.text('Ajouter un chant'));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Chant 1'),
        'Tu es digne',
      );
      await tester.enterText(
        find.widgetWithText(
          TextFormField,
          'Lien audio, partition ou paroles (facultatif)',
        ),
        'https://exemple.be/tu-es-digne.pdf',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Paul'),
        'Guitare',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Hélène'),
        'Voix',
      );
      await tester.tap(find.text('Enregistrer'));
      await tester.pumpAndSettle();

      final r =
          (await b.firestore.collection('groupes/louange/rencontres').get())
              .docs
              .single
              .data();
      expect(r['type'], 'repetition');
      expect(r['titre'], 'Répétition');
      expect((r['debut'] as Timestamp).toDate(), DateTime(2026, 10, 6, 19));
      expect(r['chants'], [
        {'titre': 'Tu es digne', 'lien': 'https://exemple.be/tu-es-digne.pdf'},
      ]);
      expect(r['roles'], {'u2': 'Guitare', 'u3': 'Voix'});
      expect(r['remplacement'], 'aucun');

      // Détail : chants, qui joue quoi, ma réponse.
      await tester.tap(find.text('Répétition'));
      await tester.pumpAndSettle();
      expect(find.text('Tu es digne'), findsOneWidget);
      expect(find.text('Guitare'), findsOneWidget);
      await tester.tap(find.byTooltip('Ouvrir le lien'));
      expect(
        b.lanceur.ouverts.single.toString(),
        'https://exemple.be/tu-es-digne.pdf',
      );
      await tester.tap(find.text('Je viens'));
      await tester.pumpAndSettle();
      final rid =
          (await b.firestore.collection('groupes/louange/rencontres').get())
              .docs
              .single
              .id;
      final p = await b.firestore
          .doc('groupes/louange/rencontres/$rid/presences/u1')
          .get();
      expect(p['reponse'], 'oui');
      expect(p['nom'], 'Marie');
      expect(
        find.text('Je viens : 1 · Je ne viens pas : 0 · Peut-être : 0'),
        findsOneWidget,
      );
    },
  );

  testWidgets('modération : le modérateur demande un remplaçant', (
    tester,
  ) async {
    final b = await banc();
    await b.firestore.doc('groupes/mod/rencontres/r1').set({
      'type': 'moderation',
      'titre': 'Culte du dimanche',
      'debut': Timestamp.fromDate(DateTime(2026, 10, 11, 10)),
      'moderateur': 'u1',
      'remplacement': 'aucun',
      'deroule': derouleCulte,
    });
    await lancer(tester, banc: b, taille: grand);
    await ouvrir(tester, 'Modération');
    expect(find.text('Modéré par Marie'), findsOneWidget);
    await tester.tap(find.text('Culte du dimanche'));
    await tester.pumpAndSettle();
    expect(find.text('Prédication'), findsOneWidget);
    // Pas administratrice de ce groupe : pas de modification.
    expect(find.byTooltip('Modifier'), findsNothing);
    await tester.tap(
      find.text('Je ne suis pas disponible : demander un remplaçant'),
    );
    await tester.pumpAndSettle();
    final r = await b.firestore.doc('groupes/mod/rencontres/r1').get();
    expect(r['remplacement'], 'demande');
    expect(r['moderateur'], 'u1');
    expect(find.text('Un remplaçant est recherché.'), findsOneWidget);
    await tester.tap(find.text('Finalement, je suis disponible'));
    await tester.pumpAndSettle();
    expect(
      (await b.firestore
          .doc('groupes/mod/rencontres/r1')
          .get())['remplacement'],
      'aucun',
    );
  });

  testWidgets('modération : un autre membre reprend', (tester) async {
    final b = await banc();
    await b.firestore.doc('groupes/mod/rencontres/r1').set({
      'type': 'moderation',
      'titre': 'Culte du dimanche',
      'debut': Timestamp.fromDate(DateTime(2026, 10, 11, 10)),
      'moderateur': 'u2',
      'remplacement': 'demande',
    });
    await lancer(tester, banc: b, taille: grand);
    await ouvrir(tester, 'Modération');
    expect(find.text('Paul cherche un remplaçant'), findsOneWidget);
    await tester.tap(find.text('Culte du dimanche'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Je remplace'));
    await tester.pumpAndSettle();
    final r = await b.firestore.doc('groupes/mod/rencontres/r1').get();
    expect(r['moderateur'], 'u1');
    expect(r['remplacement'], 'aucun');
    expect(find.text('Marie'), findsWidgets);
  });

  testWidgets('administrateur : planifier une modération avec déroulé', (
    tester,
  ) async {
    final b = await banc();
    // Marie administre aussi la modération dans ce test.
    await b.firestore.doc('groupes/mod').update({
      'admins': ['u1'],
    });
    await lancer(tester, banc: b, taille: grand);
    await ouvrir(tester, 'Modération');
    await tester.tap(find.text('Tout voir'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Ajouter un rendez-vous'));
    await tester.pumpAndSettle();
    expect(
      find.widgetWithText(TextFormField, 'Culte du dimanche'),
      findsOneWidget,
    );
    expect(find.text('dimanche 11 octobre 2026, 10:00'), findsOneWidget);
    await tester.tap(find.byType(DropdownButtonFormField<String?>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Paul').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Enregistrer'));
    await tester.pumpAndSettle();
    final r = (await b.firestore.collection('groupes/mod/rencontres').get())
        .docs
        .single
        .data();
    expect(r['type'], 'moderation');
    expect(r['moderateur'], 'u2');
    expect(r['deroule'], derouleCulte);
    expect(r['chants'], isEmpty);
    expect(find.text('Modéré par Paul'), findsOneWidget);
  });

  testWidgets('notification de rendez-vous touchée : ouvre le rendez-vous', (
    tester,
  ) async {
    final b = await banc();
    await b.firestore.doc('groupes/louange/rencontres/r9').set({
      'type': 'reunion',
      'titre': 'Soirée de partage',
      'debut': Timestamp.fromDate(DateTime(2026, 10, 8, 19)),
    });
    await lancer(tester, banc: b, taille: grand);
    b.notifications.touchees.add({
      'type': 'rencontre',
      'id': 'louange',
      'rid': 'r9',
    });
    await tester.pumpAndSettle();
    expect(find.text('Soirée de partage'), findsOneWidget);
    expect(find.text('Ma réponse'), findsOneWidget);
  });
}
