import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/routes.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/etat_vide.dart';
import '../domain/membre.dart';
import '../membres_providers.dart';

/// Liste des familles et nombre de personnes dans chacune.
class FamillesScreen extends ConsumerWidget {
  const FamillesScreen({super.key});

  Future<void> _creer(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final nom = await demanderNomFamille(
      context,
      titre: l10n.nouvelleFamille,
      bouton: l10n.creer,
    );
    if (nom == null) return;
    final id = await ref.read(membresRepositoryProvider).creerFamille(nom);
    if (context.mounted) context.push(Routes.famille(id));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final familles = ref.watch(famillesProvider);
    final membres = ref.watch(membresProvider).value ?? const <Membre>[];
    return Scaffold(
      appBar: AppBar(title: Text(l10n.familles)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _creer(context, ref),
        icon: const Icon(Icons.add),
        label: Text(l10n.nouvelleFamille),
      ),
      body: familles.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) =>
            EtatVide(icone: Icons.cloud_off, texte: l10n.erreurChargement),
        data: (liste) => liste.isEmpty
            ? EtatVide(icone: Icons.family_restroom, texte: l10n.aucuneFamille)
            : ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
                children: [
                  for (final f in liste)
                    Card(
                      child: ListTile(
                        leading: const Icon(Icons.family_restroom),
                        title: Text(f.nom),
                        subtitle: Text(
                          l10n.nombrePersonnesFamille(
                            membres.where((m) => m.familleId == f.id).length,
                          ),
                        ),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => context.push(Routes.famille(f.id)),
                      ),
                    ),
                ],
              ),
      ),
    );
  }
}

/// Une famille : ses membres, en ajouter, en retirer, la renommer.
class FamilleScreen extends ConsumerWidget {
  const FamilleScreen({super.key, required this.id});

  final String id;

  Future<void> _ajouter(
    BuildContext context,
    WidgetRef ref,
    List<Membre> autres,
  ) async {
    final l10n = AppLocalizations.of(context);
    final choisi = await showModalBottomSheet<String>(
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
                l10n.ajouterALaFamille,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            for (final m in autres)
              ListTile(
                title: Text('${m.nom.toUpperCase()} ${m.prenom}'),
                onTap: () => Navigator.pop(context, m.id),
              ),
          ],
        ),
      ),
    );
    if (choisi != null) {
      await ref.read(membresRepositoryProvider).rattacher(choisi, id);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final famille = (ref.watch(famillesProvider).value ?? const <Famille>[])
        .where((f) => f.id == id)
        .firstOrNull;
    final tous = ref.watch(membresProvider).value ?? const <Membre>[];
    final dedans = [
      for (final m in tous)
        if (m.familleId == id) m,
    ];
    final repo = ref.read(membresRepositoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(famille?.nom ?? l10n.champFamille),
        actions: [
          IconButton(
            tooltip: l10n.renommer,
            onPressed: famille == null
                ? null
                : () async {
                    final nom = await demanderNomFamille(
                      context,
                      titre: l10n.renommer,
                      initial: famille.nom,
                    );
                    if (nom != null) await repo.renommerFamille(id, nom);
                  },
            icon: const Icon(Icons.edit_outlined),
          ),
          IconButton(
            tooltip: l10n.supprimer,
            onPressed: () async {
              final ok = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text(l10n.supprimerFamille),
                  content: Text(l10n.supprimerFamilleAide),
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
              await repo.supprimerFamille(id);
              if (context.mounted) context.pop();
            },
            icon: const Icon(Icons.delete_outline),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _ajouter(context, ref, [
          for (final m in tous)
            if (m.familleId != id) m,
        ]),
        icon: const Icon(Icons.person_add_alt),
        label: Text(l10n.ajouterALaFamille),
      ),
      body: dedans.isEmpty
          ? EtatVide(icone: Icons.family_restroom, texte: l10n.familleVide)
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
              children: [
                for (final m in dedans)
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.person_outline),
                      title: Text('${m.nom.toUpperCase()} ${m.prenom}'),
                      onTap: () => context.push(Routes.ficheMembre(m.id)),
                      trailing: IconButton(
                        tooltip: l10n.retirerDeLaFamille,
                        onPressed: () => repo.rattacher(m.id, null),
                        icon: const Icon(Icons.link_off),
                      ),
                    ),
                  ),
              ],
            ),
    );
  }
}

/// Demande le nom d'une famille ; null si annulé ou vide.
Future<String?> demanderNomFamille(
  BuildContext context, {
  required String titre,
  String initial = '',
  String? bouton,
}) async {
  final nom = await showDialog<String>(
    context: context,
    builder: (context) =>
        _DialogueNom(titre: titre, initial: initial, bouton: bouton),
  );
  return nom == null || nom.isEmpty ? null : nom;
}

/// Le champ de texte vit avec la boîte de dialogue (libéré à sa fermeture).
class _DialogueNom extends StatefulWidget {
  const _DialogueNom({required this.titre, required this.initial, this.bouton});

  final String titre;
  final String initial;
  final String? bouton;

  @override
  State<_DialogueNom> createState() => _DialogueNomState();
}

class _DialogueNomState extends State<_DialogueNom> {
  late final _nom = TextEditingController(text: widget.initial);

  @override
  void dispose() {
    _nom.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(widget.titre),
      content: TextField(
        controller: _nom,
        autofocus: true,
        decoration: InputDecoration(labelText: l10n.nomFamilleChamp),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.annuler),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, _nom.text.trim()),
          child: Text(widget.bouton ?? l10n.valider),
        ),
      ],
    );
  }
}
