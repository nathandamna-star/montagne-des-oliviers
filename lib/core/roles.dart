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
