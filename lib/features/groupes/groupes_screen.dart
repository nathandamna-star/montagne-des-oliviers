import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
import '../../shared/widgets/connexion_requise.dart';
import '../../shared/widgets/ecran_a_venir.dart';
import '../auth/auth_providers.dart';

class GroupesScreen extends ConsumerWidget {
  const GroupesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    if (!ref.watch(estConnecteProvider)) {
      return ConnexionRequise(
        titre: l10n.navGroupes,
        texte: l10n.groupesConnexionTexte,
      );
    }
    return EcranAVenir(
      titre: l10n.navGroupes,
      icone: Icons.groups_outlined,
      texte: l10n.groupesAVenir,
    );
  }
}
