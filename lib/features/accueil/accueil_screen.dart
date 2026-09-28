import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/routes.dart';
import '../../core/theme/app_colors.dart';
import '../../l10n/app_localizations.dart';
import '../../shared/widgets/logo_eglise.dart';
import '../actualites/actualites_providers.dart';
import '../actualites/presentation/carte_actualite.dart';
import '../agenda/agenda_providers.dart';
import '../agenda/presentation/carte_evenement.dart';
import '../auth/auth_providers.dart';

/// Accueil : bannière (visiteurs) ou carte de l'église (membres), dernières
/// annonces et prochains événements. et, plus tard, verset du jour, annonces,
/// prochain culte et direct.
class AccueilScreen extends ConsumerWidget {
  const AccueilScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final connecte = ref.watch(estConnecteProvider);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.appTitle)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          if (connecte)
            const _CarteEglise()
          else
            // Visuel « Rester connecté avec nous » de l'église.
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Image.asset(
                  'assets/images/banniere.jpg',
                  fit: BoxFit.cover,
                  semanticLabel: '${l10n.nomEglise} — ${l10n.devise}',
                ),
              ),
            ),
          if (!connecte) ...[
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.accueilConnexionTexte),
                    const SizedBox(height: 12),
                    FilledButton(
                      onPressed: () => context.push(Routes.connexion),
                      child: Text(l10n.seConnecter),
                    ),
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: 24),
          _Section(
            titre: l10n.annonces,
            action: l10n.voirTout,
            onAction: () => context.push(Routes.actualites),
          ),
          ..._annonces(context, ref),
          const SizedBox(height: 24),
          _Section(
            titre: l10n.prochainement,
            action: l10n.toutLAgenda,
            onAction: () => context.go(Routes.agenda),
          ),
          ..._evenements(context, ref),
        ],
      ),
    );
  }
}

List<Widget> _annonces(BuildContext context, WidgetRef ref) {
  final l10n = AppLocalizations.of(context);
  final liste = ref.watch(actualitesProvider).value ?? const [];
  if (liste.isEmpty) return [_Vide(l10n.aucuneAnnonce)];
  return [
    for (final a in liste.take(3))
      Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: CarteActualite(actualite: a, lien: Routes.actualite(a.id)),
      ),
  ];
}

List<Widget> _evenements(BuildContext context, WidgetRef ref) {
  final l10n = AppLocalizations.of(context);
  final liste = ref.watch(evenementsProvider).value ?? const [];
  if (liste.isEmpty) return [_Vide(l10n.aucunEvenement)];
  return [
    for (final e in liste.take(3))
      Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: CarteEvenement(evenement: e, lien: Routes.evenement(e.id)),
      ),
  ];
}

class _Section extends StatelessWidget {
  const _Section({
    required this.titre,
    required this.action,
    required this.onAction,
  });

  final String titre;
  final String action;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Row(
      children: [
        Expanded(
          child: Text(titre, style: Theme.of(context).textTheme.titleLarge),
        ),
        TextButton(onPressed: onAction, child: Text(action)),
      ],
    ),
  );
}

class _Vide extends StatelessWidget {
  const _Vide(this.texte);

  final String texte;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Text(
      texte,
      style: theme.textTheme.bodyMedium?.copyWith(
        color: theme.colorScheme.onSurfaceVariant,
      ),
    );
  }
}

/// Logo, nom et devise de l'église sur le dégradé de l'app.
class _CarteEglise extends StatelessWidget {
  const _CarteEglise();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [AppColors.bleu, AppColors.turquoise],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        children: [
          const LogoEglise(),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.nomEglise,
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.devise,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
