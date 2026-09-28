import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/routes.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/format_date.dart';
import '../domain/rencontre.dart';
import '../groupes_providers.dart';
import 'libelles_groupes.dart';

/// Rendez-vous d'un groupe dans une liste.
class CarteRencontre extends ConsumerWidget {
  const CarteRencontre({super.key, required this.rencontre});

  final Rencontre rencontre;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final r = rencontre;
    final noms = ref.watch(annuaireProvider).value ?? const {};
    final details = [
      '${context.dateLongue(r.debut)}, ${context.heure(r.debut)}',
      if (r.lieu.isNotEmpty) r.lieu,
    ].join(' · ');
    return Card(
      child: ListTile(
        leading: Icon(
          iconeRencontre(r.type),
          color: theme.colorScheme.secondary,
        ),
        title: Text(r.titre),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(details),
            if (r.type == TypeRencontre.moderation && r.moderateur != null)
              Text(
                r.remplacementDemande
                    ? l10n.remplacantRecherche(noms[r.moderateur] ?? '')
                    : l10n.moderePar(noms[r.moderateur] ?? ''),
                style: TextStyle(
                  color: r.remplacementDemande
                      ? theme.colorScheme.error
                      : theme.colorScheme.primary,
                ),
              ),
          ],
        ),
        isThreeLine: r.type == TypeRencontre.moderation && r.moderateur != null,
        trailing: const Icon(Icons.chevron_right),
        onTap: () => context.push(Routes.rencontre(r.groupeId, r.id)),
      ),
    );
  }
}
