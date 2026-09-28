import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/routes.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/etat_vide.dart';
import '../demandes_providers.dart';
import 'carte_demande.dart';

class MesDemandesScreen extends ConsumerWidget {
  const MesDemandesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final demandes = ref.watch(mesDemandesProvider);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.mesDemandes)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(Routes.nouvelleDemande),
        icon: const Icon(Icons.add),
        label: Text(l10n.nouvelleDemande),
      ),
      body: demandes.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) =>
            EtatVide(icone: Icons.cloud_off, texte: l10n.erreurChargement),
        data: (liste) => liste.isEmpty
            ? EtatVide(icone: Icons.outbox_outlined, texte: l10n.aucuneDemande)
            : ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
                children: [
                  for (final d in liste)
                    CarteDemande(demande: d, lien: Routes.maDemande(d.id)),
                ],
              ),
      ),
    );
  }
}
