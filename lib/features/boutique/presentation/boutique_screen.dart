import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/routes.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/format_euros.dart';
import '../../../shared/widgets/etat_vide.dart';
import '../boutique_providers.dart';
import '../domain/boutique.dart';

/// Boutique : livres de l'église, payés par virement ou en ligne
/// (Bancontact, carte), à retirer à l'église.
class BoutiqueScreen extends ConsumerWidget {
  const BoutiqueScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final catalogue = ref.watch(catalogueProvider);
    final nombre = ref.watch(panierProvider).values.fold(0, (s, q) => s + q);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.boutique)),
      floatingActionButton: nombre == 0
          ? null
          : FloatingActionButton.extended(
              onPressed: () => context.push(Routes.panier),
              icon: const Icon(Icons.shopping_bag_outlined),
              label: Text(l10n.voirPanier(nombre)),
            ),
      body: catalogue.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) =>
            EtatVide(icone: Icons.cloud_off, texte: l10n.erreurChargement),
        data: (tous) {
          final livres = [
            for (final l in tous)
              if (l.disponible) l,
          ];
          if (livres.isEmpty) {
            return EtatVide(
              icone: Icons.menu_book_outlined,
              texte: l10n.boutiqueVide,
            );
          }
          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
                children: [
                  Text(l10n.boutiqueAide),
                  const SizedBox(height: 8),
                  for (final l in livres) CarteLivre(livre: l),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Couverture d'un livre (ou une icône s'il n'y en a pas).
class CouvertureLivre extends StatelessWidget {
  const CouvertureLivre({super.key, required this.livre, this.largeur = 56});

  final Livre livre;
  final double largeur;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final vide = Container(
      width: largeur,
      height: largeur * 1.4,
      color: theme.colorScheme.secondaryContainer,
      child: Icon(
        Icons.menu_book,
        color: theme.colorScheme.onSecondaryContainer,
      ),
    );
    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: livre.photoUrl == null
          ? vide
          : Image.network(
              livre.photoUrl!,
              width: largeur,
              height: largeur * 1.4,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => vide,
            ),
    );
  }
}

class CarteLivre extends StatelessWidget {
  const CarteLivre({super.key, required this.livre});

  final Livre livre;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.all(8),
        leading: CouvertureLivre(livre: livre),
        title: Text(livre.titre),
        subtitle: livre.auteur.isEmpty ? null : Text(livre.auteur),
        trailing: Text(
          context.euros(livre.prix),
          style: Theme.of(context).textTheme.titleMedium,
        ),
        onTap: () => context.push(Routes.livre(livre.id)),
      ),
    );
  }
}
