import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../l10n/app_localizations.dart';
import '../../../shared/domain/sans_accents.dart';
import '../../auth/auth_providers.dart';
import '../../groupes/groupes_providers.dart';
import '../domain/planning.dart';
import '../planning_providers.dart';

/// Secrétariat : créer (« nouvelle ») ou modifier une équipe de service.
class EditeurEquipeScreen extends ConsumerStatefulWidget {
  const EditeurEquipeScreen({super.key, required this.id});

  final String id;

  @override
  ConsumerState<EditeurEquipeScreen> createState() =>
      _EditeurEquipeScreenState();
}

class _EditeurEquipeScreenState extends ConsumerState<EditeurEquipeScreen> {
  final _formulaire = GlobalKey<FormState>();
  final _nom = TextEditingController();
  final _description = TextEditingController();
  late final String _id;
  bool _nouvelle = true;
  bool _charge = false;
  bool _occupe = false;
  final _membres = <String>{};
  final _responsables = <String>{};
  String _recherche = '';

  @override
  void initState() {
    super.initState();
    final repo = ref.read(planningRepositoryProvider);
    ref.read(fonctionsRolesProvider).reconstruireAnnuaire().catchError((_) {});
    _nouvelle = widget.id == 'nouvelle';
    _id = _nouvelle ? repo.nouvelleEquipeId() : widget.id;
    if (_nouvelle) {
      _charge = true;
    } else {
      repo.lireEquipe(_id).then((e) {
        if (!mounted || e == null) return;
        setState(() {
          _nom.text = e.nom;
          _description.text = e.description;
          _membres.addAll(e.membres);
          _responsables.addAll(e.responsables);
          _charge = true;
        });
      });
    }
  }

  @override
  void dispose() {
    _nom.dispose();
    _description.dispose();
    super.dispose();
  }

  Future<void> _enregistrer() async {
    if (!_formulaire.currentState!.validate()) return;
    final l10n = AppLocalizations.of(context);
    final messager = ScaffoldMessenger.of(context);
    setState(() => _occupe = true);
    try {
      await ref
          .read(planningRepositoryProvider)
          .enregistrerEquipe(
            Equipe(
              id: _id,
              nom: _nom.text,
              description: _description.text,
              membres: _membres.toList(),
              responsables: [
                for (final r in _responsables)
                  if (_membres.contains(r)) r,
              ],
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
        title: Text(l10n.supprimerEquipe),
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
    await ref.read(planningRepositoryProvider).supprimerEquipe(_id);
    if (mounted) context.pop();
    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final noms = ref.watch(annuaireProvider).value ?? const {};
    final mots = sansAccents(_recherche).split(' ').where((m) => m.isNotEmpty);
    final comptes = [
      for (final e in noms.entries)
        if (mots.every((m) => sansAccents(e.value).contains(m))) e,
    ]..sort((a, b) => sansAccents(a.value).compareTo(sansAccents(b.value)));
    return Scaffold(
      appBar: AppBar(
        title: Text(_nouvelle ? l10n.nouvelleEquipe : l10n.modifier),
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
                    padding: const EdgeInsets.all(16),
                    children: [
                      TextFormField(
                        controller: _nom,
                        decoration: InputDecoration(
                          labelText: l10n.nomEquipe,
                          hintText: l10n.nomEquipeAide,
                        ),
                        textCapitalization: TextCapitalization.sentences,
                        validator: (v) => (v ?? '').trim().isEmpty
                            ? l10n.champObligatoire
                            : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _description,
                        decoration: InputDecoration(
                          labelText: l10n.champDescription,
                        ),
                        textCapitalization: TextCapitalization.sentences,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        l10n.membresEtResponsables,
                        style: theme.textTheme.titleMedium,
                      ),
                      Text(
                        l10n.membresEtResponsablesAide,
                        style: theme.textTheme.bodySmall,
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.search),
                          hintText: l10n.rechercherPersonne,
                        ),
                        onChanged: (v) => setState(() => _recherche = v),
                      ),
                      for (final e in comptes)
                        CheckboxListTile(
                          contentPadding: EdgeInsets.zero,
                          value: _membres.contains(e.key),
                          title: Text(e.value),
                          onChanged: (v) => setState(() {
                            if (v == true) {
                              _membres.add(e.key);
                            } else {
                              _membres.remove(e.key);
                              _responsables.remove(e.key);
                            }
                          }),
                          secondary: _membres.contains(e.key)
                              ? FilterChip(
                                  label: Text(l10n.responsable),
                                  selected: _responsables.contains(e.key),
                                  onSelected: (v) => setState(
                                    () => v
                                        ? _responsables.add(e.key)
                                        : _responsables.remove(e.key),
                                  ),
                                )
                              : null,
                        ),
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
