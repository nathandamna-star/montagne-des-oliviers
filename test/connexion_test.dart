import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:montagne_des_oliviers/features/auth/data/fonctions_roles.dart';
import 'package:montagne_des_oliviers/features/auth/domain/role.dart';

import 'helpers.dart';

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  Future<void> ouvrirConnexion(WidgetTester tester) async {
    await tester.tap(find.text('Se connecter'));
    await tester.pumpAndSettle();
  }

  testWidgets('sans compte : carte de connexion puis retour', (tester) async {
    await lancer(tester);
    await ouvrirConnexion(tester);
    expect(find.text('Continuer avec Google'), findsOneWidget);
    expect(find.text('Continuer avec Apple'), findsNothing);
    await tester.tap(find.text('Continuer sans compte'));
    await tester.pumpAndSettle();
    expect(find.text('Se connecter'), findsOneWidget);
  });

  testWidgets('inscription par e-mail : consentement obligatoire', (
    tester,
  ) async {
    final banc = await lancer(tester);
    await ouvrirConnexion(tester);
    await tester.tap(find.text('Continuer avec un e-mail'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Créer un compte').first);
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).at(0), 'Paul Martin');
    await tester.enterText(find.byType(TextFormField).at(1), 'paul@exemple.be');
    await tester.enterText(find.byType(TextFormField).at(2), 'motdepasse');
    await tester.tap(find.widgetWithText(FilledButton, 'Créer un compte'));
    await tester.pumpAndSettle();
    expect(find.text('Cochez la case pour continuer.'), findsOneWidget);

    await tester.tap(find.byType(Checkbox));
    await tester.tap(find.widgetWithText(FilledButton, 'Créer un compte'));
    await tester.pumpAndSettle();

    // Profil créé avec la date du consentement. (Le faux Firebase ne
    // connecte pas après une inscription : la redirection est testée avec
    // Google.)
    final profils = await banc.firestore.collection('users').get();
    expect(profils.docs.single['nom'], 'Paul Martin');
    expect(profils.docs.single['langue'], 'fr');
    expect(profils.docs.single.data(), contains('consentementLe'));
  });

  testWidgets('Google sans profil : écran de consentement', (tester) async {
    final banc = await lancer(tester);
    await ouvrirConnexion(tester);
    await tester.tap(find.text('Continuer avec Google'));
    await tester.pumpAndSettle();
    expect(find.text('Bienvenue dans la famille !'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField), 'Marie Dubois');
    await tester.tap(find.byType(Checkbox));
    await tester.tap(find.text('Valider'));
    await tester.pumpAndSettle();

    expect(find.text('Bienvenue dans la famille !'), findsNothing);
    // Membre : carte de l'église avec sa devise.
    expect(
      find.text('Repentance · Délivrance · Sanctification'),
      findsOneWidget,
    );
    final profil = await banc.firestore.collection('users').doc('u1').get();
    expect(profil['nom'], 'Marie Dubois');
  });

  testWidgets('consentement refusé : déconnexion', (tester) async {
    final banc = await lancer(tester, banc: Banc(connecte: true));
    expect(find.text('Bienvenue dans la famille !'), findsOneWidget);
    await tester.tap(find.text('Annuler'));
    await tester.pumpAndSettle();
    expect(banc.auth.currentUser, isNull);
    expect(find.text('Se connecter'), findsOneWidget);
  });

  testWidgets('profil : nom, e-mail, devenir administrateur, déconnexion', (
    tester,
  ) async {
    final b = Banc(connecte: true);
    await b.avecProfil();
    await lancer(tester, banc: b);
    await tester.tap(find.text('Profil').last);
    await tester.pumpAndSettle();
    expect(find.text('Bonjour Marie'), findsOneWidget);
    expect(find.text('marie@exemple.be'), findsOneWidget);

    await tester.longPress(find.text('Bonjour Marie'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Valider'));
    await tester.pumpAndSettle();
    expect(b.fonctions.appels, ['revendiquerAdmin']);
    expect(find.text('Vous êtes maintenant administrateur.'), findsOneWidget);

    b.fonctions.erreur = const ErreurRoles('refuse');
    await tester.longPress(find.text('Bonjour Marie'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Valider'));
    await tester.pumpAndSettle();
    expect(
      find.text('Ce compte ne peut pas devenir administrateur.'),
      findsOneWidget,
    );

    await tester.tap(find.text('Se déconnecter'));
    await tester.pumpAndSettle();
    expect(b.auth.currentUser, isNull);
    expect(find.text('Connexion nécessaire'), findsOneWidget);
  });

  testWidgets('administrateur : attribuer un rôle', (tester) async {
    final b = await lancer(
      tester,
      banc: await responsable(),
      taille: const Size(1080, 6000),
    );
    await tester.tap(find.text('Profil').last);
    await tester.pumpAndSettle();
    expect(find.text('Administrateur'), findsOneWidget);

    await tester.tap(find.text('Responsables'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Rôles des responsables'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField), 'jean@exemple.be');
    await tester.tap(find.text('Trésorier'));
    await tester.tap(find.text('Enregistrer'));
    await tester.pumpAndSettle();
    expect(b.fonctions.appels, ['definirRoles jean@exemple.be tresorier']);
    expect(
      find.text('Rôles enregistrés pour jean@exemple.be.'),
      findsOneWidget,
    );
  });

  testWidgets('secrétariat : pas de gestion des rôles', (tester) async {
    await lancer(tester, banc: await responsable({Role.secretariat}));
    await tester.tap(find.text('Responsables'));
    await tester.pumpAndSettle();
    expect(find.text('Rôles des responsables'), findsNothing);
  });
}
