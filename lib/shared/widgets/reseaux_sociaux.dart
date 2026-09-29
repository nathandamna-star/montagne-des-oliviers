import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../features/parametres/parametres_eglise.dart';
import '../../l10n/app_localizations.dart';
import '../services/lanceur.dart';

/// Logos YouTube, Facebook, TikTok et Instagram de l'église : un appui ouvre
/// la page. Seuls les comptes renseignés dans les paramètres apparaissent.
class ReseauxSociaux extends ConsumerWidget {
  const ReseauxSociaux({super.key, this.titre = true});

  /// Affiche « Suivez-nous » au-dessus des logos.
  final bool titre;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final p = ref.watch(parametresEgliseProvider).value;
    if (p == null) return const SizedBox.shrink();
    final comptes = [
      (
        FontAwesomeIcons.youtube,
        'YouTube',
        const Color(0xFFFF0000),
        p.youtubeUrl,
      ),
      (
        FontAwesomeIcons.facebook,
        'Facebook',
        const Color(0xFF1877F2),
        p.facebookUrl,
      ),
      (FontAwesomeIcons.tiktok, 'TikTok', const Color(0xFF000000), p.tiktokUrl),
      (
        FontAwesomeIcons.instagram,
        'Instagram',
        const Color(0xFFE4405F),
        p.instagramUrl,
      ),
    ].where((c) => c.$4.isNotEmpty).toList();
    if (comptes.isEmpty) return const SizedBox.shrink();
    final sombre = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (titre) ...[
          Text(l10n.suivezNous, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
        ],
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            for (final (icone, nom, couleur, url) in comptes)
              Semantics(
                button: true,
                label: nom,
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () => ref.read(lanceurProvider).ouvrir(Uri.parse(url)),
                  child: SizedBox(
                    width: 84,
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 26,
                          backgroundColor:
                              sombre && couleur.computeLuminance() < 0.05
                              ? Colors.white
                              : couleur,
                          child: FaIcon(
                            icone,
                            color: sombre && couleur.computeLuminance() < 0.05
                                ? Colors.black
                                : Colors.white,
                            size: 24,
                          ),
                        ),
                        const SizedBox(height: 6),
                        ExcludeSemantics(child: Text(nom)),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}
