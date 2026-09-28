import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/app_localizations.dart';
import '../../../shared/domain_traduction.dart';
import '../../../shared/format_date.dart';
import '../../../shared/widgets/etat_vide.dart';
import '../actualites_providers.dart';

/// Une annonce en entier.
class ActualiteScreen extends ConsumerWidget {
  const ActualiteScreen({super.key, required this.id});

  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final actualite = ref.watch(actualiteProvider(id));
    return Scaffold(
      appBar: AppBar(title: Text(l10n.annonce)),
      body: actualite.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        // Annonce supprimée ou réservée aux membres.
        error: (_, _) => EtatVide(
          icone: Icons.lock_outline,
          texte: l10n.annonceIndisponible,
        ),
        data: (a) => a == null
            ? EtatVide(
                icone: Icons.campaign_outlined,
                texte: l10n.annonceIndisponible,
              )
            : Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 720),
                  child: ListView(
                    padding: const EdgeInsets.all(20),
                    children: [
                      if (a.photoUrl != null) ...[
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.network(
                            a.photoUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) => const SizedBox.shrink(),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                      Text(
                        Traduction.dans(a.titre, context.langue),
                        style: theme.textTheme.headlineSmall,
                      ),
                      if (a.publieLe != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          context.dateLongue(a.publieLe!),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                      const SizedBox(height: 16),
                      SelectableText(
                        Traduction.dans(a.texte, context.langue),
                        style: theme.textTheme.bodyLarge,
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
