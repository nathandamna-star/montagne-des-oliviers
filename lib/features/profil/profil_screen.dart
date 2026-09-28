import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
import '../../shared/widgets/connexion_requise.dart';
import '../auth/auth_providers.dart';
import '../auth/data/fonctions_roles.dart';
import '../auth/domain/role.dart';
import 'libelles_roles.dart';

class ProfilScreen extends ConsumerStatefulWidget {
  const ProfilScreen({super.key});

  @override
  ConsumerState<ProfilScreen> createState() => _ProfilScreenState();
}

class _ProfilScreenState extends ConsumerState<ProfilScreen> {
  @override
  void initState() {
    super.initState();
    // Voir tout de suite un rôle attribué depuis la dernière connexion.
    ref.read(authRepositoryProvider).rafraichirJeton().catchError((_) {});
  }

  /// Appui long sur la carte : le compte désigné au déploiement devient
  /// administrateur (une seule fois).
  Future<void> _devenirAdmin() async {
    final l10n = AppLocalizations.of(context);
    final messager = ScaffoldMessenger.of(context)..hideCurrentSnackBar();
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.activerAdminTitre),
        content: Text(l10n.activerAdminTexte),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.annuler),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.valider),
          ),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await ref.read(fonctionsRolesProvider).revendiquerAdmin();
      await ref.read(authRepositoryProvider).rafraichirJeton();
      messager.showSnackBar(SnackBar(content: Text(l10n.adminActive)));
    } on ErreurRoles {
      messager.showSnackBar(SnackBar(content: Text(l10n.adminRefuse)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final user = ref.watch(utilisateurFirebaseProvider).value;
    if (user == null) {
      return ConnexionRequise(
        titre: l10n.navProfil,
        texte: l10n.profilConnexionTexte,
      );
    }
    final profil = ref.watch(profilProvider).value;
    final roles = ref.watch(rolesProvider);
    final nom = profil?.nom ?? user.displayName ?? '';

    return Scaffold(
      appBar: AppBar(title: Text(l10n.navProfil)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onLongPress: roles.contains(Role.admin) ? null : _devenirAdmin,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.bonjourNom(nom),
                      style: theme.textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user.email ?? '',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    if (roles.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (final r in Role.values)
                            if (roles.contains(r))
                              Chip(label: Text(l10n.libelleRole(r))),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            l10n.profilAVenir,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            onPressed: () => ref.read(authRepositoryProvider).deconnexion(),
            icon: const Icon(Icons.logout),
            label: Text(l10n.seDeconnecter),
          ),
        ],
      ),
    );
  }
}
