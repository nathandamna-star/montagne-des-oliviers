import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/roles.dart';
import '../../core/router/routes.dart';
import '../../l10n/app_localizations.dart';

/// Espace Responsables : chaque module d'administration s'y ajoutera.
class ResponsablesScreen extends ConsumerWidget {
  const ResponsablesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.navResponsables)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (ref.watch(estTresorierProvider))
            Card(
              child: ListTile(
                leading: const Icon(Icons.account_balance_wallet_outlined),
                title: Text(l10n.tresorerie),
                subtitle: Text(l10n.tresorerieSousTitre),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push(Routes.tresorerie),
              ),
            ),
          if (ref.watch(gereBoutiqueProvider))
            Card(
              child: ListTile(
                leading: const Icon(Icons.storefront_outlined),
                title: Text(l10n.boutique),
                subtitle: Text(l10n.gestionBoutiqueSousTitre),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push(Routes.gestionBoutique),
              ),
            ),
          if (ref.watch(estSecretariatProvider)) ...[
            Card(
              child: ListTile(
                leading: const Icon(Icons.inbox_outlined),
                title: Text(l10n.demandesRecues),
                subtitle: Text(l10n.demandesRecuesSousTitre),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push(Routes.gestionDemandes),
              ),
            ),
            Card(
              child: ListTile(
                leading: const Icon(Icons.badge_outlined),
                title: Text(l10n.fichierMembres),
                subtitle: Text(l10n.fichierMembresSousTitre),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push(Routes.membres),
              ),
            ),
            Card(
              child: ListTile(
                leading: const Icon(Icons.meeting_room_outlined),
                title: Text(l10n.sallesEtReservations),
                subtitle: Text(l10n.sallesEtReservationsSousTitre),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push(Routes.salles),
              ),
            ),
            Card(
              child: ListTile(
                leading: const Icon(Icons.event_note_outlined),
                title: Text(l10n.planningServices),
                subtitle: Text(l10n.planningServicesSousTitre),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push(Routes.planning),
              ),
            ),
            Card(
              child: ListTile(
                leading: const Icon(Icons.groups_outlined),
                title: Text(l10n.tousLesGroupes),
                subtitle: Text(l10n.tousLesGroupesSousTitre),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push(Routes.gestionGroupes),
              ),
            ),
            Card(
              child: ListTile(
                leading: const Icon(Icons.play_circle_outline),
                title: Text(l10n.gestionMedias),
                subtitle: Text(l10n.gestionMediasSousTitre),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push(Routes.gestionMedias),
              ),
            ),
            Card(
              child: ListTile(
                leading: const Icon(Icons.campaign_outlined),
                title: Text(l10n.annonces),
                subtitle: Text(l10n.annoncesSousTitre),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push(Routes.gestionActualites),
              ),
            ),
            Card(
              child: ListTile(
                leading: const Icon(Icons.event_note_outlined),
                title: Text(l10n.gestionAgenda),
                subtitle: Text(l10n.gestionAgendaSousTitre),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push(Routes.gestionAgenda),
              ),
            ),
          ],
          if (ref.watch(estAdminProvider)) ...[
            Card(
              child: ListTile(
                leading: const Icon(Icons.volunteer_activism_outlined),
                title: Text(l10n.sujetsPriere),
                subtitle: Text(l10n.sujetsPriereSousTitre),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push(Routes.gestionPrieres),
              ),
            ),
            Card(
              child: ListTile(
                leading: const Icon(Icons.menu_book_outlined),
                title: Text(l10n.preparations),
                subtitle: Text(l10n.preparationsGestionSousTitre),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push(Routes.preparations),
              ),
            ),
            Card(
              child: ListTile(
                leading: const Icon(Icons.person_pin_outlined),
                title: Text(l10n.notrePasteur),
                subtitle: Text(l10n.notrePasteurSousTitre),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push(Routes.editerPasteur),
              ),
            ),
            Card(
              child: ListTile(
                leading: const Icon(Icons.settings_outlined),
                title: Text(l10n.parametresEglise),
                subtitle: Text(l10n.parametresEgliseSousTitre),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push(Routes.parametres),
              ),
            ),
          ],
          if (ref.watch(estAdminProvider))
            Card(
              child: ListTile(
                leading: const Icon(Icons.manage_accounts_outlined),
                title: Text(l10n.rolesTitre),
                subtitle: Text(l10n.rolesSousTitre),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push(Routes.roles),
              ),
            ),
          const SizedBox(height: 16),
          Text(
            l10n.responsablesAVenir,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
