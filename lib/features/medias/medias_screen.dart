import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:go_router/go_router.dart';

import '../../core/horloge.dart';
import '../../core/roles.dart';
import '../../core/router/routes.dart';
import '../../l10n/app_localizations.dart';
import '../../shared/widgets/reseaux_sociaux.dart';
import '../../shared/domain_traduction.dart';
import '../../shared/format_date.dart';
import '../../shared/services/lanceur.dart';
import '../../shared/widgets/etat_vide.dart';
import '../parametres/parametres_eglise.dart';
import 'domain/media.dart';
import 'medias_providers.dart';
import 'presentation/libelles_medias.dart';
import 'presentation/widgets_medias.dart';

/// Onglet Médias : verset du jour, direct, prédications et exhortations.
class MediasScreen extends ConsumerStatefulWidget {
  const MediasScreen({super.key, this.rubrique});

  /// Rubrique ouverte au départ (depuis les raccourcis de l'Accueil).
  final String? rubrique;

  @override
  ConsumerState<MediasScreen> createState() => _MediasScreenState();
}

class _MediasScreenState extends ConsumerState<MediasScreen> {
  late Rubrique _rubrique = Rubrique.depuis(widget.rubrique);
  ThemeMedia? _theme;

  @override
  void didUpdateWidget(MediasScreen ancien) {
    super.didUpdateWidget(ancien);
    if (widget.rubrique != null && widget.rubrique != ancien.rubrique) {
      _rubrique = Rubrique.depuis(widget.rubrique);
      _theme = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final medias = ref.watch(mediasProvider);
    final maintenant = ref.watch(horlogeProvider)();
    final youtube = ref.watch(parametresEgliseProvider).value?.youtubeUrl ?? '';
    final tous = medias.value ?? const <Media>[];
    // Direct du jour ou à venir.
    final directs = [
      for (final m in tous)
        if (m.type == TypeMedia.direct &&
            m.date.isAfter(maintenant.subtract(const Duration(hours: 4))))
          m,
    ]..sort((a, b) => a.date.compareTo(b.date));
    final liste = [
      for (final m in tous)
        if (m.type != TypeMedia.direct &&
            m.rubrique == _rubrique &&
            (_theme == null || m.theme == _theme))
          m,
    ];
    final gestion = ref.watch(estSecretariatProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.navMedias),
        actions: [
          if (gestion)
            IconButton(
              tooltip: l10n.gererMedias,
              onPressed: () => context.push(Routes.gestionMedias),
              icon: const Icon(Icons.edit_note),
            ),
        ],
      ),
      // Secrétariat et pasteurs : ajouter directement une prédication.
      floatingActionButton: gestion
          ? FloatingActionButton.extended(
              onPressed: () => context.push(
                '${Routes.editerMedia('nouveau')}?rubrique=${_rubrique.name}',
              ),
              icon: const Icon(Icons.add),
              label: Text(l10n.ajouterAudioVideo),
            )
          : null,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const CarteVersetDuJour(),
          const SizedBox(height: 8),
          const ReseauxSociaux(),
          if (directs.isNotEmpty || youtube.isNotEmpty) ...[
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.live_tv_outlined,
                          color: theme.colorScheme.error,
                        ),
                        const SizedBox(width: 8),
                        Text(l10n.direct, style: theme.textTheme.titleMedium),
                      ],
                    ),
                    if (directs.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        Traduction.dans(directs.first.titre, context.langue),
                      ),
                      Text(
                        directs.first.date.isAfter(maintenant)
                            ? '${context.dateLongue(directs.first.date)}, ${context.heure(directs.first.date)}'
                            : l10n.enDirectMaintenant,
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                    const SizedBox(height: 8),
                    FilledButton.icon(
                      onPressed: () {
                        final lien =
                            directs.isNotEmpty && directs.first.url != null
                            ? directs.first.url!
                            : youtube;
                        if (lien.isNotEmpty) {
                          ref.read(lanceurProvider).ouvrir(Uri.parse(lien));
                        }
                      },
                      icon: const Icon(Icons.play_arrow),
                      label: Text(l10n.regarderDirect),
                    ),
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: 8),
          SegmentedButton<Rubrique>(
            showSelectedIcon: false,
            segments: [
              for (final r in Rubrique.values)
                ButtonSegment(
                  value: r,
                  icon: Icon(iconeRubrique(r)),
                  label: Text(l10n.rubrique(r)),
                ),
            ],
            selected: {_rubrique},
            onSelectionChanged: (s) => setState(() {
              _rubrique = s.first;
              _theme = null;
            }),
          ),
          if (_rubrique.themes.isNotEmpty) ...[
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  ChoiceChip(
                    label: Text(l10n.tous),
                    selected: _theme == null,
                    onSelected: (_) => setState(() => _theme = null),
                  ),
                  for (final t in _rubrique.themes) ...[
                    const SizedBox(width: 8),
                    ChoiceChip(
                      label: Text(l10n.themeMedia(t)),
                      selected: _theme == t,
                      onSelected: (_) => setState(() => _theme = t),
                    ),
                  ],
                ],
              ),
            ),
          ],
          const SizedBox(height: 8),
          if (medias.isLoading)
            const Center(child: CircularProgressIndicator())
          else if (liste.isEmpty)
            EtatVide(icone: Icons.play_circle_outline, texte: l10n.aucunMedia)
          else
            for (final m in liste) CarteMedia(media: m),
        ],
      ),
    );
  }
}
