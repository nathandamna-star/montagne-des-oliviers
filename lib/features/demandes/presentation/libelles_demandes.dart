import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../domain/demande.dart';

extension LibellesDemandes on AppLocalizations {
  String libelleDemande(TypeDemande t) => switch (t) {
    TypeDemande.bapteme => demandeBapteme,
    TypeDemande.presentation => demandePresentation,
    TypeDemande.mariage => demandeMariage,
    TypeDemande.rendezvous => demandeRendezVous,
    TypeDemande.visite => demandeVisite,
  };

  String libelleStatutDemande(StatutDemande s) => switch (s) {
    StatutDemande.nouvelle => statutNouvelle,
    StatutDemande.enCours => statutEnCours,
    StatutDemande.acceptee => statutAcceptee,
    StatutDemande.refusee => statutRefusee,
    StatutDemande.terminee => statutTerminee,
  };
}

IconData iconeDemande(TypeDemande t) => switch (t) {
  TypeDemande.bapteme => Icons.water_drop_outlined,
  TypeDemande.presentation => Icons.child_care_outlined,
  TypeDemande.mariage => Icons.favorite_border,
  TypeDemande.rendezvous => Icons.event_available_outlined,
  TypeDemande.visite => Icons.home_outlined,
};

Color couleurStatutDemande(ColorScheme c, StatutDemande s) => switch (s) {
  StatutDemande.nouvelle => c.secondary,
  StatutDemande.enCours => c.primary,
  StatutDemande.acceptee => c.primary,
  StatutDemande.refusee => c.error,
  StatutDemande.terminee => c.outline,
};
