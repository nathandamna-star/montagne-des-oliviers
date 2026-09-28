import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:montagne_des_oliviers/app.dart';
import 'package:montagne_des_oliviers/core/roles.dart';

/// Lance l'app dans une taille d'écran donnée (téléphone par défaut).
Future<void> lancer(
  WidgetTester tester, {
  Locale locale = const Locale('fr'),
  bool responsable = false,
  Size taille = const Size(1080, 2400),
}) async {
  tester.view.physicalSize = taille;
  tester.view.devicePixelRatio = 2.5;
  addTearDown(tester.view.reset);
  tester.platformDispatcher.localesTestValue = [locale];
  addTearDown(tester.platformDispatcher.clearLocalesTestValue);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [estResponsableProvider.overrideWithValue(responsable)],
      child: const MontagneDesOliviersApp(),
    ),
  );
  await tester.pumpAndSettle();
}
