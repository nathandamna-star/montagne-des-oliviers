import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/roles.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/domain_traduction.dart';
import '../../../shared/format_date.dart';
import '../../../shared/lecteurs/lecteurs.dart';
import '../../../shared/services/lanceur.dart';
import '../../../shared/widgets/etat_vide.dart';
import '../../actualites/domain/actualite.dart';
import '../domain/media.dart';
import '../medias_providers.dart';

/// Une prédication ou exhortation : lecteur, description, partage WhatsApp.
class MediaScreen extends ConsumerWidget {
  const MediaScreen({super.key, required this.id});

  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final media = ref.watch(mediaProvider(id));
    final lecteurs = ref.watch(fabriqueLecteursProvider);
    final secretariat = ref.watch(estSecretariatProvider);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.navMedias)),
      body: media.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) =>
            EtatVide(icone: Icons.lock_outline, texte: l10n.mediaIndisponible),
        data: (m) {
          if (m == null) {
            return EtatVide(
              icone: Icons.play_circle_outline,
              texte: l10n.mediaIndisponible,
            );
          }
          final titre = Traduction.dans(m.titre, context.langue);
          final description = Traduction.dans(m.description, context.langue);
          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  Text(titre, style: theme.textTheme.headlineSmall),
                  const SizedBox(height: 4),
                  Text(
                    [
                      if (m.predicateur.isNotEmpty) m.predicateur,
                      context.dateLongue(m.date),
                    ].join(' · '),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (m.url != null && m.lienExterne)
                    FilledButton.icon(
                      onPressed: () =>
                          ref.read(lanceurProvider).ouvrir(Uri.parse(m.url!)),
                      icon: const Icon(Icons.play_arrow),
                      label: Text(l10n.regarderSurYoutube),
                    )
                  else if (m.url != null && m.type == TypeMedia.video)
                    lecteurs.video(url: m.url!, cle: 'media-$id')
                  else if (m.url != null)
                    lecteurs.audio(url: m.url!, cle: 'media-$id'),
                  if (description.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    SelectableText(
                      description,
                      style: theme.textTheme.bodyLarge,
                    ),
                  ],
                  // Partage : seulement les médias publics (la page web est publique).
                  if (m.publie && m.visibilite == Visibilite.public) ...[
                    const SizedBox(height: 24),
                    OutlinedButton.icon(
                      onPressed: () => ref
                          .read(diffusionWhatsAppProvider)
                          .partager(
                            titre: titre,
                            texte: description.length > 200
                                ? '${description.substring(0, 199)}…'
                                : description,
                            lien: pageWebMedia(m.id),
                          ),
                      icon: const Icon(Icons.share_outlined),
                      label: Text(l10n.envoyerSurWhatsApp),
                    ),
                    if (secretariat)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: SelectableText(
                          pageWebMedia(m.id).toString(),
                          style: theme.textTheme.bodySmall,
                        ),
                      ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
