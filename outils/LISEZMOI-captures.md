# Captures d'écran pour l'App Store

1. Copier `captures_stores_test.dart.txt` en `test/zz_captures_test.dart`.
2. `flutter test test/zz_captures_test.dart --update-goldens --dart-define=SORTIE=<dossier>` : images
   iPhone 6,9" (1320 × 2868), iPhone 6,3" (1206 × 2622), Android (1080 × 1920) et iPad 13" (2048 × 2732), mode iPhone (pas de dons), contenus d'exemple
   (annonces, agenda, prédications, groupe de louange).
3. Supprimer le fichier de test.
