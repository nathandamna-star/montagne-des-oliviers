import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/routes.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/format_euros.dart';
import '../../../shared/services/lanceur.dart';
import '../../../shared/services/paiements_en_ligne.dart';
import '../../../shared/widgets/etat_vide.dart';
import '../../auth/auth_providers.dart';
import '../../parametres/parametres_eglise.dart';
import '../boutique_providers.dart';
import '../domain/boutique.dart';

class PanierScreen extends ConsumerStatefulWidget {
  const PanierScreen({super.key});

  @override
  ConsumerState<PanierScreen> createState() => _PanierScreenState();
}

class _PanierScreenState extends ConsumerState<PanierScreen> {
  bool _occupe = false;

  Future<void> _commander(String mode) async {
    final l10n = AppLocalizations.of(context);
    final messager = ScaffoldMessenger.of(context);
    final routeur = GoRouter.of(context);
    setState(() => _occupe = true);
    try {
      final c = await ref
          .read(paiementsEnLigneProvider)
          .passerCommande(lignes: ref.read(panierProvider), mode: mode);
      ref.read(panierProvider.notifier).vider();
      if (c.url != null) await ref.read(lanceurProvider).ouvrir(c.url!);
      routeur.pushReplacement(Routes.commande(c.id));
    } on ErreurPaiement catch (e) {
      messager.showSnackBar(
        SnackBar(
          content: Text(
            e.code == 'reseau'
                ? l10n.erreurReseau
                : e.code == 'invalide'
                ? l10n.panierInvalide
                : l10n.paiementImpossible,
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _occupe = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final panier = ref.watch(panierProvider);
    final livres = {
      for (final l in ref.watch(catalogueProvider).value ?? const <Livre>[])
        l.id: l,
    };
    final membre = ref.watch(profilProvider).value != null;
    final virement =
        ref.watch(parametresEgliseProvider).value?.virementPossible ?? false;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.panier)),
      body: panier.isEmpty
          ? EtatVide(icone: Icons.shopping_bag_outlined, texte: l10n.panierVide)
          : Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 720),
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    for (final e in panier.entries)
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(livres[e.key]?.titre ?? '…'),
                        subtitle: Text(
                          context.euros((livres[e.key]?.prix ?? 0) * e.value),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              tooltip: l10n.enleverUn,
                              onPressed: () => ref
                                  .read(panierProvider.notifier)
                                  .retirer(e.key),
                              icon: const Icon(Icons.remove_circle_outline),
                            ),
                            Text('${e.value}'),
                            IconButton(
                              tooltip: l10n.ajouterUn,
                              onPressed: () => ref
                                  .read(panierProvider.notifier)
                                  .ajouter(e.key),
                              icon: const Icon(Icons.add_circle_outline),
                            ),
                          ],
                        ),
                      ),
                    const Divider(),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(l10n.total),
                      trailing: Text(
                        context.euros(totalPanier(panier, livres)),
                        style: theme.textTheme.titleLarge,
                      ),
                    ),
                    Text(l10n.retraitEglise, style: theme.textTheme.bodySmall),
                    const SizedBox(height: 24),
                    if (!membre)
                      FilledButton(
                        onPressed: () => context.push(Routes.connexion),
                        child: Text(l10n.seConnecterPourCommander),
                      )
                    else ...[
                      FilledButton.icon(
                        onPressed: _occupe
                            ? null
                            : () => _commander('en_ligne'),
                        icon: const Icon(Icons.credit_card),
                        label: Text(l10n.payerEnLigne),
                      ),
                      if (virement) ...[
                        const SizedBox(height: 8),
                        OutlinedButton.icon(
                          onPressed: _occupe
                              ? null
                              : () => _commander('virement'),
                          icon: const Icon(Icons.qr_code_2),
                          label: Text(l10n.payerParVirement),
                        ),
                      ],
                    ],
                  ],
                ),
              ),
            ),
    );
  }
}
