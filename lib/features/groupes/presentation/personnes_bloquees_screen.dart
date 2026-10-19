import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/app_localizations.dart';
import '../../auth/auth_providers.dart';
import '../groupes_providers.dart';

/// Personnes bloquées dans les discussions de groupe : les débloquer.
class PersonnesBloqueesScreen extends ConsumerWidget {
  const PersonnesBloqueesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final uid = ref.watch(utilisateurFirebaseProvider).value?.uid;
    final bloques = ref.watch(bloquesProvider);
    final noms = ref.watch(annuaireProvider).value ?? const <String, String>{};
    return Scaffold(
      appBar: AppBar(title: Text(l10n.personnesBloquees)),
      body: bloques.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Text(
                  l10n.aucunePersonneBloquee,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            )
          : ListView(
              children: [
                for (final b in bloques)
                  ListTile(
                    leading: const Icon(Icons.block),
                    title: Text(noms[b] ?? l10n.personneInconnue),
                    trailing: TextButton(
                      onPressed: uid == null
                          ? null
                          : () => ref
                                .read(groupesRepositoryProvider)
                                .debloquer(uid, b),
                      child: Text(l10n.debloquer),
                    ),
                  ),
              ],
            ),
    );
  }
}
