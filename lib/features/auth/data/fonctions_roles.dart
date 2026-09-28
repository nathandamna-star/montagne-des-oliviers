import 'package:cloud_functions/cloud_functions.dart';

import '../domain/role.dart';

class ErreurRoles implements Exception {
  const ErreurRoles(this.code);

  /// « refuse », « introuvable », « reseau » ou « inconnue ».
  final String code;
}

/// Cloud Functions des rôles (custom claims).
abstract interface class FonctionsRoles {
  /// Le compte dont l'e-mail a été donné au déploiement devient administrateur.
  Future<void> revendiquerAdmin();

  /// Administrateur seulement : fixe les rôles du compte [email].
  Future<void> definirRoles(String email, Set<Role> roles);
}

class FonctionsRolesFirebase implements FonctionsRoles {
  FonctionsRolesFirebase(this.fonctions);

  final FirebaseFunctions fonctions;

  Future<void> _appeler(String nom, [Object? donnees]) async {
    try {
      await fonctions.httpsCallable(nom).call<Object?>(donnees);
    } on FirebaseFunctionsException catch (e) {
      throw ErreurRoles(switch (e.code) {
        'permission-denied' || 'failed-precondition' => 'refuse',
        'not-found' => 'introuvable',
        'unavailable' || 'deadline-exceeded' => 'reseau',
        _ => 'inconnue',
      });
    }
  }

  @override
  Future<void> revendiquerAdmin() => _appeler('revendiquerAdmin');

  @override
  Future<void> definirRoles(String email, Set<Role> roles) =>
      _appeler('definirRoles', {
        'email': email.trim(),
        'roles': [for (final r in roles) r.name],
      });
}
