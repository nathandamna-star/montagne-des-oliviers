import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../shared/widgets/ecran_a_venir.dart';

class MediasScreen extends StatelessWidget {
  const MediasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return EcranAVenir(
      titre: l10n.navMedias,
      icone: Icons.play_circle_outline,
      texte: l10n.mediasAVenir,
    );
  }
}
