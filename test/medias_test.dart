import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:montagne_des_oliviers/features/auth/domain/role.dart';
import 'package:montagne_des_oliviers/features/medias/diffusion_whatsapp.dart';
import 'package:montagne_des_oliviers/features/medias/domain/media.dart';

import 'helpers.dart';

const grand = Size(1080, 6000);

Map<String, dynamic> media(
  String titre, {
  String type = 'audio',
  String visibilite = 'public',
  int jour = 4,
  String? url,
}) => {
  'type': type,
  'titre': {'fr': titre},
  'description': {'fr': 'Description de $titre'},
  'predicateur': 'Pasteur Jean',
  'date': Timestamp.fromDate(DateTime(2026, 10, jour, 10)),
  'url': url ?? 'https://exemple.be/$titre.m4a',
  'visibilite': visibilite,
  'publie': true,
};

Future<void> semer(Banc b) async {
  final db = b.firestore;
  await db.doc('medias/m1').set(media('La foi qui déplace'));
  await db
      .doc('medias/m2')
      .set(
        media(
          'Culte en vidéo',
          type: 'video',
          jour: 3,
          url: 'https://exemple.be/v.mp4',
        ),
      );
  await db
      .doc('medias/m3')
      .set(media('Réservé aux membres', visibilite: 'membres', jour: 2));
  await db
      .doc('medias/d1')
      .set(
        media(
          'Culte du dimanche',
          type: 'direct',
          jour: 11,
          url: 'https://www.youtube.com/live/abc',
        ),
      );
  await db.doc('versets/v1').set({
    'reference': 'Jean 3:16',
    'texte': {'fr': 'Car Dieu a tant aimé le monde'},
    'ordre': 1,
  });
}

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  test('verset du jour : un par jour, en boucle', () {
    final v = [
      for (var i = 1; i <= 3; i++)
        Verset(id: 'v$i', reference: 'R$i', texte: const {}, ordre: i),
    ];
    final a = versetDuJour(v, DateTime(2026, 10, 5))!;
    final b = versetDuJour(v, DateTime(2026, 10, 6))!;
    final c = versetDuJour(v, DateTime(2026, 10, 8))!;
    expect(a.id, isNot(b.id));
    expect(c.id, a.id);
    expect(versetDuJour(const [], DateTime(2026)), isNull);
  });

  test('message WhatsApp prêt', () {
    expect(
      DiffusionParLien.message(
        'La foi',
        'Exhortation',
        Uri.parse('https://x.be/m/1'),
      ),
      'La foi\n\nExhortation\n\nhttps://x.be/m/1',
    );
  });

  testWidgets('visiteur : verset, direct, prédications publiques, filtre', (
    tester,
  ) async {
    final b = Banc();
    await semer(b);
    await lancer(tester, banc: b, taille: grand);
    expect(find.text('« Car Dieu a tant aimé le monde »'), findsOneWidget);
    await tester.tap(find.text('Médias').last);
    await tester.pumpAndSettle();
    expect(find.text('Culte du dimanche'), findsOneWidget);
    await tester.tap(find.text('Regarder le direct'));
    expect(
      b.lanceur.ouverts.single.toString(),
      'https://www.youtube.com/live/abc',
    );
    expect(find.text('La foi qui déplace'), findsOneWidget);
    expect(find.text('Culte en vidéo'), findsOneWidget);
    expect(find.text('Réservé aux membres'), findsNothing);
    await tester.tap(find.widgetWithText(ChoiceChip, 'Vidéos'));
    await tester.pumpAndSettle();
    expect(find.text('La foi qui déplace'), findsNothing);
  });

  testWidgets('prédication : lecteur audio et envoi sur WhatsApp', (
    tester,
  ) async {
    final b = Banc();
    await semer(b);
    await lancer(tester, banc: b, taille: grand);
    await tester.tap(find.text('Médias').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('La foi qui déplace'));
    await tester.pumpAndSettle();
    expect(
      find.text('audio:https://exemple.be/La foi qui déplace.m4a'),
      findsOneWidget,
    );
    await tester.tap(find.text('Envoyer sur WhatsApp'));
    final lien = b.lanceur.ouverts.single;
    expect(lien.host, 'wa.me');
    expect(
      lien.queryParameters['text'],
      contains('https://montagne-des-oliviers.web.app/m/m1'),
    );
    expect(lien.queryParameters['text'], startsWith('La foi qui déplace'));
  });

  testWidgets('membre : aussi les prédications réservées aux membres', (
    tester,
  ) async {
    final b = Banc(connecte: true);
    await b.avecProfil();
    await semer(b);
    await lancer(tester, banc: b, taille: grand);
    await tester.tap(find.text('Médias').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Réservé aux membres'));
    await tester.pumpAndSettle();
    // Réservé aux membres : pas de page web publique, donc pas de partage.
    expect(find.text('Envoyer sur WhatsApp'), findsNothing);
  });

  testWidgets(
    'secrétariat : publier une exhortation audio et ajouter un verset',
    (tester) async {
      final b = Banc(connecte: true, roles: {Role.secretariat});
      await b.avecProfil();
      await lancer(tester, banc: b, taille: grand);
      await tester.tap(find.text('Responsables'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Médias').first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Nouveau média'));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Titre (FR)'),
        'Tenir ferme',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Prédicateur'),
        'Pasteur Jean',
      );
      await tester.tap(find.text('Enregistrer'));
      await tester.pumpAndSettle();
      expect(
        find.text('Envoyez un fichier ou indiquez un lien.'),
        findsOneWidget,
      );
      await tester.tap(find.text('Choisir un fichier'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Enregistrer'));
      await tester.pumpAndSettle();
      final m = (await b.firestore.collection('medias').get()).docs.single
          .data();
      expect(m['type'], 'audio');
      expect(m['titre'], {'fr': 'Tenir ferme'});
      expect(m['url'], startsWith('https://exemple.be/medias/'));
      expect(m['notifier'], isTrue);
      expect(m['publie'], isTrue);

      await tester.tap(find.text('Versets du jour'));
      await tester.pumpAndSettle();
      // Le message « Enregistré » recouvre le bas de l'écran quelques secondes.
      ScaffoldMessenger.of(tester.element(find.text('Versets du jour')))
          .clearSnackBars();
      await tester.pumpAndSettle();
      await tester.tap(find.text('Ajouter un verset'));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.widgetWithText(TextField, 'Référence'),
        'Psaume 23:1',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Texte (FR)'),
        'L\'Éternel est mon berger',
      );
      await tester.tap(find.text('Enregistrer'));
      await tester.pumpAndSettle();
      final v = (await b.firestore.collection('versets').get()).docs.single
          .data();
      expect(v['reference'], 'Psaume 23:1');
      expect(v['ordre'], 1);
    },
  );
}
