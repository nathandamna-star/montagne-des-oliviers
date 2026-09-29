import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:montagne_des_oliviers/features/auth/domain/role.dart';

import 'helpers.dart';

const grand = Size(1080, 6000);

Future<Banc> membre({
  Set<Role> roles = const {},
  bool intercession = true,
}) async {
  final b = Banc(connecte: true, roles: roles);
  await b.avecProfil();
  final db = b.firestore;
  if (intercession) {
    await db.doc('parametres/eglise').set({'groupeIntercessionId': 'inter'});
  }
  await db.doc('groupes/inter').set({
    'nom': 'Intercession',
    'type': 'intercession',
    'prive': true,
    'membres': ['u1', 'u2'],
    'admins': ['u1'],
  });
  return b;
}

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  testWidgets('demande de baptême depuis l\'accueil, suivi et retrait', (
    tester,
  ) async {
    final b = await membre();
    await lancer(tester, banc: b, taille: grand);
    await tester.tap(find.text('Faire une demande'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Envoyer la demande'));
    await tester.pumpAndSettle();
    expect(find.text('Choisissez le type de demande.'), findsOneWidget);
    await tester.tap(find.text('Baptême'));
    await tester.enterText(
      find.byType(TextField),
      'Disponible le dimanche après le culte',
    );
    await tester.tap(find.text('Envoyer la demande'));
    await tester.pumpAndSettle();
    final d = (await b.firestore.collection('demandes').get()).docs.single;
    expect(d['type'], 'bapteme');
    expect(d['uid'], 'u1');
    expect(d['nom'], 'Marie');
    expect(d['statut'], 'nouvelle');

    await tester.tap(find.text('Profil').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Mes demandes'));
    await tester.pumpAndSettle();
    expect(find.text('Baptême'), findsOneWidget);
    await tester.tap(find.text('Baptême'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Retirer ma demande'));
    await tester.pumpAndSettle();
    expect((await b.firestore.collection('demandes').get()).docs, isEmpty);
  });

  testWidgets('secrétariat : répondre à une demande', (tester) async {
    final b = await membre(roles: {Role.secretariat});
    await b.firestore.doc('demandes/d1').set({
      'uid': 'u9',
      'nom': 'Paul',
      'type': 'mariage',
      'message': 'Pour juin',
      'statut': 'nouvelle',
      'createdAt': Timestamp.fromDate(DateTime(2026, 10, 1)),
    });
    await b.firestore.doc('demandes/d2').set({
      'uid': 'u8',
      'nom': 'Anne',
      'type': 'visite',
      'statut': 'terminee',
      'createdAt': Timestamp.fromDate(DateTime(2026, 9, 1)),
    });
    await lancer(tester, banc: b, taille: grand);
    await tester.tap(find.text('Responsables'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Demandes'));
    await tester.pumpAndSettle();
    expect(find.text('Mariage · Paul'), findsOneWidget);
    expect(find.text('Visite à domicile · Anne'), findsNothing);
    await tester.tap(find.widgetWithText(ChoiceChip, 'Toutes'));
    await tester.pumpAndSettle();
    expect(find.text('Visite à domicile · Anne'), findsOneWidget);
    await tester.tap(find.text('Mariage · Paul'));
    await tester.pumpAndSettle();
    expect(find.text('Pour juin'), findsOneWidget);
    await tester.enterText(
      find.widgetWithText(TextField, 'Réponse à la personne'),
      'Premier entretien le 12 octobre.',
    );
    await tester.tap(find.text('Enregistrer et prévenir la personne'));
    await tester.pumpAndSettle();
    final d = await b.firestore.doc('demandes/d1').get();
    expect(d['statut'], 'en_cours');
    expect(d['reponse'], 'Premier entretien le 12 octobre.');
    expect(d['traiteePar'], 'u1');
  });

  testWidgets('sujet de prière partagé, anonyme ; l\'intercession prie', (
    tester,
  ) async {
    final b = await membre();
    await lancer(tester, banc: b, taille: grand);
    await tester.tap(find.text('Sujet de prière'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Pour la santé de ma mère');
    await tester.tap(find.text('Aussi l\'équipe d\'intercession'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Rester anonyme'));
    await tester.tap(find.text('Confier ce sujet'));
    await tester.pumpAndSettle();
    final p = (await b.firestore.collection('prieres').get()).docs.single;
    expect(p['partage'], 'intercession');
    expect(p['groupeId'], 'inter');
    expect(p['anonyme'], isTrue);
    expect(p['statut'], 'ouverte');

    // Un autre membre de l'intercession voit le sujet, sans le nom, et prie.
    await b.firestore.doc('prieres/p2').set({
      'uid': 'u2',
      'nom': 'Paul',
      'anonyme': true,
      'texte': 'Pour mon travail',
      'partage': 'intercession',
      'groupeId': 'inter',
      'statut': 'ouverte',
      'createdAt': Timestamp.fromDate(DateTime(2026, 10, 2)),
    });
    await tester.tap(find.text('Groupes').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Intercession'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Sujets de prière'));
    await tester.pumpAndSettle();
    expect(find.text('Pour mon travail'), findsOneWidget);
    expect(find.textContaining('Paul'), findsNothing);
    await tester.tap(find.text('Pour mon travail'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('J\'ai prié'));
    await tester.pumpAndSettle();
    expect(
      (await b.firestore.doc('prieres/p2/priants/u1').get()).exists,
      isTrue,
    );
    expect(find.text('Vous avez prié. Merci !'), findsOneWidget);
  });

  testWidgets('sans groupe d\'intercession : pasteurs seulement ; exaucement', (
    tester,
  ) async {
    final b = await membre(intercession: false);
    await b.firestore.doc('prieres/p1').set({
      'uid': 'u1',
      'nom': 'Marie',
      'anonyme': false,
      'texte': 'Pour un emploi',
      'partage': 'pasteurs',
      'groupeId': null,
      'statut': 'ouverte',
      'nbPrieres': 3,
      'createdAt': Timestamp.fromDate(DateTime(2026, 10, 1)),
    });
    await lancer(tester, banc: b, taille: grand);
    await tester.tap(find.text('Profil').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Mes sujets de prière'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Nouveau sujet de prière'));
    await tester.pumpAndSettle();
    expect(
      find.text('Pas encore de groupe d\'intercession désigné par l\'église.'),
      findsOneWidget,
    );
    await tester.tap(find.byTooltip('Retour'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Pour un emploi'));
    await tester.pumpAndSettle();
    expect(find.text('3 personnes ont prié'), findsOneWidget);
    expect(find.text('J\'ai prié'), findsNothing);
    await tester.tap(find.text('Ma prière est exaucée !'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'J\'ai trouvé un travail !');
    await tester.tap(find.text('Valider'));
    await tester.pumpAndSettle();
    final p = await b.firestore.doc('prieres/p1').get();
    expect(p['statut'], 'exaucee');
    expect(p['temoignage'], 'J\'ai trouvé un travail !');
    expect(find.text('Prière exaucée'), findsOneWidget);
  });

  testWidgets('pasteur : paramètres de l\'église et liens sur l\'accueil', (
    tester,
  ) async {
    final b = await membre(roles: {Role.admin}, intercession: false);
    await lancer(tester, banc: b, taille: grand);
    // Chaîne de l'église par défaut.
    expect(find.text('YouTube'), findsOneWidget);
    await tester.tap(find.text('Responsables'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Paramètres de l\'église'));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(DropdownButtonFormField<String?>).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Intercession').last);
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Chaîne YouTube'),
      'https://www.youtube.com/@montagnedesoliviers',
    );
    await tester.tap(find.text('Enregistrer'));
    await tester.pumpAndSettle();
    final p = await b.firestore.doc('parametres/eglise').get();
    expect(p['groupeIntercessionId'], 'inter');
    expect(p['youtubeUrl'], 'https://www.youtube.com/@montagnedesoliviers');
    await tester.tap(find.text('Accueil').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('YouTube'));
    expect(b.lanceur.ouverts.single.host, 'www.youtube.com');
  });
}
