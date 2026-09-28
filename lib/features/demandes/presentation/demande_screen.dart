import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../l10n/app_localizations.dart';
import '../../../shared/format_date.dart';
import '../../../shared/widgets/etat_vide.dart';
import '../../auth/auth_providers.dart';
import '../demandes_providers.dart';
import '../domain/demande.dart';
import 'libelles_demandes.dart';

/// Une demande. [gestion] : vue du secrétariat / des pasteurs (réponse, suivi).
class DemandeScreen extends ConsumerWidget {
  const DemandeScreen({super.key, required this.id, this.gestion = false});

  final String id;
  final bool gestion;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final demande = ref.watch(demandeProvider(id));
    return Scaffold(
      appBar: AppBar(title: Text(l10n.demande)),
      body: demande.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => EtatVide(
          icone: Icons.lock_outline,
          texte: l10n.demandeIndisponible,
        ),
        data: (d) => d == null
            ? EtatVide(
                icone: Icons.outbox_outlined,
                texte: l10n.demandeIndisponible,
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
                            iconeDemande(d.type),
                            color: theme.colorScheme.secondary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            l10n.libelleDemande(d.type),
                            style: theme.textTheme.titleLarge,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        [
                          if (gestion) d.nom,
                          if (d.createdAt != null)
                            context.dateLongue(d.createdAt!),
                        ].join(' · '),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Chip(
                        label: Text(l10n.libelleStatutDemande(d.statut)),
                        labelStyle: TextStyle(
                          color: couleurStatutDemande(
                            theme.colorScheme,
                            d.statut,
                          ),
                        ),
                      ),
                      if (d.message.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        SelectableText(
                          d.message,
                          style: theme.textTheme.bodyLarge,
                        ),
                      ],
                      if (!gestion && d.reponse.isNotEmpty) ...[
                        const SizedBox(height: 20),
                        Card(
                          color: theme.colorScheme.primaryContainer,
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  l10n.reponseEglise,
                                  style: theme.textTheme.titleSmall,
                                ),
                                const SizedBox(height: 4),
                                SelectableText(d.reponse),
                              ],
                            ),
                          ),
                        ),
                      ],
                      if (!gestion && d.statut == StatutDemande.nouvelle) ...[
                        const SizedBox(height: 24),
                        OutlinedButton.icon(
                          onPressed: () async {
                            await ref
                                .read(demandesRepositoryProvider)
                                .retirer(d.id);
                            if (context.mounted) context.pop();
                          },
                          icon: const Icon(Icons.undo),
                          label: Text(l10n.retirerDemande),
                        ),
                      ],
                      if (gestion) ...[
                        const SizedBox(height: 24),
                        _Reponse(demande: d),
                      ],
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}

class _Reponse extends ConsumerStatefulWidget {
  const _Reponse({required this.demande});

  final Demande demande;

  @override
  ConsumerState<_Reponse> createState() => _ReponseState();
}

class _ReponseState extends ConsumerState<_Reponse> {
  late final _reponse = TextEditingController(text: widget.demande.reponse);
  late StatutDemande _statut = widget.demande.statut == StatutDemande.nouvelle
      ? StatutDemande.enCours
      : widget.demande.statut;
  bool _occupe = false;

  @override
  void dispose() {
    _reponse.dispose();
    super.dispose();
  }

  Future<void> _enregistrer() async {
    final l10n = AppLocalizations.of(context);
    final messager = ScaffoldMessenger.of(context);
    final uid = ref.read(utilisateurFirebaseProvider).value?.uid ?? '';
    setState(() => _occupe = true);
    try {
      await ref
          .read(demandesRepositoryProvider)
          .repondre(
            widget.demande.id,
            statut: _statut,
            reponse: _reponse.text,
            par: uid,
          );
      messager.showSnackBar(SnackBar(content: Text(l10n.enregistre)));
    } catch (_) {
      messager.showSnackBar(SnackBar(content: Text(l10n.erreurInconnue)));
    } finally {
      if (mounted) setState(() => _occupe = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DropdownButtonFormField<StatutDemande>(
          initialValue: _statut,
          decoration: InputDecoration(labelText: l10n.champStatut),
          items: [
            for (final s in StatutDemande.values)
              DropdownMenuItem(
                value: s,
                child: Text(l10n.libelleStatutDemande(s)),
              ),
          ],
          onChanged: (s) => setState(() => _statut = s ?? _statut),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _reponse,
          decoration: InputDecoration(
            labelText: l10n.reponseALaPersonne,
            helperText: l10n.reponseAide,
          ),
          minLines: 3,
          maxLines: null,
          textCapitalization: TextCapitalization.sentences,
        ),
        const SizedBox(height: 12),
        FilledButton(
          onPressed: _occupe ? null : _enregistrer,
          child: Text(l10n.enregistrerEtPrevenir),
        ),
      ],
    );
  }
}
