import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/horloge.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/domain_traduction.dart';
import '../../../shared/format_date.dart';
import '../../../shared/widgets/champs_traduits.dart';
import '../../actualites/domain/actualite.dart';
import '../../agenda/agenda_providers.dart';
import '../../agenda/domain/evenement.dart';
import '../../agenda/presentation/libelles_agenda.dart';

/// Créer ou modifier un événement ([id] = « nouveau »), et voir les inscrits.
class EditeurEvenementScreen extends ConsumerStatefulWidget {
  const EditeurEvenementScreen({super.key, required this.id});

  final String id;

  @override
  ConsumerState<EditeurEvenementScreen> createState() =>
      _EditeurEvenementScreenState();
}

class _EditeurEvenementScreenState
    extends ConsumerState<EditeurEvenementScreen> {
  final _formulaire = GlobalKey<FormState>();
  final _titreFr = TextEditingController();
  final _titreNl = TextEditingController();
  final _descFr = TextEditingController();
  final _descNl = TextEditingController();
  final _lieu = TextEditingController();
  final _places = TextEditingController();
  late final String _id;
  bool _nouveau = true;
  bool _charge = false;
  TypeEvenement _type = TypeEvenement.culte;
  late DateTime _debut;
  late DateTime _fin;
  Visibilite _visibilite = Visibilite.public;
  bool _publie = true;
  bool _notifier = true;
  bool _inscription = false;
  bool _occupe = false;
  String? _erreurDates;

  @override
  void initState() {
    super.initState();
    final repo = ref.read(agendaRepositoryProvider);
    _nouveau = widget.id == 'nouveau';
    _id = _nouveau ? repo.nouvelId() : widget.id;
    // Par défaut : dimanche prochain, 10 h – 12 h.
    final n = ref.read(horlogeProvider)();
    final jours = (DateTime.sunday - n.weekday) % 7;
    _debut = DateTime(n.year, n.month, n.day + (jours == 0 ? 7 : jours), 10);
    _fin = _debut.add(const Duration(hours: 2));
    if (_nouveau) {
      _charge = true;
    } else {
      repo.un(_id).first.then((e) {
        if (!mounted || e == null) return;
        setState(() {
          _titreFr.text = e.titre['fr'] ?? '';
          _titreNl.text = e.titre['nl'] ?? '';
          _descFr.text = e.description['fr'] ?? '';
          _descNl.text = e.description['nl'] ?? '';
          _lieu.text = e.lieu;
          _places.text = e.placesMax?.toString() ?? '';
          _type = e.type;
          _debut = e.debut;
          _fin = e.fin;
          _visibilite = e.visibilite;
          _publie = e.publie;
          _notifier = !e.publie && e.notifier;
          _inscription = e.inscription;
          _charge = true;
        });
      });
    }
  }

  @override
  void dispose() {
    for (final c in [_titreFr, _titreNl, _descFr, _descNl, _lieu, _places]) {
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
    final l10n = AppLocalizations.of(context);
    final datesOk = !_fin.isBefore(_debut);
    setState(() => _erreurDates = datesOk ? null : l10n.finAvantDebut);
    if (!_formulaire.currentState!.validate() || !datesOk) return;
    final messager = ScaffoldMessenger.of(context);
    setState(() => _occupe = true);
    try {
      await ref
          .read(agendaRepositoryProvider)
          .enregistrer(
            Evenement(
              id: _id,
              titre: Traduction.ecrire(_titreFr.text, _titreNl.text),
              description: Traduction.ecrire(_descFr.text, _descNl.text)
                ..removeWhere((_, v) => v.isEmpty),
              type: _type,
              debut: _debut,
              fin: _fin,
              lieu: _lieu.text.trim(),
              visibilite: _visibilite,
              publie: _publie,
              notifier: _publie && _notifier,
              inscription: _inscription,
              placesMax: _inscription
                  ? int.tryParse(_places.text.trim())
                  : null,
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
        title: Text(l10n.supprimerEvenement),
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
    await ref.read(agendaRepositoryProvider).supprimer(_id);
    if (mounted) context.pop();
  }

  Widget _date(
    String libelle,
    DateTime valeur,
    ValueChanged<DateTime> choisi,
  ) => ListTile(
    contentPadding: EdgeInsets.zero,
    leading: const Icon(Icons.schedule),
    title: Text(libelle),
    subtitle: Text('${context.dateLongue(valeur)}, ${context.heure(valeur)}'),
    trailing: const Icon(Icons.edit_calendar_outlined),
    onTap: () async {
      final d = await _choisir(valeur);
      if (d != null) setState(() => choisi(d));
    },
  );

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(_nouveau ? l10n.nouvelEvenement : l10n.modifierEvenement),
        actions: [
          if (!_nouveau)
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
                    padding: const EdgeInsets.all(16),
                    children: [
                      DropdownButtonFormField<TypeEvenement>(
                        initialValue: _type,
                        decoration: InputDecoration(
                          labelText: l10n.typeEvenementChamp,
                        ),
                        items: [
                          for (final t in TypeEvenement.values)
                            DropdownMenuItem(
                              value: t,
                              child: Text(l10n.libelleType(t)),
                            ),
                        ],
                        onChanged: (t) => setState(() => _type = t ?? _type),
                      ),
                      const SizedBox(height: 16),
                      ChampsTraduits(
                        libelle: l10n.champTitre,
                        fr: _titreFr,
                        nl: _titreNl,
                      ),
                      const SizedBox(height: 8),
                      _date(l10n.debut, _debut, (d) {
                        final duree = _fin.difference(_debut);
                        _debut = d;
                        _fin = d.add(duree);
                      }),
                      _date(l10n.fin, _fin, (d) => _fin = d),
                      if (_erreurDates != null)
                        Text(
                          _erreurDates!,
                          style: TextStyle(color: theme.colorScheme.error),
                        ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _lieu,
                        decoration: InputDecoration(labelText: l10n.lieu),
                      ),
                      const SizedBox(height: 16),
                      ChampsTraduits(
                        libelle: l10n.champDescription,
                        fr: _descFr,
                        nl: _descNl,
                        lignes: 3,
                        obligatoire: false,
                      ),
                      const SizedBox(height: 16),
                      Text(l10n.visibilite),
                      const SizedBox(height: 8),
                      SegmentedButton<Visibilite>(
                        segments: [
                          ButtonSegment(
                            value: Visibilite.public,
                            label: Text(l10n.visibilitePublic),
                          ),
                          ButtonSegment(
                            value: Visibilite.membres,
                            label: Text(l10n.visibiliteMembres),
                          ),
                        ],
                        selected: {_visibilite},
                        onSelectionChanged: (s) =>
                            setState(() => _visibilite = s.first),
                      ),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(l10n.inscriptionOuverte),
                        value: _inscription,
                        onChanged: (v) => setState(() => _inscription = v),
                      ),
                      if (_inscription)
                        TextFormField(
                          controller: _places,
                          decoration: InputDecoration(
                            labelText: l10n.placesMax,
                            helperText: l10n.placesMaxAide,
                          ),
                          keyboardType: TextInputType.number,
                          validator: (v) {
                            final t = (v ?? '').trim();
                            if (t.isEmpty) return null;
                            final n = int.tryParse(t);
                            return n == null || n < 1
                                ? l10n.nombreInvalide
                                : null;
                          },
                        ),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(l10n.publier),
                        subtitle: Text(l10n.publierAide),
                        value: _publie,
                        onChanged: (v) => setState(() => _publie = v),
                      ),
                      if (_publie)
                        SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(l10n.envoyerNotification),
                          subtitle: Text(l10n.envoyerNotificationAide),
                          value: _notifier,
                          onChanged: (v) => setState(() => _notifier = v),
                        ),
                      const SizedBox(height: 16),
                      FilledButton(
                        onPressed: _occupe ? null : _enregistrer,
                        child: Text(l10n.enregistrer),
                      ),
                      if (!_nouveau && _inscription) ...[
                        const SizedBox(height: 24),
                        _Inscrits(id: _id),
                      ],
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}

class _Inscrits extends ConsumerWidget {
  const _Inscrits({required this.id});

  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final liste = ref.watch(inscriptionsProvider(id)).value ?? const [];
    final total = liste.fold<int>(0, (s, i) => s + i.personnes);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.inscritsNombre(total), style: theme.textTheme.titleMedium),
        for (final i in liste)
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.person_outline),
            title: Text(i.nom),
            trailing: Text('${i.personnes}'),
          ),
      ],
    );
  }
}
