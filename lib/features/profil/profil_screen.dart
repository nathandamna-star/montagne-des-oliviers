import 'dart:ui' show PlatformDispatcher;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/langue.dart';
import '../../core/router/routes.dart';
import '../../l10n/app_localizations.dart';
import '../../shared/services/partage.dart';
import '../../shared/widgets/connexion_requise.dart';
import '../../shared/widgets/liens_legaux.dart';
import '../actualites/actualites_providers.dart';
import '../notifications/notifications_providers.dart';
import '../auth/auth_providers.dart';
import '../auth/data/fonctions_roles.dart';
import '../auth/domain/role.dart';
import 'data/fonctions_compte.dart';
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

  bool _occupe = false;

  Future<void> _modifierNom(String actuel) async {
    final uid = ref.read(utilisateurFirebaseProvider).value?.uid;
    final nom = await showDialog<String>(
      context: context,
      builder: (context) => _DialogueNom(actuel: actuel),
    );
    if (uid == null || nom == null || nom.trim().isEmpty) return;
    await ref.read(authRepositoryProvider).modifierProfil(uid, nom: nom);
  }

  Future<void> _modifierPhoto() async {
    final uid = ref.read(utilisateurFirebaseProvider).value?.uid;
    if (uid == null) return;
    final url = await ref
        .read(envoiPhotosProvider)
        .choisirEtEnvoyer(
          'users/$uid/photo-${DateTime.now().millisecondsSinceEpoch}.jpg',
        );
    if (url == null) return;
    await ref.read(authRepositoryProvider).modifierProfil(uid, photoUrl: url);
  }

  /// Langue de l'app ; celle du profil sert aux notifications.
  Future<void> _choisirLangue(String? langue) async {
    final uid = ref.read(utilisateurFirebaseProvider).value?.uid;
    await ref.read(langueAppProvider.notifier).choisir(langue);
    if (uid == null) return;
    final effective =
        langue ??
        (PlatformDispatcher.instance.locale.languageCode == 'nl' ? 'nl' : 'fr');
    await ref
        .read(authRepositoryProvider)
        .modifierProfil(uid, langue: effective);
    await ref
        .read(notificationsServiceProvider)
        .activer(langue: effective, uid: uid);
  }

  Future<void> _exporter() async {
    final l10n = AppLocalizations.of(context);
    final messager = ScaffoldMessenger.of(context);
    setState(() => _occupe = true);
    try {
      final json = await ref.read(fonctionsCompteProvider).exporterMesDonnees();
      await ref
          .read(partageProvider)
          .partagerFichier(
            nom: 'mes-donnees-montagne-des-oliviers.json',
            contenu: json,
            typeMime: 'application/json',
          );
    } on ErreurCompte {
      messager.showSnackBar(SnackBar(content: Text(l10n.erreurInconnue)));
    } finally {
      if (mounted) setState(() => _occupe = false);
    }
  }

  Future<void> _supprimer() async {
    final l10n = AppLocalizations.of(context);
    final messager = ScaffoldMessenger.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.supprimerCompteTitre),
        content: Text(l10n.supprimerCompteTexte),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.annuler),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.supprimerDefinitivement),
          ),
        ],
      ),
    );
    if (ok != true) return;
    setState(() => _occupe = true);
    try {
      await ref.read(fonctionsCompteProvider).supprimerMonCompte();
      await ref.read(authRepositoryProvider).deconnexion();
      messager.showSnackBar(SnackBar(content: Text(l10n.compteSupprime)));
    } on ErreurCompte catch (e) {
      messager.showSnackBar(
        SnackBar(
          content: Text(switch (e.code) {
            'dernier-admin' => l10n.suppressionDernierAdmin,
            'commande-a-retirer' => l10n.suppressionCommandeARetirer,
            'reseau' => l10n.erreurReseau,
            _ => l10n.erreurInconnue,
          }),
        ),
      );
    } finally {
      if (mounted) setState(() => _occupe = false);
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
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 28,
                          foregroundImage: profil?.photoUrl == null
                              ? null
                              : NetworkImage(profil!.photoUrl!),
                          // Photo introuvable : l'initiale reste affichée.
                          onForegroundImageError: profil?.photoUrl == null
                              ? null
                              : (_, _) {},
                          child: Text(
                            nom.characters.firstOrNull?.toUpperCase() ?? '?',
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            l10n.bonjourNom(nom),
                            style: theme.textTheme.headlineSmall,
                          ),
                        ),
                      ],
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
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.outbox_outlined),
                  title: Text(l10n.mesDemandes),
                  subtitle: Text(l10n.mesDemandesSousTitre),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push(Routes.mesDemandes),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.event_note_outlined),
                  title: Text(l10n.planning),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push(Routes.planning),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.menu_book_outlined),
                  title: Text(l10n.preparations),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push(Routes.preparations),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.volunteer_activism_outlined),
                  title: Text(l10n.mesSujetsPriere),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push(Routes.mesPrieres),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.savings_outlined),
                  title: Text(l10n.mesDons),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push(Routes.dons),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.shopping_bag_outlined),
                  title: Text(l10n.mesCommandes),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push(Routes.mesCommandes),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.badge_outlined),
                  title: Text(l10n.champNom),
                  subtitle: Text(nom),
                  trailing: const Icon(Icons.edit_outlined),
                  onTap: profil == null ? null : () => _modifierNom(nom),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.photo_camera_outlined),
                  title: Text(l10n.photoProfil),
                  trailing: const Icon(Icons.edit_outlined),
                  onTap: profil == null ? null : _modifierPhoto,
                ),
                const Divider(height: 1),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l10n.langueApp, style: theme.textTheme.titleSmall),
                      const SizedBox(height: 8),
                      SegmentedButton<String>(
                        segments: [
                          ButtonSegment(
                            value: 'auto',
                            label: Text(l10n.langueTelephone),
                          ),
                          const ButtonSegment(
                            value: 'fr',
                            label: Text('Français'),
                          ),
                          const ButtonSegment(
                            value: 'nl',
                            label: Text('Nederlands'),
                          ),
                        ],
                        selected: {ref.watch(langueAppProvider) ?? 'auto'},
                        onSelectionChanged: (s) =>
                            _choisirLangue(s.first == 'auto' ? null : s.first),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.download_outlined),
                  title: Text(l10n.telechargerMesDonnees),
                  subtitle: Text(l10n.telechargerMesDonneesAide),
                  onTap: _occupe ? null : _exporter,
                ),
                const Divider(height: 1),
                ListTile(
                  leading: Icon(
                    Icons.delete_forever_outlined,
                    color: theme.colorScheme.error,
                  ),
                  title: Text(
                    l10n.supprimerMonCompte,
                    style: TextStyle(color: theme.colorScheme.error),
                  ),
                  onTap: _occupe ? null : _supprimer,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            onPressed: () => ref.read(authRepositoryProvider).deconnexion(),
            icon: const Icon(Icons.logout),
            label: Text(l10n.seDeconnecter),
          ),
          const SizedBox(height: 16),
          const LiensLegaux(),
        ],
      ),
    );
  }
}

class _DialogueNom extends StatefulWidget {
  const _DialogueNom({required this.actuel});

  final String actuel;

  @override
  State<_DialogueNom> createState() => _DialogueNomState();
}

class _DialogueNomState extends State<_DialogueNom> {
  late final _nom = TextEditingController(text: widget.actuel);

  @override
  void dispose() {
    _nom.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(l10n.champNom),
      content: TextField(
        controller: _nom,
        autofocus: true,
        textCapitalization: TextCapitalization.words,
        decoration: InputDecoration(labelText: l10n.champNom),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.annuler),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, _nom.text),
          child: Text(l10n.enregistrer),
        ),
      ],
    );
  }
}
