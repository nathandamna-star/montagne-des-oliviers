import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../domain/boutique.dart';

extension LibellesBoutique on AppLocalizations {
  String statutCommande(StatutCommande s) => switch (s) {
    StatutCommande.enAttente => commandeEnAttente,
    StatutCommande.payee => commandePayee,
    StatutCommande.remise => commandeRemise,
    StatutCommande.annulee => commandeAnnulee,
  };
}

IconData iconeStatutCommande(StatutCommande s) => switch (s) {
  StatutCommande.enAttente => Icons.hourglass_top,
  StatutCommande.payee => Icons.inventory_2_outlined,
  StatutCommande.remise => Icons.check_circle,
  StatutCommande.annulee => Icons.cancel_outlined,
};
