import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/roles.dart';
import '../../../core/router/routes.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/domain/virement.dart';
import '../../../shared/format_date.dart';
import '../../../shared/format_euros.dart';
import '../../../shared/widgets/etat_vide.dart';
import '../../../shared/widgets/instructions_virement.dart';
import '../../auth/auth_providers.dart';
import '../boutique_providers.dart';
import '../domain/boutique.dart';
import 'libelles_boutique.dart';

/// Une commande dans une liste.
class CarteCommande extends StatelessWidget {
  const CarteCommande({
    super.key,
    required this.commande,
    this.avecNom = false,
  });

  final Commande commande;
  final bool avecNom;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = commande;
    return Card(
      child: ListTile(
        leading: Icon(iconeStatutCommande(c.statut)),
        title: Text(
          [
            if (avecNom) c.nom,
            l10n.nombreLivres(c.nombreLivres),
            context.euros(c.total),
          ].join(' · '),
        ),
        subtitle: Text(
          [
            if (c.createdAt != null) context.dateCourte(c.createdAt!),
            c.parVirement ? l10n.modeVirement : l10n.modeEnLigne,
            l10n.statutCommande(c.statut),
          ].join(' · '),
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => context.push(Routes.commande(c.id)),
      ),
    );
  }
}

class MesCommandesScreen extends ConsumerWidget {
  const MesCommandesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final commandes = ref.watch(mesCommandesProvider).value ?? const [];
    return Scaffold(
      appBar: AppBar(title: Text(l10n.mesCommandes)),
      body: commandes.isEmpty
          ? EtatVide(
              icone: Icons.shopping_bag_outlined,
              texte: l10n.aucuneCommande,
            )
          : Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 720),
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    for (final c in commandes) CarteCommande(commande: c),
                  ],
                ),
              ),
            ),
    );
  }
}

/// Détail d'une commande : instructions de virement pour l'acheteur ;
/// suivi (payée, remise, annulée) pour le trésorier et le secrétariat.
class CommandeScreen extends ConsumerWidget {
  const CommandeScreen({super.key, required this.id});

  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final commande = ref.watch(commandeProvider(id));
    final uid = ref.watch(utilisateurFirebaseProvider).value?.uid;
    final gestion = ref.watch(gereBoutiqueProvider);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.commande)),
      body: commande.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) =>
            EtatVide(icone: Icons.cloud_off, texte: l10n.erreurChargement),
        data: (c) {
          if (c == null) {
            return EtatVide(
              icone: Icons.shopping_bag_outlined,
              texte: l10n.commandeIntrouvable,
            );
          }
          final enAttente = c.statut == StatutCommande.enAttente;
          final moi = c.uid == uid;
          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(iconeStatutCommande(c.statut)),
                    title: Text(
                      l10n.statutCommande(c.statut),
                      style: theme.textTheme.titleLarge,
                    ),
                    subtitle: Text(
                      [
                        c.nom,
                        if (c.createdAt != null)
                          context.dateLongue(c.createdAt!),
                        if (c.parVirement) formaterCommunication(c.id),
                      ].join(' · '),
                    ),
                  ),
                  for (final l in c.lignes)
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      dense: true,
                      title: Text('${l.quantite} × ${l.titre}'),
                      trailing: Text(context.euros(l.prix * l.quantite)),
                    ),
                  const Divider(),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(l10n.total),
                    trailing: Text(
                      context.euros(c.total),
                      style: theme.textTheme.titleMedium,
                    ),
                  ),
                  Text(l10n.retraitEglise, style: theme.textTheme.bodySmall),
                  const SizedBox(height: 16),
                  if (enAttente && moi && c.parVirement) ...[
                    InstructionsVirement(montant: c.total, communication: c.id),
                    const SizedBox(height: 16),
                    OutlinedButton(
                      onPressed: () => ref
                          .read(boutiqueRepositoryProvider)
                          .annulerMaCommande(c.id),
                      child: Text(l10n.annulerCommande),
                    ),
                  ],
                  if (enAttente && moi && !c.parVirement)
                    Text(l10n.paiementEnLigneAttente),
                  if (gestion && uid != null) ...[
                    const SizedBox(height: 24),
                    Text(
                      l10n.suiviCommande,
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final s in StatutCommande.values)
                          ChoiceChip(
                            label: Text(l10n.statutCommande(s)),
                            selected: c.statut == s,
                            onSelected: c.statut == s
                                ? null
                                : (_) => ref
                                      .read(boutiqueRepositoryProvider)
                                      .changerStatut(c.id, s, par: uid),
                          ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
