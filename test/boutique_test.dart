import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:montagne_des_oliviers/features/auth/domain/role.dart';

import 'helpers.dart';

const grand = Size(1080, 14000);

Future<void> semer(Banc b) async {
  final db = b.firestore;
  await db.doc('parametres/eglise').set({
    'titulaire': 'ASBL Montagne des Oliviers',
    'iban': 'BE71096123456769',
  });
  await db.doc('livres/priere').set({
    'titre': 'La prière qui change tout',
    'auteur': 'Pasteur Jean',
    'description': {'fr': 'Un guide pour prier chaque jour.'},
    'prix': 12.5,
    'disponible': true,
  });
  await db.doc('livres/epuise').set({
    'titre': 'Ancien livre',
    'prix': 8,
    'disponible': false,
  });
}

Future<void> ajouterAuPanier(WidgetTester tester) async {
  await tester.tap(find.text('Boutique'));
  await tester.pumpAndSettle();
  expect(find.text('Ancien livre'), findsNothing);
  await tester.tap(find.text('La prière qui change tout'));
  await tester.pumpAndSettle();
  expect(find.text('Un guide pour prier chaque jour.'), findsOneWidget);
  await tester.tap(find.text('Ajouter au panier'));
  await tester.tap(find.text('Ajouter au panier'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Panier (2)'));
  await tester.pumpAndSettle();
  expect(find.text(eur('25 €')), findsNWidgets(2));
}

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  testWidgets('visiteur : voit la boutique, se connecte pour commander', (
    tester,
  ) async {
    final b = Banc();
    await semer(b);
    await lancer(tester, banc: b, taille: grand);
    await ajouterAuPanier(tester);
    expect(find.text('Se connecter pour commander'), findsOneWidget);
    expect(find.text('Payer par Bancontact ou carte'), findsNothing);
  });

  testWidgets('membre : commande par virement, QR code, annulation', (
    tester,
  ) async {
    final b = Banc(connecte: true);
    await b.avecProfil();
    await semer(b);
    await lancer(tester, banc: b, taille: grand);
    await ajouterAuPanier(tester);
    await tester.tap(find.byTooltip('Un de moins'));
    await tester.pumpAndSettle();
    expect(find.text(eur('12,50 €')), findsWidgets);
    await tester.tap(find.text('Payer par virement (QR code)'));
    await tester.pumpAndSettle();
    expect(b.paiements.appels, ['commande virement']);
    expect(find.text('+++100/0000/00034+++'), findsWidgets);
    expect(find.text('1 × La prière qui change tout'), findsOneWidget);
    await tester.tap(find.text('Annuler la commande'));
    await tester.pumpAndSettle();
    expect(
      (await b.firestore.doc('commandes/100000000034').get())['statut'],
      'annulee',
    );
  });

  testWidgets('membre : paiement en ligne, puis mes commandes', (tester) async {
    final b = Banc(connecte: true);
    await b.avecProfil();
    await semer(b);
    await lancer(tester, banc: b, taille: grand);
    await ajouterAuPanier(tester);
    await tester.tap(find.text('Payer par Bancontact ou carte'));
    await tester.pumpAndSettle();
    expect(
      b.lanceur.ouverts.single.toString(),
      'https://stripe.test/c-en-ligne',
    );
    expect(find.text('En attente du paiement'), findsOneWidget);
    // Le webhook Stripe confirme le paiement.
    await b.firestore.doc('commandes/c-en-ligne').update({'statut': 'payee'});
    await tester.pumpAndSettle();
    expect(find.text('Payée, à retirer'), findsOneWidget);
  });

  testWidgets('secrétariat : ajouter un livre, suivre une commande', (
    tester,
  ) async {
    final b = await responsable({Role.secretariat});
    await b.firestore.doc('commandes/100000000034').set({
      'uid': 'u2',
      'nom': 'Paul',
      'total': 25,
      'mode': 'virement',
      'statut': 'payee',
      'lignes': [
        {
          'livreId': 'priere',
          'titre': 'La prière',
          'prix': 12.5,
          'quantite': 2,
        },
      ],
      'createdAt': Timestamp.fromDate(maintenant),
    });
    await lancer(tester, banc: b, taille: grand);
    await tester.tap(find.text('Responsables'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Boutique').last);
    await tester.pumpAndSettle();
    await tester.tap(find.textContaining('Paul'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ChoiceChip, 'Remise'));
    await tester.pumpAndSettle();
    final c = await b.firestore.doc('commandes/100000000034').get();
    expect(c['statut'], 'remise');
    expect(c['majPar'], 'u1');
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Livres'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Nouveau livre'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Titre'),
      'Marcher par la foi',
    );
    await tester.enterText(find.widgetWithText(TextFormField, 'Prix'), '0');
    await tester.tap(find.text('Enregistrer'));
    await tester.pumpAndSettle();
    expect(find.text('Indiquez un prix entre 1 et 1 000 €.'), findsOneWidget);
    await tester.enterText(find.widgetWithText(TextFormField, 'Prix'), '9,90');
    await tester.tap(find.text('Couverture'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Enregistrer'));
    await tester.pumpAndSettle();
    final l = (await b.firestore.collection('livres').get()).docs.single.data();
    expect(l['titre'], 'Marcher par la foi');
    expect(l['prix'], 9.9);
    expect(l['disponible'], isTrue);
    expect(l['photoUrl'], startsWith('https://exemple.be/livres/'));
    expect(l['description'], isNull);
  });
}
