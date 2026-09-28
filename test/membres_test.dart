import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:montagne_des_oliviers/features/auth/domain/role.dart';
import 'package:montagne_des_oliviers/features/membres/domain/export_csv.dart';
import 'package:montagne_des_oliviers/features/membres/domain/membre.dart';

import 'helpers.dart';

const grand = Size(1080, 6000);

Future<Banc> secretariat() async {
  final b = await responsable({Role.secretariat});
  final db = b.firestore;
  await db.doc('familles/f1').set({'nom': 'Famille Mbala'});
  await db.doc('membres/m1').set({
    'nom': 'Mbala',
    'prenom': 'Hélène',
    'statut': 'actif',
    'telephone': '0470 11 22 33',
    'ville': 'Tienen',
    'familleId': 'f1',
    'services': ['Louange'],
    'dateNaissance': Timestamp.fromDate(DateTime(1985, 3, 14)),
  });
  await db.doc('membres/m2').set({
    'nom': 'Mbala',
    'prenom': 'Joseph',
    'statut': 'membre',
    'familleId': 'f1',
  });
  await db.doc('membres/m3').set({
    'nom': 'Peeters',
    'prenom': 'Anna',
    'statut': 'visiteur',
    'ville': 'Leuven',
  });
  await db.doc('users/u9').set({
    'nom': 'Jean Dupont',
    'email': 'jean@exemple.be',
    'langue': 'fr',
  });
  return b;
}

Future<void> ouvrirFichier(WidgetTester tester) async {
  await tester.tap(find.text('Responsables'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Fichier des membres'));
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  test('recherche sans accents', () {
    expect(sansAccents('Hélène Çà Œ'), 'helene ca o');
  });

  test('export CSV : point-virgule, guillemets, dates, famille', () {
    final csv = exporterCsv(
      [
        Membre(
          id: 'm1',
          nom: 'Mbala',
          prenom: 'Hélène',
          statut: StatutMembre.actif,
          familleId: 'f1',
          dateNaissance: DateTime(1985, 3, 14),
          services: const ['Louange', 'Accueil'],
          notes: 'Dit "bonjour"; merci',
        ),
      ],
      familles: {'f1': 'Famille Mbala'},
      entetes: List.generate(16, (i) => 'c$i'),
      libelleStatut: (s) => s.name,
    );
    final lignes = csv.split('\r\n');
    expect(csv.startsWith('﻿'), isTrue);
    expect(
      lignes[1],
      'Mbala;Hélène;actif;;;;;;1985-03-14;Famille Mbala;;;;;Louange, Accueil;"Dit ""bonjour""; merci"',
    );
  });

  testWidgets('recherche, filtre par statut, nombre de fiches', (tester) async {
    await lancer(tester, banc: await secretariat(), taille: grand);
    await ouvrirFichier(tester);
    expect(find.text('3 fiches'), findsOneWidget);
    await tester.enterText(find.byType(TextField).first, 'helene');
    await tester.pumpAndSettle();
    expect(find.text('MBALA Hélène'), findsOneWidget);
    expect(find.text('MBALA Joseph'), findsNothing);
    await tester.enterText(find.byType(TextField).first, '');
    await tester.tap(find.widgetWithText(ChoiceChip, 'Visiteur'));
    await tester.pumpAndSettle();
    expect(find.text('1 fiche'), findsOneWidget);
    expect(find.text('PEETERS Anna'), findsOneWidget);
  });

  testWidgets('nouvelle fiche avec famille et services', (tester) async {
    final b = await secretariat();
    await lancer(tester, banc: b, taille: grand);
    await ouvrirFichier(tester);
    await tester.tap(find.text('Nouvelle fiche'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Enregistrer'));
    await tester.pumpAndSettle();
    expect(find.text('Ce champ est obligatoire.'), findsOneWidget);

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Nom'),
      'Janssens',
    );
    await tester.enterText(find.widgetWithText(TextFormField, 'Prénom'), 'Luc');
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Téléphone'),
      '0499 00 00 00',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Adresse e-mail'),
      'pas-un-email',
    );
    await tester.tap(find.text('Membre actif'));
    await tester.tap(find.widgetWithText(FilterChip, 'Sono / vidéo'));
    await tester.tap(find.byTooltip('Nouvelle famille'));
    await tester.pumpAndSettle();
    expect(find.text('Famille Janssens'), findsOneWidget);
    await tester.tap(find.text('Créer'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Enregistrer'));
    await tester.pumpAndSettle();
    expect(find.text('Indiquez une adresse e-mail valide.'), findsOneWidget);
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Adresse e-mail'),
      'luc@exemple.be',
    );
    await tester.tap(find.text('Enregistrer'));
    await tester.pumpAndSettle();

    final fiche =
        (await b.firestore
                .collection('membres')
                .where('nom', isEqualTo: 'Janssens')
                .get())
            .docs
            .single
            .data();
    expect(fiche['prenom'], 'Luc');
    expect(fiche['statut'], 'actif');
    expect(fiche['email'], 'luc@exemple.be');
    expect(fiche['services'], ['Sono / vidéo']);
    final famille = await b.firestore
        .doc('familles/${fiche['familleId']}')
        .get();
    expect(famille['nom'], 'Famille Janssens');
    expect(find.text('4 fiches'), findsOneWidget);
  });

  testWidgets('fiche créée depuis un compte de l\'app', (tester) async {
    final b = await secretariat();
    await lancer(tester, banc: b, taille: grand);
    await ouvrirFichier(tester);
    // Marie (le compte connecté) et Jean n'ont pas de fiche.
    expect(find.text('2 comptes de l\'app sans fiche'), findsOneWidget);
    await tester.tap(find.text('2 comptes de l\'app sans fiche'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Jean Dupont'));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(TextFormField, 'Jean'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, 'Dupont'), findsOneWidget);
    await tester.tap(find.text('Enregistrer'));
    await tester.pumpAndSettle();
    final fiche =
        (await b.firestore
                .collection('membres')
                .where('uid', isEqualTo: 'u9')
                .get())
            .docs
            .single
            .data();
    expect(fiche['email'], 'jean@exemple.be');
    expect(find.text('1 compte de l\'app sans fiche'), findsOneWidget);
  });

  testWidgets('export CSV de la liste filtrée', (tester) async {
    final b = await secretariat();
    await lancer(tester, banc: b, taille: grand);
    await ouvrirFichier(tester);
    await tester.tap(find.widgetWithText(ChoiceChip, 'Membre actif'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Exporter (tableur CSV)'));
    await tester.pumpAndSettle();
    final (nom, contenu) = b.partage.fichiers.single;
    expect(nom, startsWith('membres-'));
    expect(nom, endsWith('.csv'));
    expect(contenu.codeUnitAt(0), 0xFEFF);
    final lignes = contenu.substring(1).trim().split('\r\n');
    expect(lignes.first, startsWith('Nom;Prénom;Statut;'));
    expect(lignes, hasLength(2));
    expect(lignes[1], startsWith('Mbala;Hélène;Membre actif;'));
  });

  testWidgets('familles : membres, retirer une personne', (tester) async {
    final b = await secretariat();
    await lancer(tester, banc: b, taille: grand);
    await ouvrirFichier(tester);
    await tester.tap(find.byTooltip('Familles'));
    await tester.pumpAndSettle();
    expect(find.text('2 personnes'), findsOneWidget);
    await tester.tap(find.text('Famille Mbala'));
    await tester.pumpAndSettle();
    expect(find.text('MBALA Joseph'), findsOneWidget);
    await tester.tap(find.byTooltip('Retirer de la famille').last);
    await tester.pumpAndSettle();
    expect((await b.firestore.doc('membres/m2').get())['familleId'], isNull);
    expect(find.text('MBALA Joseph'), findsNothing);
  });

  testWidgets('ordinateur : tableau', (tester) async {
    await lancer(
      tester,
      banc: await secretariat(),
      taille: const Size(3200, 2400),
    );
    await ouvrirFichier(tester);
    expect(find.byType(DataTable), findsOneWidget);
    expect(find.text('Famille Mbala'), findsNWidgets(2));
  });

  testWidgets('trésorier : pas d\'accès au fichier des membres', (
    tester,
  ) async {
    await lancer(tester, banc: await responsable({Role.tresorier}));
    await tester.tap(find.text('Responsables'));
    await tester.pumpAndSettle();
    expect(find.text('Fichier des membres'), findsNothing);
  });

  testWidgets('rôles : liste des responsables actuels', (tester) async {
    final b = await responsable({Role.admin});
    await b.firestore.doc('users/u7').set({
      'nom': 'Paul Trésor',
      'email': 'paul@exemple.be',
      'roles': ['tresorier'],
    });
    await lancer(tester, banc: b, taille: grand);
    await tester.tap(find.text('Responsables'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Rôles des responsables'));
    await tester.pumpAndSettle();
    expect(find.text('Paul Trésor'), findsOneWidget);
    await tester.tap(find.text('Paul Trésor'));
    await tester.pumpAndSettle();
    expect(
      find.widgetWithText(TextFormField, 'paul@exemple.be'),
      findsOneWidget,
    );
    await tester.tap(find.text('Enregistrer'));
    await tester.pumpAndSettle();
    expect(b.fonctions.appels.last, 'definirRoles paul@exemple.be tresorier');
  });
}
