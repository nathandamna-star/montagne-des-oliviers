import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/routes.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/etat_vide.dart';
import '../groupes_providers.dart';
import 'libelles_groupes.dart';

/// Secrétariat : tous les groupes de l'église.
class GestionGroupesScreen extends ConsumerWidget {
  const GestionGroupesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final groupes = ref.watch(tousGroupesProvider);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.tousLesGroupes)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(Routes.nouveauGroupe),
        icon: const Icon(Icons.add),
        label: Text(l10n.nouveauGroupe),
      ),
      body: groupes.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) =>
            EtatVide(icone: Icons.cloud_off, texte: l10n.erreurChargement),
        data: (liste) => liste.isEmpty
            ? EtatVide(
                icone: Icons.groups_outlined,
                texte: l10n.aucunGroupeEglise,
              )
            : ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
                children: [
                  for (final g in liste)
                    Card(
                      child: ListTile(
                        leading: Icon(iconeGroupe(g.type)),
                        title: Text(g.nom),
                        subtitle: Text(
                          '${l10n.libelleTypeGroupe(g.type)} · ${l10n.nombreMembres(g.membres.length)}',
                        ),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => context.push(Routes.groupe(g.id)),
                      ),
                    ),
                ],
              ),
      ),
    );
  }
}
