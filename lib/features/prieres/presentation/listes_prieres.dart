import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/routes.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/etat_vide.dart';
import '../domain/priere.dart';
import '../prieres_providers.dart';
import 'carte_priere.dart';

Widget _liste(
  BuildContext context,
  AsyncValue<List<Priere>> prieres, {
  required String vide,
  required String Function(Priere) lien,
  bool Function(Priere)? nomVisible,
  EdgeInsets padding = const EdgeInsets.all(16),
}) {
  final l10n = AppLocalizations.of(context);
  return prieres.when(
    loading: () => const Center(child: CircularProgressIndicator()),
    error: (_, _) =>
        EtatVide(icone: Icons.cloud_off, texte: l10n.erreurChargement),
    data: (liste) => liste.isEmpty
        ? EtatVide(icone: Icons.volunteer_activism_outlined, texte: vide)
        : ListView(
            padding: padding,
            children: [
              for (final p in liste)
                CartePriere(
                  priere: p,
                  lien: lien(p),
                  nomVisible: nomVisible?.call(p) ?? true,
                ),
            ],
          ),
  );
}

/// Mes sujets de prière.
class MesPrieresScreen extends ConsumerWidget {
  const MesPrieresScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.mesSujetsPriere)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(Routes.nouvellePriere),
        icon: const Icon(Icons.add),
        label: Text(l10n.nouveauSujet),
      ),
      body: _liste(
        context,
        ref.watch(mesPrieresProvider),
        vide: l10n.aucunSujetPriere,
        lien: (p) => Routes.maPriere(p.id),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
      ),
    );
  }
}

/// Équipe d'intercession : les sujets partagés avec le groupe.
class PrieresGroupeScreen extends ConsumerWidget {
  const PrieresGroupeScreen({super.key, required this.groupeId});

  final String groupeId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.sujetsPriere)),
      body: _liste(
        context,
        ref.watch(prieresGroupeProvider(groupeId)),
        vide: l10n.aucunSujetPartage,
        lien: (p) => Routes.priereGroupe(groupeId, p.id),
        nomVisible: (p) => !p.anonyme,
      ),
    );
  }
}

/// Pasteurs : tous les sujets de prière.
class GestionPrieresScreen extends ConsumerWidget {
  const GestionPrieresScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.sujetsPriere)),
      body: _liste(
        context,
        ref.watch(toutesPrieresProvider),
        vide: l10n.aucunSujetPriere,
        lien: (p) => Routes.gererPriere(p.id),
      ),
    );
  }
}
