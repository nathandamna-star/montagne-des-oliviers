import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/app_localizations.dart';
import '../../../shared/domain_traduction.dart';
import '../../../shared/format_date.dart';
import '../../../shared/widgets/etat_vide.dart';
import '../../auth/auth_providers.dart';
import '../agenda_providers.dart';
import '../domain/evenement.dart';
import 'libelles_agenda.dart';

/// Détail d'un événement, avec l'inscription si elle est ouverte.
class EvenementScreen extends ConsumerWidget {
  const EvenementScreen({super.key, required this.id});

  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final evenement = ref.watch(evenementProvider(id));
    return Scaffold(
      appBar: AppBar(title: Text(l10n.evenement)),
      body: evenement.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => EtatVide(
          icone: Icons.lock_outline,
          texte: l10n.evenementIndisponible,
        ),
        data: (e) => e == null
            ? EtatVide(
                icone: Icons.event_busy_outlined,
                texte: l10n.evenementIndisponible,
              )
            : Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 720),
                  child: ListView(
                    padding: const EdgeInsets.all(20),
                    children: [
                      Row(
                        children: [
                          Icon(
                            iconeType(e.type),
                            color: theme.colorScheme.secondary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            l10n.libelleType(e.type),
                            style: theme.textTheme.labelLarge?.copyWith(
                              color: theme.colorScheme.secondary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        Traduction.dans(e.titre, context.langue),
                        style: theme.textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 16),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.schedule),
                        title: Text(context.dateLongue(e.debut)),
                        subtitle: Text(
                          '${context.heure(e.debut)} – ${context.heure(e.fin)}',
                        ),
                      ),
                      if (e.lieu.isNotEmpty)
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(Icons.place_outlined),
                          title: Text(e.lieu),
                        ),
                      if (e.description.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        SelectableText(
                          Traduction.dans(e.description, context.langue),
                          style: theme.textTheme.bodyLarge,
                        ),
                      ],
                      if (e.inscription) ...[
                        const SizedBox(height: 24),
                        _Inscription(evenement: e),
                      ],
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}

class _Inscription extends ConsumerStatefulWidget {
  const _Inscription({required this.evenement});

  final Evenement evenement;

  @override
  ConsumerState<_Inscription> createState() => _InscriptionState();
}

class _InscriptionState extends ConsumerState<_Inscription> {
  int _personnes = 1;
  bool _occupe = false;

  Future<void> _agir(Future<void> Function() action) async {
    final l10n = AppLocalizations.of(context);
    final messager = ScaffoldMessenger.of(context)..hideCurrentSnackBar();
    setState(() => _occupe = true);
    try {
      await action();
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
    final e = widget.evenement;
    final user = ref.watch(utilisateurFirebaseProvider).value;
    final profil = ref.watch(profilProvider).value;
    final mienne = ref.watch(monInscriptionProvider(e.id)).value;
    final repo = ref.read(agendaRepositoryProvider);

    final places = e.placesMax == null
        ? l10n.inscritsNombre(e.inscrits)
        : l10n.inscritsSurPlaces(e.inscrits, e.placesMax!);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l10n.inscription, style: theme.textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(places, style: theme.textTheme.bodyMedium),
            const SizedBox(height: 12),
            if (user == null || profil == null)
              Text(l10n.inscriptionConnexion)
            else if (mienne != null) ...[
              Text(
                l10n.inscritPersonnes(mienne.personnes),
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 8),
              OutlinedButton(
                onPressed: _occupe
                    ? null
                    : () => _agir(() => repo.seDesinscrire(e.id, user.uid)),
                child: Text(l10n.seDesinscrire),
              ),
            ] else if (e.complet)
              Text(
                l10n.complet,
                style: TextStyle(color: theme.colorScheme.error),
              )
            else ...[
              Row(
                children: [
                  Expanded(child: Text(l10n.nombrePersonnes)),
                  IconButton(
                    tooltip: l10n.moins,
                    onPressed: _personnes > 1
                        ? () => setState(() => _personnes--)
                        : null,
                    icon: const Icon(Icons.remove_circle_outline),
                  ),
                  Text('$_personnes', style: theme.textTheme.titleMedium),
                  IconButton(
                    tooltip: l10n.plus,
                    onPressed: _personnes < 10
                        ? () => setState(() => _personnes++)
                        : null,
                    icon: const Icon(Icons.add_circle_outline),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              FilledButton(
                onPressed: _occupe
                    ? null
                    : () => _agir(
                        () => repo.sInscrire(
                          e.id,
                          uid: user.uid,
                          nom: profil.nom,
                          personnes: _personnes,
                        ),
                      ),
                child: Text(l10n.sInscrire),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
