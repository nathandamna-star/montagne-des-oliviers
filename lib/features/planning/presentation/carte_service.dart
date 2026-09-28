import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/app_localizations.dart';
import '../../../shared/format_date.dart';
import '../../auth/auth_providers.dart';
import '../domain/planning.dart';
import '../planning_providers.dart';
import 'libelles_planning.dart';

/// Un service : qui, quand, quel poste, statut ; actions selon la personne.
class CarteService extends ConsumerWidget {
  const CarteService({
    super.key,
    required this.affectation,
    this.equipeNom,
    this.responsable = false,
    this.membreEquipe = false,
    this.onModifier,
  });

  final Affectation affectation;

  /// Affiché dans « Mon planning » (plusieurs équipes).
  final String? equipeNom;
  final bool responsable;
  final bool membreEquipe;
  final VoidCallback? onModifier;

  Future<void> _actions(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final a = affectation;
    final choix = await showModalBottomSheet<StatutService>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.check_circle_outline),
              title: Text(l10n.jeConfirme),
              onTap: () => Navigator.pop(context, StatutService.confirme),
            ),
            ListTile(
              leading: const Icon(Icons.swap_horiz),
              title: Text(l10n.demanderRemplacantService),
              subtitle: Text(l10n.demanderRemplacantServiceAide),
              onTap: () => Navigator.pop(context, StatutService.remplacement),
            ),
            ListTile(
              leading: const Icon(Icons.event_busy_outlined),
              title: Text(l10n.jeNeSuisPasDisponible),
              subtitle: Text(l10n.jeNeSuisPasDisponibleAide),
              onTap: () => Navigator.pop(context, StatutService.indisponible),
            ),
          ],
        ),
      ),
    );
    if (choix == null) return;
    await ref
        .read(planningRepositoryProvider)
        .changerStatut(a.equipeId, a.id, choix);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final a = affectation;
    final uid = ref.watch(utilisateurFirebaseProvider).value?.uid;
    final moi = a.uid == uid;
    final nom = ref.watch(profilProvider).value?.nom ?? '';
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(4, 4, 4, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ListTile(
              leading: Icon(
                iconeStatutService(a.statut),
                color: couleurStatutService(theme.colorScheme, a.statut),
              ),
              title: Text(
                equipeNom == null
                    ? [a.nom, if (a.role.isNotEmpty) a.role].join(' · ')
                    : [equipeNom!, if (a.role.isNotEmpty) a.role].join(' · '),
              ),
              subtitle: Text(
                [
                  '${a.titre} — ${context.dateLongue(a.date)}, ${context.heure(a.date)}',
                  l10n.libelleStatutService(a.statut),
                  if (a.remplace.isNotEmpty) l10n.remplaceNom(a.remplace),
                ].join('\n'),
              ),
              isThreeLine: true,
              trailing: responsable && onModifier != null
                  ? IconButton(
                      tooltip: l10n.modifier,
                      onPressed: onModifier,
                      icon: const Icon(Icons.edit_outlined),
                    )
                  : null,
            ),
            if (moi)
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => _actions(context, ref),
                  child: Text(l10n.repondreService),
                ),
              )
            else if (membreEquipe && a.aRemplacer && uid != null)
              Align(
                alignment: Alignment.centerRight,
                child: FilledButton.tonalIcon(
                  onPressed: () => ref
                      .read(planningRepositoryProvider)
                      .reprendre(a, uid: uid, nom: nom),
                  icon: const Icon(Icons.front_hand_outlined),
                  label: Text(l10n.jeRemplace),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
