import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../core/theme/app_colors.dart';
import '../../l10n/app_localizations.dart';
import '../../shared/services/lanceur.dart';
import '../parametres/parametres_eglise.dart';

/// Programme habituel de l'église (tant que l'administrateur ne l'a pas changé).
List<(String, String)> programmeParDefaut(AppLocalizations l10n) => [
  (l10n.programmePriere, l10n.programmeMercredi),
  (l10n.programmePriere, l10n.programmeVendredi),
  (l10n.programmeCulte, l10n.programmeDimanche),
  (l10n.programmeVeillee, l10n.programmeVeilleeHoraire),
];

List<(String, String)> programmeEffectif(
  ParametresEglise? p,
  AppLocalizations l10n,
) => p?.programme ?? programmeParDefaut(l10n);

/// Titre en capitales espacées, comme sur le site de l'église.
class Surtitre extends StatelessWidget {
  const Surtitre(this.texte, {super.key, this.couleur});

  final String texte;
  final Color? couleur;

  @override
  Widget build(BuildContext context) => Text(
    texte.toUpperCase(),
    textAlign: TextAlign.center,
    style: Theme.of(context).textTheme.labelLarge?.copyWith(
      letterSpacing: 4,
      color: couleur ?? Theme.of(context).colorScheme.primary,
    ),
  );
}

/// « Notre programme » : bloc bleu marine, horaires sur des pastilles vertes.
class ProgrammeEglise extends ConsumerWidget {
  const ProgrammeEglise({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final p = ref.watch(parametresEgliseProvider).value;
    final programme = programmeEffectif(p, l10n);
    const creme = Color(0xFFF1EEE6);
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 20),
      decoration: BoxDecoration(
        color: AppColors.marine,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.notreProgramme.toUpperCase(),
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineMedium?.copyWith(color: creme),
          ),
          const SizedBox(height: 8),
          Center(
            child: Container(width: 120, height: 1, color: AppColors.olive),
          ),
          const SizedBox(height: 12),
          for (final (titre, horaire) in programme) ...[
            const SizedBox(height: 12),
            Text(
              titre.toUpperCase(),
              style: theme.textTheme.titleLarge?.copyWith(color: creme),
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
              decoration: BoxDecoration(
                color: AppColors.oliveClair,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                horaire.toUpperCase(),
                textAlign: TextAlign.center,
                style: theme.textTheme.titleSmall?.copyWith(
                  color: AppColors.marine,
                  letterSpacing: 1.2,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
          if (p != null) ...[
            const SizedBox(height: 20),
            Text(
              '${p.adresse} · ${p.telephone}',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: creme.withValues(alpha: 0.85),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// « Nous trouver » : adresse (ouvre la carte), téléphone (appelle).
class NousTrouver extends ConsumerWidget {
  const NousTrouver({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final p = ref.watch(parametresEgliseProvider).value;
    if (p == null) return const SizedBox.shrink();
    final lanceur = ref.read(lanceurProvider);
    final tel = p.telephone.replaceAll(RegExp(r'[^\d+]'), '');
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.nousTrouver, style: theme.textTheme.headlineSmall),
            const SizedBox(height: 8),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(
                Icons.place_outlined,
                color: theme.colorScheme.primary,
              ),
              title: Text('${p.adresse}, ${l10n.belgique}'),
              onTap: () => lanceur.ouvrir(
                Uri.https('www.google.com', '/maps/search/', {
                  'api': '1',
                  'query': '${p.adresse}, Belgique',
                }),
              ),
            ),
            if (tel.isNotEmpty)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(
                  Icons.phone_outlined,
                  color: theme.colorScheme.primary,
                ),
                title: Text(p.telephone),
                onTap: () => lanceur.ouvrir(Uri(scheme: 'tel', path: tel)),
              ),
          ],
        ),
      ),
    );
  }
}

/// « WhatsApp direct » : pour une demande urgente.
class WhatsAppDirect extends ConsumerWidget {
  const WhatsAppDirect({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final lien =
        ref.watch(parametresEgliseProvider).value?.whatsappDirect ?? '';
    if (lien.isEmpty) return const SizedBox.shrink();
    return Card(
      color: AppColors.oliveTresClair,
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: const FaIcon(
          FontAwesomeIcons.whatsapp,
          color: Color(0xFF25D366),
          size: 36,
        ),
        title: Text(
          l10n.whatsappDirect,
          style: theme.textTheme.titleLarge?.copyWith(color: AppColors.marine),
        ),
        subtitle: Text(
          l10n.whatsappDirectAide,
          style: const TextStyle(color: AppColors.texteSecondaire),
        ),
        onTap: () => ref.read(lanceurProvider).ouvrir(Uri.parse(lien)),
      ),
    );
  }
}
