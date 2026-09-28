import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/etat_vide.dart';
import '../../../shared/widgets/instructions_virement.dart';
import '../dons_providers.dart';
import '../domain/don.dart';
import 'libelles_dons.dart';

/// Virement annoncé : QR code et communication structurée à utiliser.
class VirementDonScreen extends ConsumerWidget {
  const VirementDonScreen({super.key, required this.id});

  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final don = ref.watch(donProvider(id));
    return Scaffold(
      appBar: AppBar(title: Text(l10n.virementTitre)),
      body: don.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) =>
            EtatVide(icone: Icons.cloud_off, texte: l10n.erreurChargement),
        data: (d) {
          if (d == null) {
            return EtatVide(
              icone: Icons.volunteer_activism_outlined,
              texte: l10n.donIntrouvable,
            );
          }
          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Text(
                    l10n.affectation(d.affectation),
                    style: theme.textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  if (d.statut == StatutDon.enAttente) ...[
                    InstructionsVirement(
                      montant: d.montant,
                      communication: d.id,
                    ),
                    const SizedBox(height: 24),
                    OutlinedButton(
                      onPressed: () async {
                        await ref.read(donsRepositoryProvider).renoncer(d.id);
                        if (context.mounted) context.pop();
                      },
                      child: Text(l10n.renoncerDon),
                    ),
                  ] else
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(iconeStatutDon(d.statut)),
                      title: Text(l10n.statutDon(d.statut)),
                      subtitle: d.statut == StatutDon.recu
                          ? Text(l10n.merciDon)
                          : null,
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
