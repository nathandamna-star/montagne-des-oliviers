import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/auth/auth_providers.dart';
import '../features/auth/domain/role.dart';

/// Vrai si la personne connectée a au moins un rôle de responsable
/// (administrateur, secrétariat, trésorier). Les responsables de groupe
/// s'ajouteront avec le module Groupes.
final estResponsableProvider = Provider<bool>(
  (ref) => ref.watch(rolesProvider).isNotEmpty,
);

final estAdminProvider = Provider<bool>(
  (ref) => ref.watch(rolesProvider).contains(Role.admin),
);

/// Secrétariat ou administrateur : actualités, agenda, membres, salles.
final estSecretariatProvider = Provider<bool>((ref) {
  final roles = ref.watch(rolesProvider);
  return roles.contains(Role.secretariat) || roles.contains(Role.admin);
});

/// Trésorier ou administrateur : dons, relevés, coordonnées bancaires.
final estTresorierProvider = Provider<bool>((ref) {
  final roles = ref.watch(rolesProvider);
  return roles.contains(Role.tresorier) || roles.contains(Role.admin);
});

/// Boutique de livres : trésorier, secrétariat ou administrateur.
final gereBoutiqueProvider = Provider<bool>(
  (ref) => ref.watch(estTresorierProvider) || ref.watch(estSecretariatProvider),
);
