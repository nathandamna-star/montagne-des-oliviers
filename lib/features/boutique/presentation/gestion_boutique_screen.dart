import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/routes.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/format_euros.dart';
import '../../../shared/widgets/etat_vide.dart';
import '../boutique_providers.dart';
import '../domain/boutique.dart';
import 'boutique_screen.dart';
import 'commandes_screens.dart';

/// Trésorier et secrétariat : commandes à suivre et catalogue des livres.
class GestionBoutiqueScreen extends ConsumerWidget {
  const GestionBoutiqueScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final commandes = ref.watch(toutesCommandesProvider).value ?? const [];
    final livres = ref.watch(catalogueProvider).value ?? const <Livre>[];
    // D'abord ce qui reste à faire : en attente, puis payées (à remettre).
    int rang(Commande c) => switch (c.statut) {
      StatutCommande.enAttente => 1,
      StatutCommande.payee => 0,
      _ => 2,
    };
    final triees = [...commandes]
      ..sort((a, b) {
        final r = rang(a).compareTo(rang(b));
        return r != 0 ? r : Commande.parDate(a, b);
      });
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.boutique),
          bottom: TabBar(
            tabs: [
              Tab(text: l10n.commandes),
              Tab(text: l10n.livres),
            ],
          ),
        ),
        floatingActionButton: Builder(
          builder: (context) {
            final onglets = DefaultTabController.of(context);
            return AnimatedBuilder(
              animation: onglets,
              builder: (context, _) => onglets.index == 1
                  ? FloatingActionButton.extended(
                      onPressed: () =>
                          context.push(Routes.editerLivre('nouveau')),
                      icon: const Icon(Icons.add),
                      label: Text(l10n.nouveauLivre),
                    )
                  : const SizedBox.shrink(),
            );
          },
        ),
        body: TabBarView(
          children: [
            triees.isEmpty
                ? EtatVide(
                    icone: Icons.shopping_bag_outlined,
                    texte: l10n.aucuneCommande,
                  )
                : ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      for (final c in triees)
                        CarteCommande(commande: c, avecNom: true),
                    ],
                  ),
            livres.isEmpty
                ? EtatVide(
                    icone: Icons.menu_book_outlined,
                    texte: l10n.boutiqueVide,
                  )
                : ListView(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
                    children: [
                      for (final l in livres)
                        Card(
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(8),
                            leading: CouvertureLivre(livre: l),
                            title: Text(l.titre),
                            subtitle: Text(
                              l.disponible
                                  ? context.euros(l.prix)
                                  : '${context.euros(l.prix)} · ${l10n.livreEpuise}',
                            ),
                            trailing: const Icon(Icons.edit_outlined),
                            onTap: () => context.push(Routes.editerLivre(l.id)),
                          ),
                        ),
                    ],
                  ),
          ],
        ),
      ),
    );
  }
}
