import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/horloge.dart';
import '../../core/roles.dart';
import '../../l10n/app_localizations.dart';
import '../../shared/format_date.dart';
import '../../shared/widgets/connexion_requise.dart';
import '../../shared/widgets/etat_vide.dart';
import '../auth/auth_providers.dart';
import 'entretien.dart';

/// Entretien de la salle : séances de nettoyage, chacun s'inscrit.
class EntretienScreen extends ConsumerWidget {
  const EntretienScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    if (ref.watch(profilProvider).value == null) {
      return ConnexionRequise(titre: l10n.entretienSalle);
    }
    final secretariat = ref.watch(estSecretariatProvider);
    final seances = ref.watch(nettoyagesProvider);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.entretienSalle)),
      floatingActionButton: secretariat
          ? FloatingActionButton.extended(
              onPressed: () => showDialog<void>(
                context: context,
                builder: (context) => const _NouvelleSeance(),
              ),
              icon: const Icon(Icons.add),
              label: Text(l10n.nouvelleSeanceNettoyage),
            )
          : null,
      body: seances.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) =>
            EtatVide(icone: Icons.cloud_off, texte: l10n.erreurChargement),
        data: (liste) => liste.isEmpty
            ? EtatVide(
                icone: Icons.cleaning_services_outlined,
                texte: l10n.aucuneSeanceNettoyage,
              )
            : ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
                children: [
                  Text(l10n.entretienIntro, style: theme.textTheme.bodyMedium),
                  const SizedBox(height: 12),
                  for (final n in liste)
                    _Seance(seance: n, gestion: secretariat),
                ],
              ),
      ),
    );
  }
}

class _Seance extends ConsumerWidget {
  const _Seance({required this.seance, required this.gestion});

  final Nettoyage seance;
  final bool gestion;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final n = seance;
    final uid = ref.watch(utilisateurFirebaseProvider).value?.uid;
    final nom = ref.watch(profilProvider).value?.nom ?? '';
    final inscrits =
        ref.watch(inscritsNettoyageProvider(n.id)).value ??
        const <String, String>{};
    final inscrit = uid != null && inscrits.containsKey(uid);
    final repo = ref.read(entretienRepositoryProvider);
    final nombre = inscrits.length;
    final complet = n.places != null && nombre >= n.places!;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(
                  Icons.cleaning_services_outlined,
                  color: theme.colorScheme.secondary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(n.titre, style: theme.textTheme.titleMedium),
                ),
                if (gestion)
                  IconButton(
                    tooltip: l10n.supprimer,
                    onPressed: () => repo.supprimer(n.id),
                    icon: const Icon(Icons.delete_outline),
                  ),
              ],
            ),
            Text('${context.dateLongue(n.date)}, ${context.heure(n.date)}'),
            if (n.description.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(n.description, style: theme.textTheme.bodyMedium),
            ],
            const SizedBox(height: 8),
            Text(
              n.places == null
                  ? l10n.inscritsNettoyage(nombre)
                  : l10n.inscritsNettoyageSur(nombre, n.places!),
              style: theme.textTheme.labelLarge,
            ),
            if (inscrits.isNotEmpty)
              Text(
                (inscrits.values.toList()..sort()).join(', '),
                style: theme.textTheme.bodySmall,
              ),
            const SizedBox(height: 8),
            if (inscrit)
              OutlinedButton.icon(
                onPressed: () => repo.seDesinscrire(n.id, uid),
                icon: const Icon(Icons.check),
                label: Text(l10n.inscritAnnuler),
              )
            else if (complet)
              Text(
                l10n.complet,
                style: TextStyle(color: theme.colorScheme.error),
              )
            else
              FilledButton.icon(
                onPressed: uid == null
                    ? null
                    : () => repo.sInscrire(n.id, uid, nom),
                icon: const Icon(Icons.front_hand_outlined),
                label: Text(l10n.jeViensNettoyer),
              ),
          ],
        ),
      ),
    );
  }
}

class _NouvelleSeance extends ConsumerStatefulWidget {
  const _NouvelleSeance();

  @override
  ConsumerState<_NouvelleSeance> createState() => _NouvelleSeanceState();
}

class _NouvelleSeanceState extends ConsumerState<_NouvelleSeance> {
  late final _titre = TextEditingController(
    text: AppLocalizations.of(context).titreNettoyageDefaut,
  );
  final _description = TextEditingController();
  final _places = TextEditingController();
  late DateTime _date;

  @override
  void initState() {
    super.initState();
    // Par défaut : samedi prochain, 10 h.
    final n = ref.read(horlogeProvider)();
    final jours = (DateTime.saturday - n.weekday) % 7;
    _date = DateTime(n.year, n.month, n.day + (jours == 0 ? 7 : jours), 10);
  }

  @override
  void dispose() {
    _titre.dispose();
    _description.dispose();
    _places.dispose();
    super.dispose();
  }

  Future<void> _choisirDate() async {
    final jour = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (jour == null || !mounted) return;
    final heure = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_date),
    );
    if (heure == null) return;
    setState(
      () => _date = DateTime(
        jour.year,
        jour.month,
        jour.day,
        heure.hour,
        heure.minute,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(l10n.nouvelleSeanceNettoyage),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titre,
              decoration: InputDecoration(labelText: l10n.champTitre),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.schedule),
              title: Text(
                '${context.dateLongue(_date)}, ${context.heure(_date)}',
              ),
              onTap: _choisirDate,
            ),
            TextField(
              controller: _places,
              decoration: InputDecoration(
                labelText: l10n.personnesSouhaitees,
                helperText: l10n.placesMaxAide,
              ),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _description,
              decoration: InputDecoration(labelText: l10n.champDescription),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.annuler),
        ),
        FilledButton(
          onPressed: () async {
            if (_titre.text.trim().isEmpty) return;
            final places = int.tryParse(_places.text.trim());
            await ref
                .read(entretienRepositoryProvider)
                .creer(
                  titre: _titre.text,
                  date: _date,
                  description: _description.text,
                  places: places != null && places >= 1 ? places : null,
                );
            if (context.mounted) Navigator.pop(context);
          },
          child: Text(l10n.creer),
        ),
      ],
    );
  }
}
