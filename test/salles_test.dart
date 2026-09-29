import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:montagne_des_oliviers/features/auth/domain/role.dart';
import 'package:montagne_des_oliviers/features/salles/salles.dart';

import 'helpers.dart';

const grand = Size(1080, 14000);

Timestamp le6(int h) => Timestamp.fromDate(DateTime(2026, 10, 6, h));

Future<Banc> banc({Set<Role> roles = const {}}) async {
  final b = Banc(connecte: true, roles: roles);
  await b.avecProfil();
  final db = b.firestore;
  await db.doc('salles/s1').set({'nom': 'Grande salle', 'capacite': 120});
  // Demain (6 octobre) 15 h – 17 h : déjà pris.
  await db.doc('reservations/r1').set({
    'uid': 'u7',
    'nom': 'Paul',
    'salleId': 's1',
    'salleNom': 'Grande salle',
    'debut': le6(15),
    'fin': le6(17),
    'motif': 'Répétition chorale',
    'statut': 'validee',
  });
  return b;
}

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  test('chevauchement des créneaux', () {
    DateTime d(int h) => DateTime(2026, 10, 6, h);
    expect(chevauchement(d(10), d(12), d(11), d(13)), isTrue);
    expect(chevauchement(d(10), d(12), d(12), d(14)), isFalse);
  });

  testWidgets('créneau déjà pris : demande bloquée', (tester) async {
    await lancer(tester, banc: await banc(), taille: grand);
    await tester.tap(find.text('Réserver une salle'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Grande salle'));
    await tester.pumpAndSettle();
    expect(find.text('Répétition chorale'), findsOneWidget);
    // Par défaut : demain 14 h – 16 h, qui chevauche 15 h – 17 h.
    expect(find.text('Déjà réservé : Répétition chorale'), findsOneWidget);
    final bouton = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'Envoyer la demande'),
    );
    expect(bouton.onPressed, isNull);
  });

  testWidgets('demande sur un créneau libre, puis annulation', (tester) async {
    final b = await banc();
    await b.firestore.doc('reservations/r1').update({
      'debut': le6(18),
      'fin': le6(20),
    });
    await lancer(tester, banc: b, taille: grand);
    await tester.tap(find.text('Réserver une salle'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Grande salle'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Envoyer la demande'));
    await tester.pumpAndSettle();
    expect(find.text('Indiquez pour quoi vous réservez.'), findsOneWidget);
    await tester.enterText(
      find.widgetWithText(TextField, 'Pour quoi ?'),
      'Réunion des jeunes',
    );
    await tester.tap(find.text('Envoyer la demande'));
    await tester.pumpAndSettle();
    final r =
        (await b.firestore
                .collection('reservations')
                .where('uid', isEqualTo: 'u1')
                .get())
            .docs
            .single;
    expect(r['motif'], 'Réunion des jeunes');
    expect(r['statut'], 'demandee');
    expect(r['salleNom'], 'Grande salle');
    expect((r['debut'] as Timestamp).toDate(), DateTime(2026, 10, 6, 14));
    expect((r['fin'] as Timestamp).toDate(), DateTime(2026, 10, 6, 16));

    await tester.tap(find.byTooltip('Retour'));
    await tester.pumpAndSettle();
    expect(find.textContaining('En attente de validation'), findsOneWidget);
    await tester.tap(find.byTooltip('Annuler la réservation'));
    await tester.pumpAndSettle();
    expect(
      (await b.firestore.doc('reservations/${r.id}').get())['statut'],
      'annulee',
    );
  });

  testWidgets(
    'secrétariat : conflit signalé, validation d\'une demande libre',
    (tester) async {
      final b = await banc(roles: {Role.secretariat});
      await b.firestore.doc('reservations/r2').set({
        'uid': 'u8',
        'nom': 'Anne',
        'salleId': 's1',
        'salleNom': 'Grande salle',
        'debut': le6(16),
        'fin': le6(18),
        'motif': 'Anniversaire',
        'statut': 'demandee',
      });
      await b.firestore.doc('reservations/r3').set({
        'uid': 'u9',
        'nom': 'Luc',
        'salleId': 's1',
        'salleNom': 'Grande salle',
        'debut': le6(9),
        'fin': le6(11),
        'motif': 'Prière',
        'statut': 'demandee',
      });
      await lancer(tester, banc: b, taille: grand);
      await tester.tap(find.text('Réserver une salle'));
      await tester.pumpAndSettle();
      expect(find.text('2'), findsOneWidget);
      await tester.tap(find.text('Réservations à valider'));
      await tester.pumpAndSettle();
      expect(
        find.text('Conflit avec : Répétition chorale (Paul)'),
        findsOneWidget,
      );
      await tester.tap(find.widgetWithText(FilledButton, 'Valider').first);
      await tester.pumpAndSettle();
      expect(
        (await b.firestore.doc('reservations/r3').get())['statut'],
        'validee',
      );
      await tester.tap(find.widgetWithText(TextButton, 'Refuser'));
      await tester.pumpAndSettle();
      expect(
        (await b.firestore.doc('reservations/r2').get())['statut'],
        'refusee',
      );
    },
  );

  testWidgets('secrétariat : ajouter une salle', (tester) async {
    final b = await banc(roles: {Role.secretariat});
    await lancer(tester, banc: b, taille: grand);
    await tester.tap(find.text('Réserver une salle'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Nouvelle salle'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextField, 'Nom de la salle'),
      'Petite salle',
    );
    await tester.enterText(
      find.widgetWithText(TextField, 'Capacité (personnes)'),
      '25',
    );
    await tester.tap(find.text('Enregistrer'));
    await tester.pumpAndSettle();
    final s =
        (await b.firestore
                .collection('salles')
                .where('nom', isEqualTo: 'Petite salle')
                .get())
            .docs
            .single;
    expect(s['capacite'], 25);
    expect(find.text('25 personnes'), findsOneWidget);
  });
}
