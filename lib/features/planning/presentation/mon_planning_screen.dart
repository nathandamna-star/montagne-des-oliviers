import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/roles.dart';
import '../../../core/router/routes.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/connexion_requise.dart';
import '../../auth/auth_providers.dart';
import '../domain/planning.dart';
import '../planning_providers.dart';
import 'carte_service.dart';

/// Mon planning de service et mes équipes (toutes les équipes pour le secrétariat).
class MonPlanningScreen extends ConsumerWidget {
  const MonPlanningScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    if (ref.watch(profilProvider).value == null) {
      return ConnexionRequise(titre: l10n.planning);
    }
    final uid = ref.watch(utilisateurFirebaseProvider).value?.uid;
    final secretariat = ref.watch(estSecretariatProvider);
    final services =
        ref.watch(mesAffectationsProvider).value ?? const <Affectation>[];
    final equipes = ref.watch(equipesProvider).value ?? const <Equipe>[];
    final noms = {for (final e in equipes) e.id: e.nom};
    final mesEquipes = [
      for (final e in equipes)
        if (e.estMembre(uid)) e,
    ];
    final autres = [
      for (final e in equipes)
        if (!e.estMembre(uid)) e,
    ];

    Widget carteEquipe(Equipe e) => Card(
      child: ListTile(
        leading: const Icon(Icons.groups_2_outlined),
        title: Text(e.nom),
        subtitle: Text(
          [
            if (e.estResponsable(uid)) l10n.responsableEquipe,
            l10n.nombreMembres(e.membres.length),
          ].join(' · '),
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => context.push(Routes.equipe(e.id)),
      ),
    );

    return Scaffold(
      appBar: AppBar(title: Text(l10n.planning)),
      floatingActionButton: secretariat
          ? FloatingActionButton.extended(
              onPressed: () => context.push(Routes.editerEquipe('nouvelle')),
              icon: const Icon(Icons.add),
              label: Text(l10n.nouvelleEquipe),
            )
          : null,
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
        children: [
          Text(l10n.mesServices, style: theme.textTheme.titleLarge),
          const SizedBox(height: 8),
          if (services.isEmpty) Text(l10n.aucunService),
          for (final a in services)
            CarteService(affectation: a, equipeNom: noms[a.equipeId] ?? ''),
          const SizedBox(height: 24),
          Text(l10n.mesEquipes, style: theme.textTheme.titleLarge),
          const SizedBox(height: 8),
          if (mesEquipes.isEmpty) Text(l10n.aucuneEquipe),
          for (final e in mesEquipes) carteEquipe(e),
          if (secretariat && autres.isNotEmpty) ...[
            const SizedBox(height: 24),
            Text(l10n.autresEquipes, style: theme.textTheme.titleLarge),
            const SizedBox(height: 8),
            for (final e in autres) carteEquipe(e),
          ],
        ],
      ),
    );
  }
}
