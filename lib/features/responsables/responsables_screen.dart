import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/roles.dart';
import '../../core/router/routes.dart';
import '../../l10n/app_localizations.dart';

/// Espace Responsables : chaque module d'administration s'y ajoutera.
class ResponsablesScreen extends ConsumerWidget {
  const ResponsablesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.navResponsables)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (ref.watch(estSecretariatProvider)) ...[
            Card(
              child: ListTile(
                leading: const Icon(Icons.campaign_outlined),
                title: Text(l10n.annonces),
                subtitle: Text(l10n.annoncesSousTitre),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push(Routes.gestionActualites),
              ),
            ),
            Card(
              child: ListTile(
                leading: const Icon(Icons.event_note_outlined),
                title: Text(l10n.gestionAgenda),
                subtitle: Text(l10n.gestionAgendaSousTitre),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push(Routes.gestionAgenda),
              ),
            ),
          ],
          if (ref.watch(estAdminProvider))
            Card(
              child: ListTile(
                leading: const Icon(Icons.manage_accounts_outlined),
                title: Text(l10n.rolesTitre),
                subtitle: Text(l10n.rolesSousTitre),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push(Routes.roles),
              ),
            ),
          const SizedBox(height: 16),
          Text(
            l10n.responsablesAVenir,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
