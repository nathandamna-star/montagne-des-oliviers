import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../domain/planning.dart';

extension LibellesPlanning on AppLocalizations {
  String libelleStatutService(StatutService s) => switch (s) {
    StatutService.prevu => servicePrevu,
    StatutService.confirme => serviceConfirme,
    StatutService.indisponible => serviceIndisponible,
    StatutService.remplacement => serviceRemplacement,
  };
}

Color couleurStatutService(ColorScheme c, StatutService s) => switch (s) {
  StatutService.prevu => c.outline,
  StatutService.confirme => c.primary,
  StatutService.indisponible => c.error,
  StatutService.remplacement => c.error,
};

IconData iconeStatutService(StatutService s) => switch (s) {
  StatutService.prevu => Icons.schedule,
  StatutService.confirme => Icons.check_circle_outline,
  StatutService.indisponible => Icons.event_busy_outlined,
  StatutService.remplacement => Icons.swap_horiz,
};
