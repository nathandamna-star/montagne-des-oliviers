import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../l10n/app_localizations.dart';
import '../../../shared/data/envoi_fichiers.dart';
import '../../../shared/domain_traduction.dart';
import '../../../shared/widgets/champs_traduits.dart';
import '../domain/preparation.dart';
import '../preparations_providers.dart';

/// Pasteurs : créer (« nouvelle ») ou modifier une leçon, avec audio, vidéo
/// et document envoyés depuis le téléphone ou l'ordinateur.
class EditeurLeconScreen extends ConsumerStatefulWidget {
  const EditeurLeconScreen({
    super.key,
    required this.preparationId,
    required this.id,
    this.genre = GenreLecon.lecon,
  });

  final String preparationId;
  final String id;

  /// Pour une création : leçon ou exhortation.
  final GenreLecon genre;

  @override
  ConsumerState<EditeurLeconScreen> createState() => _EditeurLeconScreenState();
}

class _EditeurLeconScreenState extends ConsumerState<EditeurLeconScreen> {
  final _formulaire = GlobalKey<FormState>();
  final _titreFr = TextEditingController();
  final _titreNl = TextEditingController();
  final _texteFr = TextEditingController();
  final _texteNl = TextEditingController();
  late final String _id;
  bool _nouvelle = true;
  bool _charge = false;
  bool _occupe = false;
  bool _publique = false;
  late GenreLecon _genre = widget.genre;
  int _ordre = 0;
  final _urls = <GenreFichier, String?>{};
  GenreFichier? _envoiEnCours;
  double _progression = 0;

  @override
  void initState() {
    super.initState();
    final repo = ref.read(preparationsRepositoryProvider);
    _nouvelle = widget.id == 'nouvelle';
    _id = _nouvelle ? repo.nouvelleLeconId(widget.preparationId) : widget.id;
    if (_nouvelle) {
      // À la suite des leçons existantes.
      repo.lecons(widget.preparationId, toutes: true).first.then((l) {
        if (!mounted) return;
        setState(() {
          _ordre = l.isEmpty
              ? 1
              : l.map((x) => x.ordre).reduce((a, b) => a > b ? a : b) + 1;
          _charge = true;
        });
      });
    } else {
      repo.lireLecon(widget.preparationId, _id).then((l) {
        if (!mounted || l == null) return;
        setState(() {
          _titreFr.text = l.titre['fr'] ?? '';
          _titreNl.text = l.titre['nl'] ?? '';
          _texteFr.text = l.texte['fr'] ?? '';
          _texteNl.text = l.texte['nl'] ?? '';
          _publique = l.publique;
          _genre = l.genre;
          _ordre = l.ordre;
          _urls[GenreFichier.audio] = l.audioUrl;
          _urls[GenreFichier.video] = l.videoUrl;
          _urls[GenreFichier.document] = l.documentUrl;
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

  Future<void> _envoyer(GenreFichier genre) async {
    final l10n = AppLocalizations.of(context);
    final messager = ScaffoldMessenger.of(context);
    setState(() {
      _envoiEnCours = genre;
      _progression = 0;
    });
    try {
      final url = await ref
          .read(envoiFichiersProvider)
          .choisirEtEnvoyer(
            dossier: 'preparations/${widget.preparationId}/$_id',
            genre: genre,
            progression: (p) {
              if (mounted) setState(() => _progression = p);
            },
          );
      if (url != null && mounted) setState(() => _urls[genre] = url);
    } catch (_) {
      messager.showSnackBar(SnackBar(content: Text(l10n.envoiEchoue)));
    } finally {
      if (mounted) setState(() => _envoiEnCours = null);
    }
  }

  Future<void> _enregistrer() async {
    if (!_formulaire.currentState!.validate()) return;
    final l10n = AppLocalizations.of(context);
    final messager = ScaffoldMessenger.of(context);
    setState(() => _occupe = true);
    try {
      await ref
          .read(preparationsRepositoryProvider)
          .enregistrerLecon(
            widget.preparationId,
            Lecon(
              id: _id,
              titre: Traduction.ecrire(_titreFr.text, _titreNl.text),
              texte: Traduction.ecrire(_texteFr.text, _texteNl.text)
                ..removeWhere((_, v) => v.isEmpty),
              ordre: _ordre,
              genre: _genre,
              publique: _publique,
              audioUrl: _urls[GenreFichier.audio],
              videoUrl: _urls[GenreFichier.video],
              documentUrl: _urls[GenreFichier.document],
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
        title: Text(l10n.supprimerLecon),
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
        .read(preparationsRepositoryProvider)
        .supprimerLecon(widget.preparationId, _id);
    if (mounted) context.pop();
    if (mounted) context.pop();
  }

  Widget _fichier(GenreFichier genre, IconData icone, String libelle) {
    final l10n = AppLocalizations.of(context);
    final present = _urls[genre] != null;
    final enCours = _envoiEnCours == genre;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            ListTile(
              leading: Icon(icone),
              title: Text(libelle),
              subtitle: Text(present ? l10n.fichierEnvoye : l10n.aucunFichier),
              trailing: present
                  ? IconButton(
                      tooltip: l10n.retirer,
                      onPressed: () => setState(() => _urls[genre] = null),
                      icon: const Icon(Icons.close),
                    )
                  : null,
            ),
            if (enCours)
              LinearProgressIndicator(value: _progression)
            else
              OutlinedButton.icon(
                onPressed: _envoiEnCours == null ? () => _envoyer(genre) : null,
                icon: const Icon(Icons.upload_file),
                label: Text(
                  present ? l10n.remplacerFichier : l10n.choisirFichier,
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
    return Scaffold(
      appBar: AppBar(
        title: Text(
          !_nouvelle
              ? l10n.modifier
              : _genre == GenreLecon.exhortation
              ? l10n.ajouterExhortation
              : l10n.ajouterLecon,
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
                        lignes: 6,
                        obligatoire: false,
                      ),
                      const SizedBox(height: 16),
                      _fichier(
                        GenreFichier.audio,
                        Icons.headphones,
                        l10n.fichierAudio,
                      ),
                      _fichier(
                        GenreFichier.video,
                        Icons.videocam_outlined,
                        l10n.fichierVideo,
                      ),
                      _fichier(
                        GenreFichier.document,
                        Icons.picture_as_pdf_outlined,
                        l10n.fichierDocument,
                      ),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(l10n.leconPublique),
                        subtitle: Text(l10n.leconPubliqueAide),
                        value: _publique,
                        onChanged: (v) => setState(() => _publique = v),
                      ),
                      const SizedBox(height: 16),
                      FilledButton(
                        onPressed: _occupe || _envoiEnCours != null
                            ? null
                            : _enregistrer,
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
