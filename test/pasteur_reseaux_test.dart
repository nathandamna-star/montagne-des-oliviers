import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:montagne_des_oliviers/features/auth/domain/role.dart';

import 'helpers.dart';

const grand = Size(1080, 14000);

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  testWidgets('notre pasteur : bientôt, puis présenté par l\'administrateur', (
    tester,
  ) async {
    final b = await responsable({Role.admin});
    await lancer(tester, banc: b, taille: grand);
    await tester.tap(find.text('Notre pasteur'));
    await tester.pumpAndSettle();
    // Présentation de départ, reprise du site de l'église.
    expect(find.text('Pasteur Claude Lumbala'), findsOneWidget);
    expect(find.textContaining('prière de délivrance'), findsOneWidget);
    await tester.tap(find.byTooltip('Modifier'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Prénom et nom'),
      'Jean Mukendi',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Présentation (FR)'),
      'Pasteur de l\'église depuis 2012, marié et père de trois enfants.',
    );
    await tester.tap(find.text('Photo'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Enregistrer'));
    await tester.pumpAndSettle();
    expect(find.text('Jean Mukendi'), findsOneWidget);
    expect(find.text('Pasteur principal'), findsOneWidget);
    expect(find.textContaining('depuis 2012'), findsOneWidget);
    final p = (await b.firestore.doc('parametres/eglise').get()).data()!;
    expect(p['pasteurPhotoUrl'], startsWith('https://exemple.be/parametres/'));
  });

  testWidgets('visiteur : logos des réseaux renseignés, ouverts d\'un appui', (
    tester,
  ) async {
    final b = Banc();
    await b.firestore.doc('parametres/eglise').set({
      'youtubeUrl': 'https://www.youtube.com/@montagne',
      'tiktokUrl': 'https://www.tiktok.com/@montagne',
      'facebookUrl': '',
      'instagramUrl': '',
    });
    await lancer(tester, banc: b, taille: grand);
    expect(find.text('Suivez-nous'), findsOneWidget);
    expect(find.text('Facebook'), findsNothing);
    expect(find.text('Instagram'), findsNothing);
    await tester.tap(find.text('TikTok'));
    expect(b.lanceur.ouverts.single.host, 'www.tiktok.com');
  });

  testWidgets('administrateur : ajouter TikTok et Instagram plus tard', (
    tester,
  ) async {
    final b = await responsable({Role.admin});
    await lancer(tester, banc: b, taille: grand);
    await tester.tap(find.text('Responsables'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Paramètres de l\'église'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Instagram'),
      'instagram.com/montagne',
    );
    await tester.tap(find.text('Enregistrer'));
    await tester.pumpAndSettle();
    expect(find.text('Enregistrer'), findsOneWidget); // lien refusé
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Instagram'),
      'https://www.instagram.com/montagne',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'TikTok'),
      'https://www.tiktok.com/@montagne',
    );
    await tester.tap(find.text('Enregistrer'));
    await tester.pumpAndSettle();
    final p = (await b.firestore.doc('parametres/eglise').get()).data()!;
    expect(p['instagramUrl'], 'https://www.instagram.com/montagne');
    expect(p['tiktokUrl'], 'https://www.tiktok.com/@montagne');
  });

  group('s\'adapte à l\'écran', () {
    NavigationRail? rail(WidgetTester tester) {
      final r = find.byType(NavigationRail);
      return r.evaluate().isEmpty ? null : tester.widget<NavigationRail>(r);
    }

    testWidgets('téléphone : barre en bas', (tester) async {
      await lancer(tester, taille: const Size(1080, 2400));
      expect(find.byType(NavigationBar), findsOneWidget);
      expect(rail(tester), isNull);
    });

    testWidgets('tablette : menu latéral compact', (tester) async {
      await lancer(tester, taille: const Size(2048, 2732));
      expect(find.byType(NavigationBar), findsNothing);
      expect(rail(tester)!.extended, isFalse);
    });

    testWidgets('ordinateur : menu latéral déplié', (tester) async {
      await lancer(tester, taille: const Size(3600, 2200));
      expect(rail(tester)!.extended, isTrue);
      expect(find.text('MONTAGNE\nDES OLIVIERS'), findsOneWidget);
    });
  });
}
