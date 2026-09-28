import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:montagne_des_oliviers/features/auth/domain/role.dart';
import 'package:montagne_des_oliviers/features/groupes/domain/groupe.dart';

import 'helpers.dart';

const grand = Size(1080, 6000);

/// Marie (u1) : administratrice de « Intercession du mardi », membre de
/// « Louange ». « Jeunes » est un groupe ouvert.
Future<Banc> banc({Set<Role> roles = const {}}) async {
  final b = Banc(connecte: true, roles: roles);
  await b.avecProfil();
  final db = b.firestore;
  for (final (uid, nom) in [
    ('u1', 'Marie'),
    ('u2', 'Paul'),
    ('u3', 'Hélène'),
    ('u4', 'Jean'),
  ]) {
    await db.doc('annuaire/$uid').set({'nom': nom});
  }
  await db.doc('groupes/inter').set({
    'nom': 'Intercession du mardi',
    'type': 'intercession',
    'prive': true,
    'membres': ['u1', 'u2'],
    'admins': ['u1'],
    'lienAppel': 'https://meet.google.com/abc',
  });
  await db.doc('groupes/louange').set({
    'nom': 'Louange',
    'type': 'louange',
    'prive': true,
    'membres': ['u1', 'u3'],
    'admins': ['u3'],
    'dernierMessage': {
      'auteur': 'u3',
      'nom': 'Hélène',
      'texte': 'Répétition jeudi',
      'le': Timestamp.fromDate(DateTime(2026, 10, 4)),
    },
  });
  await db.doc('groupes/jeunes').set({
    'nom': 'Jeunes',
    'type': 'jeunes',
    'prive': false,
    'membres': ['u4'],
    'admins': ['u4'],
  });
  await db.doc('groupes/secret').set({
    'nom': 'Conseil',
    'type': 'autre',
    'prive': true,
    'membres': ['u4'],
    'admins': ['u4'],
  });
  return b;
}

Future<void> ouvrirGroupe(WidgetTester tester, String nom) async {
  await tester.tap(find.text('Groupes').last);
  await tester.pumpAndSettle();
  await tester.tap(find.text(nom));
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  test('lien d\'appel : vide ou https', () {
    expect(lienAppelValide(''), isTrue);
    expect(lienAppelValide('https://zoom.us/j/123'), isTrue);
    expect(lienAppelValide('http://zoom.us/j/123'), isFalse);
    expect(lienAppelValide('meet.google.com/abc'), isFalse);
  });

  testWidgets('mes groupes, groupes ouverts, message non lu', (tester) async {
    await lancer(tester, banc: await banc(), taille: grand);
    await tester.tap(find.text('Groupes').last);
    await tester.pumpAndSettle();
    expect(find.text('Intercession du mardi'), findsOneWidget);
    expect(find.text('Louange'), findsOneWidget);
    expect(find.text('Hélène : Répétition jeudi'), findsOneWidget);
    expect(find.text('Nouveau'), findsOneWidget);
    // Groupe ouvert visible, groupe privé des autres invisible.
    expect(find.text('Jeunes'), findsOneWidget);
    expect(find.text('Conseil'), findsNothing);

    // Ouvrir la discussion marque comme lu.
    await tester.tap(find.text('Louange'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Discussion'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Retour'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Retour'));
    await tester.pumpAndSettle();
    expect(find.text('Nouveau'), findsNothing);
  });

  testWidgets('discussion : envoyer un texte et une photo', (tester) async {
    final b = await banc();
    await lancer(tester, banc: b, taille: grand);
    await ouvrirGroupe(tester, 'Intercession du mardi');
    await tester.tap(find.text('Discussion'));
    await tester.pumpAndSettle();
    expect(find.text('Aucun message. Écrivez le premier !'), findsOneWidget);
    await tester.enterText(
      find.byType(TextField),
      'Prions pour la famille Mbala',
    );
    await tester.tap(find.byTooltip('Envoyer'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Envoyer une photo'));
    await tester.pumpAndSettle();
    final msgs =
        (await b.firestore
                .collection('groupes/inter/messages')
                .orderBy('createdAt')
                .get())
            .docs;
    expect(msgs, hasLength(2));
    expect(msgs[0]['texte'], 'Prions pour la famille Mbala');
    expect(msgs[0]['auteur'], 'u1');
    expect(msgs[0]['nom'], 'Marie');
    expect(
      msgs[1]['fichierUrl'],
      startsWith('https://exemple.be/groupes/inter/'),
    );
    expect(find.text('Prions pour la famille Mbala'), findsOneWidget);
  });

  testWidgets(
    'administrateur du groupe : ajouter, nommer, retirer ; lien d\'appel',
    (tester) async {
      final b = await banc();
      await lancer(tester, banc: b, taille: grand);
      await ouvrirGroupe(tester, 'Intercession du mardi');
      expect(find.text('2 membres'), findsOneWidget);
      await tester.tap(find.text('Rejoindre l\'appel'));
      expect(
        b.lanceur.ouverts.single.toString(),
        'https://meet.google.com/abc',
      );

      await tester.tap(find.text('Ajouter'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField).last, 'helene');
      await tester.pumpAndSettle();
      expect(find.text('Jean'), findsNothing);
      await tester.tap(find.text('Hélène'));
      await tester.pump();
      await tester.tap(find.text('Ajouter 1 personne'));
      await tester.pumpAndSettle();
      expect((await b.firestore.doc('groupes/inter').get())['membres'], [
        'u1',
        'u2',
        'u3',
      ]);
      expect(find.text('3 membres'), findsOneWidget);

      // Hélène (en tête, ordre alphabétique) devient administratrice,
      // puis Paul est retiré.
      await tester.tap(find.byTooltip('Options').first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Nommer administrateur'));
      await tester.pumpAndSettle();
      expect(
        (await b.firestore.doc('groupes/inter').get())['admins'],
        containsAll(['u1', 'u3']),
      );
      await tester.tap(find.byTooltip('Options').last);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Retirer du groupe'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Valider'));
      await tester.pumpAndSettle();
      expect((await b.firestore.doc('groupes/inter').get())['membres'], [
        'u1',
        'u3',
      ]);
    },
  );

  testWidgets(
    'administrateur du groupe : modifier le lien (https obligatoire)',
    (tester) async {
      final b = await banc();
      await lancer(tester, banc: b, taille: grand);
      await ouvrirGroupe(tester, 'Intercession du mardi');
      await tester.tap(find.byTooltip('Modifier le groupe'));
      await tester.pumpAndSettle();
      // Pas le secrétariat : ni type ni confidentialité.
      expect(find.text('Groupe privé'), findsNothing);
      await tester.enterText(
        find.widgetWithText(
          TextFormField,
          'Lien d\'appel (Meet, Zoom, WhatsApp…)',
        ),
        'http://zoom.us/j/1',
      );
      await tester.tap(find.text('Enregistrer'));
      await tester.pumpAndSettle();
      expect(find.text('Le lien doit commencer par https://'), findsOneWidget);
      await tester.enterText(
        find.widgetWithText(
          TextFormField,
          'Lien d\'appel (Meet, Zoom, WhatsApp…)',
        ),
        'https://zoom.us/j/1',
      );
      await tester.tap(find.text('Enregistrer'));
      await tester.pumpAndSettle();
      final g = await b.firestore.doc('groupes/inter').get();
      expect(g['lienAppel'], 'https://zoom.us/j/1');
      expect(g['type'], 'intercession');
    },
  );

  testWidgets('membre simple : pas de gestion, peut quitter', (tester) async {
    final b = await banc();
    await lancer(tester, banc: b, taille: grand);
    await ouvrirGroupe(tester, 'Louange');
    expect(find.byTooltip('Modifier le groupe'), findsNothing);
    expect(find.byTooltip('Options'), findsNothing);
    expect(find.text('Ajouter'), findsNothing);
    await tester.tap(find.text('Quitter le groupe'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Valider'));
    await tester.pumpAndSettle();
    expect((await b.firestore.doc('groupes/louange').get())['membres'], ['u3']);
  });

  testWidgets('groupe ouvert : qui contacter pour le rejoindre', (
    tester,
  ) async {
    await lancer(tester, banc: await banc(), taille: grand);
    await ouvrirGroupe(tester, 'Jeunes');
    expect(
      find.text('Pour rejoindre ce groupe, demandez à : Jean.'),
      findsOneWidget,
    );
    expect(find.text('Discussion'), findsNothing);
  });

  testWidgets('secrétariat : créer l\'équipe média avec son administrateur', (
    tester,
  ) async {
    final b = await banc(roles: {Role.secretariat});
    await lancer(tester, banc: b, taille: grand);
    await tester.tap(find.text('Responsables'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Groupes de l\'église'));
    await tester.pumpAndSettle();
    expect(find.text('Conseil'), findsOneWidget);
    await tester.tap(find.text('Nouveau groupe'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Nom du groupe'),
      'Équipe média',
    );
    await tester.tap(find.byType(DropdownButtonFormField<TypeGroupe>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Équipe média').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Enregistrer'));
    await tester.pumpAndSettle();
    expect(find.text('Choisissez au moins un administrateur.'), findsOneWidget);
    await tester.tap(find.widgetWithText(CheckboxListTile, 'Paul'));
    await tester.tap(find.text('Enregistrer'));
    await tester.pumpAndSettle();
    final g =
        (await b.firestore
                .collection('groupes')
                .where('type', isEqualTo: 'media')
                .get())
            .docs
            .single
            .data();
    expect(g['nom'], 'Équipe média');
    expect(g['admins'], ['u2']);
    expect(g['membres'], ['u2']);
    expect(g['prive'], isTrue);
  });

  testWidgets('notification de groupe touchée : ouvre la discussion', (
    tester,
  ) async {
    final b = await banc();
    await lancer(tester, banc: b, taille: grand);
    b.notifications.touchees.add({'type': 'groupe', 'id': 'inter'});
    await tester.pumpAndSettle();
    expect(find.text('Aucun message. Écrivez le premier !'), findsOneWidget);
  });

  testWidgets('ajouter un administrateur directement (pas encore membre)', (
    tester,
  ) async {
    final b = await banc();
    await lancer(tester, banc: b, taille: grand);
    await ouvrirGroupe(tester, 'Intercession du mardi');
    await tester.tap(find.text('Ajouter un administrateur'));
    await tester.pumpAndSettle();
    // Marie est déjà administratrice : pas proposée ; Paul (membre) et Jean oui.
    expect(find.widgetWithText(CheckboxListTile, 'Marie'), findsNothing);
    expect(find.widgetWithText(CheckboxListTile, 'Paul'), findsOneWidget);
    await tester.tap(find.widgetWithText(CheckboxListTile, 'Jean'));
    await tester.pump();
    await tester.tap(find.text('Ajouter 1 personne'));
    await tester.pumpAndSettle();
    final g = await b.firestore.doc('groupes/inter').get();
    expect(g['admins'], ['u1', 'u4']);
    expect(g['membres'], ['u1', 'u2', 'u4']);
    expect(find.text('Administrateur du groupe'), findsNWidgets(2));
  });

  testWidgets('création : rechercher et choisir l\'administrateur', (
    tester,
  ) async {
    final b = await banc(roles: {Role.secretariat});
    await lancer(tester, banc: b, taille: grand);
    await tester.tap(find.text('Responsables'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Groupes de l\'église'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Nouveau groupe'));
    await tester.pumpAndSettle();
    expect(b.fonctions.appels, contains('reconstruireAnnuaire'));
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Nom du groupe'),
      'Cellule de Tienen',
    );
    await tester.enterText(
      find.widgetWithText(TextField, 'Rechercher une personne'),
      'hel',
    );
    await tester.pumpAndSettle();
    expect(find.widgetWithText(CheckboxListTile, 'Paul'), findsNothing);
    await tester.tap(find.widgetWithText(CheckboxListTile, 'Hélène'));
    await tester.pumpAndSettle();
    // L'administratrice choisie apparaît en haut.
    expect(find.widgetWithText(InputChip, 'Hélène'), findsOneWidget);
    await tester.tap(find.text('Enregistrer'));
    await tester.pumpAndSettle();
    final g =
        (await b.firestore
                .collection('groupes')
                .where('nom', isEqualTo: 'Cellule de Tienen')
                .get())
            .docs
            .single
            .data();
    expect(g['admins'], ['u3']);
    expect(g['membres'], ['u3']);
  });
}
