import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/horloge.dart';
import '../../core/roles.dart';
import '../../core/router/routes.dart';
import '../../core/theme/app_colors.dart';
import '../../l10n/app_localizations.dart';
import '../../shared/domain_traduction.dart';
import '../../shared/format_date.dart';
import '../../shared/services/lanceur.dart';
import '../../shared/widgets/logo_eglise.dart';
import '../../shared/widgets/reseaux_sociaux.dart';
import '../parametres/parametres_eglise.dart';
import '../pasteur/pasteur_screen.dart';
import 'blocs_eglise.dart';

/// Mise en page commune : contenu centré, lisible sur tous les écrans.
class _Page extends StatelessWidget {
  const _Page({required this.titre, required this.enfants, this.actions});

  final String titre;
  final List<Widget> enfants;
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(titre), actions: actions),
    body: Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 820),
        child: ListView(padding: const EdgeInsets.all(20), children: enfants),
      ),
    ),
  );
}

/// Bouton « Modifier » pour l'administrateur (contenu de l'église).
List<Widget> _modifier(BuildContext context, WidgetRef ref) => [
  if (ref.watch(estAdminProvider))
    IconButton(
      tooltip: AppLocalizations.of(context).modifier,
      onPressed: () => context.push(Routes.contenuEglise),
      icon: const Icon(Icons.edit_outlined),
    ),
];

/// « Notre église » : présentation, domaines (délivrance, guérison, combat
/// spirituel), le pasteur, les réseaux et le contact.
class EgliseScreen extends ConsumerWidget {
  const EgliseScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final p = ref.watch(parametresEgliseProvider).value;
    final presentation = p == null || p.eglisePresentation.isEmpty
        ? l10n.presentationEgliseDefaut
        : Traduction.dans(p.eglisePresentation, context.langue);
    final domaines = [
      (Icons.replay_outlined, l10n.themeRepentance, l10n.domaineRepentance),
      (Icons.lock_open_outlined, l10n.themeDelivrance, l10n.domaineDelivrance),
      (Icons.healing_outlined, l10n.themeGuerison, l10n.domaineGuerison),
      (Icons.shield_outlined, l10n.themeCombatSpirituel, l10n.domaineCombat),
      (Icons.arrow_forward, l10n.sanctification, l10n.domaineSanctification),
    ];
    return _Page(
      titre: l10n.notreEglise,
      actions: _modifier(context, ref),
      enfants: [
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
              const LogoEglise(taille: 120),
              const SizedBox(height: 16),
              Text(
                l10n.nomEglise,
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                l10n.devise,
                textAlign: TextAlign.center,
                style: theme.textTheme.titleSmall?.copyWith(
                  color: Colors.white.withValues(alpha: 0.9),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Text(
          presentation,
          style: theme.textTheme.bodyLarge?.copyWith(height: 1.5),
        ),
        const SizedBox(height: 24),
        Text(l10n.nosDomaines, style: theme.textTheme.titleLarge),
        const SizedBox(height: 8),
        LayoutBuilder(
          builder: (context, c) {
            final colonnes = c.maxWidth >= 640 ? 3 : 1;
            final largeur = (c.maxWidth - 12 * (colonnes - 1)) / colonnes;
            return Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                for (final (icone, titre, texte) in domaines)
                  SizedBox(
                    width: largeur,
                    child: Card(
                      margin: EdgeInsets.zero,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              icone,
                              color: theme.colorScheme.primary,
                              size: 32,
                            ),
                            const SizedBox(height: 8),
                            Text(titre, style: theme.textTheme.titleMedium),
                            const SizedBox(height: 4),
                            Text(texte),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
        const SizedBox(height: 24),
        Text(l10n.notrePasteur, style: theme.textTheme.titleLarge),
        const SizedBox(height: 8),
        Card(
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () => context.push(Routes.pasteur),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  PhotoPasteur(
                    url: p?.pasteurPhotoUrl,
                    hauteur: 120,
                    largeur: 90,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (p != null && p.pasteurNom.isNotEmpty)
                          Text(
                            p.pasteurNom,
                            style: theme.textTheme.titleMedium,
                          ),
                        Text(l10n.pasteurPrincipal),
                        const SizedBox(height: 8),
                        Text(
                          l10n.decouvrirPasteur,
                          style: TextStyle(color: theme.colorScheme.primary),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        FilledButton.icon(
          onPressed: () => context.push(Routes.contact),
          icon: const Icon(Icons.mail_outline),
          label: Text(l10n.nousContacter),
        ),
        const SizedBox(height: 24),
        const ProgrammeEglise(),
        const SizedBox(height: 24),
        const NousTrouver(),
        const SizedBox(height: 12),
        const WhatsAppDirect(),
        const SizedBox(height: 24),
        const ReseauxSociaux(),
      ],
    );
  }
}

/// Rencontre en direct chaque semaine : jour, heure, lien, questions.
class InteractionScreen extends ConsumerWidget {
  const InteractionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final p = ref.watch(parametresEgliseProvider).value;
    final maintenant = ref.watch(horlogeProvider)();
    final prochaine = p?.prochaineInteraction(maintenant);
    final description = p == null || p.interactionDescription.isEmpty
        ? l10n.rencontreDirectDefaut
        : Traduction.dans(p.interactionDescription, context.langue);
    return _Page(
      titre: l10n.rencontreDirect,
      actions: _modifier(context, ref),
      enfants: [
        // Bandeau : le pasteur (photo détourée) sur le dégradé de l'église.
        Container(
          height: 220,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: const LinearGradient(
              colors: [AppColors.bleu, AppColors.turquoise],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.forum_outlined, color: Colors.white),
                      const SizedBox(height: 8),
                      Text(
                        l10n.rencontreDirect,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          color: Colors.white,
                        ),
                      ),
                      if (prochaine != null)
                        Text(
                          l10n.chaqueSemaine(
                            DateFormat.EEEE(context.langue).format(prochaine),
                            context.heure(prochaine),
                          ),
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              Image.asset(
                'assets/images/pasteur-2.png',
                fit: BoxFit.fitHeight,
                alignment: Alignment.bottomRight,
                semanticLabel: l10n.notrePasteur,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text(
          description,
          style: theme.textTheme.bodyLarge?.copyWith(height: 1.5),
        ),
        const SizedBox(height: 20),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: prochaine == null
                ? Text(l10n.rencontreBientot)
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        l10n.chaqueSemaine(
                          DateFormat.EEEE(context.langue).format(prochaine),
                          context.heure(prochaine),
                        ),
                        style: theme.textTheme.titleMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        l10n.prochaineRencontre(context.dateLongue(prochaine)),
                      ),
                      if (p!.interactionLien.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        FilledButton.icon(
                          onPressed: () => ref
                              .read(lanceurProvider)
                              .ouvrir(Uri.parse(p.interactionLien)),
                          icon: const Icon(Icons.videocam_outlined),
                          label: Text(l10n.rejoindreRencontre),
                        ),
                      ],
                    ],
                  ),
          ),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: () => context.push('${Routes.contact}?sujet=question'),
          icon: const Icon(Icons.help_outline),
          label: Text(l10n.envoyerQuestionAvance),
        ),
      ],
    );
  }
}

/// Communauté : groupes WhatsApp de la Montagne des Oliviers et réseaux.
class CommunauteScreen extends ConsumerWidget {
  const CommunauteScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final liens =
        ref.watch(parametresEgliseProvider).value?.liensCommunaute ??
        const <(String, String)>[];
    const vert = Color(0xFF25D366);
    return _Page(
      titre: l10n.communaute,
      actions: _modifier(context, ref),
      enfants: [
        Text(l10n.communauteIntro, style: theme.textTheme.bodyLarge),
        const SizedBox(height: 16),
        if (liens.isEmpty)
          Text(l10n.communauteBientot)
        else
          for (final (titre, url) in liens)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: vert,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.all(16),
                ),
                onPressed: () =>
                    ref.read(lanceurProvider).ouvrir(Uri.parse(url)),
                icon: const FaIcon(FontAwesomeIcons.whatsapp),
                label: Text(titre.isEmpty ? l10n.rejoindreWhatsApp : titre),
              ),
            ),
        const SizedBox(height: 24),
        const ReseauxSociaux(),
      ],
    );
  }
}
