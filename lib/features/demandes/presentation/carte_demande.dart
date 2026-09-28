import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../l10n/app_localizations.dart';
import '../../../shared/format_date.dart';
import '../domain/demande.dart';
import 'libelles_demandes.dart';

class CarteDemande extends StatelessWidget {
  const CarteDemande({
    super.key,
    required this.demande,
    required this.lien,
    this.avecNom = false,
  });

  final Demande demande;
  final String lien;

  /// Affiche le nom de la personne (liste du secrétariat).
  final bool avecNom;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final d = demande;
    return Card(
      child: ListTile(
        leading: Icon(iconeDemande(d.type), color: theme.colorScheme.secondary),
        title: Text(
          avecNom
              ? '${l10n.libelleDemande(d.type)} · ${d.nom}'
              : l10n.libelleDemande(d.type),
        ),
        subtitle: Text(
          [
            if (d.createdAt != null) context.dateCourte(d.createdAt!),
            l10n.libelleStatutDemande(d.statut),
          ].join(' · '),
          style: TextStyle(
            color: couleurStatutDemande(theme.colorScheme, d.statut),
          ),
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => context.push(lien),
      ),
    );
  }
}
