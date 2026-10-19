import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/app_localizations.dart';
import '../../../shared/format_date.dart';
import '../domain/signalement.dart';
import '../groupes_providers.dart';

/// Messages de groupe signalés (secrétariat et pasteurs) : effacer le message
/// ou classer le signalement.
class SignalementsScreen extends ConsumerWidget {
  const SignalementsScreen({super.key});

  Future<void> _agir(
    BuildContext context,
    WidgetRef ref,
    Future<void> Function() action,
  ) async {
    final l10n = AppLocalizations.of(context);
    final messager = ScaffoldMessenger.of(context);
    try {
      await action();
    } catch (_) {
      messager.showSnackBar(SnackBar(content: Text(l10n.erreurInconnue)));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final liste =
        ref.watch(signalementsProvider).value ?? const <Signalement>[];
    final depot = ref.read(groupesRepositoryProvider);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.signalements)),
      body: liste.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Text(
                  l10n.aucunSignalement,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                for (final s in liste)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${s.auteurNom} · ${s.groupeNom}',
                            style: theme.textTheme.titleSmall,
                          ),
                          if (s.createdAt != null)
                            Text(
                              context.dateCourte(s.createdAt!),
                              style: theme.textTheme.labelSmall,
                            ),
                          const SizedBox(height: 8),
                          Text(s.extrait),
                          if (s.motif.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Text(
                              l10n.motifDuSignalement(s.motif),
                              style: theme.textTheme.bodySmall?.copyWith(
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            children: [
                              FilledButton.tonalIcon(
                                onPressed: () => _agir(
                                  context,
                                  ref,
                                  () => depot.effacerMessageSignale(s),
                                ),
                                icon: const Icon(Icons.delete_outline),
                                label: Text(l10n.effacerLeMessage),
                              ),
                              TextButton(
                                onPressed: () => _agir(
                                  context,
                                  ref,
                                  () => depot.classerSignalement(s.id),
                                ),
                                child: Text(l10n.classerSignalement),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
    );
  }
}
