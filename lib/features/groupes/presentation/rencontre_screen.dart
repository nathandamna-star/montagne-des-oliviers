import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/roles.dart';
import '../../../core/router/routes.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/format_date.dart';
import '../../../shared/services/lanceur.dart';
import '../../../shared/widgets/etat_vide.dart';
import '../../auth/auth_providers.dart';
import '../domain/groupe.dart';
import '../domain/rencontre.dart';
import '../groupes_providers.dart';
import 'libelles_groupes.dart';

/// Détail d'un rendez-vous : infos, chants, qui joue quoi, modérateur,
/// déroulé, présences et ma réponse.
class RencontreScreen extends ConsumerWidget {
  const RencontreScreen({super.key, required this.groupeId, required this.id});

  final String groupeId;
  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final rencontre = ref.watch(rencontreProvider((groupeId, id)));
    final groupe = ref.watch(groupeProvider(groupeId)).value;
    return rencontre.when(
      loading: () => Scaffold(
        appBar: AppBar(),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (_, _) => Scaffold(
        appBar: AppBar(),
        body: EtatVide(
          icone: Icons.lock_outline,
          texte: l10n.rendezVousIndisponible,
        ),
      ),
      data: (r) => r == null || groupe == null
          ? Scaffold(
              appBar: AppBar(),
              body: EtatVide(
                icone: Icons.event_busy_outlined,
                texte: l10n.rendezVousIndisponible,
              ),
            )
          : _Rencontre(rencontre: r, groupe: groupe),
    );
  }
}

class _Rencontre extends ConsumerWidget {
  const _Rencontre({required this.rencontre, required this.groupe});

  final Rencontre rencontre;
  final Groupe groupe;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final r = rencontre;
    final g = groupe;
    final uid = ref.watch(utilisateurFirebaseProvider).value?.uid;
    final nomMoi = ref.watch(profilProvider).value?.nom ?? '';
    final gere = g.estAdmin(uid) || ref.watch(estSecretariatProvider);
    final membre = g.estMembre(uid);
    final noms = ref.watch(annuaireProvider).value ?? const {};
    final presences =
        ref.watch(presencesProvider((g.id, r.id))).value ??
        const <String, Reponse>{};
    final repo = ref.read(groupesRepositoryProvider);
    String nom(String u) => noms[u] ?? l10n.compteInconnu;
    Widget titre(String t) => Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 4),
      child: Text(t, style: theme.textTheme.titleMedium),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.libelleRencontre(r.type)),
        actions: [
          if (gere)
            IconButton(
              tooltip: l10n.modifier,
              onPressed: () => context.push(Routes.editerRencontre(g.id, r.id)),
              icon: const Icon(Icons.edit_outlined),
            ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text(r.titre, style: theme.textTheme.headlineSmall),
              const SizedBox(height: 8),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.schedule),
                title: Text(context.dateLongue(r.debut)),
                subtitle: Text(
                  r.fin == null
                      ? context.heure(r.debut)
                      : '${context.heure(r.debut)} – ${context.heure(r.fin!)}',
                ),
              ),
              if (r.lieu.isNotEmpty)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.place_outlined),
                  title: Text(r.lieu),
                ),
              if (r.type == TypeRencontre.appel &&
                  g.lienAppel.isNotEmpty &&
                  membre)
                OutlinedButton.icon(
                  onPressed: () =>
                      ref.read(lanceurProvider).ouvrir(Uri.parse(g.lienAppel)),
                  icon: const Icon(Icons.call_outlined),
                  label: Text(l10n.rejoindreAppel),
                ),
              if (r.notes.isNotEmpty) ...[
                const SizedBox(height: 8),
                SelectableText(r.notes, style: theme.textTheme.bodyLarge),
              ],

              // Modération : qui modère, remplacement.
              if (r.type == TypeRencontre.moderation) ...[
                titre(l10n.moderateur),
                Text(
                  r.moderateur == null
                      ? l10n.aucunModerateur
                      : nom(r.moderateur!),
                  style: theme.textTheme.bodyLarge,
                ),
                if (r.remplacementDemande)
                  Text(
                    l10n.remplacementDemande,
                    style: TextStyle(color: theme.colorScheme.error),
                  ),
                const SizedBox(height: 8),
                if (membre && r.moderateur == uid)
                  OutlinedButton.icon(
                    onPressed: () => repo.demanderRemplacement(
                      g.id,
                      r.id,
                      uid!,
                      demande: !r.remplacementDemande,
                    ),
                    icon: Icon(
                      r.remplacementDemande ? Icons.undo : Icons.swap_horiz,
                    ),
                    label: Text(
                      r.remplacementDemande
                          ? l10n.finalementDisponible
                          : l10n.demanderRemplacant,
                    ),
                  )
                else if (membre && r.remplacementDemande)
                  FilledButton.icon(
                    onPressed: () => repo.remplacer(g.id, r.id, uid!),
                    icon: const Icon(Icons.front_hand_outlined),
                    label: Text(l10n.jeRemplace),
                  ),
                if (r.deroule.isNotEmpty) ...[
                  titre(l10n.deroule),
                  for (final (i, etape) in r.deroule.indexed)
                    ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      leading: CircleAvatar(
                        radius: 12,
                        child: Text('${i + 1}'),
                      ),
                      title: Text(etape),
                    ),
                ],
              ],

              // Louange : chants et qui joue quoi.
              if (r.chants.isNotEmpty) ...[
                titre(l10n.chantsAPreparer),
                for (final c in r.chants)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.music_note_outlined),
                    title: Text(c.titre),
                    trailing: c.lien.isEmpty
                        ? null
                        : IconButton(
                            tooltip: l10n.ouvrirLien,
                            icon: const Icon(Icons.open_in_new),
                            onPressed: () => ref
                                .read(lanceurProvider)
                                .ouvrir(Uri.parse(c.lien)),
                          ),
                  ),
              ],
              if (r.roles.isNotEmpty) ...[
                titre(l10n.quiJoueQuoi),
                for (final e in r.roles.entries)
                  ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    title: Text(nom(e.key)),
                    trailing: Text(e.value),
                  ),
              ],

              // Présences.
              if (membre && r.type != TypeRencontre.moderation) ...[
                titre(l10n.maReponse),
                SegmentedButton<Reponse>(
                  emptySelectionAllowed: true,
                  segments: [
                    for (final rep in Reponse.values)
                      ButtonSegment(
                        value: rep,
                        label: Text(l10n.libelleReponse(rep)),
                      ),
                  ],
                  selected: {?presences[uid]},
                  onSelectionChanged: (s) {
                    if (s.isEmpty) return;
                    repo.repondre(
                      g.id,
                      r.id,
                      uid: uid!,
                      nom: nomMoi,
                      reponse: s.first,
                    );
                  },
                ),
              ],
              if (r.type != TypeRencontre.moderation) ...[
                titre(l10n.presences),
                Text(
                  [
                    for (final rep in Reponse.values)
                      '${l10n.libelleReponse(rep)} : ${presences.values.where((x) => x == rep).length}',
                  ].join(' · '),
                ),
                for (final rep in Reponse.values)
                  for (final e in presences.entries)
                    if (e.value == rep)
                      ListTile(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(switch (rep) {
                          Reponse.oui => Icons.check_circle_outline,
                          Reponse.non => Icons.cancel_outlined,
                          Reponse.peutetre => Icons.help_outline,
                        }),
                        title: Text(nom(e.key)),
                      ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
