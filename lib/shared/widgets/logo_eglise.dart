import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';

/// Logo de l'église, sur un disque blanc.
class LogoEglise extends StatelessWidget {
  const LogoEglise({super.key, this.taille = 72});

  final double taille;

  @override
  Widget build(BuildContext context) => ClipOval(
    child: Image.asset(
      'assets/images/logo.png',
      width: taille,
      height: taille,
      semanticLabel: AppLocalizations.of(context).nomEglise,
    ),
  );
}
