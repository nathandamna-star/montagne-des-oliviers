import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/routes.dart';
import '../../core/theme/app_colors.dart';
import '../../l10n/app_localizations.dart';
import '../../shared/widgets/liens_legaux.dart';
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
    final raccourcis = [
      _Raccourci(Icons.savings_outlined, l10n.dimesEtOffrandes, Routes.dons),
      _Raccourci(Icons.storefront_outlined, l10n.boutique, Routes.boutique),
      _Raccourci(Icons.person_pin_outlined, l10n.notrePasteur, Routes.pasteur),
      if (membre) ...[
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
        _Raccourci(Icons.event_note_outlined, l10n.planning, Routes.planning),
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
    ];
    return Scaffold(
      appBar: AppBar(title: Text(l10n.appTitle)),
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
                  if (connecte)
                    const _CarteEglise()
                  else
                    // Visuel « Rester connecté avec nous » de l'église.
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxHeight: 380),
                        child: AspectRatio(
                          aspectRatio: 16 / 9,
                          child: Image.asset(
                            'assets/images/banniere.jpg',
                            fit: BoxFit.cover,
                            semanticLabel: '${l10n.nomEglise} — ${l10n.devise}',
                          ),
                        ),
                      ),
                    ),
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
                  const SizedBox(height: 24),
                  Text(
                    l10n.accesRapide,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  _GrilleRaccourcis(raccourcis),
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
  const _Raccourci(this.icone, this.libelle, this.route);

  final IconData icone;
  final String libelle;
  final String route;
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
                    onTap: () => context.push(r.route),
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
