// Configuration du projet Firebase « montagne-des-oliviers ».
// Ces valeurs ne sont pas secrètes : elles identifient le projet et figurent
// de toute façon dans l'app publiée. La sécurité repose sur les règles
// Firestore et Storage (dossier firebase/).
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

abstract final class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    return switch (defaultTargetPlatform) {
      TargetPlatform.iOS => ios,
      TargetPlatform.android => android,
      _ => throw UnsupportedError('Plateforme non prise en charge.'),
    };
  }

  static const web = FirebaseOptions(
    apiKey: 'AIzaSyDpxEU6btfT8PxfXIVTqIYFracQRhrOF80',
    appId: '1:137354564124:web:9e4f4c7dc3f7e68ff445d9',
    messagingSenderId: '137354564124',
    projectId: 'montagne-des-oliviers',
    authDomain: 'montagne-des-oliviers.firebaseapp.com',
    storageBucket: 'montagne-des-oliviers.firebasestorage.app',
  );

  static const android = FirebaseOptions(
    apiKey: 'AIzaSyC8X8z2FMLJGOLnV_0tPuKTxamuzygs0rU',
    appId: '1:137354564124:android:55fb8d3bf481ed31f445d9',
    messagingSenderId: '137354564124',
    projectId: 'montagne-des-oliviers',
    storageBucket: 'montagne-des-oliviers.firebasestorage.app',
  );

  static const ios = FirebaseOptions(
    apiKey: 'AIzaSyCi9P2rMO8crUTg2f_XwYQG58eDn5FGWSQ',
    appId: '1:137354564124:ios:1a77971fb31aa4baf445d9',
    messagingSenderId: '137354564124',
    projectId: 'montagne-des-oliviers',
    storageBucket: 'montagne-des-oliviers.firebasestorage.app',
    iosClientId: googleIosClientId,
    iosBundleId: 'be.montagnedesoliviers.app',
  );
}

/// Identifiant « client Web » OAuth (client_type 3), requis pour Google sur Android.
const String googleServerClientId =
    '137354564124-id09em24huh2isghrtuhgccia6qjv8lm.apps.googleusercontent.com';

/// Identifiant « client iOS » OAuth ; son schéma inversé est déclaré dans
/// ios/Runner/Info.plist (CFBundleURLSchemes) pour le retour de Google.
const String googleIosClientId =
    '137354564124-ikj82lce4pqedun2ceclvlrl4q7pi66s.apps.googleusercontent.com';
