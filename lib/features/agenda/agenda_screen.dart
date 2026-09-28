import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/router/routes.dart';
import '../../l10n/app_localizations.dart';
import '../../shared/format_date.dart';
import '../../shared/widgets/etat_vide.dart';
import '../divers/presentation/divers_liste.dart';
import 'agenda_providers.dart';
import 'domain/evenement.dart';
import 'presentation/carte_evenement.dart';
import 'presentation/libelles_agenda.dart';

/// Agenda : cultes, réunions et événements à venir, filtrables par type.
class AgendaScreen extends ConsumerStatefulWidget {
  const AgendaScreen({super.key});

  @override
  ConsumerState<AgendaScreen> createState() => _AgendaScreenState();
}

class _AgendaScreenState extends ConsumerState<AgendaScreen> {
  TypeEvenement? _filtre;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final evenements = ref.watch(evenementsProvider);
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.navAgenda),
          bottom: TabBar(
            tabs: [
              Tab(text: l10n.cultesEtEvenements),
              Tab(text: l10n.divers),
            ],
          ),
        ),
        body: TabBarView(
          children: [_evenements(context, evenements), const DiversListe()],
        ),
      ),
    );
  }

  Widget _evenements(
    BuildContext context,
    AsyncValue<List<Evenement>> evenements,
  ) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Column(
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              ChoiceChip(
                label: Text(l10n.tous),
                selected: _filtre == null,
                onSelected: (_) => setState(() => _filtre = null),
              ),
              for (final t in TypeEvenement.values) ...[
                const SizedBox(width: 8),
                ChoiceChip(
                  label: Text(l10n.libelleType(t)),
                  selected: _filtre == t,
                  onSelected: (_) => setState(() => _filtre = t),
                ),
              ],
            ],
          ),
        ),
        Expanded(
          child: evenements.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, _) =>
                EtatVide(icone: Icons.cloud_off, texte: l10n.erreurChargement),
            data: (tous) {
              final liste = [
                for (final e in tous)
                  if (_filtre == null || e.type == _filtre) e,
              ];
              if (liste.isEmpty) {
                return EtatVide(
                  icone: Icons.event_available_outlined,
                  texte: l10n.aucunEvenement,
                );
              }
              // Un titre par jour.
              final lignes = <Widget>[];
              DateTime? jour;
              for (final e in liste) {
                final j = DateTime(e.debut.year, e.debut.month, e.debut.day);
                if (j != jour) {
                  jour = j;
                  lignes.add(
                    Padding(
                      padding: const EdgeInsets.fromLTRB(4, 16, 4, 8),
                      child: Text(
                        context.dateLongue(j),
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                  );
                }
                lignes.add(
                  CarteEvenement(evenement: e, lien: Routes.evenement(e.id)),
                );
              }
              return ListView(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                children: lignes,
              );
            },
          ),
        ),
      ],
    );
  }
}
