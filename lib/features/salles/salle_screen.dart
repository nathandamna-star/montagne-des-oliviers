import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/horloge.dart';
import '../../core/roles.dart';
import '../../l10n/app_localizations.dart';
import '../../shared/format_date.dart';
import '../../shared/widgets/etat_vide.dart';
import '../auth/auth_providers.dart';
import 'salles.dart';
import 'salles_screen.dart';

/// Une salle : créneaux déjà réservés et demande de réservation.
class SalleScreen extends ConsumerStatefulWidget {
  const SalleScreen({super.key, required this.id});

  final String id;

  @override
  ConsumerState<SalleScreen> createState() => _SalleScreenState();
}

class _SalleScreenState extends ConsumerState<SalleScreen> {
  final _motif = TextEditingController();
  late DateTime _jour;
  TimeOfDay _debut = const TimeOfDay(hour: 14, minute: 0);
  TimeOfDay _fin = const TimeOfDay(hour: 16, minute: 0);
  bool _occupe = false;
  String? _erreur;

  @override
  void initState() {
    super.initState();
    final n = ref.read(horlogeProvider)();
    _jour = DateTime(n.year, n.month, n.day + 1);
  }

  @override
  void dispose() {
    _motif.dispose();
    super.dispose();
  }

  DateTime _a(TimeOfDay t) =>
      DateTime(_jour.year, _jour.month, _jour.day, t.hour, t.minute);

  Future<void> _demander(Salle salle, List<Reservation> occupees) async {
    final l10n = AppLocalizations.of(context);
    final debut = _a(_debut);
    final fin = _a(_fin);
    String? erreur;
    if (!fin.isAfter(debut)) erreur = l10n.finAvantDebut;
    if (_motif.text.trim().isEmpty) erreur = l10n.motifObligatoire;
    if (conflits(salle.id, debut, fin, occupees).isNotEmpty) {
      erreur = l10n.creneauDejaPris;
    }
    setState(() => _erreur = erreur);
    if (erreur != null) return;
    final uid = ref.read(utilisateurFirebaseProvider).value?.uid;
    final nom = ref.read(profilProvider).value?.nom;
    if (uid == null || nom == null) return;
    final messager = ScaffoldMessenger.of(context);
    setState(() => _occupe = true);
    try {
      await ref
          .read(sallesRepositoryProvider)
          .demander(
            uid: uid,
            nom: nom,
            salle: salle,
            debut: debut,
            fin: fin,
            motif: _motif.text,
          );
      _motif.clear();
      messager.showSnackBar(SnackBar(content: Text(l10n.reservationEnvoyee)));
    } catch (_) {
      messager.showSnackBar(SnackBar(content: Text(l10n.erreurInconnue)));
    } finally {
      if (mounted) setState(() => _occupe = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final salle = (ref.watch(sallesProvider).value ?? const <Salle>[])
        .where((s) => s.id == widget.id)
        .firstOrNull;
    final occupees = [
      for (final r
          in ref.watch(reservationsValideesProvider).value ??
              const <Reservation>[])
        if (r.salleId == widget.id) r,
    ];
    final secretariat = ref.watch(estSecretariatProvider);
    if (salle == null) {
      return Scaffold(
        appBar: AppBar(),
        body: EtatVide(
          icone: Icons.meeting_room_outlined,
          texte: l10n.salleIndisponible,
        ),
      );
    }
    final pris = conflits(salle.id, _a(_debut), _a(_fin), occupees);
    return Scaffold(
      appBar: AppBar(
        title: Text(salle.nom),
        actions: [
          if (secretariat)
            IconButton(
              tooltip: l10n.supprimer,
              onPressed: () async {
                await ref
                    .read(sallesRepositoryProvider)
                    .supprimerSalle(salle.id);
                if (context.mounted) Navigator.of(context).pop();
              },
              icon: const Icon(Icons.delete_outline),
            ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (salle.description.isNotEmpty)
                Text(salle.description, style: theme.textTheme.bodyLarge),
              if (salle.capacite != null)
                Text(l10n.capacitePersonnes(salle.capacite!)),
              const SizedBox(height: 16),
              Text(l10n.creneauxReserves, style: theme.textTheme.titleMedium),
              if (occupees.isEmpty) Text(l10n.aucunCreneauReserve),
              for (final r in occupees)
                ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.event_busy_outlined),
                  title: Text(creneau(context, r)),
                  subtitle: Text(r.motif),
                ),
              const SizedBox(height: 24),
              Text(
                l10n.demanderReservation,
                style: theme.textTheme.titleMedium,
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.calendar_today_outlined),
                title: Text(context.dateLongue(_jour)),
                onTap: () async {
                  final j = await showDatePicker(
                    context: context,
                    initialDate: _jour,
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2100),
                  );
                  if (j != null) setState(() => _jour = j);
                },
              ),
              Row(
                children: [
                  Expanded(
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(l10n.debut),
                      subtitle: Text(_debut.format(context)),
                      onTap: () async {
                        final t = await showTimePicker(
                          context: context,
                          initialTime: _debut,
                        );
                        if (t != null) setState(() => _debut = t);
                      },
                    ),
                  ),
                  Expanded(
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(l10n.fin),
                      subtitle: Text(_fin.format(context)),
                      onTap: () async {
                        final t = await showTimePicker(
                          context: context,
                          initialTime: _fin,
                        );
                        if (t != null) setState(() => _fin = t);
                      },
                    ),
                  ),
                ],
              ),
              if (pris.isNotEmpty)
                Text(
                  l10n.creneauDejaPrisPar(pris.map((r) => r.motif).join(', ')),
                  style: TextStyle(color: theme.colorScheme.error),
                ),
              TextField(
                controller: _motif,
                decoration: InputDecoration(
                  labelText: l10n.motifReservation,
                  hintText: l10n.motifReservationAide,
                ),
                textCapitalization: TextCapitalization.sentences,
              ),
              if (_erreur != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    _erreur!,
                    style: TextStyle(color: theme.colorScheme.error),
                  ),
                ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: _occupe || pris.isNotEmpty
                    ? null
                    : () => _demander(salle, occupees),
                child: Text(l10n.envoyerDemandeReservation),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
