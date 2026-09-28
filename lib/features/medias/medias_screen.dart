import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/horloge.dart';
import '../../l10n/app_localizations.dart';
import '../../shared/domain_traduction.dart';
import '../../shared/format_date.dart';
import '../../shared/services/lanceur.dart';
import '../../shared/widgets/etat_vide.dart';
import '../parametres/parametres_eglise.dart';
import 'domain/media.dart';
import 'medias_providers.dart';
import 'presentation/widgets_medias.dart';

/// Onglet Médias : verset du jour, direct, prédications et exhortations.
class MediasScreen extends ConsumerStatefulWidget {
  const MediasScreen({super.key});

  @override
  ConsumerState<MediasScreen> createState() => _MediasScreenState();
}

class _MediasScreenState extends ConsumerState<MediasScreen> {
  TypeMedia? _filtre;

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
            (_filtre == null || m.type == _filtre))
          m,
    ];
    return Scaffold(
      appBar: AppBar(title: Text(l10n.navMedias)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const CarteVersetDuJour(),
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
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                ChoiceChip(
                  label: Text(l10n.tous),
                  selected: _filtre == null,
                  onSelected: (_) => setState(() => _filtre = null),
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  avatar: const Icon(Icons.headphones, size: 18),
                  label: Text(l10n.audios),
                  selected: _filtre == TypeMedia.audio,
                  onSelected: (_) => setState(() => _filtre = TypeMedia.audio),
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  avatar: const Icon(Icons.smart_display_outlined, size: 18),
                  label: Text(l10n.videos),
                  selected: _filtre == TypeMedia.video,
                  onSelected: (_) => setState(() => _filtre = TypeMedia.video),
                ),
              ],
            ),
          ),
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
