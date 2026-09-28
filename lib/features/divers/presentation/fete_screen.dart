import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/roles.dart';
import '../../../core/router/routes.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/format_date.dart';
import '../../../shared/widgets/etat_vide.dart';
import '../../auth/auth_providers.dart';
import '../../groupes/groupes_providers.dart';
import '../../parametres/parametres_eglise.dart';
import '../divers_providers.dart';
import '../domain/fete.dart';
import 'libelles_divers.dart';

/// Une fête : infos, « J'apporte… » et, pour la cuisine, ce que chacun apporte.
class FeteScreen extends ConsumerWidget {
  const FeteScreen({super.key, required this.id});

  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final fete = ref.watch(feteProvider(id));
    final uid = ref.watch(utilisateurFirebaseProvider).value?.uid;
    final secretariat = ref.watch(estSecretariatProvider);
    final cuisineId = ref
        .watch(parametresEgliseProvider)
        .value
        ?.groupeCuisineId;
    final cuisine =
        secretariat ||
        (cuisineId != null &&
            (ref.watch(mesGroupesProvider).value ?? const []).any(
              (g) => g.id == cuisineId,
            ));
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.divers),
        actions: [
          if (fete.value != null && (fete.value!.uid == uid || secretariat))
            IconButton(
              tooltip: l10n.modifier,
              onPressed: () => context.push(Routes.editerFete(id)),
              icon: const Icon(Icons.edit_outlined),
            ),
        ],
      ),
      body: fete.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) =>
            EtatVide(icone: Icons.lock_outline, texte: l10n.feteIndisponible),
        data: (f) => f == null
            ? EtatVide(icone: Icons.cake_outlined, texte: l10n.feteIndisponible)
            : Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 720),
                  child: ListView(
                    padding: const EdgeInsets.all(20),
                    children: [
                      Row(
                        children: [
                          Icon(
                            iconeFete(f.type),
                            color: theme.colorScheme.secondary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            l10n.libelleFete(f.type),
                            style: theme.textTheme.labelLarge?.copyWith(
                              color: theme.colorScheme.secondary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(f.titre, style: theme.textTheme.headlineSmall),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.schedule),
                        title: Text(context.dateLongue(f.date)),
                        subtitle: Text(context.heure(f.date)),
                      ),
                      if (f.lieu.isNotEmpty)
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(Icons.place_outlined),
                          title: Text(f.lieu),
                        ),
                      if (f.description.isNotEmpty)
                        SelectableText(
                          f.description,
                          style: theme.textTheme.bodyLarge,
                        ),
                      Text(
                        l10n.annonceePar(f.nom),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 24),
                      _JApporte(fete: f),
                      if (cuisine) ...[
                        const SizedBox(height: 24),
                        _Cuisine(feteId: f.id),
                      ],
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}

class _JApporte extends ConsumerStatefulWidget {
  const _JApporte({required this.fete});

  final Fete fete;

  @override
  ConsumerState<_JApporte> createState() => _JApporteState();
}

class _JApporteState extends ConsumerState<_JApporte> {
  final _precision = TextEditingController();
  final _apporte = <Apport>{};
  bool _charge = false;
  bool _occupe = false;

  @override
  void dispose() {
    _precision.dispose();
    super.dispose();
  }

  Future<void> _enregistrer() async {
    final l10n = AppLocalizations.of(context);
    final uid = ref.read(utilisateurFirebaseProvider).value?.uid;
    final nom = ref.read(profilProvider).value?.nom;
    if (uid == null || nom == null) return;
    final messager = ScaffoldMessenger.of(context)..hideCurrentSnackBar();
    setState(() => _occupe = true);
    try {
      final repo = ref.read(diversRepositoryProvider);
      if (_apporte.isEmpty) {
        await repo.retirerContribution(widget.fete.id, uid);
      } else {
        await repo.apporter(
          widget.fete.id,
          Contribution(
            uid: uid,
            nom: nom,
            apporte: {..._apporte},
            precision: _precision.text,
          ),
        );
      }
      messager.showSnackBar(SnackBar(content: Text(l10n.cuisineInformee)));
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
    final mienne = ref.watch(maContributionProvider(widget.fete.id));
    // Reprendre ce que la personne a déjà indiqué (une seule fois).
    if (!_charge && mienne.hasValue) {
      _charge = true;
      final c = mienne.value;
      if (c != null) {
        _apporte.addAll(c.apporte);
        _precision.text = c.precision;
      }
    }
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l10n.japporte, style: theme.textTheme.titleMedium),
            Text(l10n.japporteAide, style: theme.textTheme.bodySmall),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final a in Apport.values)
                  FilterChip(
                    avatar: Icon(iconeApport(a), size: 18),
                    label: Text(l10n.libelleApport(a)),
                    selected: _apporte.contains(a),
                    onSelected: (v) => setState(
                      () => v ? _apporte.add(a) : _apporte.remove(a),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _precision,
              decoration: InputDecoration(labelText: l10n.precisionApport),
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: _occupe ? null : _enregistrer,
              child: Text(l10n.informerCuisine),
            ),
          ],
        ),
      ),
    );
  }
}

/// Responsables cuisine : ce que chacun apporte, et le total par catégorie.
class _Cuisine extends ConsumerWidget {
  const _Cuisine({required this.feteId});

  final String feteId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final liste =
        ref.watch(contributionsProvider(feteId)).value ??
        const <Contribution>[];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.pourLaCuisine, style: theme.textTheme.titleMedium),
        const SizedBox(height: 4),
        Wrap(
          spacing: 8,
          children: [
            for (final a in Apport.values)
              Chip(
                avatar: Icon(iconeApport(a), size: 18),
                label: Text(
                  '${l10n.libelleApport(a)} : ${liste.where((c) => c.apporte.contains(a)).length}',
                ),
              ),
          ],
        ),
        if (liste.isEmpty)
          Text(l10n.personneNApporte, style: theme.textTheme.bodyMedium),
        for (final c in liste)
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(c.nom),
            subtitle: Text(
              [
                c.apporte.map(l10n.libelleApport).join(', '),
                if (c.precision.isNotEmpty) c.precision,
              ].join(' — '),
            ),
          ),
      ],
    );
  }
}
