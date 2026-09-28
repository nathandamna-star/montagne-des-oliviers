import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/routes.dart';
import '../../../l10n/app_localizations.dart';
import '../domain/groupe.dart';
import '../groupes_providers.dart';
import 'libelles_groupes.dart';

/// Groupe dans une liste : type, nom, dernier message, pastille non lu.
class CarteGroupe extends ConsumerWidget {
  const CarteGroupe({super.key, required this.groupe});

  final Groupe groupe;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final g = groupe;
    final nonLu = ref.watch(nonLuProvider(g));
    final dm = g.dernierMessage;
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: theme.colorScheme.primaryContainer,
          child: Icon(
            iconeGroupe(g.type),
            color: theme.colorScheme.onPrimaryContainer,
          ),
        ),
        title: Text(g.nom, style: theme.textTheme.titleMedium),
        subtitle: Text(
          dm == null
              ? '${l10n.libelleTypeGroupe(g.type)} · ${l10n.nombreMembres(g.membres.length)}'
              : '${dm.nom} : ${dm.texte.isEmpty ? l10n.photo : dm.texte}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: nonLu ? const TextStyle(fontWeight: FontWeight.bold) : null,
        ),
        trailing: nonLu
            ? Badge(
                label: Text(l10n.nouveau),
                backgroundColor: theme.colorScheme.secondary,
              )
            : const Icon(Icons.chevron_right),
        onTap: () => context.push(Routes.groupe(g.id)),
      ),
    );
  }
}
