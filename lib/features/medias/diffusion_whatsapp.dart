import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../shared/services/lanceur.dart';

/// Envoi d'une exhortation sur WhatsApp. Aujourd'hui : ouvre WhatsApp avec un
/// message prêt (gratuit). Plus tard, un envoi automatique à chaque membre
/// (WhatsApp Business, payant) pourra être branché ici sans changer l'app.
abstract interface class DiffusionWhatsApp {
  Future<void> partager({
    required String titre,
    required String texte,
    required Uri lien,
  });
}

class DiffusionParLien implements DiffusionWhatsApp {
  DiffusionParLien(this.ref);

  final Ref ref;

  /// Message prêt : titre, court texte, lien de la page web publique.
  static String message(String titre, String texte, Uri lien) =>
      [titre, if (texte.isNotEmpty) texte, lien.toString()].join('\n\n');

  @override
  Future<void> partager({
    required String titre,
    required String texte,
    required Uri lien,
  }) => ref
      .read(lanceurProvider)
      .ouvrir(Uri.https('wa.me', '/', {'text': message(titre, texte, lien)}));
}
