import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:montagne_des_oliviers/features/auth/domain/role.dart';

import 'helpers.dart';

const grand = Size(1080, 6000);

/// Équipe Sono : Marie (u1) et Paul (u2) membres ; [responsable] : Marie en est responsable.
Future<Banc> banc({
  bool responsable = false,
  Set<Role> roles = const {},
}) async {
  final b = Banc(connecte: true, roles: roles);
  await b.avecProfil();
  final db = b.firestore;
  for (final (u, n) in [('u1', 'Marie'), ('u2', 'Paul'), ('u3', 'Hélène')]) {
    await db.doc('annuaire/$u').set({'nom': n});
  }
  await db.doc('equipes/sono').set({
    'nom': 'Sono et vidéo',
    'membres': ['u1', 'u2'],
    'responsables': [if (responsable) 'u1' else 'u2'],
  });
  await db.doc('equipes/sono/affectations/a1').set({
    'uid': 'u1',
    'nom': 'Marie',
    'date': Timestamp.fromDate(DateTime(2026, 10, 11, 10)),
    'titre': 'Culte du dimanche',
    'role': 'Table de mixage',
    'statut': 'prevu',
  });
  await db.doc('equipes/sono/affectations/a2').set({
    'uid': 'u2',
    'nom': 'Paul',
    'date': Timestamp.fromDate(DateTime(2026, 10, 18, 10)),
    'titre': 'Culte du dimanche',
    'role': 'Caméra',
    'statut': 'remplacement',
  });
  return b;
}

Future<void> ouvrirPlanning(WidgetTester tester) async {
  await tester.tap(find.text('Planning des services').first);
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  testWidgets('mon planning : je confirme mon service', (tester) async {
    final b = await banc();
    await lancer(tester, banc: b, taille: grand);
    await ouvrirPlanning(tester);
    expect(find.text('Sono et vidéo · Table de mixage'), findsOneWidget);
    await tester.tap(find.text('Confirmer ou se désister'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Je confirme, je serai là'));
    await tester.pumpAndSettle();
    expect(
      (await b.firestore.doc('equipes/sono/affectations/a1').get())['statut'],
      'confirme',
    );
  });

  testWidgets('équipe : je remplace un membre indisponible', (tester) async {
    final b = await banc();
    await lancer(tester, banc: b, taille: grand);
    await ouvrirPlanning(tester);
    await tester.tap(find.text('Sono et vidéo'));
    await tester.pumpAndSettle();
    expect(find.text('Paul · Caméra'), findsOneWidget);
    await tester.tap(find.text('Je remplace'));
    await tester.pumpAndSettle();
    final a = await b.firestore.doc('equipes/sono/affectations/a2').get();
    expect(a['uid'], 'u1');
    expect(a['nom'], 'Marie');
    expect(a['statut'], 'confirme');
    expect(a['remplace'], 'Paul');
    // Pas responsable : ni ajout ni modification.
    expect(find.text('Ajouter au planning'), findsNothing);
  });

  testWidgets('responsable : mettre quelqu\'un au planning depuis l\'agenda', (
    tester,
  ) async {
    final b = await banc(responsable: true);
    await b.firestore.doc('evenements/e1').set({
      'titre': {'fr': 'Culte de baptême'},
      'type': 'culte',
      'debut': Timestamp.fromDate(DateTime(2026, 10, 25, 10)),
      'fin': Timestamp.fromDate(DateTime(2026, 10, 25, 12)),
      'visibilite': 'public',
      'publie': true,
      'inscription': false,
    });
    await lancer(tester, banc: b, taille: grand);
    await ouvrirPlanning(tester);
    await tester.tap(find.text('Sono et vidéo'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Ajouter au planning'));
    await tester.pumpAndSettle();
    await tester.tap(find.textContaining('Culte de baptême ·'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Enregistrer'));
    await tester.pumpAndSettle();
    expect(find.text('Choisissez la personne.'), findsOneWidget);
    await tester.tap(find.byType(DropdownButtonFormField<String?>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Paul').last);
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Poste (facultatif)'),
      'Projection des chants',
    );
    await tester.tap(find.text('Enregistrer'));
    await tester.pumpAndSettle();
    final a =
        (await b.firestore
                .collection('equipes/sono/affectations')
                .where('role', isEqualTo: 'Projection des chants')
                .get())
            .docs
            .single
            .data();
    expect(a['uid'], 'u2');
    expect(a['nom'], 'Paul');
    expect(a['titre'], 'Culte de baptême');
    expect((a['date'] as Timestamp).toDate(), DateTime(2026, 10, 25, 10));
    expect(a['statut'], 'prevu');
  });

  testWidgets('secrétariat : créer une équipe avec un responsable', (
    tester,
  ) async {
    final b = await banc(roles: {Role.secretariat});
    await lancer(tester, banc: b, taille: grand);
    await tester.tap(find.text('Responsables'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Planning des services'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Nouvelle équipe'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Nom de l\'équipe'),
      'Accueil',
    );
    await tester.tap(find.widgetWithText(CheckboxListTile, 'Hélène'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilterChip, 'Responsable'));
    await tester.tap(find.widgetWithText(CheckboxListTile, 'Paul'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Enregistrer'));
    await tester.pumpAndSettle();
    final e =
        (await b.firestore
                .collection('equipes')
                .where('nom', isEqualTo: 'Accueil')
                .get())
            .docs
            .single
            .data();
    expect(e['membres'], containsAll(['u3', 'u2']));
    expect(e['responsables'], ['u3']);
    expect(find.text('Accueil'), findsWidgets);
  });
}
