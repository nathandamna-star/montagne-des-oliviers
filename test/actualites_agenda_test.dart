import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:montagne_des_oliviers/features/auth/domain/role.dart';

import 'helpers.dart';

Map<String, dynamic> annonce(
  String titre, {
  String visibilite = 'public',
  bool publie = true,
  bool epingle = false,
  int jour = 1,
}) => {
  'titre': {'fr': titre, 'nl': '$titre (NL)'},
  'texte': {'fr': 'Texte de $titre'},
  'visibilite': visibilite,
  'publie': publie,
  'epingle': epingle,
  'publieLe': Timestamp.fromDate(DateTime(2026, 10, jour)),
  'modifieLe': Timestamp.fromDate(DateTime(2026, 10, jour)),
};

Map<String, dynamic> evenement(
  String titre, {
  required DateTime debut,
  String type = 'culte',
  String visibilite = 'public',
  bool publie = true,
  bool inscription = false,
  int? placesMax,
  int inscrits = 0,
}) => {
  'titre': {'fr': titre},
  'description': {'fr': 'Description de $titre'},
  'type': type,
  'debut': Timestamp.fromDate(debut),
  'fin': Timestamp.fromDate(debut.add(const Duration(hours: 2))),
  'lieu': 'Tienen',
  'visibilite': visibilite,
  'publie': publie,
  'inscription': inscription,
  'placesMax': placesMax,
  'inscrits': inscrits,
};

Future<void> semer(Banc b) async {
  final db = b.firestore;
  await db.doc('actualites/a1').set(annonce('Culte de louange', jour: 2));
  await db
      .doc('actualites/a2')
      .set(annonce('Réunion des membres', visibilite: 'membres', jour: 3));
  await db.doc('actualites/a3').set(annonce('Brouillon secret', publie: false));
  await db
      .doc('actualites/a4')
      .set(annonce('Horaires d\'hiver', epingle: true, jour: 1));
  await db
      .doc('evenements/e1')
      .set(evenement('Culte du dimanche', debut: DateTime(2026, 10, 11, 10)));
  await db
      .doc('evenements/e2')
      .set(
        evenement(
          'Soirée de prière',
          type: 'priere',
          debut: DateTime(2026, 10, 7, 19),
        ),
      );
  await db
      .doc('evenements/e3')
      .set(evenement('Culte passé', debut: DateTime(2026, 9, 27, 10)));
  await db
      .doc('evenements/e4')
      .set(
        evenement(
          'Conférence jeunesse',
          type: 'conference',
          debut: DateTime(2026, 10, 17, 14),
          inscription: true,
          placesMax: 50,
          inscrits: 12,
        ),
      );
  await db
      .doc('evenements/e5')
      .set(
        evenement(
          'Repas complet',
          type: 'evenement',
          debut: DateTime(2026, 10, 18, 12),
          inscription: true,
          placesMax: 10,
          inscrits: 10,
        ),
      );
}

/// Écran haut : tout le contenu des listes est construit.
const grand = Size(1080, 14000);

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  testWidgets('visiteur : annonces publiques, épinglée en premier, détail', (
    tester,
  ) async {
    final b = Banc();
    await semer(b);
    await lancer(tester, banc: b, taille: grand);
    expect(find.text('Horaires d\'hiver'), findsOneWidget);
    expect(find.text('Culte de louange'), findsOneWidget);
    expect(find.text('Réunion des membres'), findsNothing);
    expect(find.text('Brouillon secret'), findsNothing);
    // Épinglée avant la plus récente.
    expect(
      tester.getTopLeft(find.text('Horaires d\'hiver')).dy,
      lessThan(tester.getTopLeft(find.text('Culte de louange')).dy),
    );
    await tester.tap(find.text('Culte de louange'));
    await tester.pumpAndSettle();
    expect(find.text('Texte de Culte de louange'), findsOneWidget);
    expect(find.text('vendredi 2 octobre 2026'), findsOneWidget);
    // Visiteur abonné aux annonces publiques seulement.
    expect(b.notifications.appels, ['activer fr -']);
  });

  testWidgets('membre : aussi les annonces des membres ; en néerlandais', (
    tester,
  ) async {
    final b = Banc(connecte: true);
    await b.avecProfil();
    await semer(b);
    await lancer(tester, banc: b, taille: grand, locale: const Locale('nl'));
    expect(find.text('Réunion des membres (NL)'), findsOneWidget);
    await tester.tap(find.text('Alles bekijken'));
    await tester.pumpAndSettle();
    expect(find.text('Culte de louange (NL)'), findsOneWidget);
    expect(b.notifications.appels.last, 'activer fr u1');
  });

  testWidgets('agenda : à venir, par jour, filtre par type', (tester) async {
    final b = Banc();
    await semer(b);
    await lancer(tester, banc: b, taille: grand);
    await tester.tap(find.text('Agenda').last);
    await tester.pumpAndSettle();
    expect(find.text('Culte passé'), findsNothing);
    expect(find.text('mercredi 7 octobre 2026'), findsOneWidget);
    expect(find.text('Soirée de prière'), findsOneWidget);
    expect(find.text('Culte du dimanche'), findsOneWidget);
    expect(
      tester.getTopLeft(find.text('Soirée de prière')).dy,
      lessThan(tester.getTopLeft(find.text('Culte du dimanche')).dy),
    );
    await tester.tap(find.widgetWithText(ChoiceChip, 'Prière'));
    await tester.pumpAndSettle();
    expect(find.text('Culte du dimanche'), findsNothing);
    expect(find.text('Soirée de prière'), findsOneWidget);
  });

  testWidgets(
    'inscription : visiteur invité à se connecter, membre s\'inscrit puis annule',
    (tester) async {
      final b = Banc(connecte: true);
      await b.avecProfil();
      await semer(b);
      await lancer(tester, banc: b, taille: grand);
      await tester.tap(find.text('Agenda').last);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Conférence jeunesse'));
      await tester.pumpAndSettle();
      expect(find.text('12 inscrits sur 50 places'), findsOneWidget);
      await tester.tap(find.byTooltip('Plus'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Je m\'inscris'));
      await tester.tap(find.text('Je m\'inscris'));
      await tester.pumpAndSettle();
      final insc = await b.firestore.doc('evenements/e4/inscriptions/u1').get();
      expect(insc['personnes'], 2);
      expect(insc['nom'], 'Marie');
      expect(find.text('Inscription confirmée (2 personnes).'), findsOneWidget);
      await tester.tap(find.text('Annuler mon inscription'));
      await tester.pumpAndSettle();
      expect(
        (await b.firestore.doc('evenements/e4/inscriptions/u1').get()).exists,
        isFalse,
      );
    },
  );

  testWidgets('secrétariat : publier une annonce avec photo et notification', (
    tester,
  ) async {
    final b = await responsable({Role.secretariat});
    await lancer(tester, banc: b, taille: grand);
    await tester.tap(find.text('Responsables'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Annonces'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Nouvelle annonce'));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Titre (FR)'),
      'Baptêmes le 25 octobre',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Titre (NL)'),
      'Dopen op 25 oktober',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Texte (FR)'),
      'Inscrivez-vous auprès du pasteur.',
    );
    await tester.tap(find.text('Ajouter une photo'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Membres'));
    await tester.tap(find.text('Membres'));
    await tester.ensureVisible(find.text('Enregistrer'));
    await tester.tap(find.text('Enregistrer'));
    await tester.pumpAndSettle();

    final docs = (await b.firestore.collection('actualites').get()).docs;
    final a = docs.single.data();
    expect(a['titre'], {
      'fr': 'Baptêmes le 25 octobre',
      'nl': 'Dopen op 25 oktober',
    });
    expect(a['texte'], {'fr': 'Inscrivez-vous auprès du pasteur.'});
    expect(a['visibilite'], 'membres');
    expect(a['publie'], isTrue);
    expect(a['notifier'], isTrue);
    expect(a['publieLe'], isNotNull);
    expect(
      a['photoUrl'],
      startsWith('https://exemple.be/actualites/${docs.single.id}/'),
    );
    expect(find.text('Baptêmes le 25 octobre'), findsOneWidget);
  });

  testWidgets('secrétariat : titre obligatoire, brouillon sans notification', (
    tester,
  ) async {
    final b = await responsable({Role.secretariat});
    await lancer(tester, banc: b, taille: grand);
    await tester.tap(find.text('Responsables'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Annonces'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Nouvelle annonce'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Enregistrer'));
    await tester.tap(find.text('Enregistrer'));
    await tester.pumpAndSettle();
    expect(find.text('Ce champ est obligatoire.'), findsNWidgets(2));

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Titre (FR)'),
      'En préparation',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Texte (FR)'),
      '…',
    );
    await tester.ensureVisible(find.text('Publier'));
    await tester.tap(find.text('Publier'));
    await tester.pumpAndSettle();
    expect(find.text('Prévenir par notification'), findsNothing);
    await tester.ensureVisible(find.text('Enregistrer'));
    await tester.tap(find.text('Enregistrer'));
    await tester.pumpAndSettle();
    final a = (await b.firestore.collection('actualites').get()).docs.single
        .data();
    expect(a['publie'], isFalse);
    expect(a['notifier'], isFalse);
    expect(a.containsKey('publieLe'), isFalse);
    expect(find.text('Brouillon'), findsOneWidget);
  });

  testWidgets('secrétariat : créer un événement avec inscriptions', (
    tester,
  ) async {
    final b = await responsable({Role.admin});
    await lancer(tester, banc: b, taille: grand);
    await tester.tap(find.text('Responsables'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Agenda de l\'église'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Nouvel événement'));
    await tester.pumpAndSettle();
    // Par défaut : dimanche suivant, 10 h – 12 h.
    expect(find.text('dimanche 11 octobre 2026, 10:00'), findsOneWidget);
    expect(find.text('dimanche 11 octobre 2026, 12:00'), findsOneWidget);

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Titre (FR)'),
      'Culte de baptême',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Lieu'),
      'Vroentestraat 100, Hoegaarden',
    );
    await tester.ensureVisible(find.text('Inscriptions ouvertes'));
    await tester.tap(find.text('Inscriptions ouvertes'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Nombre de places'),
      '80',
    );
    await tester.ensureVisible(find.text('Enregistrer'));
    await tester.tap(find.text('Enregistrer'));
    await tester.pumpAndSettle();

    final e = (await b.firestore.collection('evenements').get()).docs.single
        .data();
    expect(e['titre'], {'fr': 'Culte de baptême'});
    expect(e['type'], 'culte');
    expect((e['debut'] as Timestamp).toDate(), DateTime(2026, 10, 11, 10));
    expect(e['lieu'], 'Vroentestraat 100, Hoegaarden');
    expect(e['inscription'], isTrue);
    expect(e['placesMax'], 80);
    expect(e['description'], isEmpty);
    expect(find.text('Culte de baptême'), findsOneWidget);
  });

  testWidgets('notification touchée : ouvre l\'annonce', (tester) async {
    final b = Banc();
    await semer(b);
    await lancer(tester, banc: b, taille: grand);
    b.notifications.touchees.add({'type': 'actualite', 'id': 'a1'});
    await tester.pumpAndSettle();
    expect(find.text('Texte de Culte de louange'), findsOneWidget);
  });
}
