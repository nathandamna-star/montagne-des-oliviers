import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../domain/fete.dart';

extension LibellesDivers on AppLocalizations {
  String libelleFete(TypeFete t) => switch (t) {
    TypeFete.anniversaire => feteAnniversaire,
    TypeFete.naissance => feteNaissance,
    TypeFete.mariage => feteMariage,
    TypeFete.fete => feteFete,
    TypeFete.autre => feteAutre,
  };

  String libelleApport(Apport a) => switch (a) {
    Apport.nourriture => apportNourriture,
    Apport.gateau => apportGateau,
    Apport.boisson => apportBoisson,
    Apport.autre => apportAutre,
  };
}

IconData iconeFete(TypeFete t) => switch (t) {
  TypeFete.anniversaire => Icons.cake_outlined,
  TypeFete.naissance => Icons.child_friendly_outlined,
  TypeFete.mariage => Icons.favorite_border,
  TypeFete.fete => Icons.celebration_outlined,
  TypeFete.autre => Icons.event_outlined,
};

IconData iconeApport(Apport a) => switch (a) {
  Apport.nourriture => Icons.restaurant_outlined,
  Apport.gateau => Icons.cake_outlined,
  Apport.boisson => Icons.local_drink_outlined,
  Apport.autre => Icons.shopping_bag_outlined,
};
