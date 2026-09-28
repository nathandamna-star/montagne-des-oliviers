import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/app_localizations.dart';
import '../../../shared/domain/sans_accents.dart';
import '../../../shared/widgets/etat_vide.dart';
import '../groupes_providers.dart';

/// Liste des comptes de l'église à cocher (recherche par nom).
class ChoixPersonnes extends ConsumerStatefulWidget {
  const ChoixPersonnes({super.key, required this.titre, required this.exclus});

  final String titre;

  /// Déjà présents : pas proposés.
  final Set<String> exclus;

  @override
  ConsumerState<ChoixPersonnes> createState() => _ChoixPersonnesState();
}

class _ChoixPersonnesState extends ConsumerState<ChoixPersonnes> {
  final _choisis = <String>{};
  String _recherche = '';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final noms = ref.watch(annuaireProvider).value ?? const {};
    final mots = sansAccents(_recherche).split(' ').where((m) => m.isNotEmpty);
    final candidats = [
      for (final e in noms.entries)
        if (!widget.exclus.contains(e.key) &&
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
            child: Text(
              widget.titre,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
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
