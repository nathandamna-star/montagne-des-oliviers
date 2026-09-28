import 'dart:convert';
import 'dart:typed_data';

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

  /// Fichier binaire (PDF…).
  Future<void> partagerOctets({
    required String nom,
    required Uint8List octets,
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
  }) => partagerOctets(
    nom: nom,
    octets: utf8.encode(contenu),
    typeMime: typeMime,
  );

  @override
  Future<void> partagerOctets({
    required String nom,
    required Uint8List octets,
    required String typeMime,
  }) => SharePlus.instance.share(
    ShareParams(
      files: [XFile.fromData(octets, name: nom, mimeType: typeMime)],
      fileNameOverrides: [nom],
    ),
  );
}

final partageProvider = Provider<Partage>((ref) => const PartageNatif());
