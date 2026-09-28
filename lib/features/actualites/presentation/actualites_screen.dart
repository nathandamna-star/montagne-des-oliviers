import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/router/routes.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/etat_vide.dart';
import '../actualites_providers.dart';
import 'carte_actualite.dart';

/// Toutes les annonces publiées.
class ActualitesScreen extends ConsumerWidget {
  const ActualitesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final actualites = ref.watch(actualitesProvider);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.annonces)),
      body: actualites.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) =>
            EtatVide(icone: Icons.cloud_off, texte: l10n.erreurChargement),
        data: (liste) => liste.isEmpty
            ? EtatVide(
                icone: Icons.campaign_outlined,
                texte: l10n.aucuneAnnonce,
              )
            : ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: liste.length,
                separatorBuilder: (_, _) => const SizedBox(height: 8),
                itemBuilder: (context, i) => CarteActualite(
                  actualite: liste[i],
                  lien: Routes.actualite(liste[i].id),
                ),
              ),
      ),
    );
  }
}
