import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/roles.dart';
import '../../../core/router/routes.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/domain/sans_accents.dart';
import '../../../shared/services/lanceur.dart';
import '../../../shared/widgets/etat_vide.dart';
import '../../auth/auth_providers.dart';
import '../domain/groupe.dart';
import '../groupes_providers.dart';
import 'carte_rencontre.dart';
import 'libelles_groupes.dart';

/// Page d'un groupe : discussion, appel, membres ; gestion pour ses
/// administrateurs.
class GroupeScreen extends ConsumerWidget {
  const GroupeScreen({super.key, required this.id});

  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final groupe = ref.watch(groupeProvider(id));
    return groupe.when(
      loading: () => Scaffold(
        appBar: AppBar(),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (_, _) => Scaffold(
        appBar: AppBar(),
        body: EtatVide(
          icone: Icons.lock_outline,
          texte: l10n.groupeIndisponible,
        ),
      ),
      data: (g) => g == null
          ? Scaffold(
              appBar: AppBar(),
              body: EtatVide(
                icone: Icons.groups_outlined,
                texte: l10n.groupeIndisponible,
              ),
            )
          : _Groupe(groupe: g),
    );
  }
}

class _Groupe extends ConsumerWidget {
  const _Groupe({required this.groupe});

  final Groupe groupe;

  Future<void> _confirmer(
    BuildContext context,
    String titre,
    Future<void> Function() action,
  ) async {
    final l10n = AppLocalizations.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(titre),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.annuler),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.valider),
          ),
        ],
      ),
    );
    if (ok == true) await action();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final g = groupe;
    final uid = ref.watch(utilisateurFirebaseProvider).value?.uid;
    final membre = g.estMembre(uid);
    final admin = g.estAdmin(uid);
    final secretariat = ref.watch(estSecretariatProvider);
    final gere = admin || secretariat;
    final noms = ref.watch(annuaireProvider).value ?? const {};
    final repo = ref.read(groupesRepositoryProvider);
    final nonLu = ref.watch(nonLuProvider(g));
    String nom(String u) => noms[u] ?? l10n.compteInconnu;
    final membres = [...g.membres]
      ..sort((a, b) {
        if (g.estAdmin(a) != g.estAdmin(b)) return g.estAdmin(a) ? -1 : 1;
        return sansAccents(nom(a)).compareTo(sansAccents(nom(b)));
      });

    return Scaffold(
      appBar: AppBar(
        title: Text(g.nom),
        actions: [
          if (gere)
            IconButton(
              tooltip: l10n.modifierGroupe,
              onPressed: () => context.push(Routes.modifierGroupe(g.id)),
              icon: const Icon(Icons.edit_outlined),
            ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Row(
                children: [
                  Icon(iconeGroupe(g.type), color: theme.colorScheme.secondary),
                  const SizedBox(width: 8),
                  Text(
                    [
                      l10n.libelleTypeGroupe(g.type),
                      g.prive ? l10n.groupePrive : l10n.groupeOuvert,
                    ].join(' · '),
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: theme.colorScheme.secondary,
                    ),
                  ),
                ],
              ),
              if (g.description.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(g.description, style: theme.textTheme.bodyLarge),
              ],
              const SizedBox(height: 16),
              if (membre) ...[
                FilledButton.icon(
                  onPressed: () => context.push(Routes.discussion(g.id)),
                  icon: Badge(
                    isLabelVisible: nonLu,
                    child: const Icon(Icons.forum_outlined),
                  ),
                  label: Text(l10n.discussion),
                ),
                if (g.type == TypeGroupe.intercession) ...[
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: () => context.push(Routes.prieresGroupe(g.id)),
                    icon: const Icon(Icons.volunteer_activism_outlined),
                    label: Text(l10n.sujetsPriere),
                  ),
                ],
                if (g.lienAppel.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: () => ref
                        .read(lanceurProvider)
                        .ouvrir(Uri.parse(g.lienAppel)),
                    icon: const Icon(Icons.call_outlined),
                    label: Text(l10n.rejoindreAppel),
                  ),
                ],
              ] else
                Card(
                  color: theme.colorScheme.secondaryContainer,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      l10n.rejoindreGroupeAide(g.admins.map(nom).join(', ')),
                    ),
                  ),
                ),
              if (membre || secretariat) ...[
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        l10n.calendrier,
                        style: theme.textTheme.titleMedium,
                      ),
                    ),
                    TextButton(
                      onPressed: () => context.push(Routes.calendrier(g.id)),
                      child: Text(l10n.voirTout),
                    ),
                  ],
                ),
                ..._prochaines(context, ref),
              ],
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      l10n.nombreMembres(g.membres.length),
                      style: theme.textTheme.titleMedium,
                    ),
                  ),
                  if (gere)
                    TextButton.icon(
                      onPressed: () => _ajouter(context, ref),
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
                      nom(u).characters.firstOrNull?.toUpperCase() ?? '?',
                    ),
                  ),
                  title: Text(nom(u)),
                  subtitle: g.estAdmin(u) ? Text(l10n.adminGroupe) : null,
                  trailing: gere && u != uid
                      ? PopupMenuButton<String>(
                          tooltip: l10n.options,
                          onSelected: (choix) async {
                            switch (choix) {
                              case 'admin':
                                await repo.definirAdmin(g.id, u, admin: true);
                              case 'plusAdmin':
                                if (g.admins.length > 1) {
                                  await repo.definirAdmin(
                                    g.id,
                                    u,
                                    admin: false,
                                  );
                                }
                              case 'retirer':
                                if (!context.mounted) return;
                                await _confirmer(
                                  context,
                                  l10n.retirerDuGroupeQuestion(nom(u)),
                                  () => repo.retirerMembre(g.id, u),
                                );
                            }
                          },
                          itemBuilder: (context) => [
                            if (!g.estAdmin(u))
                              PopupMenuItem(
                                value: 'admin',
                                child: Text(l10n.nommerAdmin),
                              )
                            else if (g.admins.length > 1)
                              PopupMenuItem(
                                value: 'plusAdmin',
                                child: Text(l10n.retirerAdmin),
                              ),
                            if (!g.estAdmin(u) || g.admins.length > 1)
                              PopupMenuItem(
                                value: 'retirer',
                                child: Text(l10n.retirerDuGroupe),
                              ),
                          ],
                        )
                      : null,
                ),
              if (membre && !admin) ...[
                const SizedBox(height: 24),
                OutlinedButton.icon(
                  onPressed: () =>
                      _confirmer(context, l10n.quitterGroupeQuestion, () async {
                        await repo.quitter(g.id, uid!);
                        if (context.mounted) context.pop();
                      }),
                  icon: const Icon(Icons.logout),
                  label: Text(l10n.quitterGroupe),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _prochaines(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final liste = ref.watch(rencontresProvider(groupe.id)).value ?? const [];
    if (liste.isEmpty) {
      return [
        Text(
          l10n.aucunRendezVous,
          style: Theme.of(context).textTheme.bodyMedium
              ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
        ),
      ];
    }
    return [for (final r in liste.take(3)) CarteRencontre(rencontre: r)];
  }

  /// Choisir des personnes parmi les comptes de l'église.
  Future<void> _ajouter(BuildContext context, WidgetRef ref) async {
    final choisis = await showModalBottomSheet<List<String>>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => _ChoixMembres(dejaMembres: groupe.membres.toSet()),
    );
    if (choisis == null || choisis.isEmpty) return;
    await ref
        .read(groupesRepositoryProvider)
        .ajouterMembres(groupe.id, choisis);
  }
}

/// Liste des comptes de l'église à cocher (recherche par nom).
class _ChoixMembres extends ConsumerStatefulWidget {
  const _ChoixMembres({required this.dejaMembres});

  final Set<String> dejaMembres;

  @override
  ConsumerState<_ChoixMembres> createState() => _ChoixMembresState();
}

class _ChoixMembresState extends ConsumerState<_ChoixMembres> {
  final _choisis = <String>{};
  String _recherche = '';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final noms = ref.watch(annuaireProvider).value ?? const {};
    final mots = sansAccents(_recherche).split(' ').where((m) => m.isNotEmpty);
    final candidats = [
      for (final e in noms.entries)
        if (!widget.dejaMembres.contains(e.key) &&
            mots.every((m) => sansAccents(e.value).contains(m)))
          e,
    ]..sort((a, b) => sansAccents(a.value).compareTo(sansAccents(b.value)));
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.8,
      builder: (context, controleur) => Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: TextField(
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: l10n.rechercherPersonne,
              ),
              onChanged: (v) => setState(() => _recherche = v),
            ),
          ),
          Expanded(
            child: candidats.isEmpty
                ? EtatVide(
                    icone: Icons.person_search,
                    texte: l10n.personneATrouver,
                  )
                : ListView(
                    controller: controleur,
                    children: [
                      for (final e in candidats)
                        CheckboxListTile(
                          value: _choisis.contains(e.key),
                          title: Text(e.value),
                          onChanged: (v) => setState(
                            () => v == true
                                ? _choisis.add(e.key)
                                : _choisis.remove(e.key),
                          ),
                        ),
                    ],
                  ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _choisis.isEmpty
                      ? null
                      : () => Navigator.pop(context, _choisis.toList()),
                  child: Text(l10n.ajouterNombre(_choisis.length)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
