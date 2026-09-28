import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/roles.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/domain/sans_accents.dart';
import '../../auth/auth_providers.dart';
import '../domain/groupe.dart';
import '../groupes_providers.dart';
import 'libelles_groupes.dart';

/// Créer un groupe (secrétariat, [id] null) ou le modifier (administrateur
/// du groupe ou secrétariat).
class EditeurGroupeScreen extends ConsumerStatefulWidget {
  const EditeurGroupeScreen({super.key, this.id});

  final String? id;

  @override
  ConsumerState<EditeurGroupeScreen> createState() =>
      _EditeurGroupeScreenState();
}

class _EditeurGroupeScreenState extends ConsumerState<EditeurGroupeScreen> {
  final _formulaire = GlobalKey<FormState>();
  final _nom = TextEditingController();
  final _description = TextEditingController();
  final _lien = TextEditingController();
  TypeGroupe _type = TypeGroupe.cellule;
  bool _prive = true;
  final _admins = <String>{};
  bool _charge = false;
  bool _occupe = false;
  String? _erreurAdmin;
  String _recherche = '';

  bool get _nouveau => widget.id == null;

  @override
  void initState() {
    super.initState();
    if (_nouveau) {
      _charge = true;
      // Liste des noms à jour (comptes créés récemment).
      ref
          .read(fonctionsRolesProvider)
          .reconstruireAnnuaire()
          .catchError((_) {});
    } else {
      ref.read(groupesRepositoryProvider).lire(widget.id!).then((g) {
        if (!mounted || g == null) return;
        setState(() {
          _nom.text = g.nom;
          _description.text = g.description;
          _lien.text = g.lienAppel;
          _type = g.type;
          _prive = g.prive;
          _charge = true;
        });
      });
    }
  }

  @override
  void dispose() {
    _nom.dispose();
    _description.dispose();
    _lien.dispose();
    super.dispose();
  }

  Future<void> _enregistrer() async {
    final l10n = AppLocalizations.of(context);
    final adminOk = !_nouveau || _admins.isNotEmpty;
    setState(() => _erreurAdmin = adminOk ? null : l10n.choisirAdminGroupe);
    if (!_formulaire.currentState!.validate() || !adminOk) return;
    final repo = ref.read(groupesRepositoryProvider);
    final secretariat = ref.read(estSecretariatProvider);
    final messager = ScaffoldMessenger.of(context);
    setState(() => _occupe = true);
    try {
      if (_nouveau) {
        await repo.creer(
          id: repo.nouvelId(),
          nom: _nom.text,
          type: _type,
          description: _description.text,
          prive: _prive,
          admins: _admins.toList(),
          lienAppel: _lien.text,
        );
      } else {
        await repo.modifier(
          widget.id!,
          nom: _nom.text,
          description: _description.text,
          lienAppel: _lien.text,
          type: secretariat ? _type : null,
          prive: secretariat ? _prive : null,
        );
      }
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
        title: Text(l10n.supprimerGroupe),
        content: Text(l10n.supprimerGroupeAide),
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
    await ref.read(groupesRepositoryProvider).supprimer(widget.id!);
    if (mounted) context.go('/groupes');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final secretariat = ref.watch(estSecretariatProvider);
    final noms = ref.watch(annuaireProvider).value ?? const {};
    final comptes = noms.entries.toList()
      ..sort((a, b) => sansAccents(a.value).compareTo(sansAccents(b.value)));

    return Scaffold(
      appBar: AppBar(
        title: Text(_nouveau ? l10n.nouveauGroupe : l10n.modifierGroupe),
        actions: [
          if (!_nouveau && secretariat)
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
                        decoration: InputDecoration(labelText: l10n.nomGroupe),
                        textCapitalization: TextCapitalization.sentences,
                        validator: (v) => (v ?? '').trim().isEmpty
                            ? l10n.champObligatoire
                            : null,
                      ),
                      const SizedBox(height: 12),
                      if (secretariat) ...[
                        DropdownButtonFormField<TypeGroupe>(
                          initialValue: _type,
                          decoration: InputDecoration(
                            labelText: l10n.typeEvenementChamp,
                          ),
                          items: [
                            for (final t in TypeGroupe.values)
                              DropdownMenuItem(
                                value: t,
                                child: Text(l10n.libelleTypeGroupe(t)),
                              ),
                          ],
                          onChanged: (t) => setState(() => _type = t ?? _type),
                        ),
                        SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(l10n.groupePrive),
                          subtitle: Text(l10n.groupePriveAide),
                          value: _prive,
                          onChanged: (v) => setState(() => _prive = v),
                        ),
                      ],
                      TextFormField(
                        controller: _description,
                        decoration: InputDecoration(
                          labelText: l10n.champDescription,
                        ),
                        minLines: 2,
                        maxLines: null,
                        textCapitalization: TextCapitalization.sentences,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _lien,
                        decoration: InputDecoration(
                          labelText: l10n.lienAppel,
                          helperText: l10n.lienAppelAide,
                          helperMaxLines: 2,
                        ),
                        keyboardType: TextInputType.url,
                        autocorrect: false,
                        validator: (v) =>
                            lienAppelValide(v ?? '') ? null : l10n.lienInvalide,
                      ),
                      if (_nouveau) ...[
                        const SizedBox(height: 24),
                        Text(
                          l10n.adminsGroupe,
                          style: theme.textTheme.titleMedium,
                        ),
                        Text(
                          l10n.adminsGroupeAide,
                          style: theme.textTheme.bodySmall,
                        ),
                        if (_erreurAdmin != null)
                          Text(
                            _erreurAdmin!,
                            style: TextStyle(color: theme.colorScheme.error),
                          ),
                        if (_admins.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              for (final u in _admins)
                                InputChip(
                                  avatar: const Icon(
                                    Icons.admin_panel_settings_outlined,
                                    size: 18,
                                  ),
                                  label: Text(noms[u] ?? l10n.compteInconnu),
                                  onDeleted: () =>
                                      setState(() => _admins.remove(u)),
                                ),
                            ],
                          ),
                        ],
                        const SizedBox(height: 8),
                        TextField(
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.search),
                            hintText: l10n.rechercherPersonne,
                          ),
                          onChanged: (v) => setState(() => _recherche = v),
                        ),
                        for (final e in comptes)
                          if (sansAccents(_recherche)
                              .split(' ')
                              .where((m) => m.isNotEmpty)
                              .every((m) => sansAccents(e.value).contains(m)))
                            CheckboxListTile(
                              contentPadding: EdgeInsets.zero,
                              value: _admins.contains(e.key),
                              title: Text(e.value),
                              onChanged: (v) => setState(
                                () => v == true
                                    ? _admins.add(e.key)
                                    : _admins.remove(e.key),
                              ),
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
