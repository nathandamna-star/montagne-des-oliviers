import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/routes.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/domain_traduction.dart';
import '../../../shared/format_date.dart';
import '../../../shared/widgets/etat_vide.dart';
import '../../actualites/actualites_providers.dart';

/// Secrétariat : toutes les annonces (publiées et brouillons).
class GestionActualitesScreen extends ConsumerWidget {
  const GestionActualitesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final actualites = ref.watch(toutesActualitesProvider);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.annonces)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(Routes.editerActualite('nouvelle')),
        icon: const Icon(Icons.add),
        label: Text(l10n.nouvelleAnnonce),
      ),
      body: actualites.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) =>
            EtatVide(icone: Icons.cloud_off, texte: l10n.erreurChargement),
        data: (liste) => liste.isEmpty
            ? EtatVide(
                icone: Icons.campaign_outlined,
                texte: l10n.aucuneAnnonce,
              )
            : ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
                children: [
                  for (final a in liste)
                    Card(
                      child: ListTile(
                        leading: Icon(
                          a.epingle ? Icons.push_pin : Icons.campaign_outlined,
                        ),
                        title: Text(Traduction.dans(a.titre, context.langue)),
                        subtitle: Text(
                          a.publie
                              ? l10n.publieeLe(
                                  a.publieLe == null
                                      ? ''
                                      : context.dateCourte(a.publieLe!),
                                )
                              : l10n.brouillon,
                          style: a.publie
                              ? null
                              : TextStyle(color: theme.colorScheme.error),
                        ),
                        trailing: const Icon(Icons.edit_outlined),
                        onTap: () => context.push(Routes.editerActualite(a.id)),
                      ),
                    ),
                ],
              ),
      ),
    );
  }
}
