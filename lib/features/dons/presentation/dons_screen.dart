import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/routes.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/domain/virement.dart';
import '../../../shared/format_date.dart';
import '../../../shared/format_euros.dart';
import '../../../shared/services/lanceur.dart';
import '../../../shared/services/paiements_en_ligne.dart';
import '../../../shared/widgets/connexion_requise.dart';
import '../../auth/auth_providers.dart';
import '../../parametres/parametres_eglise.dart';
import '../dons_providers.dart';
import '../domain/don.dart';
import 'libelles_dons.dart';

/// Page des dons sur le site de l'église (ouverte depuis l'iPhone).
final pageDonsWeb = Uri.parse(
  'https://montagne-des-oliviers.web.app/#/accueil/dons',
);

const _montantsProposes = [10.0, 20.0, 50.0, 100.0];

/// Dîmes et offrandes : donner (virement avec QR code, carte ou Bancontact,
/// don mensuel), suivre ses dons, relevé annuel.
class DonsScreen extends ConsumerStatefulWidget {
  const DonsScreen({super.key});

  @override
  ConsumerState<DonsScreen> createState() => _DonsScreenState();
}

class _DonsScreenState extends ConsumerState<DonsScreen> {
  final _autre = TextEditingController();
  double? _montant = 20;
  Affectation _affectation = Affectation.dime;
  bool _mensuel = false;
  bool _occupe = false;
  String? _erreur;

  @override
  void dispose() {
    _autre.dispose();
    super.dispose();
  }

  double? get _montantChoisi {
    if (_montant != null) return _montant;
    final m = double.tryParse(_autre.text.trim().replaceAll(',', '.'));
    if (m == null || m < 1 || m > 10000) return null;
    return (m * 100).roundToDouble() / 100;
  }

  Future<void> _virement() async {
    final l10n = AppLocalizations.of(context);
    final montant = _montantChoisi;
    if (montant == null) {
      setState(() => _erreur = l10n.montantInvalide);
      return;
    }
    final uid = ref.read(utilisateurFirebaseProvider).value?.uid;
    final nom = ref.read(profilProvider).value?.nom;
    if (uid == null || nom == null) return;
    final messager = ScaffoldMessenger.of(context);
    setState(() {
      _occupe = true;
      _erreur = null;
    });
    try {
      final communication = genererCommunication();
      await ref
          .read(donsRepositoryProvider)
          .annoncerVirement(
            communication: communication,
            uid: uid,
            nom: nom,
            montant: montant,
            affectation: _affectation,
          );
      if (mounted) context.push(Routes.virementDon(communication));
    } catch (_) {
      messager.showSnackBar(SnackBar(content: Text(l10n.erreurInconnue)));
    } finally {
      if (mounted) setState(() => _occupe = false);
    }
  }

  Future<void> _enLigne() async {
    final l10n = AppLocalizations.of(context);
    final montant = _montantChoisi;
    if (montant == null) {
      setState(() => _erreur = l10n.montantInvalide);
      return;
    }
    final messager = ScaffoldMessenger.of(context);
    setState(() {
      _occupe = true;
      _erreur = null;
    });
    try {
      final url = await ref
          .read(paiementsEnLigneProvider)
          .payerDon(
            montant: montant,
            affectation: _affectation.name,
            mensuel: _mensuel,
          );
      await ref.read(lanceurProvider).ouvrir(url);
    } on ErreurPaiement catch (e) {
      messager.showSnackBar(
        SnackBar(
          content: Text(
            e.code == 'reseau' ? l10n.erreurReseau : l10n.paiementImpossible,
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _occupe = false);
    }
  }

  Future<void> _arreter(DonMensuel d) async {
    final l10n = AppLocalizations.of(context);
    final messager = ScaffoldMessenger.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.arreterDonMensuelTitre),
        content: Text(l10n.arreterDonMensuelTexte),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.annuler),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.arreter),
          ),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await ref.read(paiementsEnLigneProvider).arreterDonMensuel(d.id);
      messager.showSnackBar(SnackBar(content: Text(l10n.donMensuelArrete)));
    } on ErreurPaiement {
      messager.showSnackBar(SnackBar(content: Text(l10n.erreurInconnue)));
    }
  }

  Widget _formulaire(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final virement =
        ref.watch(parametresEgliseProvider).value?.virementPossible ?? false;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l10n.montant, style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final m in _montantsProposes)
                  ChoiceChip(
                    label: Text(context.euros(m)),
                    selected: _montant == m,
                    onSelected: (_) => setState(() => _montant = m),
                  ),
                ChoiceChip(
                  label: Text(l10n.autreMontant),
                  selected: _montant == null,
                  onSelected: (_) => setState(() => _montant = null),
                ),
              ],
            ),
            if (_montant == null) ...[
              const SizedBox(height: 8),
              TextField(
                controller: _autre,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: InputDecoration(
                  labelText: l10n.montantEnEuros,
                  suffixText: '€',
                ),
              ),
            ],
            const SizedBox(height: 16),
            Text(l10n.affectationDon, style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final a in Affectation.values)
                  ChoiceChip(
                    label: Text(l10n.affectation(a)),
                    selected: _affectation == a,
                    onSelected: (_) => setState(() => _affectation = a),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            SegmentedButton<bool>(
              segments: [
                ButtonSegment(value: false, label: Text(l10n.uneFois)),
                ButtonSegment(value: true, label: Text(l10n.chaqueMois)),
              ],
              selected: {_mensuel},
              onSelectionChanged: (s) => setState(() => _mensuel = s.first),
            ),
            if (_mensuel) ...[
              const SizedBox(height: 8),
              Text(l10n.donMensuelAide, style: theme.textTheme.bodySmall),
            ],
            if (_erreur != null) ...[
              const SizedBox(height: 8),
              Text(_erreur!, style: TextStyle(color: theme.colorScheme.error)),
            ],
            const SizedBox(height: 16),
            if (!_mensuel && virement) ...[
              FilledButton.icon(
                onPressed: _occupe ? null : _virement,
                icon: const Icon(Icons.qr_code_2),
                label: Text(l10n.donnerParVirement),
              ),
              const SizedBox(height: 8),
            ],
            FilledButton.tonalIcon(
              onPressed: _occupe ? null : _enLigne,
              icon: const Icon(Icons.credit_card),
              label: Text(
                _mensuel ? l10n.donnerChaqueMois : l10n.donnerEnLigne,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    if (ref.watch(utilisateurFirebaseProvider).value == null) {
      return ConnexionRequise(
        titre: l10n.dimesEtOffrandes,
        texte: l10n.donsConnexionTexte,
      );
    }
    final dons = ref.watch(mesDonsProvider).value ?? const <Don>[];
    final mensuels = [
      for (final d in ref.watch(mesDonsMensuelsProvider).value ?? const [])
        if (d.actif) d,
    ];
    final navigateur = ref.watch(donsDansLeNavigateurProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.dimesEtOffrandes),
        actions: [
          IconButton(
            tooltip: l10n.releveAnnuel,
            onPressed: () => context.push(Routes.releveDons),
            icon: const Icon(Icons.receipt_long_outlined),
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                l10n.donsVerset,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 16),
              if (navigateur)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(l10n.donsSurLeSiteTexte),
                        const SizedBox(height: 12),
                        FilledButton.icon(
                          onPressed: () =>
                              ref.read(lanceurProvider).ouvrir(pageDonsWeb),
                          icon: const Icon(Icons.open_in_new),
                          label: Text(l10n.donnerSurLeSite),
                        ),
                      ],
                    ),
                  ),
                )
              else
                _formulaire(context),
              if (mensuels.isNotEmpty) ...[
                const SizedBox(height: 24),
                Text(l10n.mesDonsMensuels, style: theme.textTheme.titleLarge),
                for (final d in mensuels)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.autorenew),
                    title: Text(l10n.parMois(context.euros(d.montant))),
                    subtitle: Text(l10n.affectation(d.affectation)),
                    trailing: TextButton(
                      onPressed: () => _arreter(d),
                      child: Text(l10n.arreter),
                    ),
                  ),
              ],
              const SizedBox(height: 24),
              Text(l10n.mesDons, style: theme.textTheme.titleLarge),
              if (dons.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(l10n.aucunDon),
                ),
              for (final d in dons) CarteDon(don: d),
            ],
          ),
        ),
      ),
    );
  }
}

/// Un don dans une liste ; un virement en attente ouvre ses instructions.
class CarteDon extends StatelessWidget {
  const CarteDon({super.key, required this.don, this.avecNom = false});

  final Don don;
  final bool avecNom;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final d = don;
    final enAttente = d.statut == StatutDon.enAttente;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(iconeStatutDon(d.statut)),
      title: Text(
        [
          context.euros(d.montant),
          l10n.affectation(d.affectation),
          if (avecNom) d.nom,
        ].join(' · '),
      ),
      subtitle: Text(
        [
          if (d.createdAt != null) context.dateCourte(d.createdAt!),
          l10n.modeDon(d.mode),
          l10n.statutDon(d.statut),
        ].join(' · '),
      ),
      trailing: enAttente ? const Icon(Icons.chevron_right) : null,
      onTap: enAttente ? () => context.push(Routes.virementDon(d.id)) : null,
    );
  }
}
