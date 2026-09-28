import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/horloge.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/format_date.dart';
import '../domain/groupe.dart';
import '../domain/rencontre.dart';
import '../groupes_providers.dart';
import 'libelles_groupes.dart';

/// Créer ou modifier un rendez-vous du groupe ([id] = « nouvelle »).
class EditeurRencontreScreen extends ConsumerStatefulWidget {
  const EditeurRencontreScreen({
    super.key,
    required this.groupeId,
    required this.id,
  });

  final String groupeId;
  final String id;

  @override
  ConsumerState<EditeurRencontreScreen> createState() =>
      _EditeurRencontreScreenState();
}

class _EditeurRencontreScreenState
    extends ConsumerState<EditeurRencontreScreen> {
  final _formulaire = GlobalKey<FormState>();
  final _titre = TextEditingController();
  final _lieu = TextEditingController();
  final _notes = TextEditingController();
  final _deroule = TextEditingController(text: derouleCulte.join('\n'));
  final _chants = <(TextEditingController, TextEditingController)>[];
  final _roles = <String, TextEditingController>{};
  late final String _id;
  bool _nouvelle = true;
  bool _charge = false;
  bool _occupe = false;
  TypeRencontre _type = TypeRencontre.reunion;
  late DateTime _debut;
  DateTime? _fin;
  DateTime? _debutInitial;
  String? _moderateur;
  bool _remplacement = false;
  Groupe? _groupe;

  @override
  void initState() {
    super.initState();
    final repo = ref.read(groupesRepositoryProvider);
    _nouvelle = widget.id == 'nouvelle';
    _id = _nouvelle ? repo.nouvelleRencontreId(widget.groupeId) : widget.id;
    final n = ref.read(horlogeProvider)();
    _debut = DateTime(n.year, n.month, n.day + 1, 19);
    _fin = _debut.add(const Duration(hours: 2));
    repo.lire(widget.groupeId).then((g) async {
      if (!mounted || g == null) return;
      _groupe = g;
      for (final u in g.membres) {
        _roles[u] = TextEditingController();
      }
      if (_nouvelle) {
        _changerType(typeParDefaut(g.type));
        setState(() => _charge = true);
        return;
      }
      final r = await repo.lireRencontre(widget.groupeId, _id);
      if (!mounted || r == null) return;
      setState(() {
        _type = r.type;
        _titre.text = r.titre;
        _lieu.text = r.lieu;
        _notes.text = r.notes;
        _debut = r.debut;
        _debutInitial = r.debut;
        _fin = r.fin;
        _moderateur = r.moderateur;
        _remplacement = r.remplacementDemande;
        if (r.deroule.isNotEmpty) _deroule.text = r.deroule.join('\n');
        for (final c in r.chants) {
          _chants.add((
            TextEditingController(text: c.titre),
            TextEditingController(text: c.lien),
          ));
        }
        for (final e in r.roles.entries) {
          (_roles[e.key] ??= TextEditingController()).text = e.value;
        }
        _charge = true;
      });
    });
  }

  /// Nouveau type : titre et date proposés (modifiables).
  void _changerType(TypeRencontre t) {
    final l10n = AppLocalizations.of(context);
    setState(() {
      if (_titre.text.isEmpty ||
          TypeRencontre.values.any(
            (x) => _titre.text == _titreParDefaut(l10n, x),
          )) {
        _titre.text = _titreParDefaut(l10n, t);
      }
      if (_nouvelle && t == TypeRencontre.moderation && _type != t) {
        final n = ref.read(horlogeProvider)();
        final jours = (DateTime.sunday - n.weekday) % 7;
        _debut = DateTime(
          n.year,
          n.month,
          n.day + (jours == 0 ? 7 : jours),
          10,
        );
        _fin = _debut.add(const Duration(hours: 2));
      }
      _type = t;
    });
  }

  String _titreParDefaut(AppLocalizations l10n, TypeRencontre t) => switch (t) {
    TypeRencontre.moderation => l10n.titreCulteDimanche,
    _ => l10n.libelleRencontre(t),
  };

  @override
  void dispose() {
    for (final c in [_titre, _lieu, _notes, _deroule]) {
      c.dispose();
    }
    for (final (a, b) in _chants) {
      a.dispose();
      b.dispose();
    }
    for (final c in _roles.values) {
      c.dispose();
    }
    super.dispose();
  }

  Future<DateTime?> _choisir(DateTime depart) async {
    final jour = await showDatePicker(
      context: context,
      initialDate: depart,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (jour == null || !mounted) return null;
    final heure = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(depart),
    );
    if (heure == null) return null;
    return DateTime(jour.year, jour.month, jour.day, heure.hour, heure.minute);
  }

  Future<void> _enregistrer() async {
    if (!_formulaire.currentState!.validate()) return;
    final l10n = AppLocalizations.of(context);
    final messager = ScaffoldMessenger.of(context);
    setState(() => _occupe = true);
    try {
      final r = Rencontre(
        id: _id,
        groupeId: widget.groupeId,
        type: _type,
        titre: _titre.text,
        debut: _debut,
        fin: _fin,
        lieu: _lieu.text,
        notes: _notes.text,
        chants: _type == TypeRencontre.repetition
            ? [
                for (final (t, l) in _chants)
                  if (t.text.trim().isNotEmpty)
                    Chant(titre: t.text.trim(), lien: l.text.trim()),
              ]
            : const [],
        roles: _type == TypeRencontre.repetition
            ? {
                for (final e in _roles.entries)
                  if (e.value.text.trim().isNotEmpty)
                    e.key: e.value.text.trim(),
              }
            : const {},
        moderateur: _type == TypeRencontre.moderation ? _moderateur : null,
        remplacementDemande: _type == TypeRencontre.moderation && _remplacement,
        deroule: _type == TypeRencontre.moderation
            ? [
                for (final l in _deroule.text.split('\n'))
                  if (l.trim().isNotEmpty) l.trim(),
              ]
            : const [],
        modeAppel: _type == TypeRencontre.appel ? 'externe' : 'aucun',
      );
      await ref
          .read(groupesRepositoryProvider)
          .enregistrerRencontre(r, dateChangee: _debutInitial != _debut);
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
        title: Text(l10n.supprimerRendezVous),
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
    await ref
        .read(groupesRepositoryProvider)
        .supprimerRencontre(widget.groupeId, _id);
    // Retour au calendrier (la fiche n'existe plus).
    if (mounted) context.pop();
    if (mounted) context.pop();
  }

  Widget _date(
    String libelle,
    DateTime? valeur,
    ValueChanged<DateTime> choisi,
  ) => ListTile(
    contentPadding: EdgeInsets.zero,
    leading: const Icon(Icons.schedule),
    title: Text(libelle),
    subtitle: Text(
      valeur == null
          ? '—'
          : '${context.dateLongue(valeur)}, ${context.heure(valeur)}',
    ),
    trailing: const Icon(Icons.edit_calendar_outlined),
    onTap: () async {
      final d = await _choisir(valeur ?? _debut);
      if (d != null) setState(() => choisi(d));
    },
  );

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final noms = ref.watch(annuaireProvider).value ?? const {};
    final g = _groupe;
    Widget section(String t) => Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 8),
      child: Text(t, style: theme.textTheme.titleMedium),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _nouvelle ? l10n.ajouterRendezVous : l10n.modifierRendezVous,
        ),
        actions: [
          if (!_nouvelle)
            IconButton(
              tooltip: l10n.supprimer,
              onPressed: _supprimer,
              icon: const Icon(Icons.delete_outline),
            ),
        ],
      ),
      body: !_charge || g == null
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 720),
                child: Form(
                  key: _formulaire,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      DropdownButtonFormField<TypeRencontre>(
                        initialValue: _type,
                        decoration: InputDecoration(
                          labelText: l10n.typeEvenementChamp,
                        ),
                        items: [
                          for (final t in TypeRencontre.values)
                            DropdownMenuItem(
                              value: t,
                              child: Text(l10n.libelleRencontre(t)),
                            ),
                        ],
                        onChanged: (t) {
                          if (t != null) _changerType(t);
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _titre,
                        decoration: InputDecoration(labelText: l10n.champTitre),
                        textCapitalization: TextCapitalization.sentences,
                        validator: (v) => (v ?? '').trim().isEmpty
                            ? l10n.champObligatoire
                            : null,
                      ),
                      _date(l10n.debut, _debut, (d) {
                        final duree = _fin?.difference(_debut);
                        _debut = d;
                        if (duree != null) _fin = d.add(duree);
                      }),
                      _date(
                        l10n.fin,
                        _fin,
                        (d) => _fin = d.isBefore(_debut) ? _debut : d,
                      ),
                      TextFormField(
                        controller: _lieu,
                        decoration: InputDecoration(labelText: l10n.lieu),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _notes,
                        decoration: InputDecoration(labelText: l10n.champNotes),
                        minLines: 2,
                        maxLines: null,
                        textCapitalization: TextCapitalization.sentences,
                      ),
                      if (_type == TypeRencontre.appel) ...[
                        const SizedBox(height: 12),
                        Text(
                          g.lienAppel.isEmpty
                              ? l10n.appelSansLien
                              : l10n.appelAvecLien,
                          style: theme.textTheme.bodyMedium,
                        ),
                      ],
                      if (_type == TypeRencontre.repetition) ...[
                        section(l10n.chantsAPreparer),
                        for (final (i, (t, l)) in _chants.indexed)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    children: [
                                      TextFormField(
                                        controller: t,
                                        decoration: InputDecoration(
                                          labelText: l10n.chantNumero(i + 1),
                                        ),
                                      ),
                                      TextFormField(
                                        controller: l,
                                        decoration: InputDecoration(
                                          labelText: l10n.lienChant,
                                        ),
                                        keyboardType: TextInputType.url,
                                        validator: (v) {
                                          final s = (v ?? '').trim();
                                          return s.isEmpty || lienAppelValide(s)
                                              ? null
                                              : l10n.lienInvalide;
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  tooltip: l10n.retirer,
                                  onPressed: () => setState(() {
                                    final (a, b) = _chants.removeAt(i);
                                    a.dispose();
                                    b.dispose();
                                  }),
                                  icon: const Icon(Icons.close),
                                ),
                              ],
                            ),
                          ),
                        OutlinedButton.icon(
                          onPressed: () => setState(
                            () => _chants.add((
                              TextEditingController(),
                              TextEditingController(),
                            )),
                          ),
                          icon: const Icon(Icons.add),
                          label: Text(l10n.ajouterChant),
                        ),
                        section(l10n.quiJoueQuoi),
                        for (final u in g.membres)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: TextFormField(
                              controller: _roles[u],
                              decoration: InputDecoration(
                                labelText: noms[u] ?? l10n.compteInconnu,
                                hintText: l10n.instrumentAide,
                              ),
                            ),
                          ),
                      ],
                      if (_type == TypeRencontre.moderation) ...[
                        section(l10n.moderateur),
                        DropdownButtonFormField<String?>(
                          initialValue: g.membres.contains(_moderateur)
                              ? _moderateur
                              : null,
                          decoration: InputDecoration(
                            labelText: l10n.moderateur,
                          ),
                          items: [
                            DropdownMenuItem(
                              value: null,
                              child: Text(l10n.aucun),
                            ),
                            for (final u in g.membres)
                              DropdownMenuItem(
                                value: u,
                                child: Text(noms[u] ?? l10n.compteInconnu),
                              ),
                          ],
                          onChanged: (u) => setState(() {
                            _moderateur = u;
                            _remplacement = false;
                          }),
                        ),
                        section(l10n.deroule),
                        TextFormField(
                          controller: _deroule,
                          decoration: InputDecoration(
                            helperText: l10n.derouleAide,
                          ),
                          minLines: 5,
                          maxLines: null,
                        ),
                      ],
                      const SizedBox(height: 16),
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
