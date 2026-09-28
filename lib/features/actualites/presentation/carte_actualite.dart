import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../l10n/app_localizations.dart';
import '../../../shared/domain_traduction.dart';
import '../../../shared/format_date.dart';
import '../domain/actualite.dart';

/// Annonce dans une liste : photo, titre, date, épinglée.
class CarteActualite extends StatelessWidget {
  const CarteActualite({
    super.key,
    required this.actualite,
    required this.lien,
  });

  final Actualite actualite;

  /// Adresse de la fiche de l'annonce.
  final String lien;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final a = actualite;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.push(lien),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (a.photoUrl != null)
              Image.network(
                a.photoUrl!,
                width: 96,
                height: 96,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => const SizedBox(width: 96),
              ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        if (a.epingle) ...[
                          Icon(
                            Icons.push_pin,
                            size: 16,
                            color: theme.colorScheme.secondary,
                            semanticLabel: l10n.epinglee,
                          ),
                          const SizedBox(width: 4),
                        ],
                        if (a.visibilite == Visibilite.membres) ...[
                          Icon(
                            Icons.lock_outline,
                            size: 16,
                            color: theme.colorScheme.onSurfaceVariant,
                            semanticLabel: l10n.visibiliteMembres,
                          ),
                          const SizedBox(width: 4),
                        ],
                        if (a.publieLe != null)
                          Text(
                            context.dateCourte(a.publieLe!),
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      Traduction.dans(a.titre, context.langue),
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      Traduction.dans(a.texte, context.langue),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
