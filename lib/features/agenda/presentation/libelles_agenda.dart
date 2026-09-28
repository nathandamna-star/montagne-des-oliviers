import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../domain/evenement.dart';

extension LibellesAgenda on AppLocalizations {
  String libelleType(TypeEvenement t) => switch (t) {
    TypeEvenement.culte => typeCulte,
    TypeEvenement.priere => typePriere,
    TypeEvenement.jeune => typeJeune,
    TypeEvenement.cellule => typeCellule,
    TypeEvenement.evenement => typeEvenement,
    TypeEvenement.conference => typeConference,
  };
}

IconData iconeType(TypeEvenement t) => switch (t) {
  TypeEvenement.culte => Icons.church_outlined,
  TypeEvenement.priere => Icons.volunteer_activism_outlined,
  TypeEvenement.jeune => Icons.no_food_outlined,
  TypeEvenement.cellule => Icons.home_outlined,
  TypeEvenement.evenement => Icons.celebration_outlined,
  TypeEvenement.conference => Icons.mic_none_outlined,
};
