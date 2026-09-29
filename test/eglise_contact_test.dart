import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:montagne_des_oliviers/features/auth/domain/role.dart';
import 'package:montagne_des_oliviers/features/parametres/parametres_eglise.dart';

import 'helpers.dart';

const grand = Size(1080, 14000);

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  test('prochaine rencontre en direct : jour et heure de la semaine', () {
    const p = ParametresEglise(interactionJour: 4, interactionHeure: '20:00');
    // Lundi 5 octobre 2026, 9 h → jeudi 8 octobre, 20 h.
    expect(p.prochaineInteraction(maintenant), DateTime(2026, 10, 8, 20));
    expect(
      p.prochaineInteraction(DateTime(2026, 10, 8, 21)),
      DateTime(2026, 10, 8, 20),
    );
    expect(
      p.prochaineInteraction(DateTime(2026, 10, 8, 23)),
      DateTime(2026, 10, 15, 20),
    );
    expect(const ParametresEglise().prochaineInteraction(maintenant), isNull);
    expect(heureValide('9:30'), isTrue);
    expect(heureValide('25:00'), isFalse);
  });

  testWidgets('visiteur : nous contacter, sans compte', (tester) async {
    final b = Banc();
    await lancer(tester, banc: b, taille: grand);
    await tester.tap(find.text('Nous contacter'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ChoiceChip, 'Délivrance'));
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Votre message'),
      'Je fais des cauchemars depuis des mois.',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Prénom et nom'),
      'Luc',
    );
    await tester.tap(find.text('Envoyer'));
    await tester.pumpAndSettle();
    expect(
      find.text('Indiquez au moins un e-mail ou un numéro de téléphone.'),
      findsOneWidget,
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Téléphone'),
      '0470 12 34 56',
    );
    await tester.tap(find.text('Envoyer'));
    await tester.pumpAndSettle();
    expect(find.text('Cochez la case pour continuer.'), findsOneWidget);
    await tester.tap(find.byType(Checkbox));
    await tester.tap(find.text('Envoyer'));
    await tester.pumpAndSettle();
    final c = (await b.firestore.collection('contacts').get()).docs.single
        .data();
    expect(c['sujet'], 'delivrance');
    expect(c['telephone'], '0470 12 34 56');
    expect(c['consentement'], isTrue);
    expect(c.containsKey('uid'), isFalse);
    expect(find.textContaining('Un pasteur vous recontactera'), findsOneWidget);
  });

  testWidgets('pasteur : message reçu, marqué traité', (tester) async {
    final b = await responsable({Role.admin});
    await b.firestore.doc('contacts/c1').set({
      'nom': 'Luc',
      'email': 'luc@x.be',
      'telephone': '',
      'sujet': 'guerison',
      'message': 'Priez pour mon dos.',
      'traite': false,
      'createdAt': maintenant,
    });
    await lancer(tester, banc: b, taille: grand);
    await tester.tap(find.text('Responsables'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Messages reçus'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Guérison · Luc'));
    await tester.pumpAndSettle();
    expect(find.text('Priez pour mon dos.'), findsOneWidget);
    await tester.tap(find.text('luc@x.be'));
    expect(b.lanceur.ouverts.single.toString(), 'mailto:luc@x.be');
    await tester.tap(find.text('Marquer comme traité'));
    await tester.pumpAndSettle();
    expect((await b.firestore.doc('contacts/c1').get())['traite'], isTrue);
    expect(find.text('Guérison · Luc'), findsNothing);
  });

  testWidgets('notre église : texte proposé et domaines', (tester) async {
    await lancer(tester, taille: grand);
    await tester.tap(find.text('Notre église'));
    await tester.pumpAndSettle();
    expect(find.textContaining('annonce Jésus-Christ'), findsOneWidget);
    expect(find.text('Combat spirituel'), findsOneWidget);
    expect(find.text('Guérison'), findsOneWidget);
  });

  testWidgets(
    'administrateur : rencontre du jeudi et lien WhatsApp, puis visiteur',
    (tester) async {
      final b = await responsable({Role.admin});
      await lancer(tester, banc: b, taille: grand);
      await tester.tap(find.text('Responsables'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Contenu de l\'église'));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(DropdownButtonFormField<int?>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('jeudi').last);
      await tester.pumpAndSettle();
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Heure'),
        '20:00',
      );
      await tester.enterText(
        find.widgetWithText(
          TextFormField,
          'Lien de la rencontre (YouTube, Zoom, WhatsApp…)',
        ),
        'https://meet.google.com/abc',
      );
      await tester.tap(find.text('Ajouter un lien'));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.widgetWithText(
          TextFormField,
          'Nom (ex. : Communauté, Jeunes, Prière)',
        ),
        'Communauté',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Lien d\'invitation WhatsApp'),
        'https://chat.whatsapp.com/xyz',
      );
      await tester.tap(find.text('Enregistrer'));
      await tester.pumpAndSettle();
      final p = (await b.firestore.doc('parametres/eglise').get()).data()!;
      expect(p['interactionJour'], 4);
      expect(p['liensCommunaute'], [
        {'titre': 'Communauté', 'url': 'https://chat.whatsapp.com/xyz'},
      ]);

      await tester.tap(find.text('Accueil').last);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Rencontre en direct'));
      await tester.pumpAndSettle();
      expect(find.text('Chaque jeudi à 20:00'), findsWidgets);
      await tester.tap(find.text('Rejoindre la rencontre'));
      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Communauté'));
      await tester.pumpAndSettle();
      // Bouton vert WhatsApp (le titre de la page porte le même nom).
      await tester.tap(find.text('Communauté').first);
      expect(b.lanceur.ouverts.map((u) => u.host), [
        'meet.google.com',
        'chat.whatsapp.com',
      ]);
    },
  );
}
