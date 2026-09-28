import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
import '../../shared/widgets/etat_vide.dart';
import 'salles.dart';
import 'salles_screen.dart';

/// Secrétariat : valider ou refuser les demandes (conflits signalés).
class ReservationsAValiderScreen extends ConsumerWidget {
  const ReservationsAValiderScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final demandes =
        ref.watch(reservationsAValiderProvider).value ?? const <Reservation>[];
    final validees =
        ref.watch(reservationsValideesProvider).value ?? const <Reservation>[];
    return Scaffold(
      appBar: AppBar(title: Text(l10n.reservationsAValider)),
      body: demandes.isEmpty
          ? EtatVide(
              icone: Icons.fact_check_outlined,
              texte: l10n.aucuneReservationAValider,
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                for (final r in demandes)
                  _Demande(
                    reservation: r,
                    conflits: conflits(
                      r.salleId,
                      r.debut,
                      r.fin,
                      validees,
                      sauf: r.id,
                    ),
                  ),
              ],
            ),
    );
  }
}

class _Demande extends ConsumerStatefulWidget {
  const _Demande({required this.reservation, required this.conflits});

  final Reservation reservation;
  final List<Reservation> conflits;

  @override
  ConsumerState<_Demande> createState() => _DemandeState();
}

class _DemandeState extends ConsumerState<_Demande> {
  final _reponse = TextEditingController();

  @override
  void dispose() {
    _reponse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final r = widget.reservation;
    final repo = ref.read(sallesRepositoryProvider);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              '${r.salleNom} · ${r.motif}',
              style: theme.textTheme.titleMedium,
            ),
            Text(creneau(context, r)),
            Text(l10n.demandeePar(r.nom), style: theme.textTheme.bodySmall),
            if (widget.conflits.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  l10n.conflitAvec(
                    widget.conflits
                        .map((c) => '${c.motif} (${c.nom})')
                        .join(', '),
                  ),
                  style: TextStyle(color: theme.colorScheme.error),
                ),
              ),
            TextField(
              controller: _reponse,
              decoration: InputDecoration(labelText: l10n.messageFacultatif),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => repo.decider(
                    r.id,
                    StatutReservation.refusee,
                    reponse: _reponse.text,
                  ),
                  child: Text(l10n.refuser),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: widget.conflits.isNotEmpty
                      ? null
                      : () => repo.decider(
                          r.id,
                          StatutReservation.validee,
                          reponse: _reponse.text,
                        ),
                  child: Text(l10n.valider),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
