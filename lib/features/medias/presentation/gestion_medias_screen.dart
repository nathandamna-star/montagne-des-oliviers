import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/routes.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/domain_traduction.dart';
import '../../../shared/format_date.dart';
import '../../../shared/widgets/champs_traduits.dart';
import '../../../shared/widgets/etat_vide.dart';
import '../medias_providers.dart';
import 'widgets_medias.dart';

/// Secrétariat : tous les médias et les versets du jour.
class GestionMediasScreen extends ConsumerWidget {
  const GestionMediasScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final medias = ref.watch(tousMediasProvider);
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.gestionMedias),
          bottom: TabBar(
            tabs: [
              Tab(text: l10n.predicationsEtDirects),
              Tab(text: l10n.versetsDuJour),
            ],
          ),
        ),
        floatingActionButton: Builder(
          builder: (context) {
            final onglets = DefaultTabController.of(context);
            return AnimatedBuilder(
              animation: onglets,
              builder: (context, _) => onglets.index == 0
                  ? FloatingActionButton.extended(
                      onPressed: () =>
                          context.push(Routes.editerMedia('nouveau')),
                      icon: const Icon(Icons.add),
                      label: Text(l10n.nouveauMedia),
                    )
                  : FloatingActionButton.extended(
                      onPressed: () {
                        final versets =
                            ref.read(versetsProvider).value ?? const [];
                        showDialog<void>(
                          context: context,
                          builder: (context) => _DialogueVerset(
                            ordre: versets.isEmpty ? 1 : versets.last.ordre + 1,
                          ),
                        );
                      },
                      icon: const Icon(Icons.add),
                      label: Text(l10n.ajouterVerset),
                    ),
            );
          },
        ),
        body: TabBarView(
          children: [
            Stack(
              children: [
                medias.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (_, _) => EtatVide(
                    icone: Icons.cloud_off,
                    texte: l10n.erreurChargement,
                  ),
                  data: (liste) => liste.isEmpty
                      ? EtatVide(
                          icone: Icons.play_circle_outline,
                          texte: l10n.aucunMedia,
                        )
                      : ListView(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
                          children: [
                            for (final m in liste)
                              CarteMedia(
                                media: m,
                                lien: Routes.editerMedia(m.id),
                              ),
                          ],
                        ),
                ),
              ],
            ),
            const _Versets(),
          ],
        ),
      ),
    );
  }
}

class _Versets extends ConsumerWidget {
  const _Versets();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final versets = ref.watch(versetsProvider).value ?? const [];
    final aujourdhui = ref.watch(versetDuJourProvider);
    final repo = ref.read(mediasRepositoryProvider);
    return Stack(
      children: [
        ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
          children: [
            Text(l10n.versetsAide),
            const SizedBox(height: 8),
            if (versets.isEmpty) Text(l10n.aucunVerset),
            for (final v in versets)
              Card(
                child: ListTile(
                  leading: v.id == aujourdhui?.id
                      ? const Icon(Icons.today)
                      : Text('${v.ordre}'),
                  title: Text(v.reference),
                  subtitle: Text(
                    Traduction.dans(v.texte, context.langue),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: IconButton(
                    tooltip: l10n.supprimer,
                    onPressed: () => repo.supprimerVerset(v.id),
                    icon: const Icon(Icons.delete_outline),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _DialogueVerset extends ConsumerStatefulWidget {
  const _DialogueVerset({required this.ordre});

  final int ordre;

  @override
  ConsumerState<_DialogueVerset> createState() => _DialogueVersetState();
}

class _DialogueVersetState extends ConsumerState<_DialogueVerset> {
  final _reference = TextEditingController();
  final _fr = TextEditingController();
  final _nl = TextEditingController();

  @override
  void dispose() {
    _reference.dispose();
    _fr.dispose();
    _nl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(l10n.ajouterVerset),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _reference,
              decoration: InputDecoration(
                labelText: l10n.referenceBiblique,
                hintText: 'Jean 3:16',
              ),
            ),
            const SizedBox(height: 8),
            ChampsTraduits(
              libelle: l10n.champTexte,
              fr: _fr,
              nl: _nl,
              lignes: 3,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.annuler),
        ),
        FilledButton(
          onPressed: () async {
            if (_reference.text.trim().isEmpty || _fr.text.trim().isEmpty) {
              return;
            }
            await ref
                .read(mediasRepositoryProvider)
                .ajouterVerset(
                  reference: _reference.text,
                  texte: Traduction.ecrire(_fr.text, _nl.text),
                  ordre: widget.ordre,
                );
            if (context.mounted) Navigator.pop(context);
          },
          child: Text(l10n.enregistrer),
        ),
      ],
    );
  }
}
