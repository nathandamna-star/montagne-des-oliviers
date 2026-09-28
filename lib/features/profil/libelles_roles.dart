import '../../l10n/app_localizations.dart';
import '../auth/domain/role.dart';

extension LibellesRoles on AppLocalizations {
  String libelleRole(Role r) => switch (r) {
    Role.admin => roleAdmin,
    Role.secretariat => roleSecretariat,
    Role.tresorier => roleTresorier,
  };
}
