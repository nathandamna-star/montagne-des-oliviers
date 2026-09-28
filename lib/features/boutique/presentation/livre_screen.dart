import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/routes.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/domain_traduction.dart';
import '../../../shared/format_date.dart';
import '../../../shared/format_euros.dart';
import '../../../shared/widgets/etat_vide.dart';
import '../boutique_providers.dart';
import 'boutique_screen.dart';

class LivreScreen extends ConsumerWidget {
  const LivreScreen({super.key, required this.id});

  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final livre = ref.watch(livreProvider(id));
    final dansLePanier = ref.watch(panierProvider)[id] ?? 0;
    return Scaffold(
      appBar: AppBar(title: Text(livre.value?.titre ?? l10n.boutique)),
      body: livre.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) =>
            EtatVide(icone: Icons.cloud_off, texte: l10n.erreurChargement),
        data: (l) {
          if (l == null) {
            return EtatVide(
              icone: Icons.menu_book_outlined,
              texte: l10n.livreIndisponible,
            );
          }
          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Center(child: CouvertureLivre(livre: l, largeur: 160)),
                  const SizedBox(height: 16),
                  Text(l.titre, style: theme.textTheme.headlineSmall),
                  if (l.auteur.isNotEmpty)
                    Text(l.auteur, style: theme.textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Text(
                    context.euros(l.prix),
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (l.description.isNotEmpty)
                    Text(Traduction.dans(l.description, context.langue)),
                  const SizedBox(height: 24),
                  if (!l.disponible)
                    Text(l10n.livreEpuise)
                  else ...[
                    FilledButton.icon(
                      onPressed: () =>
                          ref.read(panierProvider.notifier).ajouter(l.id),
                      icon: const Icon(Icons.add_shopping_cart),
                      label: Text(l10n.ajouterAuPanier),
                    ),
                    if (dansLePanier > 0) ...[
                      const SizedBox(height: 8),
                      OutlinedButton(
                        onPressed: () => context.push(Routes.panier),
                        child: Text(l10n.voirPanier(dansLePanier)),
                      ),
                    ],
                  ],
                  const SizedBox(height: 8),
                  Text(l10n.retraitEglise, style: theme.textTheme.bodySmall),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
