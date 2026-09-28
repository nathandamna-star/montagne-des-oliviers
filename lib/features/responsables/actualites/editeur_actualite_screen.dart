import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../l10n/app_localizations.dart';
import '../../../shared/domain_traduction.dart';
import '../../../shared/widgets/champs_traduits.dart';
import '../../actualites/actualites_providers.dart';
import '../../actualites/domain/actualite.dart';

/// Créer ou modifier une annonce ([id] = « nouvelle » pour en créer une).
class EditeurActualiteScreen extends ConsumerStatefulWidget {
  const EditeurActualiteScreen({super.key, required this.id});

  final String id;

  @override
  ConsumerState<EditeurActualiteScreen> createState() =>
      _EditeurActualiteScreenState();
}

class _EditeurActualiteScreenState
    extends ConsumerState<EditeurActualiteScreen> {
  final _formulaire = GlobalKey<FormState>();
  final _titreFr = TextEditingController();
  final _titreNl = TextEditingController();
  final _texteFr = TextEditingController();
  final _texteNl = TextEditingController();
  late final String _id;
  bool _nouvelle = true;
  bool _charge = false;
  bool _dejaPubliee = false;
  String? _photoUrl;
  Visibilite _visibilite = Visibilite.public;
  bool _epingle = false;
  bool _publie = true;
  bool _notifier = true;
  bool _occupe = false;

  @override
  void initState() {
    super.initState();
    final repo = ref.read(actualitesRepositoryProvider);
    _nouvelle = widget.id == 'nouvelle';
    _id = _nouvelle ? repo.nouvelId() : widget.id;
    if (_nouvelle) {
      _charge = true;
    } else {
      repo.lire(_id).then((a) {
        if (!mounted || a == null) return;
        setState(() {
          _titreFr.text = a.titre['fr'] ?? '';
          _titreNl.text = a.titre['nl'] ?? '';
          _texteFr.text = a.texte['fr'] ?? '';
          _texteNl.text = a.texte['nl'] ?? '';
          _photoUrl = a.photoUrl;
          _visibilite = a.visibilite;
          _epingle = a.epingle;
          _publie = a.publie;
          _dejaPubliee = a.publie;
          // Déjà publiée : on ne renvoie pas de notification par défaut.
          _notifier = !a.publie && a.notifier;
          _charge = true;
        });
      });
    }
  }

  @override
  void dispose() {
    for (final c in [_titreFr, _titreNl, _texteFr, _texteNl]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _choisirPhoto() async {
    final l10n = AppLocalizations.of(context);
    try {
      final url = await ref
          .read(envoiPhotosProvider)
          .choisirEtEnvoyer(
            'actualites/$_id/photo-${DateTime.now().millisecondsSinceEpoch}.jpg',
          );
      if (url != null && mounted) setState(() => _photoUrl = url);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l10n.erreurPhoto)));
    }
  }

  Future<void> _enregistrer() async {
    if (!_formulaire.currentState!.validate()) return;
    final l10n = AppLocalizations.of(context);
    final messager = ScaffoldMessenger.of(context);
    setState(() => _occupe = true);
    try {
      await ref
          .read(actualitesRepositoryProvider)
          .enregistrer(
            Actualite(
              id: _id,
              titre: Traduction.ecrire(_titreFr.text, _titreNl.text),
              texte: Traduction.ecrire(_texteFr.text, _texteNl.text),
              photoUrl: _photoUrl,
              visibilite: _visibilite,
              epingle: _epingle,
              publie: _publie,
              notifier: _publie && _notifier,
            ),
            dejaPubliee: _dejaPubliee,
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
        title: Text(l10n.supprimerAnnonce),
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
    await ref.read(actualitesRepositoryProvider).supprimer(_id);
    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(_nouvelle ? l10n.nouvelleAnnonce : l10n.modifierAnnonce),
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
                      ChampsTraduits(
                        libelle: l10n.champTitre,
                        fr: _titreFr,
                        nl: _titreNl,
                      ),
                      const SizedBox(height: 16),
                      ChampsTraduits(
                        libelle: l10n.champTexte,
                        fr: _texteFr,
                        nl: _texteNl,
                        lignes: 5,
                      ),
                      const SizedBox(height: 16),
                      if (_photoUrl != null) ...[
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            _photoUrl!,
                            height: 160,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) => const SizedBox.shrink(),
                          ),
                        ),
                        TextButton(
                          onPressed: () => setState(() => _photoUrl = null),
                          child: Text(l10n.retirerPhoto),
                        ),
                      ],
                      OutlinedButton.icon(
                        onPressed: _choisirPhoto,
                        icon: const Icon(Icons.photo_outlined),
                        label: Text(
                          _photoUrl == null
                              ? l10n.ajouterPhoto
                              : l10n.changerPhoto,
                        ),
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
                        title: Text(l10n.epingler),
                        subtitle: Text(l10n.epinglerAide),
                        value: _epingle,
                        onChanged: (v) => setState(() => _epingle = v),
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
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
