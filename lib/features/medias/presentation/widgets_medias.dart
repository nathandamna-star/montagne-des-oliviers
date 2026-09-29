import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/routes.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/domain_traduction.dart';
import '../../../shared/format_date.dart';
import '../domain/media.dart';
import 'libelles_medias.dart';
import '../medias_providers.dart';

IconData iconeMedia(TypeMedia t) => switch (t) {
  TypeMedia.audio => Icons.headphones,
  TypeMedia.video => Icons.smart_display_outlined,
  TypeMedia.direct => Icons.live_tv_outlined,
};

/// Carte du verset du jour (Accueil et Médias).
class CarteVersetDuJour extends ConsumerWidget {
  const CarteVersetDuJour({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final v = ref.watch(versetDuJourProvider);
    if (v == null) return const SizedBox.shrink();
    return Card(
      color: theme.colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.versetDuJour,
              style: theme.textTheme.labelLarge?.copyWith(
                color: theme.colorScheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '« ${Traduction.dans(v.texte, context.langue)} »',
              style: theme.textTheme.bodyLarge?.copyWith(
                fontStyle: FontStyle.italic,
                color: theme.colorScheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              v.reference,
              style: theme.textTheme.labelLarge?.copyWith(
                color: theme.colorScheme.onPrimaryContainer,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CarteMedia extends StatelessWidget {
  const CarteMedia({super.key, required this.media, this.lien});

  final Media media;
  final String? lien;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final m = media;
    return Card(
      child: ListTile(
        leading: Icon(iconeMedia(m.type), color: theme.colorScheme.secondary),
        title: Text(Traduction.dans(m.titre, context.langue)),
        subtitle: Text(
          [
            if (m.theme != null)
              AppLocalizations.of(context).themeMedia(m.theme!),
            if (m.predicateur.isNotEmpty) m.predicateur,
            context.dateCourte(m.date),
            if (!m.publie) l10n.brouillon,
          ].join(' · '),
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => context.push(lien ?? Routes.media(m.id)),
      ),
    );
  }
}
