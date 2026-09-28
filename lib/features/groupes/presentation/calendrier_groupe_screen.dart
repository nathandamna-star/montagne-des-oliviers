import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/roles.dart';
import '../../../core/router/routes.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/etat_vide.dart';
import '../../auth/auth_providers.dart';
import '../groupes_providers.dart';
import 'carte_rencontre.dart';

/// Calendrier d'un groupe : répétitions, modérations, réunions, appels.
class CalendrierGroupeScreen extends ConsumerWidget {
  const CalendrierGroupeScreen({super.key, required this.id});

  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final uid = ref.watch(utilisateurFirebaseProvider).value?.uid;
    final groupe = ref.watch(groupeProvider(id)).value;
    final gere =
        (groupe?.estAdmin(uid) ?? false) || ref.watch(estSecretariatProvider);
    final rencontres = ref.watch(rencontresProvider(id));
    return Scaffold(
      appBar: AppBar(title: Text(l10n.calendrierDe(groupe?.nom ?? ''))),
      floatingActionButton: gere
          ? FloatingActionButton.extended(
              onPressed: () =>
                  context.push(Routes.editerRencontre(id, 'nouvelle')),
              icon: const Icon(Icons.add),
              label: Text(l10n.ajouterRendezVous),
            )
          : null,
      body: rencontres.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) =>
            EtatVide(icone: Icons.cloud_off, texte: l10n.erreurChargement),
        data: (liste) => liste.isEmpty
            ? EtatVide(
                icone: Icons.event_available_outlined,
                texte: l10n.aucunRendezVous,
              )
            : ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
                children: [for (final r in liste) CarteRencontre(rencontre: r)],
              ),
      ),
    );
  }
}
