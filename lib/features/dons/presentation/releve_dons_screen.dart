import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/horloge.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/format_date.dart';
import '../../../shared/format_euros.dart';
import '../../../shared/services/partage.dart';
import '../../auth/auth_providers.dart';
import '../dons_providers.dart';
import '../domain/don.dart';
import 'libelles_dons.dart';

/// Relevé annuel des dons reçus (ce n'est pas une attestation fiscale).
class ReleveDonsScreen extends ConsumerStatefulWidget {
  const ReleveDonsScreen({super.key});

  @override
  ConsumerState<ReleveDonsScreen> createState() => _ReleveDonsScreenState();
}

class _ReleveDonsScreenState extends ConsumerState<ReleveDonsScreen> {
  late int _annee = ref.read(horlogeProvider)().year;

  Future<void> _partager(List<Don> dons) async {
    final l10n = AppLocalizations.of(context);
    final nom = ref.read(profilProvider).value?.nom ?? '';
    final lignes = [
      l10n.releveTitre('$_annee'),
      l10n.nomEglise,
      nom,
      '',
      for (final d in dons)
        '${context.dateCourte(d.createdAt!)} ${d.createdAt!.year} · '
            '${l10n.affectation(d.affectation)} · ${context.euros(d.montant)}',
      '',
      '${l10n.total} : ${context.euros(totalDons(dons))}',
      '',
      l10n.releveAvertissement,
    ];
    await ref
        .read(partageProvider)
        .partagerFichier(
          nom: 'releve-dons-$_annee.txt',
          contenu: '${lignes.join('\n')}\n',
          typeMime: 'text/plain',
        );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final dons = recusEn(
      ref.watch(mesDonsProvider).value ?? const <Don>[],
      _annee,
    );
    final anneeCourante = ref.watch(horlogeProvider)().year;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.releveAnnuel),
        actions: [
          IconButton(
            tooltip: l10n.partager,
            onPressed: dons.isEmpty ? null : () => _partager(dons),
            icon: const Icon(Icons.share_outlined),
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    tooltip: l10n.anneePrecedente,
                    onPressed: () => setState(() => _annee--),
                    icon: const Icon(Icons.chevron_left),
                  ),
                  Text('$_annee', style: theme.textTheme.headlineSmall),
                  IconButton(
                    tooltip: l10n.anneeSuivante,
                    onPressed: _annee >= anneeCourante
                        ? null
                        : () => setState(() => _annee++),
                    icon: const Icon(Icons.chevron_right),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Card(
                child: ListTile(
                  title: Text(l10n.totalRecu),
                  trailing: Text(
                    context.euros(totalDons(dons)),
                    style: theme.textTheme.titleLarge,
                  ),
                ),
              ),
              for (final e in totauxParAffectation(dons).entries)
                ListTile(
                  dense: true,
                  title: Text(l10n.affectation(e.key)),
                  trailing: Text(context.euros(e.value)),
                ),
              const Divider(),
              if (dons.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(l10n.aucunDonCetteAnnee),
                ),
              for (final d in dons)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    '${context.euros(d.montant)} · '
                    '${l10n.affectation(d.affectation)}',
                  ),
                  subtitle: Text(
                    '${context.dateLongue(d.createdAt!)} · '
                    '${l10n.modeDon(d.mode)}',
                  ),
                ),
              const SizedBox(height: 16),
              Text(l10n.releveAvertissement, style: theme.textTheme.bodySmall),
            ],
          ),
        ),
      ),
    );
  }
}
