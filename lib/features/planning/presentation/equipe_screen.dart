import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/roles.dart';
import '../../../core/router/routes.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/domain/sans_accents.dart';
import '../../../shared/format_date.dart';
import '../../../shared/widgets/etat_vide.dart';
import '../../auth/auth_providers.dart';
import '../../groupes/groupes_providers.dart';
import '../../groupes/presentation/choix_personnes.dart';
import '../domain/planning.dart';
import '../planning_providers.dart';
import 'carte_service.dart';

/// Une équipe : son planning (par date) et ses membres.
class EquipeScreen extends ConsumerWidget {
  const EquipeScreen({super.key, required this.id});

  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final equipe = ref.watch(equipeProvider(id));
    final uid = ref.watch(utilisateurFirebaseProvider).value?.uid;
    final secretariat = ref.watch(estSecretariatProvider);
    final noms = ref.watch(annuaireProvider).value ?? const {};
    final e = equipe.value;
    final responsable = secretariat || (e?.estResponsable(uid) ?? false);
    final services =
        ref.watch(affectationsProvider(id)).value ?? const <Affectation>[];

    return Scaffold(
      appBar: AppBar(
        title: Text(e?.nom ?? l10n.planning),
        actions: [
          if (secretariat)
            IconButton(
              tooltip: l10n.modifier,
              onPressed: () => context.push(Routes.editerEquipe(id)),
              icon: const Icon(Icons.edit_outlined),
            ),
        ],
      ),
      floatingActionButton: responsable
          ? FloatingActionButton.extended(
              onPressed: () =>
                  context.push(Routes.editerAffectation(id, 'nouvelle')),
              icon: const Icon(Icons.add),
              label: Text(l10n.ajouterAuPlanning),
            )
          : null,
      body: equipe.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) =>
            EtatVide(icone: Icons.cloud_off, texte: l10n.erreurChargement),
        data: (e) {
          if (e == null) {
            return EtatVide(
              icone: Icons.groups_2_outlined,
              texte: l10n.equipeIndisponible,
            );
          }
          final lignes = <Widget>[];
          DateTime? jour;
          for (final a in services) {
            final j = DateTime(a.date.year, a.date.month, a.date.day);
            if (j != jour) {
              jour = j;
              lignes.add(
                Padding(
                  padding: const EdgeInsets.fromLTRB(4, 16, 4, 4),
                  child: Text(
                    context.dateLongue(j),
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
              );
            }
            lignes.add(
              CarteService(
                affectation: a,
                responsable: responsable,
                membreEquipe: e.estMembre(uid),
                onModifier: () =>
                    context.push(Routes.editerAffectation(id, a.id)),
              ),
            );
          }
          final membres = [...e.membres]
            ..sort((a, b) {
              if (e.estResponsable(a) != e.estResponsable(b)) {
                return e.estResponsable(a) ? -1 : 1;
              }
              return sansAccents(noms[a] ?? '')
                  .compareTo(sansAccents(noms[b] ?? ''));
            });
          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
                children: [
                  if (e.description.isNotEmpty)
                    Text(e.description, style: theme.textTheme.bodyLarge),
                  Text(l10n.planning, style: theme.textTheme.titleLarge),
                  if (services.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(l10n.planningVide),
                    ),
                  ...lignes,
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          l10n.nombreMembres(e.membres.length),
                          style: theme.textTheme.titleMedium,
                        ),
                      ),
                      if (responsable)
                        TextButton.icon(
                          onPressed: () async {
                            final choisis =
                                await showModalBottomSheet<List<String>>(
                                  context: context,
                                  isScrollControlled: true,
                                  showDragHandle: true,
                                  builder: (context) => ChoixPersonnes(
                                    titre: l10n.ajouterMembres,
                                    exclus: e.membres.toSet(),
                                  ),
                                );
                            if (choisis == null || choisis.isEmpty) return;
                            await ref
                                .read(planningRepositoryProvider)
                                .modifierMembres(id, [
                                  ...e.membres,
                                  ...choisis,
                                ]);
                          },
                          icon: const Icon(Icons.person_add_alt),
                          label: Text(l10n.ajouterMembres),
                        ),
                    ],
                  ),
                  for (final u in membres)
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: CircleAvatar(
                        child: Text(
                          (noms[u] ?? '?').characters.firstOrNull
                                  ?.toUpperCase() ??
                              '?',
                        ),
                      ),
                      title: Text(noms[u] ?? l10n.compteInconnu),
                      subtitle: e.estResponsable(u)
                          ? Text(l10n.responsableEquipe)
                          : null,
                      trailing: responsable && !e.estResponsable(u)
                          ? IconButton(
                              tooltip: l10n.retirerDeLEquipe,
                              onPressed: () => ref
                                  .read(planningRepositoryProvider)
                                  .modifierMembres(id, [
                                    for (final x in e.membres)
                                      if (x != u) x,
                                  ]),
                              icon: const Icon(Icons.person_remove_outlined),
                            )
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
