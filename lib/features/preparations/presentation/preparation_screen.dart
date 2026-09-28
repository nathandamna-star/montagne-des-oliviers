import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/roles.dart';
import '../../../core/router/routes.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/domain/sans_accents.dart';
import '../../../shared/domain_traduction.dart';
import '../../../shared/format_date.dart';
import '../../../shared/widgets/etat_vide.dart';
import '../../demandes/domain/demande.dart';
import '../../groupes/groupes_providers.dart';
import '../domain/preparation.dart';
import '../preparations_providers.dart';
import 'preparations_screen.dart';

/// Une préparation : progression et rencontres (candidat), leçons, et pour
/// les pasteurs : leçons à gérer et candidats.
class PreparationScreen extends ConsumerWidget {
  const PreparationScreen({super.key, required this.id});

  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final pasteur = ref.watch(estAdminProvider);
    final preparation = ref.watch(preparationProvider(id));
    final inscrit = ref.watch(monInscritProvider(id)).value;
    final lecons = ref.watch(leconsProvider(id)).value ?? const <Lecon>[];
    final repo = ref.read(preparationsRepositoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          preparation.value == null
              ? l10n.preparations
              : Traduction.dans(preparation.value!.titre, context.langue),
        ),
        actions: [
          if (pasteur)
            IconButton(
              tooltip: l10n.modifier,
              onPressed: () => context.push(Routes.editerPreparation(id)),
              icon: const Icon(Icons.edit_outlined),
            ),
        ],
      ),
      floatingActionButton: pasteur
          ? FloatingActionButton.extended(
              onPressed: () => context.push(Routes.editerLecon(id, 'nouvelle')),
              icon: const Icon(Icons.add),
              label: Text(l10n.ajouterLecon),
            )
          : null,
      body: preparation.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => EtatVide(
          icone: Icons.lock_outline,
          texte: l10n.preparationIndisponible,
        ),
        data: (p) => p == null
            ? EtatVide(
                icone: Icons.menu_book_outlined,
                texte: l10n.preparationIndisponible,
              )
            : Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 720),
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 96),
                    children: [
                      Row(
                        children: [
                          Icon(
                            iconePreparation(p.type),
                            color: theme.colorScheme.secondary,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              Traduction.dans(p.titre, context.langue),
                              style: theme.textTheme.headlineSmall,
                            ),
                          ),
                        ],
                      ),
                      if (p.description.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          Traduction.dans(p.description, context.langue),
                          style: theme.textTheme.bodyLarge,
                        ),
                      ],
                      const SizedBox(height: 16),
                      if (inscrit != null) ...[
                        Text(
                          l10n.progression(
                            inscrit.faites
                                .where((f) => lecons.any((l) => l.id == f))
                                .length,
                            lecons.length,
                          ),
                          style: theme.textTheme.titleSmall,
                        ),
                        const SizedBox(height: 6),
                        LinearProgressIndicator(
                          value: lecons.isEmpty
                              ? 0
                              : inscrit.faites
                                        .where(
                                          (f) => lecons.any((l) => l.id == f),
                                        )
                                        .length /
                                    lecons.length,
                          minHeight: 8,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        if (inscrit.rencontres.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          Text(
                            l10n.mesRencontres,
                            style: theme.textTheme.titleMedium,
                          ),
                          for (final r in inscrit.rencontres)
                            ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: const Icon(Icons.event_outlined),
                              title: Text(r.titre),
                              subtitle: Text(
                                '${context.dateLongue(r.date)}, ${context.heure(r.date)}',
                              ),
                            ),
                        ],
                      ] else if (!pasteur)
                        Card(
                          color: theme.colorScheme.secondaryContainer,
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(l10n.pasInscritPreparation),
                                const SizedBox(height: 8),
                                OutlinedButton(
                                  onPressed: () => context.push(
                                    '${Routes.nouvelleDemande}?type=${p.type == TypePreparation.mariage ? TypeDemande.mariage.name : TypeDemande.bapteme.name}',
                                  ),
                                  child: Text(l10n.faireDemande),
                                ),
                              ],
                            ),
                          ),
                        ),
                      const SizedBox(height: 16),
                      Text(l10n.lecons, style: theme.textTheme.titleMedium),
                      if (lecons.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Text(l10n.aucuneLecon),
                        ),
                      for (final (i, l) in lecons.indexed)
                        Card(
                          child: ListTile(
                            leading:
                                inscrit != null && inscrit.faites.contains(l.id)
                                ? Icon(
                                    Icons.check_circle,
                                    color: theme.colorScheme.secondary,
                                  )
                                : CircleAvatar(
                                    radius: 14,
                                    child: Text('${i + 1}'),
                                  ),
                            title: Text(
                              Traduction.dans(l.titre, context.langue),
                            ),
                            subtitle: Row(
                              children: [
                                if (l.audioUrl != null)
                                  const Icon(Icons.headphones, size: 16),
                                if (l.videoUrl != null)
                                  const Icon(Icons.videocam_outlined, size: 16),
                                if (l.documentUrl != null)
                                  const Icon(
                                    Icons.picture_as_pdf_outlined,
                                    size: 16,
                                  ),
                                if (pasteur && l.publique) ...[
                                  const SizedBox(width: 4),
                                  Text(l10n.publique),
                                ],
                              ],
                            ),
                            trailing: pasteur
                                ? Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        tooltip: l10n.monter,
                                        onPressed: i == 0
                                            ? null
                                            : () => repo.echanger(
                                                id,
                                                l,
                                                lecons[i - 1],
                                              ),
                                        icon: const Icon(Icons.arrow_upward),
                                      ),
                                      IconButton(
                                        tooltip: l10n.descendre,
                                        onPressed: i == lecons.length - 1
                                            ? null
                                            : () => repo.echanger(
                                                id,
                                                l,
                                                lecons[i + 1],
                                              ),
                                        icon: const Icon(Icons.arrow_downward),
                                      ),
                                    ],
                                  )
                                : const Icon(Icons.chevron_right),
                            onTap: () => context.push(Routes.lecon(id, l.id)),
                          ),
                        ),
                      if (pasteur) ...[
                        const SizedBox(height: 24),
                        _Candidats(preparationId: id, nbLecons: lecons.length),
                      ],
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}

/// Pasteurs : candidats inscrits et leur progression.
class _Candidats extends ConsumerWidget {
  const _Candidats({required this.preparationId, required this.nbLecons});

  final String preparationId;
  final int nbLecons;

  Future<void> _inscrire(
    BuildContext context,
    WidgetRef ref,
    Set<String> deja,
  ) async {
    final l10n = AppLocalizations.of(context);
    final noms = ref.read(annuaireProvider).value ?? const {};
    final comptes = [
      for (final e in noms.entries)
        if (!deja.contains(e.key)) e,
    ]..sort((a, b) => sansAccents(a.value).compareTo(sansAccents(b.value)));
    final choisi = await showModalBottomSheet<MapEntry<String, String>>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        builder: (context, controleur) => ListView(
          controller: controleur,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Text(
                l10n.inscrireCandidat,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            for (final e in comptes)
              ListTile(
                title: Text(e.value),
                onTap: () => Navigator.pop(context, e),
              ),
          ],
        ),
      ),
    );
    if (choisi == null) return;
    await ref
        .read(preparationsRepositoryProvider)
        .inscrire(preparationId, uid: choisi.key, nom: choisi.value);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final inscrits =
        ref.watch(inscritsProvider(preparationId)).value ?? const <Inscrit>[];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(l10n.candidats, style: theme.textTheme.titleMedium),
            ),
            TextButton.icon(
              onPressed: () =>
                  _inscrire(context, ref, {for (final i in inscrits) i.uid}),
              icon: const Icon(Icons.person_add_alt),
              label: Text(l10n.inscrire),
            ),
          ],
        ),
        if (inscrits.isEmpty) Text(l10n.aucunCandidat),
        for (final i in inscrits)
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.person_outline),
            title: Text(i.nom),
            subtitle: Text(
              l10n.progression(i.faites.length.clamp(0, nbLecons), nbLecons),
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push(Routes.candidat(preparationId, i.uid)),
          ),
      ],
    );
  }
}
