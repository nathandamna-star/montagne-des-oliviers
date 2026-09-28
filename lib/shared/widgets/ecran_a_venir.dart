import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';

/// Écran provisoire d'un module pas encore construit.
class EcranAVenir extends StatelessWidget {
  const EcranAVenir({
    super.key,
    required this.titre,
    required this.icone,
    required this.texte,
  });

  final String titre;
  final IconData icone;
  final String texte;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(titre)),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Column(
              children: [
                Icon(icone, size: 56, color: theme.colorScheme.primary),
                const SizedBox(height: 16),
                Text(l10n.bientot, style: theme.textTheme.headlineSmall),
                const SizedBox(height: 8),
                Text(
                  texte,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
