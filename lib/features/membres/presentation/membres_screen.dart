import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/routes.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/services/partage.dart';
import '../../../shared/widgets/etat_vide.dart';
import '../domain/export_csv.dart';
import '../domain/membre.dart';
import '../membres_providers.dart';
import 'libelles_membres.dart';

/// Fichier des membres (secrétariat, pasteurs) : recherche, filtres, export.
class MembresScreen extends ConsumerStatefulWidget {
  const MembresScreen({super.key});

  @override
  ConsumerState<MembresScreen> createState() => _MembresScreenState();
}

class _MembresScreenState extends ConsumerState<MembresScreen> {
  final _recherche = TextEditingController();
  StatutMembre? _statut;

  @override
  void dispose() {
    _recherche.dispose();
    super.dispose();
  }

  List<Membre> _filtrer(List<Membre> tous) {
    final mots = sansAccents(_recherche.text)
        .split(' ')
        .where((m) => m.isNotEmpty);
    return [
      for (final m in tous)
        if ((_statut == null || m.statut == _statut) &&
            mots.every((mot) => m.cle.contains(mot)))
          m,
    ];
  }

  Future<void> _exporter(List<Membre> liste) async {
    final l10n = AppLocalizations.of(context);
    final familles = {
      for (final f in ref.read(famillesProvider).value ?? const <Famille>[])
        f.id: f.nom,
    };
    final csv = exporterCsv(
      liste,
      familles: familles,
      entetes: l10n.entetesCsv,
      libelleStatut: l10n.libelleStatut,
    );
    final n = DateTime.now();
    final date =
        '${n.year}-${n.month.toString().padLeft(2, '0')}-${n.day.toString().padLeft(2, '0')}';
    await ref
        .read(partageProvider)
        .partagerFichier(
          nom: 'membres-$date.csv',
          contenu: csv,
          typeMime: 'text/csv',
        );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final membres = ref.watch(membresProvider);
    final sansFiche = ref.watch(comptesSansFicheProvider);
    final large = MediaQuery.sizeOf(context).width >= 900;
    final liste = _filtrer(membres.value ?? const []);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.fichierMembres),
        actions: [
          IconButton(
            tooltip: l10n.familles,
            onPressed: () => context.push(Routes.familles),
            icon: const Icon(Icons.family_restroom),
          ),
          IconButton(
            tooltip: l10n.exporterCsv,
            onPressed: liste.isEmpty ? null : () => _exporter(liste),
            icon: const Icon(Icons.download_outlined),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(Routes.ficheMembre('nouveau')),
        icon: const Icon(Icons.person_add_alt),
        label: Text(l10n.nouvelleFiche),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: TextField(
              controller: _recherche,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: l10n.rechercherMembre,
              ),
              onChanged: (_) => setState(() {}),
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                ChoiceChip(
                  label: Text(l10n.tous),
                  selected: _statut == null,
                  onSelected: (_) => setState(() => _statut = null),
                ),
                for (final s in StatutMembre.values) ...[
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: Text(l10n.libelleStatut(s)),
                    selected: _statut == s,
                    onSelected: (_) => setState(() => _statut = s),
                  ),
                ],
              ],
            ),
          ),
          if (sansFiche.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Card(
                color: theme.colorScheme.secondaryContainer,
                child: ListTile(
                  leading: const Icon(Icons.person_search_outlined),
                  title: Text(l10n.comptesSansFiche(sansFiche.length)),
                  subtitle: Text(l10n.comptesSansFicheAide),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _choisirCompte(context),
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                l10n.nombreFiches(liste.length),
                style: theme.textTheme.labelLarge,
              ),
            ),
          ),
          Expanded(
            child: membres.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, _) => EtatVide(
                icone: Icons.cloud_off,
                texte: l10n.erreurChargement,
              ),
              data: (_) => liste.isEmpty
                  ? EtatVide(
                      icone: Icons.people_outline,
                      texte: l10n.aucuneFiche,
                    )
                  : large
                  ? _Tableau(membres: liste)
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 96),
                      itemCount: liste.length,
                      itemBuilder: (context, i) => _Ligne(membre: liste[i]),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  /// Créer une fiche à partir d'un compte de l'app (nom et e-mail repris).
  Future<void> _choisirCompte(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final uid = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (context) => Consumer(
        builder: (context, ref, _) {
          final comptes = ref.watch(comptesSansFicheProvider);
          return ListView(
            shrinkWrap: true,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: Text(
                  l10n.creerFicheDepuisCompte,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              for (final c in comptes)
                ListTile(
                  leading: const Icon(Icons.person_outline),
                  title: Text(c.nom),
                  subtitle: Text(c.email),
                  onTap: () => Navigator.pop(context, c.uid),
                ),
            ],
          );
        },
      ),
    );
    if (uid != null && context.mounted) {
      context.push('${Routes.ficheMembre('nouveau')}?uid=$uid');
    }
  }
}

class _Ligne extends ConsumerWidget {
  const _Ligne({required this.membre});

  final Membre membre;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final m = membre;
    final details = [
      if (m.telephone.isNotEmpty) m.telephone,
      if (m.email.isNotEmpty) m.email,
      if (m.ville.isNotEmpty) m.ville,
    ].join(' · ');
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          child: Text(
            (m.prenom.isNotEmpty ? m.prenom : m.nom).characters.first
                .toUpperCase(),
          ),
        ),
        title: Text('${m.nom.toUpperCase()} ${m.prenom}'),
        subtitle: details.isEmpty ? null : Text(details),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (m.uid != null)
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Icon(
                  Icons.phone_iphone,
                  size: 18,
                  color: theme.colorScheme.onSurfaceVariant,
                  semanticLabel: l10n.compteLie,
                ),
              ),
            Text(
              l10n.libelleStatut(m.statut),
              style: theme.textTheme.labelMedium?.copyWith(
                color: couleurStatut(theme.colorScheme, m.statut),
              ),
            ),
          ],
        ),
        onTap: () => context.push(Routes.ficheMembre(m.id)),
      ),
    );
  }
}

/// Grand écran (ordinateur) : tableau.
class _Tableau extends ConsumerWidget {
  const _Tableau({required this.membres});

  final List<Membre> membres;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final familles = {
      for (final f in ref.watch(famillesProvider).value ?? const <Famille>[])
        f.id: f.nom,
    };
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 96),
      child: SizedBox(
        width: double.infinity,
        child: DataTable(
          showCheckboxColumn: false,
          columns: [
            DataColumn(label: Text(l10n.champNomFamille)),
            DataColumn(label: Text(l10n.champPrenom)),
            DataColumn(label: Text(l10n.champStatut)),
            DataColumn(label: Text(l10n.champTelephone)),
            DataColumn(label: Text(l10n.champEmail)),
            DataColumn(label: Text(l10n.champVille)),
            DataColumn(label: Text(l10n.champFamille)),
          ],
          rows: [
            for (final m in membres)
              DataRow(
                onSelectChanged: (_) => context.push(Routes.ficheMembre(m.id)),
                cells: [
                  DataCell(Text(m.nom.toUpperCase())),
                  DataCell(Text(m.prenom)),
                  DataCell(
                    Text(
                      l10n.libelleStatut(m.statut),
                      style: TextStyle(
                        color: couleurStatut(theme.colorScheme, m.statut),
                      ),
                    ),
                  ),
                  DataCell(Text(m.telephone)),
                  DataCell(Text(m.email)),
                  DataCell(Text(m.ville)),
                  DataCell(Text(familles[m.familleId] ?? '')),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
