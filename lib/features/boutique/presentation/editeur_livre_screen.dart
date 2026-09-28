import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../l10n/app_localizations.dart';
import '../../actualites/actualites_providers.dart';
import '../../../shared/domain_traduction.dart';
import '../../../shared/widgets/champs_traduits.dart';
import '../boutique_providers.dart';
import '../domain/boutique.dart';
import 'boutique_screen.dart';

/// Ajouter (« nouveau ») ou modifier un livre de la boutique.
class EditeurLivreScreen extends ConsumerStatefulWidget {
  const EditeurLivreScreen({super.key, required this.id});

  final String id;

  @override
  ConsumerState<EditeurLivreScreen> createState() => _EditeurLivreScreenState();
}

class _EditeurLivreScreenState extends ConsumerState<EditeurLivreScreen> {
  final _formulaire = GlobalKey<FormState>();
  final _titre = TextEditingController();
  final _auteur = TextEditingController();
  final _prix = TextEditingController();
  final _descFr = TextEditingController();
  final _descNl = TextEditingController();
  late final String _id;
  late final bool _nouveau = widget.id == 'nouveau';
  bool _charge = false;
  bool _occupe = false;
  bool _disponible = true;
  String? _photoUrl;

  @override
  void initState() {
    super.initState();
    final repo = ref.read(boutiqueRepositoryProvider);
    _id = _nouveau ? repo.nouveauLivreId() : widget.id;
    if (_nouveau) {
      _charge = true;
    } else {
      repo.lireLivre(_id).then((l) {
        if (!mounted || l == null) return;
        setState(() {
          _titre.text = l.titre;
          _auteur.text = l.auteur;
          _prix.text = l.prix
              .toStringAsFixed(l.prix == l.prix.roundToDouble() ? 0 : 2)
              .replaceAll('.', ',');
          _descFr.text = l.description['fr'] ?? '';
          _descNl.text = l.description['nl'] ?? '';
          _disponible = l.disponible;
          _photoUrl = l.photoUrl;
          _charge = true;
        });
      });
    }
  }

  @override
  void dispose() {
    for (final c in [_titre, _auteur, _prix, _descFr, _descNl]) {
      c.dispose();
    }
    super.dispose();
  }

  double? get _prixSaisi {
    final p = double.tryParse(_prix.text.trim().replaceAll(',', '.'));
    if (p == null || p < 1 || p > 1000) return null;
    return (p * 100).roundToDouble() / 100;
  }

  Future<void> _photo() async {
    final url = await ref
        .read(envoiPhotosProvider)
        .choisirEtEnvoyer(
          'livres/$_id/couverture-${DateTime.now().millisecondsSinceEpoch}.jpg',
        );
    if (url != null && mounted) setState(() => _photoUrl = url);
  }

  Future<void> _enregistrer() async {
    if (!_formulaire.currentState!.validate()) return;
    final l10n = AppLocalizations.of(context);
    final messager = ScaffoldMessenger.of(context);
    setState(() => _occupe = true);
    try {
      final description = Traduction.ecrire(_descFr.text, _descNl.text)
        ..removeWhere((_, v) => v.isEmpty);
      await ref
          .read(boutiqueRepositoryProvider)
          .enregistrerLivre(
            Livre(
              id: _id,
              titre: _titre.text,
              auteur: _auteur.text,
              description: description,
              prix: _prixSaisi!,
              photoUrl: _photoUrl,
              disponible: _disponible,
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
        title: Text(l10n.supprimerLivre),
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
    await ref.read(boutiqueRepositoryProvider).supprimerLivre(_id);
    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(_nouveau ? l10n.nouveauLivre : l10n.modifier),
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
                      Row(
                        children: [
                          CouvertureLivre(
                            livre: Livre(
                              id: _id,
                              titre: '',
                              prix: 0,
                              photoUrl: _photoUrl,
                            ),
                            largeur: 72,
                          ),
                          const SizedBox(width: 16),
                          OutlinedButton.icon(
                            onPressed: _photo,
                            icon: const Icon(Icons.photo_outlined),
                            label: Text(l10n.couverture),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _titre,
                        decoration: InputDecoration(labelText: l10n.champTitre),
                        validator: (v) => (v ?? '').trim().isEmpty
                            ? l10n.champObligatoire
                            : null,
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _auteur,
                        decoration: InputDecoration(labelText: l10n.auteur),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _prix,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: InputDecoration(
                          labelText: l10n.prix,
                          suffixText: '€',
                        ),
                        validator: (_) =>
                            _prixSaisi == null ? l10n.prixInvalide : null,
                      ),
                      const SizedBox(height: 16),
                      ChampsTraduits(
                        libelle: l10n.description,
                        fr: _descFr,
                        nl: _descNl,
                        lignes: 5,
                        obligatoire: false,
                      ),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(l10n.livreDisponible),
                        value: _disponible,
                        onChanged: (v) => setState(() => _disponible = v),
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
