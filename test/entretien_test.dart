import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:montagne_des_oliviers/features/auth/domain/role.dart';

import 'helpers.dart';

const grand = Size(1080, 6000);

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  testWidgets('je m\'inscris au nettoyage puis j\'annule', (tester) async {
    final b = Banc(connecte: true);
    await b.avecProfil();
    await b.firestore.doc('nettoyages/n1').set({
      'titre': 'Nettoyage de la salle',
      'date': Timestamp.fromDate(DateTime(2026, 10, 10, 10)),
      'description': 'Balais fournis',
      'places': 4,
    });
    await b.firestore.doc('nettoyages/n1/inscrits/u7').set({'nom': 'Paul'});
    await lancer(tester, banc: b, taille: grand);
    await tester.tap(find.text('Entretien de la salle'));
    await tester.pumpAndSettle();
    expect(find.text('1 inscrit(s) sur 4 souhaité(s)'), findsOneWidget);
    expect(find.text('Paul'), findsOneWidget);
    await tester.tap(find.text('Je viens aider'));
    await tester.pumpAndSettle();
    expect(
      (await b.firestore.doc('nettoyages/n1/inscrits/u1').get())['nom'],
      'Marie',
    );
    expect(find.text('Marie, Paul'), findsOneWidget);
    await tester.tap(find.text('Inscrit — annuler'));
    await tester.pumpAndSettle();
    expect(
      (await b.firestore.doc('nettoyages/n1/inscrits/u1').get()).exists,
      isFalse,
    );
  });

  testWidgets('séance complète', (tester) async {
    final b = Banc(connecte: true);
    await b.avecProfil();
    await b.firestore.doc('nettoyages/n1').set({
      'titre': 'Nettoyage',
      'date': Timestamp.fromDate(DateTime(2026, 10, 10, 10)),
      'places': 1,
    });
    await b.firestore.doc('nettoyages/n1/inscrits/u7').set({'nom': 'Paul'});
    await lancer(tester, banc: b, taille: grand);
    await tester.tap(find.text('Entretien de la salle'));
    await tester.pumpAndSettle();
    expect(find.text('Complet'), findsOneWidget);
    expect(find.text('Je viens aider'), findsNothing);
  });

  testWidgets('secrétariat : créer une séance de nettoyage', (tester) async {
    final b = Banc(connecte: true, roles: {Role.secretariat});
    await b.avecProfil();
    await lancer(tester, banc: b, taille: grand);
    await tester.tap(find.text('Entretien de la salle'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Nouvelle séance'));
    await tester.pumpAndSettle();
    // Par défaut : samedi prochain à 10 h.
    expect(find.text('samedi 10 octobre 2026, 10:00'), findsOneWidget);
    await tester.enterText(
      find.widgetWithText(TextField, 'Nombre de personnes souhaitées'),
      '6',
    );
    await tester.tap(find.text('Créer'));
    await tester.pumpAndSettle();
    final n = (await b.firestore.collection('nettoyages').get()).docs.single
        .data();
    expect(n['titre'], 'Nettoyage de la salle');
    expect(n['places'], 6);
    expect((n['date'] as Timestamp).toDate(), DateTime(2026, 10, 10, 10));
    expect(find.text('0 inscrit(s) sur 6 souhaité(s)'), findsOneWidget);
  });
}
