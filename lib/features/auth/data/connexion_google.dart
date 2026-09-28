import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../core/firebase/firebase_options.dart';
import '../domain/erreur_auth.dart';

/// Connexion Google et Apple. Isolé derrière une interface pour pouvoir le
/// remplacer dans les tests.
abstract interface class ConnexionFournisseurs {
  Future<UserCredential> google(FirebaseAuth auth);
  Future<UserCredential> apple(FirebaseAuth auth);
  Future<void> deconnecterGoogle();
}

class ConnexionFournisseursNative implements ConnexionFournisseurs {
  Future<void>? _initialisation;

  Future<void> _initialiserGoogle() =>
      _initialisation ??= GoogleSignIn.instance.initialize(
        clientId: defaultTargetPlatform == TargetPlatform.iOS
            ? googleIosClientId
            : null,
        serverClientId: googleServerClientId,
      );

  @override
  Future<UserCredential> google(FirebaseAuth auth) async {
    // Sur le site web : fenêtre Google fournie par Firebase.
    if (kIsWeb) return auth.signInWithPopup(GoogleAuthProvider());
    await _initialiserGoogle();
    try {
      final compte = await GoogleSignIn.instance.authenticate();
      final idToken = compte.authentication.idToken;
      if (idToken == null) throw const ExceptionAuth(ErreurAuth.inconnue);
      return await auth.signInWithCredential(
        GoogleAuthProvider.credential(idToken: idToken),
      );
    } on GoogleSignInException catch (e) {
      throw ExceptionAuth(
        e.code == GoogleSignInExceptionCode.canceled
            ? ErreurAuth.annule
            : ErreurAuth.inconnue,
      );
    }
  }

  @override
  Future<UserCredential> apple(FirebaseAuth auth) {
    final provider = AppleAuthProvider()
      ..addScope('email')
      ..addScope('name');
    return auth.signInWithProvider(provider);
  }

  @override
  Future<void> deconnecterGoogle() async {
    if (kIsWeb) return;
    await _initialiserGoogle();
    await GoogleSignIn.instance.signOut();
  }
}
