import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/horloge.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/data/envoi_fichiers.dart';
import '../../../shared/domain_traduction.dart';
import '../../../shared/format_date.dart';
import '../../../shared/widgets/champs_traduits.dart';
import '../../actualites/domain/actualite.dart';
import '../../groupes/domain/groupe.dart';
import '../../preparations/preparations_providers.dart';
import '../domain/media.dart';
import '../medias_providers.dart';
import 'libelles_medias.dart';
import 'widgets_medias.dart';

/// Secrétariat : publier une prédication, une exhortation ou un direct.
class EditeurMediaScreen extends ConsumerStatefulWidget {
  const EditeurMediaScreen({super.key, required this.id, this.rubrique});

  final String id;

  /// Rubrique proposée pour un nouveau média.
  final Rubrique? rubrique;

  @override
  ConsumerState<EditeurMediaScreen> createState() => _EditeurMediaScreenState();
}

class _EditeurMediaScreenState extends ConsumerState<EditeurMediaScreen> {
  final _formulaire = GlobalKey<FormState>();
  final _titreFr = TextEditingController();
  final _titreNl = TextEditingController();
  final _descFr = TextEditingController();
  final _descNl = TextEditingController();
  final _predicateur = TextEditingController();
  final _lien = TextEditingController();
  late final String _id;
  bool _nouveau = true;
  bool _charge = false;
  bool _occupe = false;
  TypeMedia _type = TypeMedia.audio;
  late Rubrique _rubrique = widget.rubrique ?? Rubrique.predication;
  ThemeMedia? _theme;
  late DateTime _date;
  String? _fichier;
  double? _progression;
  Visibilite _visibilite = Visibilite.public;
  bool _publie = true;
  bool _notifier = true;
  bool _dejaPublie = false;

  @override
  void initState() {
    super.initState();
    final repo = ref.read(mediasRepositoryProvider);
    _nouveau = widget.id == 'nouveau';
    _id = _nouveau ? repo.nouvelId() : widget.id;
    final n = ref.read(horlogeProvider)();
    _date = DateTime(n.year, n.month, n.day, n.hour);
    if (_nouveau) {
      _charge = true;
    } else {
      repo.lire(_id).then((m) {
        if (!mounted || m == null) return;
        setState(() {
          _type = m.type;
          _rubrique = m.rubrique;
          _theme = m.theme;
          _titreFr.text = m.titre['fr'] ?? '';
          _titreNl.text = m.titre['nl'] ?? '';
          _descFr.text = m.description['fr'] ?? '';
          _descNl.text = m.description['nl'] ?? '';
          _predicateur.text = m.predicateur;
          _date = m.date;
          if (m.lienExterne) {
            _lien.text = m.url ?? '';
          } else {
            _fichier = m.url;
          }
          _visibilite = m.visibilite;
          _publie = m.publie;
          _dejaPublie = m.publie;
          _notifier = false;
          _charge = true;
        });
      });
    }
  }

  @override
  void dispose() {
    for (final c in [
      _titreFr,
      _titreNl,
      _descFr,
      _descNl,
      _predicateur,
      _lien,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _envoyer() async {
    final l10n = AppLocalizations.of(context);
    final messager = ScaffoldMessenger.of(context);
    setState(() => _progression = 0);
    try {
      final url = await ref
          .read(envoiFichiersProvider)
          .choisirEtEnvoyer(
            dossier: 'medias/$_id',
            genre: _type == TypeMedia.video
                ? GenreFichier.video
                : GenreFichier.audio,
            progression: (p) {
              if (mounted) setState(() => _progression = p);
            },
          );
      if (url != null && mounted) setState(() => _fichier = url);
    } catch (_) {
      messager.showSnackBar(SnackBar(content: Text(l10n.envoiEchoue)));
    } finally {
      if (mounted) setState(() => _progression = null);
    }
  }

  Future<void> _choisirDate() async {
    final jour = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
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
    if (!_formulaire.currentState!.validate()) return;
    final l10n = AppLocalizations.of(context);
    final url = _lien.text.trim().isNotEmpty ? _lien.text.trim() : _fichier;
    final messager = ScaffoldMessenger.of(context);
    if (url == null && _type != TypeMedia.direct) {
      messager.showSnackBar(SnackBar(content: Text(l10n.fichierOuLienRequis)));
      return;
    }
    setState(() => _occupe = true);
    try {
      await ref
          .read(mediasRepositoryProvider)
          .enregistrer(
            Media(
              id: _id,
              type: _type,
              titre: Traduction.ecrire(_titreFr.text, _titreNl.text),
              description: Traduction.ecrire(_descFr.text, _descNl.text)
                ..removeWhere((_, v) => v.isEmpty),
              predicateur: _predicateur.text,
              date: _date,
              url: url,
              visibilite: _visibilite,
              publie: _publie,
              notifier: _publie && _notifier && !_dejaPublie,
              rubrique: _rubrique,
              theme: _rubrique.themes.contains(_theme) ? _theme : null,
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
        title: Text(_nouveau ? l10n.nouveauMedia : l10n.modifier),
        actions: [
          if (!_nouveau)
            IconButton(
              tooltip: l10n.supprimer,
              onPressed: () async {
                await ref.read(mediasRepositoryProvider).supprimer(_id);
                if (context.mounted) context.pop();
              },
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
                      SegmentedButton<TypeMedia>(
                        segments: [
                          ButtonSegment(
                            value: TypeMedia.audio,
                            icon: Icon(iconeMedia(TypeMedia.audio)),
                            label: Text(l10n.audio),
                          ),
                          ButtonSegment(
                            value: TypeMedia.video,
                            icon: Icon(iconeMedia(TypeMedia.video)),
                            label: Text(l10n.video),
                          ),
                          ButtonSegment(
                            value: TypeMedia.direct,
                            icon: Icon(iconeMedia(TypeMedia.direct)),
                            label: Text(l10n.direct),
                          ),
                        ],
                        selected: {_type},
                        onSelectionChanged: (s) =>
                            setState(() => _type = s.first),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        l10n.rubriqueMedia,
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const SizedBox(height: 8),
                      SegmentedButton<Rubrique>(
                        segments: [
                          for (final r in Rubrique.values)
                            ButtonSegment(
                              value: r,
                              icon: Icon(iconeRubrique(r)),
                              label: Text(l10n.rubrique(r)),
                            ),
                        ],
                        selected: {_rubrique},
                        onSelectionChanged: (s) =>
                            setState(() => _rubrique = s.first),
                      ),
                      if (_rubrique.themes.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Text(
                          l10n.themeMediaTitre,
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            for (final t in _rubrique.themes)
                              ChoiceChip(
                                label: Text(l10n.themeMedia(t)),
                                selected: _theme == t,
                                onSelected: (oui) =>
                                    setState(() => _theme = oui ? t : null),
                              ),
                          ],
                        ),
                      ],
                      const SizedBox(height: 16),
                      ChampsTraduits(
                        libelle: l10n.champTitre,
                        fr: _titreFr,
                        nl: _titreNl,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _predicateur,
                        decoration: InputDecoration(
                          labelText: l10n.predicateur,
                        ),
                        textCapitalization: TextCapitalization.words,
                      ),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.schedule),
                        title: Text(
                          _type == TypeMedia.direct
                              ? l10n.debutDirect
                              : l10n.dateEtHeure,
                        ),
                        subtitle: Text(
                          '${context.dateLongue(_date)}, ${context.heure(_date)}',
                        ),
                        onTap: _choisirDate,
                      ),
                      if (_type != TypeMedia.direct) ...[
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(8),
                            child: Column(
                              children: [
                                ListTile(
                                  leading: const Icon(Icons.upload_file),
                                  title: Text(
                                    _type == TypeMedia.video
                                        ? l10n.fichierVideo
                                        : l10n.fichierAudio,
                                  ),
                                  subtitle: Text(
                                    _fichier == null
                                        ? l10n.aucunFichier
                                        : l10n.fichierEnvoye,
                                  ),
                                ),
                                if (_progression != null)
                                  LinearProgressIndicator(value: _progression)
                                else
                                  OutlinedButton(
                                    onPressed: _envoyer,
                                    child: Text(
                                      _fichier == null
                                          ? l10n.choisirFichier
                                          : l10n.remplacerFichier,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                      ],
                      TextFormField(
                        controller: _lien,
                        decoration: InputDecoration(
                          labelText: _type == TypeMedia.direct
                              ? l10n.lienDirect
                              : l10n.ouLienYoutube,
                          hintText: 'https://www.youtube.com/…',
                        ),
                        keyboardType: TextInputType.url,
                        validator: (v) {
                          final t = (v ?? '').trim();
                          if (t.isEmpty) {
                            return _type == TypeMedia.direct
                                ? l10n.champObligatoire
                                : null;
                          }
                          return lienAppelValide(t) ? null : l10n.lienInvalide;
                        },
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
                        title: Text(l10n.publier),
                        value: _publie,
                        onChanged: (v) => setState(() => _publie = v),
                      ),
                      if (_publie && !_dejaPublie)
                        SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(l10n.envoyerNotification),
                          subtitle: Text(l10n.envoyerNotificationAide),
                          value: _notifier,
                          onChanged: (v) => setState(() => _notifier = v),
                        ),
                      const SizedBox(height: 16),
                      FilledButton(
                        onPressed: _occupe || _progression != null
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
