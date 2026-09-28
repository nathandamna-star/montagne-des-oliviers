import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'data/auth_repository.dart';
import 'data/connexion_google.dart';
import 'data/fonctions_roles.dart';
import 'domain/role.dart';
import 'domain/utilisateur.dart';

final firebaseAuthProvider = Provider<FirebaseAuth>(
  (ref) => FirebaseAuth.instance,
);

final firestoreProvider = Provider<FirebaseFirestore>(
  (ref) => FirebaseFirestore.instance,
);

final connexionFournisseursProvider = Provider<ConnexionFournisseurs>(
  (ref) => ConnexionFournisseursNative(),
);

final fonctionsRolesProvider = Provider<FonctionsRoles>(
  (ref) => FonctionsRolesFirebase(
    FirebaseFunctions.instanceFor(region: 'europe-west1'),
  ),
);

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepository(
    auth: ref.watch(firebaseAuthProvider),
    firestore: ref.watch(firestoreProvider),
    fournisseurs: ref.watch(connexionFournisseursProvider),
  ),
);

/// Utilisateur connecté (null sinon). Suit aussi le rafraîchissement du jeton,
/// pour voir un rôle dès qu'il est attribué.
final utilisateurFirebaseProvider = StreamProvider<User?>((ref) async* {
  final auth = ref.watch(firebaseAuthProvider);
  yield auth.currentUser;
  yield* auth.idTokenChanges();
});

final estConnecteProvider = Provider<bool>(
  (ref) => ref.watch(utilisateurFirebaseProvider).value != null,
);

/// Rôles lus dans le jeton (custom claims).
final rolesFutureProvider = FutureProvider<Set<Role>>((ref) async {
  final user = ref.watch(utilisateurFirebaseProvider).value;
  if (user == null) return const {};
  final jeton = await user.getIdTokenResult();
  return Role.depuisClaims(jeton.claims);
});

final rolesProvider = Provider<Set<Role>>(
  (ref) => ref.watch(rolesFutureProvider).value ?? const {},
);

/// Profil Firestore de la personne connectée (null : pas encore créé).
final profilProvider = StreamProvider<Utilisateur?>((ref) {
  final user = ref.watch(utilisateurFirebaseProvider).value;
  if (user == null) return Stream.value(null);
  return ref
      .watch(firestoreProvider)
      .collection('users')
      .doc(user.uid)
      .snapshots()
      .map((doc) => doc.exists ? Utilisateur.depuisFirestore(doc) : null);
});

/// Connecté mais sans profil : il faut encore donner son consentement.
final profilManquantProvider = Provider<bool>((ref) {
  if (!ref.watch(estConnecteProvider)) return false;
  final profil = ref.watch(profilProvider);
  return profil.hasValue && profil.value == null;
});
