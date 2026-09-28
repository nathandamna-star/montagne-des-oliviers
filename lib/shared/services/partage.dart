import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

/// Partage d'un fichier : feuille de partage du téléphone (e-mail, Fichiers…),
/// téléchargement sur ordinateur.
abstract interface class Partage {
  Future<void> partagerFichier({
    required String nom,
    required String contenu,
    required String typeMime,
  });
}

class PartageNatif implements Partage {
  const PartageNatif();

  @override
  Future<void> partagerFichier({
    required String nom,
    required String contenu,
    required String typeMime,
  }) => SharePlus.instance.share(
    ShareParams(
      files: [
        XFile.fromData(utf8.encode(contenu), name: nom, mimeType: typeMime),
      ],
      fileNameOverrides: [nom],
    ),
  );
}

final partageProvider = Provider<Partage>((ref) => const PartageNatif());
