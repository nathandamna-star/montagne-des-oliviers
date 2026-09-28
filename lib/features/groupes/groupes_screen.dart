import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
import '../../shared/widgets/connexion_requise.dart';
import '../../shared/widgets/etat_vide.dart';
import '../auth/auth_providers.dart';
import 'groupes_providers.dart';
import 'presentation/carte_groupe.dart';

/// Onglet Groupes : mes groupes, puis les groupes ouverts.
class GroupesScreen extends ConsumerWidget {
  const GroupesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    if (!ref.watch(estConnecteProvider)) {
      return ConnexionRequise(
        titre: l10n.navGroupes,
        texte: l10n.groupesConnexionTexte,
      );
    }
    final mes = ref.watch(mesGroupesProvider);
    final autres = ref.watch(autresGroupesProvider).value ?? const [];
    return Scaffold(
      appBar: AppBar(title: Text(l10n.navGroupes)),
      body: mes.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) =>
            EtatVide(icone: Icons.cloud_off, texte: l10n.erreurChargement),
        data: (liste) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(l10n.mesGroupes, style: theme.textTheme.titleLarge),
            const SizedBox(height: 8),
            if (liste.isEmpty)
              Text(
                l10n.aucunGroupe,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            for (final g in liste) CarteGroupe(groupe: g),
            if (autres.isNotEmpty) ...[
              const SizedBox(height: 24),
              Text(l10n.autresGroupes, style: theme.textTheme.titleLarge),
              const SizedBox(height: 4),
              Text(
                l10n.autresGroupesAide,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 8),
              for (final g in autres) CarteGroupe(groupe: g),
            ],
          ],
        ),
      ),
    );
  }
}
