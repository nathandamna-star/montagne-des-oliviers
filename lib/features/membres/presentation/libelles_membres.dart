import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../domain/membre.dart';

extension LibellesMembres on AppLocalizations {
  String libelleStatut(StatutMembre s) => switch (s) {
    StatutMembre.visiteur => statutVisiteur,
    StatutMembre.membre => statutMembre,
    StatutMembre.actif => statutActif,
  };

  List<String> get entetesCsv => [
    champNomFamille,
    champPrenom,
    champStatut,
    champEmail,
    champTelephone,
    champRue,
    champCodePostal,
    champVille,
    champDateNaissance,
    champFamille,
    champArrivee,
    champBapteme,
    champPresentation,
    champMariage,
    champServices,
    champNotes,
  ];
}

Color couleurStatut(ColorScheme c, StatutMembre s) => switch (s) {
  StatutMembre.visiteur => c.outline,
  StatutMembre.membre => c.primary,
  StatutMembre.actif => c.secondary,
};
