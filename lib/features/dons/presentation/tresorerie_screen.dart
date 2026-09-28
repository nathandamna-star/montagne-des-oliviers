import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/horloge.dart';
import '../../../core/router/routes.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/domain/virement.dart';
import '../../../shared/format_date.dart';
import '../../../shared/format_euros.dart';
import '../../../shared/services/partage.dart';
import '../../auth/auth_providers.dart';
import '../../boutique/boutique_providers.dart';
import '../../boutique/domain/boutique.dart';
import '../../parametres/parametres_eglise.dart';
import '../dons_providers.dart';
import '../domain/don.dart';
import 'dons_screen.dart';
import 'libelles_dons.dart';

/// Trésorier : virements à confirmer (dons et livres), dons de l'année,
/// export pour la comptabilité.
class TresorerieScreen extends ConsumerWidget {
  const TresorerieScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final coordonnees =
        ref.watch(parametresEgliseProvider).value?.virementPossible ?? true;
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.tresorerie),
          actions: [
            IconButton(
              tooltip: l10n.coordonneesBancaires,
              onPressed: () => context.push(Routes.coordonneesBancaires),
              icon: const Icon(Icons.account_balance_outlined),
            ),
          ],
          bottom: TabBar(
            tabs: [
              Tab(text: l10n.aConfirmer),
              Tab(text: l10n.donsDeLAnnee),
            ],
          ),
        ),
        body: Column(
          children: [
            if (!coordonnees)
              MaterialBanner(
                content: Text(l10n.coordonneesAManquer),
                actions: [
                  TextButton(
                    onPressed: () => context.push(Routes.coordonneesBancaires),
                    child: Text(l10n.completer),
                  ),
                ],
              ),
            const Expanded(
              child: TabBarView(children: [_AConfirmer(), _DonsAnnee()]),
            ),
          ],
        ),
      ),
    );
  }
}

class _AConfirmer extends ConsumerStatefulWidget {
  const _AConfirmer();

  @override
  ConsumerState<_AConfirmer> createState() => _AConfirmerState();
}

class _AConfirmerState extends ConsumerState<_AConfirmer> {
  final _recherche = TextEditingController();

  @override
  void dispose() {
    _recherche.dispose();
    super.dispose();
  }

  /// La communication recopiée d'un extrait de compte, avec ou sans +++ / ;
  /// ou un nom.
  bool _correspond(String id, String nom) {
    final q = _recherche.text.trim().toLowerCase();
    if (q.isEmpty) return true;
    final chiffres = q.replaceAll(RegExp(r'\D'), '');
    return (chiffres.length >= 3 && id.contains(chiffres)) ||
        nom.toLowerCase().contains(q);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final uid = ref.watch(utilisateurFirebaseProvider).value?.uid ?? '';
    final dons = [
      for (final d in ref.watch(donsEnAttenteProvider).value ?? const <Don>[])
        if (d.mode == ModeDon.virement && _correspond(d.id, d.nom)) d,
    ];
    final commandes = [
      for (final c
          in ref.watch(toutesCommandesProvider).value ?? const <Commande>[])
        if (c.parVirement &&
            c.statut == StatutCommande.enAttente &&
            _correspond(c.id, c.nom))
          c,
    ];
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        TextField(
          controller: _recherche,
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.search),
            labelText: l10n.rechercherCommunication,
          ),
        ),
        const SizedBox(height: 8),
        Text(l10n.aConfirmerAide, style: theme.textTheme.bodySmall),
        if (dons.isEmpty && commandes.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Text(l10n.rienAConfirmer, textAlign: TextAlign.center),
          ),
        for (final d in dons)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ListTile(
                    title: Text(
                      '${context.euros(d.montant)} · '
                      '${l10n.affectation(d.affectation)} · ${d.nom}',
                    ),
                    subtitle: Text(
                      [
                        formaterCommunication(d.id),
                        if (d.createdAt != null)
                          context.dateCourte(d.createdAt!),
                      ].join(' · '),
                    ),
                  ),
                  OverflowBar(
                    alignment: MainAxisAlignment.end,
                    spacing: 8,
                    children: [
                      TextButton(
                        onPressed: () => ref
                            .read(donsRepositoryProvider)
                            .confirmer(d.id, recu: false, par: uid),
                        child: Text(l10n.annuler),
                      ),
                      FilledButton(
                        onPressed: () => ref
                            .read(donsRepositoryProvider)
                            .confirmer(d.id, recu: true, par: uid),
                        child: Text(l10n.marquerRecu),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        for (final c in commandes)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ListTile(
                    leading: const Icon(Icons.menu_book_outlined),
                    title: Text(
                      '${context.euros(c.total)} · ${l10n.commande} · ${c.nom}',
                    ),
                    subtitle: Text(formaterCommunication(c.id)),
                    onTap: () => context.push(Routes.commande(c.id)),
                  ),
                  OverflowBar(
                    alignment: MainAxisAlignment.end,
                    children: [
                      FilledButton(
                        onPressed: () => ref
                            .read(boutiqueRepositoryProvider)
                            .changerStatut(
                              c.id,
                              StatutCommande.payee,
                              par: uid,
                            ),
                        child: Text(l10n.marquerRecu),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _DonsAnnee extends ConsumerStatefulWidget {
  const _DonsAnnee();

  @override
  ConsumerState<_DonsAnnee> createState() => _DonsAnneeState();
}

class _DonsAnneeState extends ConsumerState<_DonsAnnee> {
  late int _annee = ref.read(horlogeProvider)().year;

  Future<void> _exporter(List<Don> dons) async {
    final l10n = AppLocalizations.of(context);
    final csv = exporterDonsCsv(
      dons,
      entetes: l10n.entetesCsvDons.split(','),
      libelleAffectation: l10n.affectation,
      libelleMode: l10n.modeDon,
    );
    await ref
        .read(partageProvider)
        .partagerFichier(
          nom: 'dons-$_annee.csv',
          contenu: csv,
          typeMime: 'text/csv',
        );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final dons = recusEn(
      ref.watch(donsDeLAnneeProvider(_annee)).value ?? const <Don>[],
      _annee,
    );
    final mensuels =
        ref.watch(donsMensuelsActifsProvider).value ?? const <DonMensuel>[];
    final anneeCourante = ref.watch(horlogeProvider)().year;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            IconButton(
              tooltip: l10n.anneePrecedente,
              onPressed: () => setState(() => _annee--),
              icon: const Icon(Icons.chevron_left),
            ),
            Text('$_annee', style: theme.textTheme.headlineSmall),
            IconButton(
              tooltip: l10n.anneeSuivante,
              onPressed: _annee >= anneeCourante
                  ? null
                  : () => setState(() => _annee++),
              icon: const Icon(Icons.chevron_right),
            ),
            const Spacer(),
            TextButton.icon(
              onPressed: dons.isEmpty ? null : () => _exporter(dons),
              icon: const Icon(Icons.download_outlined),
              label: Text(l10n.exporterCsv),
            ),
          ],
        ),
        Card(
          child: ListTile(
            title: Text(l10n.totalRecu),
            subtitle: Text(l10n.nombreDons(dons.length)),
            trailing: Text(
              context.euros(totalDons(dons)),
              style: theme.textTheme.titleLarge,
            ),
          ),
        ),
        for (final e in totauxParAffectation(dons).entries)
          ListTile(
            dense: true,
            title: Text(l10n.affectation(e.key)),
            trailing: Text(context.euros(e.value)),
          ),
        if (mensuels.isNotEmpty)
          ListTile(
            dense: true,
            leading: const Icon(Icons.autorenew),
            title: Text(l10n.donsMensuelsActifs(mensuels.length)),
            trailing: Text(
              l10n.parMois(
                context.euros(mensuels.fold(0.0, (s, d) => s + d.montant)),
              ),
            ),
          ),
        const SizedBox(height: 16),
        Text(l10n.parDonateur, style: theme.textTheme.titleMedium),
        for (final (_, nom, total) in totauxParDonateur(dons))
          ListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            title: Text(nom),
            trailing: Text(context.euros(total)),
          ),
        const SizedBox(height: 16),
        Text(l10n.tousLesDons, style: theme.textTheme.titleMedium),
        for (final d in dons.reversed) CarteDon(don: d, avecNom: true),
      ],
    );
  }
}

/// Trésorier : compte bancaire de l'église (dons et livres par virement).
class CoordonneesBancairesScreen extends ConsumerStatefulWidget {
  const CoordonneesBancairesScreen({super.key});

  @override
  ConsumerState<CoordonneesBancairesScreen> createState() =>
      _CoordonneesBancairesScreenState();
}

class _CoordonneesBancairesScreenState
    extends ConsumerState<CoordonneesBancairesScreen> {
  final _formulaire = GlobalKey<FormState>();
  final _titulaire = TextEditingController();
  final _iban = TextEditingController();
  final _bic = TextEditingController();
  bool _charge = false;
  bool _occupe = false;

  @override
  void initState() {
    super.initState();
    ref.read(firestoreProvider).doc('parametres/eglise').get().then((d) {
      if (!mounted) return;
      final p = ParametresEglise.depuis(d.data());
      setState(() {
        _titulaire.text = p.titulaire;
        _iban.text = p.iban.isEmpty ? '' : formaterIban(p.iban);
        _bic.text = p.bic;
        _charge = true;
      });
    });
  }

  @override
  void dispose() {
    for (final c in [_titulaire, _iban, _bic]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _enregistrer() async {
    if (!_formulaire.currentState!.validate()) return;
    final l10n = AppLocalizations.of(context);
    final messager = ScaffoldMessenger.of(context);
    setState(() => _occupe = true);
    try {
      await enregistrerCoordonnees(
        ref.read(firestoreProvider),
        titulaire: _titulaire.text,
        iban: _iban.text,
        bic: _bic.text,
      );
      messager.showSnackBar(SnackBar(content: Text(l10n.enregistre)));
      if (mounted) context.pop();
    } catch (_) {
      messager.showSnackBar(SnackBar(content: Text(l10n.erreurInconnue)));
    } finally {
      if (mounted) setState(() => _occupe = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.coordonneesBancaires)),
      body: !_charge
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 560),
                child: Form(
                  key: _formulaire,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      Text(l10n.coordonneesAide),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _titulaire,
                        decoration: InputDecoration(
                          labelText: l10n.titulaireCompte,
                        ),
                        validator: (v) => (v ?? '').trim().isEmpty
                            ? l10n.champObligatoire
                            : null,
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _iban,
                        decoration: InputDecoration(labelText: l10n.iban),
                        validator: (v) =>
                            ibanValide(v ?? '') ? null : l10n.ibanInvalide,
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _bic,
                        decoration: InputDecoration(
                          labelText: l10n.bicFacultatif,
                        ),
                      ),
                      const SizedBox(height: 24),
                      FilledButton(
                        onPressed: _occupe ? null : _enregistrer,
                        child: Text(l10n.enregistrer),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
