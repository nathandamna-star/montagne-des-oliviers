import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/roles.dart';
import '../../core/router/routes.dart';
import '../../l10n/app_localizations.dart';
import '../../shared/format_date.dart';
import '../../shared/widgets/connexion_requise.dart';
import '../auth/auth_providers.dart';
import 'salles.dart';

extension LibellesSalles on AppLocalizations {
  String libelleStatutReservation(StatutReservation s) => switch (s) {
    StatutReservation.demandee => reservationDemandee,
    StatutReservation.validee => reservationValidee,
    StatutReservation.refusee => reservationRefusee,
    StatutReservation.annulee => reservationAnnulee,
  };
}

Color couleurReservation(ColorScheme c, StatutReservation s) => switch (s) {
  StatutReservation.demandee => c.secondary,
  StatutReservation.validee => c.primary,
  StatutReservation.refusee => c.error,
  StatutReservation.annulee => c.outline,
};

String creneau(BuildContext context, Reservation r) =>
    '${context.dateLongue(r.debut)}, ${context.heure(r.debut)} – ${context.heure(r.fin)}';

/// Salles de l'église : mes réservations, liste des salles.
class SallesScreen extends ConsumerWidget {
  const SallesScreen({super.key});

  Future<void> _salle(BuildContext context, WidgetRef ref, [Salle? s]) async {
    final r = await showDialog<(String, int?, String)>(
      context: context,
      builder: (context) => DialogueSalle(salle: s),
    );
    if (r == null) return;
    await ref
        .read(sallesRepositoryProvider)
        .enregistrerSalle(
          id: s?.id,
          nom: r.$1,
          capacite: r.$2,
          description: r.$3,
        );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    if (ref.watch(profilProvider).value == null) {
      return ConnexionRequise(titre: l10n.reserverSalle);
    }
    final secretariat = ref.watch(estSecretariatProvider);
    final salles = ref.watch(sallesProvider).value ?? const <Salle>[];
    final miennes =
        ref.watch(mesReservationsProvider).value ?? const <Reservation>[];
    final aValider = secretariat
        ? ref.watch(reservationsAValiderProvider).value ?? const <Reservation>[]
        : const <Reservation>[];
    final repo = ref.read(sallesRepositoryProvider);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.reserverSalle)),
      floatingActionButton: secretariat
          ? FloatingActionButton.extended(
              onPressed: () => _salle(context, ref),
              icon: const Icon(Icons.add),
              label: Text(l10n.nouvelleSalle),
            )
          : null,
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
        children: [
          if (secretariat)
            Card(
              color: aValider.isEmpty
                  ? null
                  : theme.colorScheme.secondaryContainer,
              child: ListTile(
                leading: Badge(
                  isLabelVisible: aValider.isNotEmpty,
                  label: Text('${aValider.length}'),
                  child: const Icon(Icons.fact_check_outlined),
                ),
                title: Text(l10n.reservationsAValider),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push(Routes.reservationsAValider),
              ),
            ),
          const SizedBox(height: 8),
          Text(l10n.salles, style: theme.textTheme.titleLarge),
          if (salles.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(l10n.aucuneSalle),
            ),
          for (final s in salles)
            Card(
              child: ListTile(
                leading: const Icon(Icons.meeting_room_outlined),
                title: Text(s.nom),
                subtitle: s.capacite == null
                    ? null
                    : Text(l10n.capacitePersonnes(s.capacite!)),
                trailing: secretariat
                    ? IconButton(
                        tooltip: l10n.modifier,
                        onPressed: () => _salle(context, ref, s),
                        icon: const Icon(Icons.edit_outlined),
                      )
                    : const Icon(Icons.chevron_right),
                onTap: () => context.push(Routes.salle(s.id)),
              ),
            ),
          const SizedBox(height: 24),
          Text(l10n.mesReservations, style: theme.textTheme.titleLarge),
          if (miennes.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(l10n.aucuneReservation),
            ),
          for (final r in miennes)
            Card(
              child: ListTile(
                title: Text('${r.salleNom} · ${r.motif}'),
                subtitle: Text(
                  [
                    creneau(context, r),
                    l10n.libelleStatutReservation(r.statut),
                    if (r.reponse.isNotEmpty) r.reponse,
                  ].join('\n'),
                ),
                isThreeLine: true,
                trailing:
                    r.statut == StatutReservation.demandee ||
                        r.statut == StatutReservation.validee
                    ? IconButton(
                        tooltip: l10n.annulerReservation,
                        onPressed: () => repo.annuler(r.id),
                        icon: const Icon(Icons.cancel_outlined),
                      )
                    : null,
              ),
            ),
        ],
      ),
    );
  }
}

/// Créer / modifier une salle : (nom, capacité, description).
class DialogueSalle extends StatefulWidget {
  const DialogueSalle({super.key, this.salle});

  final Salle? salle;

  @override
  State<DialogueSalle> createState() => _DialogueSalleState();
}

class _DialogueSalleState extends State<DialogueSalle> {
  late final _nom = TextEditingController(text: widget.salle?.nom ?? '');
  late final _capacite = TextEditingController(
    text: widget.salle?.capacite?.toString() ?? '',
  );
  late final _description = TextEditingController(
    text: widget.salle?.description ?? '',
  );

  @override
  void dispose() {
    _nom.dispose();
    _capacite.dispose();
    _description.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(widget.salle == null ? l10n.nouvelleSalle : l10n.modifier),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _nom,
            decoration: InputDecoration(labelText: l10n.nomSalle),
          ),
          TextField(
            controller: _capacite,
            decoration: InputDecoration(labelText: l10n.capacite),
            keyboardType: TextInputType.number,
          ),
          TextField(
            controller: _description,
            decoration: InputDecoration(labelText: l10n.champDescription),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.annuler),
        ),
        FilledButton(
          onPressed: () {
            if (_nom.text.trim().isEmpty) return;
            Navigator.pop(context, (
              _nom.text.trim(),
              int.tryParse(_capacite.text.trim()),
              _description.text,
            ));
          },
          child: Text(l10n.enregistrer),
        ),
      ],
    );
  }
}
