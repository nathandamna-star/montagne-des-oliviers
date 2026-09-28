import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/routes.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/format_date.dart';
import '../../../shared/widgets/etat_vide.dart';
import '../../auth/auth_providers.dart';
import '../divers_providers.dart';
import 'libelles_divers.dart';

/// Onglet « Divers » de l'Agenda : anniversaires, naissances, fêtes.
class DiversListe extends ConsumerWidget {
  const DiversListe({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    if (ref.watch(profilProvider).value == null) {
      return EtatVide(icone: Icons.lock_outline, texte: l10n.diversConnexion);
    }
    final fetes = ref.watch(fetesProvider);
    return Stack(
      children: [
        fetes.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, _) =>
              EtatVide(icone: Icons.cloud_off, texte: l10n.erreurChargement),
          data: (liste) => liste.isEmpty
              ? EtatVide(icone: Icons.cake_outlined, texte: l10n.aucuneFete)
              : ListView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
                  children: [
                    for (final f in liste)
                      Card(
                        child: ListTile(
                          leading: Icon(
                            iconeFete(f.type),
                            color: theme.colorScheme.secondary,
                          ),
                          title: Text(f.titre),
                          subtitle: Text(
                            [
                              '${context.dateLongue(f.date)}, ${context.heure(f.date)}',
                              if (f.lieu.isNotEmpty) f.lieu,
                            ].join(' · '),
                          ),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => context.push(Routes.fete(f.id)),
                        ),
                      ),
                  ],
                ),
        ),
        Positioned(
          right: 16,
          bottom: 16,
          child: FloatingActionButton.extended(
            heroTag: 'annoncer-fete',
            onPressed: () => context.push(Routes.editerFete('nouvelle')),
            icon: const Icon(Icons.add),
            label: Text(l10n.annoncerFete),
          ),
        ),
      ],
    );
  }
}
