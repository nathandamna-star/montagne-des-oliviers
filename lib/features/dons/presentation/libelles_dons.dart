import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../domain/don.dart';

extension LibellesDons on AppLocalizations {
  String affectation(Affectation a) => switch (a) {
    Affectation.dime => affectationDime,
    Affectation.offrande => affectationOffrande,
    Affectation.mission => affectationMission,
    Affectation.construction => affectationConstruction,
    Affectation.loyer => affectationLoyer,
    Affectation.entraide => affectationEntraide,
  };

  String statutDon(StatutDon s) => switch (s) {
    StatutDon.enAttente => donEnAttente,
    StatutDon.recu => donRecu,
    StatutDon.annule => donAnnule,
  };

  String modeDon(ModeDon m) => switch (m) {
    ModeDon.virement => modeVirement,
    ModeDon.enLigne => modeEnLigne,
    ModeDon.mensuel => modeMensuel,
  };
}

IconData iconeStatutDon(StatutDon s) => switch (s) {
  StatutDon.enAttente => Icons.hourglass_top,
  StatutDon.recu => Icons.check_circle,
  StatutDon.annule => Icons.cancel_outlined,
};
