import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../domain/erreur_auth.dart';
import 'connexion_google.dart';

/// Connexion, inscription et création du profil `users/{uid}`.
class AuthRepository {
  AuthRepository({
    required this.auth,
    required this.firestore,
    required this.fournisseurs,
  });

  final FirebaseAuth auth;
  final FirebaseFirestore firestore;
  final ConnexionFournisseurs fournisseurs;

  Future<void> connexionEmail({
    required String email,
    required String motDePasse,
  }) => _executer(() async {
    await auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: motDePasse,
    );
  });

  /// Crée le compte et le profil. Le consentement a été donné explicitement
  /// (case cochée) : il est daté par le serveur dans le profil.
  Future<void> inscriptionEmail({
    required String nom,
    required String email,
    required String motDePasse,
    required String langue,
  }) => _executer(() async {
    final cred = await auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: motDePasse,
    );
    await cred.user!.updateDisplayName(nom.trim());
    await _creerProfil(cred.user!, nom: nom, langue: langue);
  });

  /// Google ou Apple. Le profil est créé ensuite, après le consentement
  /// (écran « Bienvenue dans la famille »), s'il n'existe pas encore.
  Future<void> connexionGoogle() => _executer(() => fournisseurs.google(auth));

  Future<void> connexionApple() => _executer(() => fournisseurs.apple(auth));

  /// Profil d'un compte Google ou Apple, après consentement.
  Future<void> completerProfil({required String nom, required String langue}) =>
      _executer(() async {
        final user = auth.currentUser;
        if (user == null) return;
        await _creerProfil(user, nom: nom, langue: langue);
      });

  Future<void> _creerProfil(
    User user, {
    required String nom,
    required String langue,
  }) => firestore.collection('users').doc(user.uid).set({
    'nom': nom.trim(),
    'email': user.email ?? '',
    'langue': langue,
    'consentementLe': FieldValue.serverTimestamp(),
    'createdAt': FieldValue.serverTimestamp(),
  });

  /// Nom, langue (des notifications) ou photo du profil.
  Future<void> modifierProfil(
    String uid, {
    String? nom,
    String? langue,
    String? photoUrl,
  }) => firestore.collection('users').doc(uid).update({
    'nom': ?nom?.trim(),
    'langue': ?langue,
    'photoUrl': ?photoUrl,
  });

  Future<void> motDePasseOublie(String email) =>
      _executer(() => auth.sendPasswordResetEmail(email: email.trim()));

  /// Recharge le jeton pour voir un rôle attribué par le serveur.
  Future<void> rafraichirJeton() async {
    await auth.currentUser?.getIdToken(true);
  }

  Future<void> deconnexion() async {
    await fournisseurs.deconnecterGoogle().catchError((_) {});
    await auth.signOut();
  }

  Future<void> _executer(Future<void> Function() action) async {
    try {
      await action();
    } on FirebaseAuthException catch (e) {
      throw ExceptionAuth(ErreurAuth.depuisCode(e.code));
    } on FirebaseException catch (e) {
      throw ExceptionAuth(
        e.code == 'unavailable' ? ErreurAuth.reseau : ErreurAuth.inconnue,
      );
    }
  }
}
