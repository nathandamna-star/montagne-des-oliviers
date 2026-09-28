import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../shared/widgets/ecran_a_venir.dart';

class ResponsablesScreen extends StatelessWidget {
  const ResponsablesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return EcranAVenir(
      titre: l10n.navResponsables,
      icone: Icons.admin_panel_settings_outlined,
      texte: l10n.responsablesAVenir,
    );
  }
}
