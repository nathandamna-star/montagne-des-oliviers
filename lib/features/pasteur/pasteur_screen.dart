import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/roles.dart';
import '../../core/router/routes.dart';
import '../../l10n/app_localizations.dart';
import '../../shared/domain_traduction.dart';
import '../../shared/format_date.dart';
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
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              PhotoPasteur(url: p?.pasteurPhotoUrl, hauteur: 440),
              const SizedBox(height: 16),
              if (p != null && p.pasteurNom.isNotEmpty)
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
                p == null || p.pasteurPresentation.isEmpty
                    ? l10n.pasteurPresentationDefaut
                    : Traduction.dans(p.pasteurPresentation, context.langue),
                style: theme.textTheme.bodyLarge?.copyWith(height: 1.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Photo du pasteur : celle choisie par l'administrateur, sinon la photo de
/// l'église (le pasteur en train de prêcher), en plan large.
class PhotoPasteur extends StatelessWidget {
  const PhotoPasteur({super.key, this.url, this.hauteur = 440, this.largeur});

  final String? url;
  final double hauteur;
  final double? largeur;

  static const parDefaut = 'assets/images/pasteur-1.jpg';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Image.asset(
      parDefaut,
      height: hauteur,
      width: largeur ?? double.infinity,
      fit: BoxFit.cover,
      alignment: const Alignment(0, -0.4),
      semanticLabel: l10n.notrePasteur,
    );
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: url == null
          ? locale
          : Image.network(
              url!,
              height: hauteur,
              width: largeur ?? double.infinity,
              fit: BoxFit.cover,
              alignment: const Alignment(0, -0.4),
              semanticLabel: l10n.notrePasteur,
              errorBuilder: (_, _, _) => locale,
            ),
    );
  }
}
