import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/accueil/accueil_screen.dart';
import '../../features/actualites/presentation/actualite_screen.dart';
import '../../features/actualites/presentation/actualites_screen.dart';
import '../../features/agenda/presentation/evenement_screen.dart';
import '../../features/responsables/actualites/editeur_actualite_screen.dart';
import '../../features/responsables/actualites/gestion_actualites_screen.dart';
import '../../features/responsables/agenda/editeur_evenement_screen.dart';
import '../../features/responsables/agenda/gestion_agenda_screen.dart';
import '../../features/auth/auth_providers.dart';
import '../../features/auth/presentation/connexion_email_screen.dart';
import '../../features/auth/presentation/connexion_screen.dart';
import '../../features/auth/presentation/consentement_screen.dart';
import '../../features/demandes/domain/demande.dart';
import '../../features/demandes/presentation/demande_screen.dart';
import '../../features/demandes/presentation/gestion_demandes_screen.dart';
import '../../features/demandes/presentation/mes_demandes_screen.dart';
import '../../features/demandes/presentation/nouvelle_demande_screen.dart';
import '../../features/divers/presentation/editeur_fete_screen.dart';
import '../../features/divers/presentation/fete_screen.dart';
import '../../features/parametres/parametres_eglise_screen.dart';
import '../../features/prieres/presentation/listes_prieres.dart';
import '../../features/prieres/presentation/nouvelle_priere_screen.dart';
import '../../features/prieres/presentation/priere_screen.dart';
import '../../features/groupes/presentation/calendrier_groupe_screen.dart';
import '../../features/groupes/presentation/discussion_screen.dart';
import '../../features/groupes/presentation/editeur_rencontre_screen.dart';
import '../../features/groupes/presentation/rencontre_screen.dart';
import '../../features/groupes/presentation/editeur_groupe_screen.dart';
import '../../features/groupes/presentation/gestion_groupes_screen.dart';
import '../../features/groupes/presentation/groupe_screen.dart';
import '../../features/membres/presentation/familles_screen.dart';
import '../../features/membres/presentation/fiche_membre_screen.dart';
import '../../features/membres/presentation/membres_screen.dart';
import '../../features/responsables/roles_screen.dart';
import '../../shared/widgets/logo_eglise.dart';
import '../../features/agenda/agenda_screen.dart';
import '../../features/groupes/groupes_screen.dart';
import '../../features/medias/medias_screen.dart';
import '../../features/profil/profil_screen.dart';
import '../../features/responsables/responsables_screen.dart';
import '../../l10n/app_localizations.dart';
import '../roles.dart';
import 'routes.dart';

export 'routes.dart';

/// Largeur à partir de laquelle on affiche le menu latéral (ordinateur,
/// tablette) au lieu de la barre du bas.
const largeurMenuLateral = 800.0;

final routerProvider = Provider<GoRouter>((ref) {
  // Relance les redirections quand la connexion, le profil ou les rôles changent.
  final rafraichir = ValueNotifier(0);
  ref.listen(estConnecteProvider, (_, _) => rafraichir.value++);
  ref.listen(profilManquantProvider, (_, _) => rafraichir.value++);
  ref.listen(estResponsableProvider, (_, _) => rafraichir.value++);
  ref.onDispose(rafraichir.dispose);

  return GoRouter(
    initialLocation: Routes.accueil,
    refreshListenable: rafraichir,
    redirect: (context, state) {
      final lieu = state.matchedLocation;
      final connecte = ref.read(estConnecteProvider);
      // Compte Google / Apple sans profil : consentement d'abord.
      if (ref.read(profilManquantProvider)) {
        return lieu == Routes.consentement ? null : Routes.consentement;
      }
      if (lieu == Routes.consentement) return Routes.accueil;
      // Une fois connecté, on quitte les écrans de connexion.
      if (connecte && lieu.startsWith(Routes.connexion)) return Routes.accueil;
      // Espace Responsables réservé aux responsables.
      if (lieu.startsWith(Routes.responsables) &&
          !ref.read(estResponsableProvider)) {
        return Routes.accueil;
      }
      return null;
    },
    onException: (context, state, router) => router.go(Routes.accueil),
    routes: [
      GoRoute(
        path: Routes.connexion,
        builder: (context, state) => const ConnexionScreen(),
        routes: [
          GoRoute(
            path: 'email',
            builder: (context, state) => const ConnexionEmailScreen(),
          ),
          GoRoute(
            path: 'profil',
            builder: (context, state) => const ConsentementScreen(),
          ),
        ],
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => _Coquille(shell: shell),
        branches: [
          for (final (chemin, ecran) in [
            (Routes.accueil, const AccueilScreen()),
            (Routes.agenda, const AgendaScreen()),
            (Routes.groupes, const GroupesScreen()),
            (Routes.medias, const MediasScreen()),
            (Routes.profil, const ProfilScreen()),
            (Routes.responsables, const ResponsablesScreen()),
          ])
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: chemin,
                  builder: (context, state) => ecran,
                  routes: _sousRoutes[chemin] ?? const [],
                ),
              ],
            ),
        ],
      ),
    ],
  );
});

final _sousRoutes = <String, List<RouteBase>>{
  Routes.accueil: [
    GoRoute(
      path: 'actualites',
      builder: (context, state) => const ActualitesScreen(),
      routes: [
        GoRoute(
          path: ':id',
          builder: (context, state) =>
              ActualiteScreen(id: state.pathParameters['id']!),
        ),
      ],
    ),
  ],
  Routes.groupes: [
    GoRoute(
      path: ':id',
      builder: (context, state) =>
          GroupeScreen(id: state.pathParameters['id']!),
      routes: [
        GoRoute(
          path: 'discussion',
          builder: (context, state) =>
              DiscussionScreen(id: state.pathParameters['id']!),
        ),
        GoRoute(
          path: 'modifier',
          builder: (context, state) =>
              EditeurGroupeScreen(id: state.pathParameters['id']!),
        ),
        GoRoute(
          path: 'prieres',
          builder: (context, state) =>
              PrieresGroupeScreen(groupeId: state.pathParameters['id']!),
          routes: [
            GoRoute(
              path: ':pid',
              builder: (context, state) =>
                  PriereScreen(id: state.pathParameters['pid']!),
            ),
          ],
        ),
        GoRoute(
          path: 'calendrier',
          builder: (context, state) =>
              CalendrierGroupeScreen(id: state.pathParameters['id']!),
          routes: [
            // « nouvelle/modifier » : création.
            GoRoute(
              path: ':rid',
              builder: (context, state) => RencontreScreen(
                groupeId: state.pathParameters['id']!,
                id: state.pathParameters['rid']!,
              ),
              routes: [
                GoRoute(
                  path: 'modifier',
                  builder: (context, state) => EditeurRencontreScreen(
                    groupeId: state.pathParameters['id']!,
                    id: state.pathParameters['rid']!,
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    ),
  ],
  Routes.profil: [
    GoRoute(
      path: 'demandes',
      builder: (context, state) => const MesDemandesScreen(),
      routes: [
        GoRoute(
          path: 'nouvelle',
          builder: (context, state) => NouvelleDemandeScreen(
            type: TypeDemande.values
                .where((t) => t.name == state.uri.queryParameters['type'])
                .firstOrNull,
          ),
        ),
        GoRoute(
          path: ':id',
          builder: (context, state) =>
              DemandeScreen(id: state.pathParameters['id']!),
        ),
      ],
    ),
    GoRoute(
      path: 'prieres',
      builder: (context, state) => const MesPrieresScreen(),
      routes: [
        GoRoute(
          path: 'nouvelle',
          builder: (context, state) => const NouvellePriereScreen(),
        ),
        GoRoute(
          path: ':id',
          builder: (context, state) =>
              PriereScreen(id: state.pathParameters['id']!),
        ),
      ],
    ),
  ],
  Routes.agenda: [
    // Déclaré avant « :id » (événement).
    GoRoute(
      path: 'divers/:id',
      builder: (context, state) => FeteScreen(id: state.pathParameters['id']!),
      routes: [
        GoRoute(
          path: 'modifier',
          builder: (context, state) =>
              EditeurFeteScreen(id: state.pathParameters['id']!),
        ),
      ],
    ),
    GoRoute(
      path: ':id',
      builder: (context, state) =>
          EvenementScreen(id: state.pathParameters['id']!),
    ),
  ],
  Routes.responsables: [
    GoRoute(path: 'roles', builder: (context, state) => const RolesScreen()),
    GoRoute(
      path: 'parametres',
      builder: (context, state) => const ParametresEgliseScreen(),
    ),
    GoRoute(
      path: 'demandes',
      builder: (context, state) => const GestionDemandesScreen(),
      routes: [
        GoRoute(
          path: ':id',
          builder: (context, state) =>
              DemandeScreen(id: state.pathParameters['id']!, gestion: true),
        ),
      ],
    ),
    GoRoute(
      path: 'prieres',
      builder: (context, state) => const GestionPrieresScreen(),
      routes: [
        GoRoute(
          path: ':id',
          builder: (context, state) =>
              PriereScreen(id: state.pathParameters['id']!),
        ),
      ],
    ),
    GoRoute(
      path: 'groupes',
      builder: (context, state) => const GestionGroupesScreen(),
      routes: [
        GoRoute(
          path: 'nouveau',
          builder: (context, state) => const EditeurGroupeScreen(),
        ),
      ],
    ),
    GoRoute(
      path: 'membres',
      builder: (context, state) => const MembresScreen(),
      routes: [
        GoRoute(
          path: ':id',
          builder: (context, state) => FicheMembreScreen(
            id: state.pathParameters['id']!,
            uidCompte: state.uri.queryParameters['uid'],
          ),
        ),
      ],
    ),
    GoRoute(
      path: 'familles',
      builder: (context, state) => const FamillesScreen(),
      routes: [
        GoRoute(
          path: ':id',
          builder: (context, state) =>
              FamilleScreen(id: state.pathParameters['id']!),
        ),
      ],
    ),
    GoRoute(
      path: 'actualites',
      builder: (context, state) => const GestionActualitesScreen(),
      routes: [
        GoRoute(
          path: ':id',
          builder: (context, state) =>
              EditeurActualiteScreen(id: state.pathParameters['id']!),
        ),
      ],
    ),
    GoRoute(
      path: 'agenda',
      builder: (context, state) => const GestionAgendaScreen(),
      routes: [
        GoRoute(
          path: ':id',
          builder: (context, state) =>
              EditeurEvenementScreen(id: state.pathParameters['id']!),
        ),
      ],
    ),
  ],
};

/// Barre du bas sur téléphone, menu latéral sur grand écran. L'onglet
/// Responsables n'apparaît que pour les responsables.
class _Coquille extends ConsumerWidget {
  const _Coquille({required this.shell});

  final StatefulNavigationShell shell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final responsable = ref.watch(estResponsableProvider);
    final onglets = [
      (Icons.home_outlined, Icons.home, l10n.navAccueil),
      (Icons.event_outlined, Icons.event, l10n.navAgenda),
      (Icons.groups_outlined, Icons.groups, l10n.navGroupes),
      (Icons.play_circle_outline, Icons.play_circle, l10n.navMedias),
      (Icons.person_outline, Icons.person, l10n.navProfil),
      if (responsable)
        (
          Icons.admin_panel_settings_outlined,
          Icons.admin_panel_settings,
          l10n.navResponsables,
        ),
    ];
    final index = shell.currentIndex.clamp(0, onglets.length - 1);
    void aller(int i) =>
        shell.goBranch(i, initialLocation: i == shell.currentIndex);

    if (MediaQuery.sizeOf(context).width >= largeurMenuLateral) {
      return Scaffold(
        body: Row(
          children: [
            NavigationRail(
              selectedIndex: index,
              onDestinationSelected: aller,
              labelType: NavigationRailLabelType.all,
              leading: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: const LogoEglise(taille: 56),
              ),
              destinations: [
                for (final (icone, iconeActive, libelle) in onglets)
                  NavigationRailDestination(
                    icon: Icon(icone),
                    selectedIcon: Icon(iconeActive),
                    label: Text(libelle),
                  ),
              ],
            ),
            const VerticalDivider(width: 1),
            Expanded(child: shell),
          ],
        ),
      );
    }
    return Scaffold(
      body: shell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: aller,
        destinations: [
          for (final (icone, iconeActive, libelle) in onglets)
            NavigationDestination(
              icon: Icon(icone),
              selectedIcon: Icon(iconeActive),
              label: libelle,
            ),
        ],
      ),
    );
  }
}
