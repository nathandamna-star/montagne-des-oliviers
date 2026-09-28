import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/logo_eglise.dart';
import '../auth_providers.dart';
import 'message_erreur_auth.dart';

/// Choix du mode de connexion : Google, Apple (iPhone), e-mail.
class ConnexionScreen extends ConsumerStatefulWidget {
  const ConnexionScreen({super.key});

  @override
  ConsumerState<ConnexionScreen> createState() => _ConnexionScreenState();
}

class _ConnexionScreenState extends ConsumerState<ConnexionScreen> {
  bool _occupe = false;
  String? _erreur;

  /// Apple n'est proposé que sur iPhone (obligatoire pour l'App Store).
  static bool get _appleDisponible =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;

  Future<void> _connexion(Future<void> Function() action) async {
    final l10n = AppLocalizations.of(context);
    setState(() {
      _occupe = true;
      _erreur = null;
    });
    try {
      await action();
    } catch (e) {
      if (mounted) setState(() => _erreur = messageErreurAuth(l10n, e));
    } finally {
      if (mounted) setState(() => _occupe = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final repo = ref.read(authRepositoryProvider);
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: const LinearGradient(
                      colors: [AppColors.bleu, AppColors.turquoise],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Column(
                    children: [
                      const LogoEglise(taille: 96),
                      const SizedBox(height: 12),
                      Text(
                        l10n.nomEglise,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  l10n.connexionIntro,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyLarge,
                ),
                const SizedBox(height: 24),
                if (_occupe)
                  Center(
                    child: CircularProgressIndicator(
                      semanticsLabel: l10n.chargement,
                    ),
                  )
                else ...[
                  OutlinedButton.icon(
                    onPressed: () => _connexion(repo.connexionGoogle),
                    icon: const Icon(Icons.g_mobiledata, size: 28),
                    label: Text(l10n.continuerGoogle),
                  ),
                  if (_appleDisponible) ...[
                    const SizedBox(height: 12),
                    FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: theme.colorScheme.onSurface,
                        foregroundColor: theme.colorScheme.surface,
                      ),
                      onPressed: () => _connexion(repo.connexionApple),
                      icon: const Icon(Icons.apple),
                      label: Text(l10n.continuerApple),
                    ),
                  ],
                  const SizedBox(height: 12),
                  FilledButton.icon(
                    onPressed: () => context.push(Routes.connexionEmail),
                    icon: const Icon(Icons.mail_outline),
                    label: Text(l10n.continuerEmail),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () => context.go(Routes.accueil),
                    child: Text(l10n.continuerSansCompte),
                  ),
                ],
                if (_erreur != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    _erreur!,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: theme.colorScheme.error),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
