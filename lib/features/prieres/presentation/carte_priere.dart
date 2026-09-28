import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../l10n/app_localizations.dart';
import '../../../shared/format_date.dart';
import '../domain/priere.dart';

class CartePriere extends StatelessWidget {
  const CartePriere({
    super.key,
    required this.priere,
    required this.lien,
    this.nomVisible = true,
  });

  final Priere priere;
  final String lien;

  /// Faux pour l'équipe d'intercession quand la personne reste anonyme.
  final bool nomVisible;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final p = priere;
    return Card(
      child: ListTile(
        leading: Icon(
          p.exaucee
              ? Icons.celebration_outlined
              : Icons.volunteer_activism_outlined,
          color: p.exaucee
              ? theme.colorScheme.secondary
              : theme.colorScheme.primary,
        ),
        title: Text(p.texte, maxLines: 2, overflow: TextOverflow.ellipsis),
        subtitle: Text(
          [
            nomVisible ? p.nom : l10n.anonyme,
            if (p.createdAt != null) context.dateCourte(p.createdAt!),
            if (p.exaucee) l10n.exaucee,
            if (p.nbPrieres > 0) l10n.nombrePrieres(p.nbPrieres),
          ].join(' · '),
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => context.push(lien),
      ),
    );
  }
}
