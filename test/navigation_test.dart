import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import 'helpers.dart';

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  testWidgets('téléphone : cinq onglets et navigation', (tester) async {
    await lancer(tester);
    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.byType(NavigationDestination), findsNWidgets(5));
    expect(find.text('Responsables'), findsNothing);
    expect(
      find.text('Centre Évangélique Montagne des Oliviers'),
      findsOneWidget,
    );

    for (final (onglet, extrait) in [
      ('Agenda', 'cultes'),
      ('Groupes', 'groupes et leurs discussions'),
      ('Médias', 'exhortations'),
      ('Profil', 'dons'),
    ]) {
      await tester.tap(find.text(onglet).last);
      await tester.pumpAndSettle();
      expect(find.textContaining(extrait), findsOneWidget, reason: onglet);
    }
  });

  testWidgets('onglet Responsables pour les responsables', (tester) async {
    await lancer(tester, banc: await responsable());
    expect(find.byType(NavigationDestination), findsNWidgets(6));
    await tester.tap(find.text('Responsables'));
    await tester.pumpAndSettle();
    expect(find.textContaining('fichier des membres'), findsOneWidget);
  });

  testWidgets('ordinateur : menu latéral', (tester) async {
    await lancer(
      tester,
      taille: const Size(2800, 1800),
      banc: await responsable(),
    );
    expect(find.byType(NavigationRail), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);
    await tester.tap(find.text('Responsables'));
    await tester.pumpAndSettle();
    expect(find.textContaining('réservation des salles'), findsOneWidget);
  });

  testWidgets('interface en néerlandais', (tester) async {
    await lancer(tester, locale: const Locale('nl'));
    expect(find.text('Groepen'), findsOneWidget);
    await tester.tap(find.text('Media'));
    await tester.pumpAndSettle();
    expect(find.textContaining('livestream'), findsOneWidget);
  });

  testWidgets('autre langue du téléphone : français', (tester) async {
    await lancer(tester, locale: const Locale('de'));
    expect(find.text('Accueil'), findsWidgets);
  });
}
