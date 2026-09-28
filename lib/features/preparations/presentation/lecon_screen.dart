import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/roles.dart';
import '../../../core/router/routes.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/domain_traduction.dart';
import '../../../shared/format_date.dart';
import '../../../shared/lecteurs/lecteurs.dart';
import '../../../shared/services/lanceur.dart';
import '../../../shared/widgets/etat_vide.dart';
import '../../auth/auth_providers.dart';
import '../preparations_providers.dart';

/// Une leçon : texte, audio, vidéo, document ; « terminée » et questions.
class LeconScreen extends ConsumerWidget {
  const LeconScreen({super.key, required this.preparationId, required this.id});

  final String preparationId;
  final String id;

  Future<void> _question(
    BuildContext context,
    WidgetRef ref,
    String uid,
  ) async {
    final l10n = AppLocalizations.of(context);
    final texte = await showDialog<String>(
      context: context,
      builder: (context) => const _DialogueQuestion(),
    );
    if (texte == null || texte.trim().isEmpty) return;
    await ref
        .read(preparationsRepositoryProvider)
        .poserQuestion(preparationId, uid, texte: texte, leconId: id);
    if (context.mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l10n.questionEnvoyee)));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final pasteur = ref.watch(estAdminProvider);
    final uid = ref.watch(utilisateurFirebaseProvider).value?.uid;
    final lecon = ref.watch(leconProvider((preparationId, id)));
    final inscrit = ref.watch(monInscritProvider(preparationId)).value;
    final questions = inscrit == null || uid == null
        ? const []
        : [
            for (final q
                in ref.watch(questionsProvider((preparationId, uid))).value ??
                    const [])
              if (q.leconId == id) q,
          ];
    final lecteurs = ref.watch(fabriqueLecteursProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.lecon),
        actions: [
          if (pasteur)
            IconButton(
              tooltip: l10n.modifier,
              onPressed: () =>
                  context.push(Routes.editerLecon(preparationId, id)),
              icon: const Icon(Icons.edit_outlined),
            ),
        ],
      ),
      body: lecon.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) =>
            EtatVide(icone: Icons.lock_outline, texte: l10n.leconReservee),
        data: (l) => l == null
            ? EtatVide(
                icone: Icons.menu_book_outlined,
                texte: l10n.leconReservee,
              )
            : Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 720),
                  child: ListView(
                    padding: const EdgeInsets.all(20),
                    children: [
                      Text(
                        Traduction.dans(l.titre, context.langue),
                        style: theme.textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 16),
                      if (l.videoUrl != null) ...[
                        lecteurs.video(url: l.videoUrl!, cle: 'prep-$id-video'),
                        const SizedBox(height: 16),
                      ],
                      if (l.audioUrl != null) ...[
                        lecteurs.audio(url: l.audioUrl!, cle: 'prep-$id-audio'),
                        const SizedBox(height: 16),
                      ],
                      if (l.texte.isNotEmpty)
                        SelectableText(
                          Traduction.dans(l.texte, context.langue),
                          style: theme.textTheme.bodyLarge,
                        ),
                      if (l.documentUrl != null) ...[
                        const SizedBox(height: 16),
                        OutlinedButton.icon(
                          onPressed: () => ref
                              .read(lanceurProvider)
                              .ouvrir(Uri.parse(l.documentUrl!)),
                          icon: const Icon(Icons.picture_as_pdf_outlined),
                          label: Text(l10n.ouvrirDocument),
                        ),
                      ],
                      if (inscrit != null && uid != null) ...[
                        const SizedBox(height: 24),
                        inscrit.faites.contains(id)
                            ? OutlinedButton.icon(
                                onPressed: () => ref
                                    .read(preparationsRepositoryProvider)
                                    .marquerFaite(
                                      preparationId,
                                      uid,
                                      id,
                                      faite: false,
                                    ),
                                icon: const Icon(Icons.check_circle),
                                label: Text(l10n.leconTerminee),
                              )
                            : FilledButton.icon(
                                onPressed: () => ref
                                    .read(preparationsRepositoryProvider)
                                    .marquerFaite(
                                      preparationId,
                                      uid,
                                      id,
                                      faite: true,
                                    ),
                                icon: const Icon(Icons.check),
                                label: Text(l10n.marquerTerminee),
                              ),
                        const SizedBox(height: 24),
                        Text(
                          l10n.mesQuestions,
                          style: theme.textTheme.titleMedium,
                        ),
                        for (final q in questions)
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(q.texte),
                                  if (q.createdAt != null)
                                    Text(
                                      context.dateCourte(q.createdAt!),
                                      style: theme.textTheme.labelSmall,
                                    ),
                                  const SizedBox(height: 6),
                                  Text(
                                    q.reponse.isEmpty
                                        ? l10n.enAttenteReponse
                                        : q.reponse,
                                    style: TextStyle(
                                      color: q.reponse.isEmpty
                                          ? theme.colorScheme.onSurfaceVariant
                                          : theme.colorScheme.primary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        TextButton.icon(
                          onPressed: () => _question(context, ref, uid),
                          icon: const Icon(Icons.help_outline),
                          label: Text(l10n.poserQuestion),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}

class _DialogueQuestion extends StatefulWidget {
  const _DialogueQuestion();

  @override
  State<_DialogueQuestion> createState() => _DialogueQuestionState();
}

class _DialogueQuestionState extends State<_DialogueQuestion> {
  final _texte = TextEditingController();

  @override
  void dispose() {
    _texte.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(l10n.poserQuestion),
      content: TextField(
        controller: _texte,
        autofocus: true,
        minLines: 3,
        maxLines: 6,
        decoration: InputDecoration(labelText: l10n.votreQuestion),
        textCapitalization: TextCapitalization.sentences,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.annuler),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, _texte.text),
          child: Text(l10n.envoyerMessage),
        ),
      ],
    );
  }
}
