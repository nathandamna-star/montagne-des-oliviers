/// Rôles de l'église, attribués par une Cloud Function (custom claims),
/// jamais par l'app. Le responsable d'un groupe n'est pas un rôle global :
/// il est enregistré dans le groupe lui-même.
enum Role {
  /// Pasteur / administrateur : tout, y compris l'attribution des rôles.
  admin,

  /// Secrétariat : fichier des membres, salles, demandes, plannings.
  secretariat,

  /// Trésorier : dîmes, offrandes et relevés.
  tresorier;

  /// Rôles présents dans les claims du jeton Firebase.
  static Set<Role> depuisClaims(Map<String, dynamic>? claims) => {
    for (final r in values)
      if (claims?[r.name] == true) r,
  };
}
