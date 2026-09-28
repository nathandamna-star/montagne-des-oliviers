import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../l10n/app_localizations.dart';
import '../../../shared/domain_traduction.dart';
import '../../../shared/widgets/champs_traduits.dart';
import '../domain/preparation.dart';
import '../preparations_providers.dart';

/// Pasteurs : créer (« nouvelle ») ou modifier une préparation.
class EditeurPreparationScreen extends ConsumerStatefulWidget {
  const EditeurPreparationScreen({super.key, required this.id});

  final String id;

  @override
  ConsumerState<EditeurPreparationScreen> createState() =>
      _EditeurPreparationScreenState();
}

class _EditeurPreparationScreenState
    extends ConsumerState<EditeurPreparationScreen> {
  final _formulaire = GlobalKey<FormState>();
  final _titreFr = TextEditingController();
  final _titreNl = TextEditingController();
  final _descFr = TextEditingController();
  final _descNl = TextEditingController();
  late final String _id;
  bool _nouvelle = true;
  bool _charge = false;
  bool _occupe = false;
  TypePreparation _type = TypePreparation.bapteme;
  bool _publie = true;

  @override
  void initState() {
    super.initState();
    final repo = ref.read(preparationsRepositoryProvider);
    _nouvelle = widget.id == 'nouvelle';
    _id = _nouvelle ? repo.nouvelId() : widget.id;
    if (_nouvelle) {
      _charge = true;
    } else {
      repo.lire(_id).then((p) {
        if (!mounted || p == null) return;
        setState(() {
          _type = p.type;
          _publie = p.publie;
          _titreFr.text = p.titre['fr'] ?? '';
          _titreNl.text = p.titre['nl'] ?? '';
          _descFr.text = p.description['fr'] ?? '';
          _descNl.text = p.description['nl'] ?? '';
          _charge = true;
        });
      });
    }
  }

  @override
  void dispose() {
    for (final c in [_titreFr, _titreNl, _descFr, _descNl]) {
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
          .read(preparationsRepositoryProvider)
          .enregistrer(
            Preparation(
              id: _id,
              type: _type,
              titre: Traduction.ecrire(_titreFr.text, _titreNl.text),
              description: Traduction.ecrire(_descFr.text, _descNl.text)
                ..removeWhere((_, v) => v.isEmpty),
              publie: _publie,
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(_nouvelle ? l10n.nouvellePreparation : l10n.modifier),
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
                      SegmentedButton<TypePreparation>(
                        segments: [
                          ButtonSegment(
                            value: TypePreparation.bapteme,
                            label: Text(l10n.demandeBapteme),
                          ),
                          ButtonSegment(
                            value: TypePreparation.mariage,
                            label: Text(l10n.demandeMariage),
                          ),
                        ],
                        selected: {_type},
                        onSelectionChanged: (s) =>
                            setState(() => _type = s.first),
                      ),
                      const SizedBox(height: 16),
                      ChampsTraduits(
                        libelle: l10n.champTitre,
                        fr: _titreFr,
                        nl: _titreNl,
                      ),
                      const SizedBox(height: 16),
                      ChampsTraduits(
                        libelle: l10n.champDescription,
                        fr: _descFr,
                        nl: _descNl,
                        lignes: 3,
                        obligatoire: false,
                      ),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(l10n.publier),
                        subtitle: Text(l10n.publierPreparationAide),
                        value: _publie,
                        onChanged: (v) => setState(() => _publie = v),
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
