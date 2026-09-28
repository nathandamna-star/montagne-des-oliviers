import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/roles.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/format_date.dart';
import '../../../shared/widgets/etat_vide.dart';
import '../../auth/auth_providers.dart';
import '../domain/priere.dart';
import '../prieres_providers.dart';

/// Un sujet de prière : « J'ai prié », exaucement et témoignage.
class PriereScreen extends ConsumerWidget {
  const PriereScreen({super.key, required this.id});

  final String id;

  Future<void> _exaucee(BuildContext context, WidgetRef ref, Priere p) async {
    final l10n = AppLocalizations.of(context);
    final temoignage = await showDialog<String>(
      context: context,
      builder: (context) => _DialogueTemoignage(initial: p.temoignage),
    );
    if (temoignage == null) return;
    await ref
        .read(prieresRepositoryProvider)
        .exaucee(p.id, oui: true, temoignage: temoignage);
    if (context.mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l10n.gloireADieu)));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final uid = ref.watch(utilisateurFirebaseProvider).value?.uid;
    final pasteur = ref.watch(estAdminProvider);
    final priere = ref.watch(priereProvider(id));
    final aiPrie = ref.watch(aiPrieProvider(id)).value ?? false;
    final repo = ref.read(prieresRepositoryProvider);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.sujetPriere)),
      body: priere.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) =>
            EtatVide(icone: Icons.lock_outline, texte: l10n.sujetIndisponible),
        data: (p) {
          if (p == null) {
            return EtatVide(
              icone: Icons.lock_outline,
              texte: l10n.sujetIndisponible,
            );
          }
          final moi = p.uid == uid;
          final nomVisible = moi || pasteur || !p.anonyme;
          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  Text(
                    [
                      nomVisible ? p.nom : l10n.anonyme,
                      if (p.createdAt != null) context.dateLongue(p.createdAt!),
                    ].join(' · '),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    p.partage == PartagePriere.pasteurs
                        ? l10n.partagePasteurs
                        : l10n.partageIntercession,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.secondary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SelectableText(p.texte, style: theme.textTheme.bodyLarge),
                  const SizedBox(height: 16),
                  Text(
                    l10n.nombrePrieres(p.nbPrieres),
                    style: theme.textTheme.titleSmall,
                  ),
                  if (p.exaucee) ...[
                    const SizedBox(height: 16),
                    Card(
                      color: theme.colorScheme.secondaryContainer,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.celebration_outlined),
                                const SizedBox(width: 8),
                                Text(
                                  l10n.priereExaucee,
                                  style: theme.textTheme.titleMedium,
                                ),
                              ],
                            ),
                            if (p.temoignage.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              SelectableText(p.temoignage),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  if (!moi)
                    aiPrie
                        ? OutlinedButton.icon(
                            onPressed: null,
                            icon: const Icon(Icons.check),
                            label: Text(l10n.vousAvezPrie),
                          )
                        : FilledButton.icon(
                            onPressed: () => repo.jaiPrie(p.id, uid!),
                            icon: const Icon(Icons.volunteer_activism),
                            label: Text(l10n.jaiPrie),
                          ),
                  if (moi) ...[
                    if (!p.exaucee)
                      FilledButton.icon(
                        onPressed: () => _exaucee(context, ref, p),
                        icon: const Icon(Icons.celebration_outlined),
                        label: Text(l10n.annoncerExaucement),
                      )
                    else
                      OutlinedButton(
                        onPressed: () => _exaucee(context, ref, p),
                        child: Text(l10n.modifierTemoignage),
                      ),
                    const SizedBox(height: 8),
                    TextButton.icon(
                      onPressed: () async {
                        final ok = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text(l10n.supprimerSujet),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: Text(l10n.annuler),
                              ),
                              FilledButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: Text(l10n.supprimer),
                              ),
                            ],
                          ),
                        );
                        if (ok != true) return;
                        await repo.supprimer(p.id);
                        if (context.mounted) context.pop();
                      },
                      icon: const Icon(Icons.delete_outline),
                      label: Text(l10n.supprimer),
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

class _DialogueTemoignage extends StatefulWidget {
  const _DialogueTemoignage({required this.initial});

  final String initial;

  @override
  State<_DialogueTemoignage> createState() => _DialogueTemoignageState();
}

class _DialogueTemoignageState extends State<_DialogueTemoignage> {
  late final _texte = TextEditingController(text: widget.initial);

  @override
  void dispose() {
    _texte.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(l10n.priereExaucee),
      content: TextField(
        controller: _texte,
        autofocus: true,
        minLines: 3,
        maxLines: 6,
        decoration: InputDecoration(labelText: l10n.temoignageFacultatif),
        textCapitalization: TextCapitalization.sentences,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.annuler),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, _texte.text),
          child: Text(l10n.valider),
        ),
      ],
    );
  }
}
