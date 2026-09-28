import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import 'helpers.dart';

const grand = Size(1080, 6000);

/// [cuisine] : Marie (u1) fait partie du groupe Cuisine.
Future<Banc> banc({bool cuisine = false}) async {
  final b = Banc(connecte: true);
  await b.avecProfil();
  final db = b.firestore;
  await db.doc('parametres/eglise').set({'groupeCuisineId': 'cuisine'});
  await db.doc('groupes/cuisine').set({
    'nom': 'Cuisine',
    'type': 'cuisine',
    'prive': true,
    'membres': [if (cuisine) 'u1', 'u5'],
    'admins': ['u5'],
  });
  await db.doc('fetes/f1').set({
    'titre': 'Anniversaire de Maman Esther',
    'type': 'anniversaire',
    'date': Timestamp.fromDate(DateTime(2026, 10, 10, 15)),
    'lieu': 'Tienen',
    'description': '',
    'uid': 'u5',
    'nom': 'Esther',
  });
  await db.doc('fetes/f1/apports/u7').set({
    'nom': 'Paul',
    'apporte': ['boisson'],
    'precision': '2 bouteilles de jus',
  });
  return b;
}

Future<void> ouvrirDivers(WidgetTester tester) async {
  await tester.tap(find.text('Agenda').last);
  await tester.pumpAndSettle();
  await tester.tap(find.text('Divers'));
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  testWidgets('annoncer un anniversaire', (tester) async {
    final b = await banc();
    await lancer(tester, banc: b, taille: grand);
    await ouvrirDivers(tester);
    expect(find.text('Anniversaire de Maman Esther'), findsOneWidget);
    await tester.tap(find.text('Annoncer'));
    await tester.pumpAndSettle();
    // Par défaut : samedi prochain à 15 h.
    expect(find.text('samedi 10 octobre 2026, 15:00'), findsOneWidget);
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Titre'),
      'Anniversaire de Joseph (40 ans)',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Lieu'),
      'Salle de l\'église',
    );
    await tester.tap(find.widgetWithText(FilledButton, 'Annoncer'));
    await tester.pumpAndSettle();
    final f =
        (await b.firestore
                .collection('fetes')
                .where('uid', isEqualTo: 'u1')
                .get())
            .docs
            .single
            .data();
    expect(f['titre'], 'Anniversaire de Joseph (40 ans)');
    expect(f['type'], 'anniversaire');
    expect(f['nom'], 'Marie');
    expect(find.text('Anniversaire de Joseph (40 ans)'), findsOneWidget);
  });

  testWidgets(
    'j\'apporte un gâteau : la cuisine est informée (membre simple)',
    (tester) async {
      final b = await banc();
      await lancer(tester, banc: b, taille: grand);
      await ouvrirDivers(tester);
      await tester.tap(find.text('Anniversaire de Maman Esther'));
      await tester.pumpAndSettle();
      // Pas de la cuisine : ne voit pas ce que les autres apportent.
      expect(find.text('Pour la cuisine'), findsNothing);
      expect(find.text('Je viens'), findsNothing);
      await tester.tap(find.widgetWithText(FilterChip, 'Gâteau'));
      await tester.enterText(find.byType(TextField), 'Gâteau au chocolat');
      await tester.tap(find.text('Informer la cuisine'));
      await tester.pumpAndSettle();
      final a = await b.firestore.doc('fetes/f1/apports/u1').get();
      expect(a['apporte'], ['gateau']);
      expect(a['precision'], 'Gâteau au chocolat');
      expect(a['nom'], 'Marie');
      expect(
        find.text('C\'est noté, la cuisine est informée. Merci !'),
        findsOneWidget,
      );
    },
  );

  testWidgets('responsable cuisine : ce que chacun apporte', (tester) async {
    await lancer(tester, banc: await banc(cuisine: true), taille: grand);
    await ouvrirDivers(tester);
    await tester.tap(find.text('Anniversaire de Maman Esther'));
    await tester.pumpAndSettle();
    expect(find.text('Pour la cuisine'), findsOneWidget);
    expect(find.text('Boissons : 1'), findsOneWidget);
    expect(find.text('Paul'), findsOneWidget);
    expect(find.text('Boissons — 2 bouteilles de jus'), findsOneWidget);
  });

  testWidgets('visiteur : divers réservé aux membres', (tester) async {
    await lancer(tester, taille: grand);
    await ouvrirDivers(tester);
    expect(
      find.text(
        'Connectez-vous pour voir les anniversaires et les fêtes de l\'église.',
      ),
      findsOneWidget,
    );
  });
}
