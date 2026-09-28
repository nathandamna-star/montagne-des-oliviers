import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/router/routes.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/etat_vide.dart';
import '../demandes_providers.dart';
import 'carte_demande.dart';

/// Secrétariat et pasteurs : les demandes des membres.
class GestionDemandesScreen extends ConsumerStatefulWidget {
  const GestionDemandesScreen({super.key});

  @override
  ConsumerState<GestionDemandesScreen> createState() =>
      _GestionDemandesScreenState();
}

class _GestionDemandesScreenState extends ConsumerState<GestionDemandesScreen> {
  bool _toutes = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final demandes = ref.watch(toutesDemandesProvider);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.demandesRecues)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Row(
              children: [
                ChoiceChip(
                  label: Text(l10n.aTraiter),
                  selected: !_toutes,
                  onSelected: (_) => setState(() => _toutes = false),
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: Text(l10n.toutes),
                  selected: _toutes,
                  onSelected: (_) => setState(() => _toutes = true),
                ),
              ],
            ),
          ),
          Expanded(
            child: demandes.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, _) => EtatVide(
                icone: Icons.cloud_off,
                texte: l10n.erreurChargement,
              ),
              data: (tout) {
                final liste = [
                  for (final d in tout)
                    if (_toutes || d.enCours) d,
                ];
                return liste.isEmpty
                    ? EtatVide(
                        icone: Icons.inbox_outlined,
                        texte: l10n.aucuneDemandeATraiter,
                      )
                    : ListView(
                        padding: const EdgeInsets.all(16),
                        children: [
                          for (final d in liste)
                            CarteDemande(
                              demande: d,
                              lien: Routes.gererDemande(d.id),
                              avecNom: true,
                            ),
                        ],
                      );
              },
            ),
          ),
        ],
      ),
    );
  }
}
