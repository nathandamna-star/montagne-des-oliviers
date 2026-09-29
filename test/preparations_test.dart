import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:montagne_des_oliviers/features/auth/domain/role.dart';

import 'helpers.dart';

const grand = Size(1080, 14000);

/// Préparation au baptême avec 2 leçons (la 2e est publique). [inscrit] :
/// Marie (u1) est candidate.
Future<Banc> banc({bool inscrit = false, Set<Role> roles = const {}}) async {
  final b = Banc(connecte: true, roles: roles);
  await b.avecProfil();
  final db = b.firestore;
  await db.doc('annuaire/u1').set({'nom': 'Marie'});
  await db.doc('annuaire/u2').set({'nom': 'Paul'});
  await db.doc('preparations/bap').set({
    'type': 'bapteme',
    'titre': {'fr': 'Préparation au baptême'},
    'publie': true,
    'description': {'fr': 'Quatre leçons avant le baptême.'},
  });
  await db.doc('preparations/bap/lecons/l1').set({
    'titre': {'fr': 'La repentance'},
    'texte': {'fr': 'Se détourner du péché…'},
    'ordre': 1,
    'publique': false,
    'audioUrl': 'https://exemple.be/repentance.m4a',
    'videoUrl': null,
    'documentUrl': 'https://exemple.be/repentance.pdf',
  });
  await db.doc('preparations/bap/lecons/l2').set({
    'titre': {'fr': 'Pourquoi le baptême ?'},
    'ordre': 2,
    'publique': true,
    'videoUrl': 'https://exemple.be/pourquoi.mp4',
  });
  if (inscrit) {
    await db.doc('preparations/bap/inscrits/u1').set({
      'nom': 'Marie',
      'faites': <String>[],
      'rencontres': [
        {
          'titre': 'Baptême',
          'date': Timestamp.fromDate(DateTime(2026, 11, 15, 11)),
        },
      ],
    });
  }
  return b;
}

Future<void> ouvrir(WidgetTester tester) async {
  await tester.tap(find.text('Préparations'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Préparation au baptême'));
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  testWidgets(
    'non inscrit : leçons publiques seulement, invitation à faire une demande',
    (tester) async {
      final b = await banc();
      await lancer(tester, banc: b, taille: grand);
      await ouvrir(tester);
      expect(find.text('Pourquoi le baptême ?'), findsOneWidget);
      expect(find.text('La repentance'), findsNothing);
      await tester.tap(find.text('Faire une demande'));
      await tester.pumpAndSettle();
      // Demande de baptême déjà choisie.
      await tester.tap(find.text('Envoyer la demande'));
      await tester.pumpAndSettle();
      final d = (await b.firestore.collection('demandes').get()).docs.single;
      expect(d['type'], 'bapteme');
    },
  );

  testWidgets(
    'pasteur : leçon avec vidéo envoyée, ordre, candidat et réponse',
    (tester) async {
      final b = await banc(inscrit: true, roles: {Role.admin});
      await b.firestore.doc('preparations/bap/inscrits/u1/questions/q1').set({
        'texte': 'Faut-il être membre ?',
        'leconId': 'l1',
        'createdAt': Timestamp.fromDate(DateTime(2026, 10, 1)),
      });
      await lancer(tester, banc: b, taille: grand);
      await ouvrir(tester);
      await tester.tap(find.text('Ajouter une leçon'));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Titre (FR)'),
        'La sanctification',
      );
      await tester.tap(find.text('Choisir un fichier').at(1));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Enregistrer'));
      await tester.pumpAndSettle();
      final l =
          (await b.firestore
                  .collection('preparations/bap/lecons')
                  .where('ordre', isEqualTo: 3)
                  .get())
              .docs
              .single
              .data();
      expect(l['titre'], {'fr': 'La sanctification'});
      expect(l['publique'], isFalse);
      expect(l['videoUrl'], startsWith('https://exemple.be/preparations/bap/'));
      expect(l['audioUrl'], isNull);

      // Monter la 2e leçon.
      await tester.tap(find.byTooltip('Monter').at(1));
      await tester.pumpAndSettle();
      expect(
        (await b.firestore.doc('preparations/bap/lecons/l2').get())['ordre'],
        1,
      );

      // Candidat : répondre et planifier.
      await tester.tap(find.text('Marie'));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.widgetWithText(TextField, 'Votre réponse'),
        'Non, mais c\'est conseillé.',
      );
      await tester.tap(find.text('Répondre'));
      await tester.pumpAndSettle();
      expect(
        (await b.firestore
            .doc('preparations/bap/inscrits/u1/questions/q1')
            .get())['reponse'],
        'Non, mais c\'est conseillé.',
      );
    },
  );

  testWidgets('pasteur : inscrire un candidat depuis sa demande de baptême', (
    tester,
  ) async {
    final b = await banc(roles: {Role.admin});
    await b.firestore.doc('demandes/d1').set({
      'uid': 'u2',
      'nom': 'Paul',
      'type': 'bapteme',
      'statut': 'en_cours',
      'createdAt': Timestamp.fromDate(DateTime(2026, 10, 1)),
    });
    await lancer(tester, banc: b, taille: grand);
    await tester.tap(find.text('Responsables'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Demandes'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Baptême · Paul'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Inscrire à une préparation'));
    await tester.pumpAndSettle();
    final i = await b.firestore.doc('preparations/bap/inscrits/u2').get();
    expect(i['nom'], 'Paul');
    expect(i['demandeId'], 'd1');
    expect(find.text('Paul est inscrit à la préparation.'), findsOneWidget);
  });

  testWidgets('exhortations : ajoutées par le pasteur, hors progression', (
    tester,
  ) async {
    final b = await banc(inscrit: true, roles: {Role.admin});
    await lancer(tester, banc: b, taille: grand);
    await ouvrir(tester);
    expect(find.text('Pas encore d\'exhortation.'), findsOneWidget);
    await tester.tap(find.text('Ajouter une exhortation'));
    await tester.pumpAndSettle();
    expect(find.text('Ajouter une exhortation'), findsOneWidget);
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Titre (FR)'),
      'Le mariage selon Dieu',
    );
    await tester.tap(find.text('Choisir un fichier').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Enregistrer'));
    await tester.pumpAndSettle();
    final x =
        (await b.firestore
                .collection('preparations/bap/lecons')
                .where('genre', isEqualTo: 'exhortation')
                .get())
            .docs
            .single
            .data();
    expect(x['titre'], {'fr': 'Le mariage selon Dieu'});
    expect(x['audioUrl'], startsWith('https://exemple.be/preparations/bap/'));
    expect(find.text('Le mariage selon Dieu'), findsOneWidget);
    // La progression ne compte que les leçons.
    expect(find.text('0 leçon(s) terminée(s) sur 2'), findsWidgets);
    await tester.tap(find.text('Le mariage selon Dieu'));
    await tester.pumpAndSettle();
    expect(find.text('Exhortation'), findsOneWidget);
    expect(find.text('J\'ai terminé cette leçon'), findsNothing);
  });
}
