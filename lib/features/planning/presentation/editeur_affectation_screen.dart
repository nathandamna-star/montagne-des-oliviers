import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/horloge.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/domain_traduction.dart';
import '../../../shared/format_date.dart';
import '../../agenda/agenda_providers.dart';
import '../../agenda/domain/evenement.dart';
import '../../groupes/groupes_providers.dart';
import '../domain/planning.dart';
import '../planning_providers.dart';
import 'libelles_planning.dart';

/// Responsables : mettre quelqu'un au planning (« nouvelle ») ou modifier.
class EditeurAffectationScreen extends ConsumerStatefulWidget {
  const EditeurAffectationScreen({
    super.key,
    required this.equipeId,
    required this.id,
  });

  final String equipeId;
  final String id;

  @override
  ConsumerState<EditeurAffectationScreen> createState() =>
      _EditeurAffectationScreenState();
}

class _EditeurAffectationScreenState
    extends ConsumerState<EditeurAffectationScreen> {
  final _formulaire = GlobalKey<FormState>();
  final _titre = TextEditingController();
  final _role = TextEditingController();
  late final String _id;
  bool _nouvelle = true;
  bool _charge = false;
  bool _occupe = false;
  late DateTime _date;
  DateTime? _dateInitiale;
  String? _uid;
  StatutService _statut = StatutService.prevu;
  String? _erreurPersonne;

  @override
  void initState() {
    super.initState();
    final repo = ref.read(planningRepositoryProvider);
    _nouvelle = widget.id == 'nouvelle';
    _id = _nouvelle ? repo.nouvelleAffectationId(widget.equipeId) : widget.id;
    // Par défaut : dimanche prochain, 10 h.
    final n = ref.read(horlogeProvider)();
    final jours = (DateTime.sunday - n.weekday) % 7;
    _date = DateTime(n.year, n.month, n.day + (jours == 0 ? 7 : jours), 10);
    if (_nouvelle) {
      _charge = true;
    } else {
      repo.lireAffectation(widget.equipeId, _id).then((a) {
        if (!mounted || a == null) return;
        setState(() {
          _titre.text = a.titre;
          _role.text = a.role;
          _date = a.date;
          _dateInitiale = a.date;
          _uid = a.uid;
          _statut = a.statut;
          _charge = true;
        });
      });
    }
  }

  @override
  void dispose() {
    _titre.dispose();
    _role.dispose();
    super.dispose();
  }

  Future<void> _choisirDate() async {
    final jour = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (jour == null || !mounted) return;
    final heure = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_date),
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

  Future<void> _enregistrer() async {
    final l10n = AppLocalizations.of(context);
    setState(
      () => _erreurPersonne = _uid == null ? l10n.choisirPersonne : null,
    );
    if (!_formulaire.currentState!.validate() || _uid == null) return;
    final messager = ScaffoldMessenger.of(context);
    final noms = ref.read(annuaireProvider).value ?? const {};
    setState(() => _occupe = true);
    try {
      await ref
          .read(planningRepositoryProvider)
          .enregistrerAffectation(
            Affectation(
              id: _id,
              equipeId: widget.equipeId,
              uid: _uid!,
              nom: noms[_uid] ?? '',
              date: _date,
              titre: _titre.text,
              role: _role.text,
              statut: _statut,
            ),
            dateChangee: _dateInitiale != _date,
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
    await ref
        .read(planningRepositoryProvider)
        .supprimerAffectation(widget.equipeId, _id);
    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final equipe = ref.watch(equipeProvider(widget.equipeId)).value;
    final noms = ref.watch(annuaireProvider).value ?? const {};
    final cultes = [
      for (final e
          in ref.watch(evenementsProvider).value ?? const <Evenement>[])
        e,
    ];
    return Scaffold(
      appBar: AppBar(
        title: Text(_nouvelle ? l10n.ajouterAuPlanning : l10n.modifier),
        actions: [
          if (!_nouvelle)
            IconButton(
              tooltip: l10n.supprimer,
              onPressed: _supprimer,
              icon: const Icon(Icons.delete_outline),
            ),
        ],
      ),
      body: !_charge || equipe == null
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 720),
                child: Form(
                  key: _formulaire,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      if (cultes.isNotEmpty) ...[
                        Text(
                          l10n.choisirCulte,
                          style: theme.textTheme.titleSmall,
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            for (final e in cultes.take(8))
                              ActionChip(
                                label: Text(
                                  '${Traduction.dans(e.titre, context.langue)} · ${context.dateCourte(e.debut)}',
                                ),
                                onPressed: () => setState(() {
                                  _titre.text = Traduction.dans(
                                    e.titre,
                                    context.langue,
                                  );
                                  _date = e.debut;
                                }),
                              ),
                          ],
                        ),
                        const SizedBox(height: 16),
                      ],
                      TextFormField(
                        controller: _titre,
                        decoration: InputDecoration(
                          labelText: l10n.cultOuEvenement,
                          hintText: l10n.titreCulteDimanche,
                        ),
                        textCapitalization: TextCapitalization.sentences,
                        validator: (v) => (v ?? '').trim().isEmpty
                            ? l10n.champObligatoire
                            : null,
                      ),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.schedule),
                        title: Text(l10n.dateEtHeure),
                        subtitle: Text(
                          '${context.dateLongue(_date)}, ${context.heure(_date)}',
                        ),
                        trailing: const Icon(Icons.edit_calendar_outlined),
                        onTap: _choisirDate,
                      ),
                      DropdownButtonFormField<String?>(
                        initialValue: equipe.membres.contains(_uid)
                            ? _uid
                            : null,
                        isExpanded: true,
                        decoration: InputDecoration(
                          labelText: l10n.quiSert,
                          errorText: _erreurPersonne,
                        ),
                        items: [
                          for (final u in equipe.membres)
                            DropdownMenuItem(
                              value: u,
                              child: Text(noms[u] ?? l10n.compteInconnu),
                            ),
                        ],
                        onChanged: (u) => setState(() => _uid = u),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _role,
                        decoration: InputDecoration(
                          labelText: l10n.poste,
                          hintText: l10n.posteAide,
                        ),
                        textCapitalization: TextCapitalization.sentences,
                      ),
                      if (!_nouvelle) ...[
                        const SizedBox(height: 12),
                        DropdownButtonFormField<StatutService>(
                          initialValue: _statut,
                          decoration: InputDecoration(
                            labelText: l10n.champStatut,
                          ),
                          items: [
                            for (final s in StatutService.values)
                              DropdownMenuItem(
                                value: s,
                                child: Text(l10n.libelleStatutService(s)),
                              ),
                          ],
                          onChanged: (s) =>
                              setState(() => _statut = s ?? _statut),
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
