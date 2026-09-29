import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/router/routes.dart';
import '../../core/theme/app_colors.dart';
import '../../l10n/app_localizations.dart';
import '../../shared/widgets/liens_legaux.dart';
import '../eglise/blocs_eglise.dart';
import '../../shared/widgets/logo_eglise.dart';
import '../../shared/widgets/reseaux_sociaux.dart';
import '../actualites/actualites_providers.dart';
import '../actualites/presentation/carte_actualite.dart';
import '../agenda/agenda_providers.dart';
import '../agenda/presentation/carte_evenement.dart';
import '../auth/auth_providers.dart';
import '../medias/presentation/widgets_medias.dart';

/// Accueil : bannière (visiteurs) ou carte de l'église (membres), verset du
/// jour, raccourcis vers chaque rubrique, réseaux sociaux, dernières annonces
/// et prochains événements. S'adapte au téléphone, à la tablette et à l'ordinateur.
class AccueilScreen extends ConsumerWidget {
  const AccueilScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final connecte = ref.watch(estConnecteProvider);
    final membre = ref.watch(profilProvider).value != null;
    final sections = <(String, List<_Raccourci>)>[
      (
        l10n.sectionDecouvrir,
        [
          _Raccourci(Icons.church_outlined, l10n.notreEglise, Routes.eglise),
          _Raccourci(
            Icons.person_pin_outlined,
            l10n.notrePasteur,
            Routes.pasteur,
          ),
          _Raccourci(
            Icons.event_outlined,
            l10n.navAgenda,
            Routes.agenda,
            onglet: true,
          ),
        ],
      ),
      (
        l10n.sectionEcouter,
        [
          _Raccourci(
            Icons.record_voice_over_outlined,
            l10n.rubriquePredications,
            Routes.mediasRubrique('predication'),
            onglet: true,
          ),
          _Raccourci(
            Icons.school_outlined,
            l10n.rubriqueEnseignements,
            Routes.mediasRubrique('enseignement'),
            onglet: true,
          ),
          _Raccourci(
            Icons.podcasts,
            l10n.rubriquePodcasts,
            Routes.mediasRubrique('podcast'),
            onglet: true,
          ),
          _Raccourci(
            Icons.forum_outlined,
            l10n.rencontreDirect,
            Routes.interaction,
          ),
        ],
      ),
      (
        l10n.sectionParticiper,
        [
          _Raccourci(
            Icons.groups_2_outlined,
            l10n.communaute,
            Routes.communaute,
          ),
          _Raccourci(Icons.mail_outline, l10n.nousContacter, Routes.contact),
          _Raccourci(
            Icons.savings_outlined,
            l10n.dimesEtOffrandes,
            Routes.dons,
          ),
          _Raccourci(Icons.storefront_outlined, l10n.boutique, Routes.boutique),
        ],
      ),
      if (membre)
        (
          l10n.sectionMonEspace,
          [
            _Raccourci(
              Icons.outbox_outlined,
              l10n.faireDemande,
              Routes.nouvelleDemande,
            ),
            _Raccourci(
              Icons.volunteer_activism_outlined,
              l10n.confierPriere,
              Routes.nouvellePriere,
            ),
            _Raccourci(
              Icons.event_note_outlined,
              l10n.planning,
              Routes.planning,
            ),
            _Raccourci(
              Icons.meeting_room_outlined,
              l10n.reserverSalle,
              Routes.salles,
            ),
            _Raccourci(
              Icons.cleaning_services_outlined,
              l10n.entretienSalle,
              Routes.entretien,
            ),
            _Raccourci(
              Icons.menu_book_outlined,
              l10n.preparations,
              Routes.preparations,
            ),
          ],
        ),
    ];
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appTitle),
        actions: [
          // Visiteurs : se connecter, toujours visible en haut.
          if (!connecte)
            IconButton(
              tooltip: l10n.seConnecter,
              onPressed: () => context.push(Routes.connexion),
              icon: const Icon(Icons.login),
            ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, contraintes) {
          final large = contraintes.maxWidth >= 900;
          final marge = contraintes.maxWidth >= 600 ? 24.0 : 16.0;
          final annonces = Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _Section(
                titre: l10n.annonces,
                action: l10n.voirTout,
                onAction: () => context.push(Routes.actualites),
              ),
              ..._annonces(context, ref),
            ],
          );
          final evenements = Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _Section(
                titre: l10n.prochainement,
                action: l10n.toutLAgenda,
                onAction: () => context.go(Routes.agenda),
              ),
              ..._evenements(context, ref),
            ],
          );
          return Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1200),
              child: ListView(
                padding: EdgeInsets.all(marge),
                children: [
                  const _EnTete(),
                  const SizedBox(height: 24),
                  const SizedBox(height: 12),
                  const CarteVersetDuJour(),
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
                  for (final (titre, raccourcis) in sections) ...[
                    const SizedBox(height: 24),
                    Text(titre, style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 8),
                    _GrilleRaccourcis(raccourcis),
                  ],
                  const SizedBox(height: 24),
                  const ProgrammeEglise(),
                  const SizedBox(height: 24),
                  const ReseauxSociaux(),
                  const SizedBox(height: 24),
                  if (large)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: annonces),
                        const SizedBox(width: 24),
                        Expanded(child: evenements),
                      ],
                    )
                  else ...[
                    annonces,
                    const SizedBox(height: 24),
                    evenements,
                  ],
                  const SizedBox(height: 24),
                  const NousTrouver(),
                  const SizedBox(height: 12),
                  const WhatsAppDirect(),
                  const SizedBox(height: 24),
                  const LiensLegaux(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _Raccourci {
  const _Raccourci(this.icone, this.libelle, this.route, {this.onglet = false});

  final IconData icone;
  final String libelle;
  final String route;

  /// Ouvre un onglet (Agenda, Médias) plutôt qu'une page par-dessus.
  final bool onglet;
}

/// Grandes tuiles faciles à toucher : 2 par ligne sur un petit téléphone,
/// jusqu'à 6 sur un ordinateur.
class _GrilleRaccourcis extends StatelessWidget {
  const _GrilleRaccourcis(this.raccourcis);

  final List<_Raccourci> raccourcis;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return LayoutBuilder(
      builder: (context, c) {
        final colonnes = (c.maxWidth / 170).floor().clamp(2, 6);
        const espace = 10.0;
        final largeur = (c.maxWidth - espace * (colonnes - 1)) / colonnes;
        return Wrap(
          spacing: espace,
          runSpacing: espace,
          children: [
            for (final r in raccourcis)
              SizedBox(
                width: largeur,
                height: 112,
                child: Card(
                  margin: EdgeInsets.zero,
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: () =>
                        r.onglet ? context.go(r.route) : context.push(r.route),
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            r.icone,
                            size: 32,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            r.libelle,
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.labelLarge,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
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

/// En-tête, comme sur le site de l'église : logo, nom, devise et accueil au
/// culte d'enseignement, avec deux boutons.
class _EnTete extends StatelessWidget {
  const _EnTete();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final devise = l10n.devise.toUpperCase().split(' · ');
    return Column(
      children: [
        const SizedBox(height: 8),
        const LogoEglise(taille: 150),
        const SizedBox(height: 20),
        Surtitre(l10n.centreEvangelique),
        const SizedBox(height: 8),
        Text(
          'MONTAGNE\nDES OLIVIERS',
          textAlign: TextAlign.center,
          style: GoogleFonts.cormorantGaramond(
            textStyle: theme.textTheme.displaySmall?.copyWith(height: 1.05),
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 16),
        Semantics(
          label: l10n.devise,
          child: ExcludeSemantics(
            child: Wrap(
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 12,
              runSpacing: 8,
              children: [
                for (final (i, mot) in devise.indexed) ...[
                  if (i > 0)
                    Container(width: 32, height: 1.5, color: AppColors.olive),
                  Text(
                    mot,
                    style: theme.textTheme.labelLarge?.copyWith(
                      letterSpacing: 4,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        Container(width: 160, height: 1.5, color: AppColors.olive),
        const SizedBox(height: 24),
        Text(
          l10n.bienvenue.toUpperCase(),
          textAlign: TextAlign.center,
          style: GoogleFonts.cormorantGaramond(
            textStyle: theme.textTheme.headlineMedium,
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          l10n.aNotreCulte.toUpperCase(),
          textAlign: TextAlign.center,
          style: GoogleFonts.cormorantGaramond(
            textStyle: theme.textTheme.headlineMedium?.copyWith(
              color: theme.colorScheme.primary,
            ),
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          l10n.dEnseignement,
          textAlign: TextAlign.center,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontStyle: FontStyle.italic,
          ),
        ),
        const SizedBox(height: 24),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              FilledButton.icon(
                iconAlignment: IconAlignment.end,
                onPressed: () =>
                    context.go(Routes.mediasRubrique('enseignement')),
                icon: const Icon(Icons.arrow_forward),
                label: Text(l10n.ecouterEnseignements),
              ),
              const SizedBox(height: 10),
              OutlinedButton(
                onPressed: () => context.push('${Routes.contact}?sujet=priere'),
                child: Text(l10n.demanderPriere),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
