import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../l10n/app_localizations.dart';
import '../../../shared/format_date.dart';
import '../domain/membre.dart';
import '../membres_providers.dart';
import 'familles_screen.dart';
import 'libelles_membres.dart';

/// Services proposés (on peut aussi en saisir d'autres).
const servicesProposes = [
  'Prédication',
  'Louange',
  'Modération',
  'Sono / vidéo',
  'Média',
  'Accueil',
  'École du dimanche',
  'Intercession',
  'Entraide',
  'Nettoyage',
];

/// Créer ou modifier une fiche ([id] = « nouveau »). [uidCompte] : créer la
/// fiche à partir d'un compte de l'app (nom et e-mail repris).
class FicheMembreScreen extends ConsumerStatefulWidget {
  const FicheMembreScreen({super.key, required this.id, this.uidCompte});

  final String id;
  final String? uidCompte;

  @override
  ConsumerState<FicheMembreScreen> createState() => _FicheMembreScreenState();
}

class _FicheMembreScreenState extends ConsumerState<FicheMembreScreen> {
  final _formulaire = GlobalKey<FormState>();
  final _nom = TextEditingController();
  final _prenom = TextEditingController();
  final _email = TextEditingController();
  final _telephone = TextEditingController();
  final _rue = TextEditingController();
  final _codePostal = TextEditingController();
  final _ville = TextEditingController();
  final _notes = TextEditingController();
  final _autreService = TextEditingController();
  late final String _id;
  bool _nouvelle = true;
  bool _charge = false;
  bool _occupe = false;
  StatutMembre _statut = StatutMembre.membre;
  String? _familleId;
  String? _uid;
  DateTime? _naissance, _arrivee, _bapteme, _presentation, _mariage;
  final _services = <String>[];

  @override
  void initState() {
    super.initState();
    final repo = ref.read(membresRepositoryProvider);
    _nouvelle = widget.id == 'nouveau';
    _id = _nouvelle ? repo.nouvelId() : widget.id;
    if (_nouvelle) {
      _uid = widget.uidCompte;
      if (_uid != null) {
        repo.comptes().first.then((comptes) {
          final c = comptes.where((c) => c.uid == _uid).firstOrNull;
          if (c == null || !mounted) return;
          // « Marie Dubois » : prénom puis nom.
          final parties = c.nom.trim().split(RegExp(r'\s+'));
          setState(() {
            _prenom.text = parties.length > 1 ? parties.first : '';
            _nom.text = parties.length > 1
                ? parties.skip(1).join(' ')
                : parties.first;
            _email.text = c.email;
          });
        });
      }
      _charge = true;
    } else {
      repo.membre(_id).first.then((m) {
        if (!mounted || m == null) return;
        setState(() {
          _nom.text = m.nom;
          _prenom.text = m.prenom;
          _email.text = m.email;
          _telephone.text = m.telephone;
          _rue.text = m.rue;
          _codePostal.text = m.codePostal;
          _ville.text = m.ville;
          _notes.text = m.notes;
          _statut = m.statut;
          _familleId = m.familleId;
          _uid = m.uid;
          _naissance = m.dateNaissance;
          _arrivee = m.arriveeLe;
          _bapteme = m.baptemeLe;
          _presentation = m.presentationLe;
          _mariage = m.mariageLe;
          _services.addAll(m.services);
          _charge = true;
        });
      });
    }
  }

  @override
  void dispose() {
    for (final c in [
      _nom,
      _prenom,
      _email,
      _telephone,
      _rue,
      _codePostal,
      _ville,
      _notes,
      _autreService,
    ]) {
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
      await ref
          .read(membresRepositoryProvider)
          .enregistrer(
            Membre(
              id: _id,
              nom: _nom.text,
              prenom: _prenom.text,
              email: _email.text,
              telephone: _telephone.text,
              rue: _rue.text,
              codePostal: _codePostal.text,
              ville: _ville.text,
              dateNaissance: _naissance,
              familleId: _familleId,
              arriveeLe: _arrivee,
              baptemeLe: _bapteme,
              presentationLe: _presentation,
              mariageLe: _mariage,
              statut: _statut,
              uid: _uid,
              services: List.of(_services),
              notes: _notes.text,
            ),
          );
      messager.showSnackBar(SnackBar(content: Text(l10n.enregistre)));
      if (mounted) context.pop();
    } catch (_) {
      messager.showSnackBar(SnackBar(content: Text(l10n.erreurInconnue)));
    } finally {
      if (mounted) setState(() => _occupe = false);
    }
  }

  Future<void> _supprimer() async {
    final l10n = AppLocalizations.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.supprimerFiche),
        content: Text(l10n.supprimerFicheAide),
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
    await ref.read(membresRepositoryProvider).supprimer(_id);
    if (mounted) context.pop();
  }

  Future<void> _nouvelleFamille() async {
    final l10n = AppLocalizations.of(context);
    final choisi = await demanderNomFamille(
      context,
      titre: l10n.nouvelleFamille,
      initial: _nom.text.trim().isEmpty ? '' : l10n.familleDe(_nom.text.trim()),
      bouton: l10n.creer,
    );
    if (choisi == null) return;
    final id = await ref.read(membresRepositoryProvider).creerFamille(choisi);
    if (mounted) setState(() => _familleId = id);
  }

  Widget _date(
    String libelle,
    DateTime? valeur,
    ValueChanged<DateTime?> choisi,
  ) {
    final l10n = AppLocalizations.of(context);
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(libelle),
      subtitle: Text(valeur == null ? '—' : context.dateLongue(valeur)),
      onTap: () async {
        final d = await showDatePicker(
          context: context,
          initialDate: valeur ?? DateTime.now(),
          firstDate: DateTime(1900),
          lastDate: DateTime(2100),
          initialEntryMode: DatePickerEntryMode.input,
        );
        if (d != null) setState(() => choisi(d));
      },
      trailing: valeur == null
          ? const Icon(Icons.edit_calendar_outlined)
          : IconButton(
              tooltip: l10n.effacerDate,
              onPressed: () => setState(() => choisi(null)),
              icon: const Icon(Icons.clear),
            ),
    );
  }

  Widget _champ(
    TextEditingController c,
    String libelle, {
    TextInputType? clavier,
    String? Function(String?)? validation,
    int lignes = 1,
  }) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: TextFormField(
      controller: c,
      decoration: InputDecoration(labelText: libelle),
      keyboardType: clavier,
      validator: validation,
      minLines: lignes,
      maxLines: lignes == 1 ? 1 : null,
      textCapitalization: clavier == null
          ? TextCapitalization.words
          : TextCapitalization.none,
    ),
  );

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final familles = ref.watch(famillesProvider).value ?? const <Famille>[];
    final comptes = ref.watch(comptesProvider).value ?? const [];
    final titre = Text(_nouvelle ? l10n.nouvelleFiche : l10n.ficheMembre);
    Widget section(String t) => Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8),
      child: Text(t, style: theme.textTheme.titleMedium),
    );

    return Scaffold(
      appBar: AppBar(
        title: titre,
        actions: [
          if (!_nouvelle)
            IconButton(
              tooltip: l10n.supprimer,
              onPressed: _supprimer,
              icon: const Icon(Icons.delete_outline),
            ),
        ],
      ),
      body: !_charge
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 720),
                child: Form(
                  key: _formulaire,
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                    children: [
                      _champ(
                        _nom,
                        l10n.champNomFamille,
                        validation: (v) => (v ?? '').trim().isEmpty
                            ? l10n.champObligatoire
                            : null,
                      ),
                      _champ(_prenom, l10n.champPrenom),
                      Text(l10n.champStatut),
                      const SizedBox(height: 8),
                      SegmentedButton<StatutMembre>(
                        segments: [
                          for (final s in StatutMembre.values)
                            ButtonSegment(
                              value: s,
                              label: Text(l10n.libelleStatut(s)),
                            ),
                        ],
                        selected: {_statut},
                        onSelectionChanged: (s) =>
                            setState(() => _statut = s.first),
                      ),
                      section(l10n.coordonnees),
                      _champ(
                        _telephone,
                        l10n.champTelephone,
                        clavier: TextInputType.phone,
                      ),
                      _champ(
                        _email,
                        l10n.champEmail,
                        clavier: TextInputType.emailAddress,
                        validation: (v) {
                          final t = (v ?? '').trim();
                          return t.isEmpty ||
                                  RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$')
                                      .hasMatch(t)
                              ? null
                              : l10n.validationEmail;
                        },
                      ),
                      _champ(_rue, l10n.champRue),
                      Row(
                        children: [
                          SizedBox(
                            width: 120,
                            child: _champ(
                              _codePostal,
                              l10n.champCodePostal,
                              clavier: TextInputType.number,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(child: _champ(_ville, l10n.champVille)),
                        ],
                      ),
                      _date(
                        l10n.champDateNaissance,
                        _naissance,
                        (d) => _naissance = d,
                      ),
                      section(l10n.champFamille),
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String?>(
                              initialValue:
                                  familles.any((f) => f.id == _familleId)
                                  ? _familleId
                                  : null,
                              key: ValueKey(
                                'famille-$_familleId-${familles.length}',
                              ),
                              decoration: InputDecoration(
                                labelText: l10n.champFamille,
                              ),
                              items: [
                                DropdownMenuItem(
                                  value: null,
                                  child: Text(l10n.aucune),
                                ),
                                for (final f in familles)
                                  DropdownMenuItem(
                                    value: f.id,
                                    child: Text(f.nom),
                                  ),
                              ],
                              onChanged: (v) => setState(() => _familleId = v),
                            ),
                          ),
                          IconButton(
                            tooltip: l10n.nouvelleFamille,
                            onPressed: _nouvelleFamille,
                            icon: const Icon(Icons.add),
                          ),
                        ],
                      ),
                      section(l10n.vieDEglise),
                      _date(l10n.champArrivee, _arrivee, (d) => _arrivee = d),
                      _date(l10n.champBapteme, _bapteme, (d) => _bapteme = d),
                      _date(
                        l10n.champPresentation,
                        _presentation,
                        (d) => _presentation = d,
                      ),
                      _date(l10n.champMariage, _mariage, (d) => _mariage = d),
                      section(l10n.champServices),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (final s in {...servicesProposes, ..._services})
                            FilterChip(
                              label: Text(s),
                              selected: _services.contains(s),
                              onSelected: (v) => setState(
                                () =>
                                    v ? _services.add(s) : _services.remove(s),
                              ),
                            ),
                        ],
                      ),
                      TextField(
                        controller: _autreService,
                        decoration: InputDecoration(
                          labelText: l10n.autreService,
                          suffixIcon: IconButton(
                            tooltip: l10n.ajouter,
                            icon: const Icon(Icons.add),
                            onPressed: () {
                              final s = _autreService.text.trim();
                              if (s.isEmpty || _services.contains(s)) return;
                              setState(() {
                                _services.add(s);
                                _autreService.clear();
                              });
                            },
                          ),
                        ),
                      ),
                      section(l10n.compteApp),
                      DropdownButtonFormField<String?>(
                        initialValue: comptes.any((c) => c.uid == _uid)
                            ? _uid
                            : null,
                        key: ValueKey('compte-$_uid-${comptes.length}'),
                        isExpanded: true,
                        decoration: InputDecoration(
                          labelText: l10n.compteLie,
                          helperText: l10n.compteLieAide,
                        ),
                        items: [
                          DropdownMenuItem(
                            value: null,
                            child: Text(l10n.aucun),
                          ),
                          for (final c in comptes)
                            DropdownMenuItem(
                              value: c.uid,
                              child: Text(
                                '${c.nom} (${c.email})',
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                        ],
                        onChanged: (v) => setState(() => _uid = v),
                      ),
                      section(l10n.champNotes),
                      _champ(
                        _notes,
                        l10n.notesAide,
                        clavier: TextInputType.multiline,
                        lignes: 3,
                      ),
                      const SizedBox(height: 8),
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
