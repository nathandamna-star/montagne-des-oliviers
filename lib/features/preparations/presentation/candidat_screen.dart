import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../l10n/app_localizations.dart';
import '../../../shared/domain_traduction.dart';
import '../../../shared/format_date.dart';
import '../../../shared/widgets/etat_vide.dart';
import '../domain/preparation.dart';
import '../preparations_providers.dart';

/// Pasteurs : suivi d'un candidat (leçons, rencontres, questions).
class CandidatScreen extends ConsumerWidget {
  const CandidatScreen({
    super.key,
    required this.preparationId,
    required this.uid,
  });

  final String preparationId;
  final String uid;

  Future<void> _ajouterRencontre(
    BuildContext context,
    WidgetRef ref,
    Inscrit i,
  ) async {
    final r = await showDialog<RencontrePastorale>(
      context: context,
      builder: (context) => const _DialogueRencontre(),
    );
    if (r == null) return;
    await ref.read(preparationsRepositoryProvider).definirRencontres(
      preparationId,
      uid,
      [...i.rencontres, r],
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final inscrit = ref.watch(inscritProvider((preparationId, uid)));
    final lecons =
        ref.watch(leconsProvider(preparationId)).value ?? const <Lecon>[];
    final questions =
        ref.watch(questionsProvider((preparationId, uid))).value ?? const [];
    final repo = ref.read(preparationsRepositoryProvider);
    return Scaffold(
      appBar: AppBar(title: Text(inscrit.value?.nom ?? l10n.candidats)),
      body: inscrit.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) =>
            EtatVide(icone: Icons.cloud_off, texte: l10n.erreurChargement),
        data: (i) => i == null
            ? EtatVide(
                icone: Icons.person_off_outlined,
                texte: l10n.aucunCandidat,
              )
            : Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 720),
                  child: ListView(
                    padding: const EdgeInsets.all(20),
                    children: [
                      Text(
                        l10n.progression(
                          i.faites
                              .where((f) => lecons.any((l) => l.id == f))
                              .length,
                          lecons.length,
                        ),
                        style: theme.textTheme.titleMedium,
                      ),
                      for (final l in lecons)
                        ListTile(
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                          leading: Icon(
                            i.faites.contains(l.id)
                                ? Icons.check_circle
                                : Icons.radio_button_unchecked,
                            color: i.faites.contains(l.id)
                                ? theme.colorScheme.secondary
                                : null,
                          ),
                          title: Text(Traduction.dans(l.titre, context.langue)),
                        ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              l10n.rencontres,
                              style: theme.textTheme.titleMedium,
                            ),
                          ),
                          TextButton.icon(
                            onPressed: () => _ajouterRencontre(context, ref, i),
                            icon: const Icon(Icons.add),
                            label: Text(l10n.planifier),
                          ),
                        ],
                      ),
                      if (i.rencontres.isEmpty) Text(l10n.aucuneRencontre),
                      for (final r in i.rencontres)
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(Icons.event_outlined),
                          title: Text(r.titre),
                          subtitle: Text(
                            '${context.dateLongue(r.date)}, ${context.heure(r.date)}',
                          ),
                          trailing: IconButton(
                            tooltip: l10n.retirer,
                            onPressed: () =>
                                repo.definirRencontres(preparationId, uid, [
                                  for (final x in i.rencontres)
                                    if (x != r) x,
                                ]),
                            icon: const Icon(Icons.close),
                          ),
                        ),
                      const SizedBox(height: 16),
                      Text(l10n.questions, style: theme.textTheme.titleMedium),
                      if (questions.isEmpty) Text(l10n.aucuneQuestion),
                      for (final q in questions)
                        _Question(
                          preparationId: preparationId,
                          uid: uid,
                          question: q,
                        ),
                      const SizedBox(height: 24),
                      TextButton.icon(
                        onPressed: () async {
                          await repo.desinscrire(preparationId, uid);
                          if (context.mounted) context.pop();
                        },
                        icon: const Icon(Icons.person_remove_outlined),
                        label: Text(l10n.desinscrire),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}

class _Question extends ConsumerStatefulWidget {
  const _Question({
    required this.preparationId,
    required this.uid,
    required this.question,
  });

  final String preparationId;
  final String uid;
  final QuestionCandidat question;

  @override
  ConsumerState<_Question> createState() => _QuestionState();
}

class _QuestionState extends ConsumerState<_Question> {
  late final _reponse = TextEditingController(text: widget.question.reponse);

  @override
  void dispose() {
    _reponse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(widget.question.texte),
            TextField(
              controller: _reponse,
              decoration: InputDecoration(labelText: l10n.votreReponse),
              minLines: 1,
              maxLines: 5,
              textCapitalization: TextCapitalization.sentences,
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () async {
                  await ref
                      .read(preparationsRepositoryProvider)
                      .repondre(
                        widget.preparationId,
                        widget.uid,
                        widget.question.id,
                        _reponse.text,
                      );
                  if (context.mounted) {
                    ScaffoldMessenger.of(context)
                      ..hideCurrentSnackBar()
                      ..showSnackBar(
                        SnackBar(content: Text(l10n.reponseEnvoyee)),
                      );
                  }
                },
                child: Text(l10n.repondre),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DialogueRencontre extends StatefulWidget {
  const _DialogueRencontre();

  @override
  State<_DialogueRencontre> createState() => _DialogueRencontreState();
}

class _DialogueRencontreState extends State<_DialogueRencontre> {
  final _titre = TextEditingController();
  DateTime? _date;

  @override
  void dispose() {
    _titre.dispose();
    super.dispose();
  }

  Future<void> _choisir() async {
    final jour = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (jour == null || !mounted) return;
    final heure = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 14, minute: 0),
    );
    if (heure == null) return;
    setState(
      () => _date = DateTime(
        jour.year,
        jour.month,
        jour.day,
        heure.hour,
        heure.minute,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(l10n.planifier),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _titre,
            decoration: InputDecoration(
              labelText: l10n.champTitre,
              hintText: l10n.rencontreAide,
            ),
            textCapitalization: TextCapitalization.sentences,
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.schedule),
            title: Text(
              _date == null
                  ? l10n.dateEtHeure
                  : '${context.dateLongue(_date!)}, ${context.heure(_date!)}',
            ),
            onTap: _choisir,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.annuler),
        ),
        FilledButton(
          onPressed: _titre.text.trim().isEmpty && _date == null
              ? null
              : () {
                  if (_titre.text.trim().isEmpty || _date == null) return;
                  Navigator.pop(
                    context,
                    RencontrePastorale(titre: _titre.text.trim(), date: _date!),
                  );
                },
          child: Text(l10n.valider),
        ),
      ],
    );
  }
}
