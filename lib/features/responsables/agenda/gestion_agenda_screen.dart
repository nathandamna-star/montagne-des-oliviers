import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/routes.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/etat_vide.dart';
import '../../agenda/agenda_providers.dart';
import '../../agenda/presentation/carte_evenement.dart';

/// Secrétariat : événements à venir (publiés et brouillons).
class GestionAgendaScreen extends ConsumerWidget {
  const GestionAgendaScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final evenements = ref.watch(tousEvenementsProvider);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.gestionAgenda)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(Routes.editerEvenement('nouveau')),
        icon: const Icon(Icons.add),
        label: Text(l10n.nouvelEvenement),
      ),
      body: evenements.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) =>
            EtatVide(icone: Icons.cloud_off, texte: l10n.erreurChargement),
        data: (liste) => liste.isEmpty
            ? EtatVide(
                icone: Icons.event_available_outlined,
                texte: l10n.aucunEvenement,
              )
            : ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
                itemCount: liste.length,
                separatorBuilder: (_, _) => const SizedBox(height: 8),
                itemBuilder: (context, i) => CarteEvenement(
                  evenement: liste[i],
                  lien: Routes.editerEvenement(liste[i].id),
                ),
              ),
      ),
    );
  }
}
