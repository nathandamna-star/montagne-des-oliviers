import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/roles.dart';
import '../../../core/router/routes.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/domain_traduction.dart';
import '../../../shared/format_date.dart';
import '../../../shared/widgets/connexion_requise.dart';
import '../../../shared/widgets/etat_vide.dart';
import '../../auth/auth_providers.dart';
import '../domain/preparation.dart';
import '../preparations_providers.dart';

IconData iconePreparation(TypePreparation t) => t == TypePreparation.mariage
    ? Icons.favorite_border
    : Icons.water_drop_outlined;

/// Préparations au mariage et au baptême.
class PreparationsScreen extends ConsumerWidget {
  const PreparationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    if (ref.watch(profilProvider).value == null) {
      return ConnexionRequise(titre: l10n.preparations);
    }
    final pasteur = ref.watch(estAdminProvider);
    final preparations = ref.watch(preparationsProvider);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.preparations)),
      floatingActionButton: pasteur
          ? FloatingActionButton.extended(
              onPressed: () =>
                  context.push(Routes.editerPreparation('nouvelle')),
              icon: const Icon(Icons.add),
              label: Text(l10n.nouvellePreparation),
            )
          : null,
      body: preparations.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) =>
            EtatVide(icone: Icons.cloud_off, texte: l10n.erreurChargement),
        data: (liste) => liste.isEmpty
            ? EtatVide(
                icone: Icons.menu_book_outlined,
                texte: l10n.aucunePreparation,
              )
            : ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
                children: [
                  Text(
                    l10n.preparationsIntro,
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 12),
                  for (final p in liste) _Carte(preparation: p),
                ],
              ),
      ),
    );
  }
}

class _Carte extends ConsumerWidget {
  const _Carte({required this.preparation});

  final Preparation preparation;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final p = preparation;
    final inscrit = ref.watch(monInscritProvider(p.id)).value;
    return Card(
      child: ListTile(
        leading: Icon(
          iconePreparation(p.type),
          color: theme.colorScheme.secondary,
        ),
        title: Text(Traduction.dans(p.titre, context.langue)),
        subtitle: Text(
          [
            if (inscrit != null) l10n.vousEtesInscrit,
            if (!p.publie) l10n.brouillon,
          ].join(' · '),
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => context.push(Routes.preparation(p.id)),
      ),
    );
  }
}
