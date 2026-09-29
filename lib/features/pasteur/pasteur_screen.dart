import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/roles.dart';
import '../../core/router/routes.dart';
import '../../l10n/app_localizations.dart';
import '../../shared/domain_traduction.dart';
import '../../shared/format_date.dart';
import '../../shared/widgets/etat_vide.dart';
import '../parametres/parametres_eglise.dart';

/// « Notre pasteur » : courte présentation du pasteur principal.
class PasteurScreen extends ConsumerWidget {
  const PasteurScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final p = ref.watch(parametresEgliseProvider).value;
    final admin = ref.watch(estAdminProvider);
    final vide =
        p == null || (p.pasteurNom.isEmpty && p.pasteurPresentation.isEmpty);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.notrePasteur),
        actions: [
          if (admin)
            IconButton(
              tooltip: l10n.modifier,
              onPressed: () => context.push(Routes.editerPasteur),
              icon: const Icon(Icons.edit_outlined),
            ),
        ],
      ),
      body: vide
          ? EtatVide(icone: Icons.person_outline, texte: l10n.pasteurBientot)
          : Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 720),
                child: ListView(
                  padding: const EdgeInsets.all(24),
                  children: [
                    Center(
                      child: CircleAvatar(
                        radius: 72,
                        backgroundColor: theme.colorScheme.primaryContainer,
                        foregroundImage: p.pasteurPhotoUrl == null
                            ? null
                            : NetworkImage(p.pasteurPhotoUrl!),
                        onForegroundImageError: p.pasteurPhotoUrl == null
                            ? null
                            : (_, _) {},
                        child: Icon(
                          Icons.person,
                          size: 72,
                          color: theme.colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      p.pasteurNom,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.headlineSmall,
                    ),
                    Text(
                      l10n.pasteurPrincipal,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      Traduction.dans(p.pasteurPresentation, context.langue),
                      style: theme.textTheme.bodyLarge?.copyWith(height: 1.5),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
