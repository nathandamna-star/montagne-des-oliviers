import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:montagne_des_oliviers/features/profil/data/fonctions_compte.dart';

import 'helpers.dart';

const grand = Size(1080, 14000);

Future<Banc> ouvrirProfil(WidgetTester tester) async {
  final b = Banc(connecte: true);
  await b.avecProfil();
  await lancer(tester, banc: b, taille: grand);
  await tester.tap(find.text('Profil'));
  await tester.pumpAndSettle();
  return b;
}

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  testWidgets('modifier son nom et sa photo', (tester) async {
    final b = await ouvrirProfil(tester);
    await tester.tap(find.text('Prénom et nom'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Marie Dupont');
    await tester.tap(find.text('Enregistrer'));
    await tester.pumpAndSettle();
    expect((await b.firestore.doc('users/u1').get())['nom'], 'Marie Dupont');
    expect(find.text('Bonjour Marie Dupont'), findsOneWidget);

    await tester.tap(find.text('Photo de profil'));
    await tester.pumpAndSettle();
    expect(
      (await b.firestore.doc('users/u1').get())['photoUrl'],
      startsWith('https://exemple.be/users/u1/photo-'),
    );
  });

  testWidgets('langue : l\'app passe en néerlandais, les notifications aussi', (
    tester,
  ) async {
    final b = await ouvrirProfil(tester);
    await tester.tap(find.text('Nederlands'));
    await tester.pumpAndSettle();
    expect(find.text('Profiel'), findsWidgets);
    expect((await b.firestore.doc('users/u1').get())['langue'], 'nl');
    expect(b.notifications.appels.last, 'activer nl u1');
    await tester.tap(find.text('Telefoon'));
    await tester.pumpAndSettle();
    expect(find.text('Profil'), findsWidgets);
  });

  testWidgets('télécharger mes données : fichier JSON partagé', (tester) async {
    final b = await ouvrirProfil(tester);
    await tester.tap(find.text('Télécharger mes données'));
    await tester.pumpAndSettle();
    final (nom, contenu) = b.partage.fichiers.single;
    expect(nom, 'mes-donnees-montagne-des-oliviers.json');
    expect(contenu, contains('Marie'));
  });

  testWidgets('supprimer mon compte : confirmation, puis déconnexion', (
    tester,
  ) async {
    final b = await ouvrirProfil(tester);
    await tester.tap(find.text('Supprimer mon compte'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Annuler'));
    await tester.pumpAndSettle();
    expect(b.compte.appels, isEmpty);
    await tester.tap(find.text('Supprimer mon compte'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Supprimer définitivement'));
    await tester.pumpAndSettle();
    expect(b.compte.appels, ['supprimer']);
    expect(b.auth.currentUser, isNull);
    expect(find.text('Votre compte a été supprimé.'), findsOneWidget);
  });

  testWidgets('suppression refusée pour le dernier administrateur', (
    tester,
  ) async {
    final b = await ouvrirProfil(tester);
    b.compte.erreur = const ErreurCompte('dernier-admin');
    await tester.tap(find.text('Supprimer mon compte'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Supprimer définitivement'));
    await tester.pumpAndSettle();
    expect(find.textContaining('seul administrateur'), findsOneWidget);
    expect(b.auth.currentUser, isNotNull);
  });

  testWidgets('pages légales ouvertes sur le site, dans la langue de l\'app', (
    tester,
  ) async {
    final b = Banc();
    await lancer(tester, banc: b, taille: grand, locale: const Locale('nl'));
    await tester.tap(find.text('Privacy'));
    expect(
      b.lanceur.ouverts.single.toString(),
      'https://montagne-des-oliviers.web.app/legal/confidentialite?langue=nl',
    );
  });
}
