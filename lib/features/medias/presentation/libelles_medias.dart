import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../domain/media.dart';

extension LibellesMedias on AppLocalizations {
  String rubrique(Rubrique r) => switch (r) {
    Rubrique.predication => rubriquePredications,
    Rubrique.enseignement => rubriqueEnseignements,
    Rubrique.podcast => rubriquePodcasts,
  };

  String themeMedia(ThemeMedia t) => switch (t) {
    ThemeMedia.repentance => themeRepentance,
    ThemeMedia.delivrance => themeDelivrance,
    ThemeMedia.guerison => themeGuerison,
    ThemeMedia.combatSpirituel => themeCombatSpirituel,
    ThemeMedia.liensFamille => themeLiensFamille,
    ThemeMedia.foi => themeFoi,
    ThemeMedia.priere => themePriere,
    ThemeMedia.mariage => themeMariage,
    ThemeMedia.bapteme => themeBapteme,
    ThemeMedia.autre => themeAutre,
  };
}

IconData iconeRubrique(Rubrique r) => switch (r) {
  Rubrique.predication => Icons.record_voice_over_outlined,
  Rubrique.enseignement => Icons.school_outlined,
  Rubrique.podcast => Icons.podcasts,
};
