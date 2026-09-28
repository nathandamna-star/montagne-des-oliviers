import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

enum GenreFichier { audio, video, document }

/// Choisir un fichier audio, vidéo ou PDF (téléphone ou ordinateur) et
/// l'envoyer dans Storage. Isolé derrière une interface pour les tests.
abstract interface class EnvoiFichiers {
  /// Envoie dans le dossier [dossier] ; renvoie l'adresse, ou null si annulé.
  /// [progression] reçoit une valeur entre 0 et 1.
  Future<String?> choisirEtEnvoyer({
    required String dossier,
    required GenreFichier genre,
    void Function(double)? progression,
  });
}

class EnvoiFichiersFirebase implements EnvoiFichiers {
  EnvoiFichiersFirebase(this.storage);

  final FirebaseStorage storage;

  @override
  Future<String?> choisirEtEnvoyer({
    required String dossier,
    required GenreFichier genre,
    void Function(double)? progression,
  }) async {
    final fichier = await FilePicker.pickFile(
      type: switch (genre) {
        GenreFichier.audio => FileType.audio,
        GenreFichier.video => FileType.video,
        GenreFichier.document => FileType.custom,
      },
      allowedExtensions: genre == GenreFichier.document ? const ['pdf'] : null,
      // Vidéos recompressées par le téléphone : envoi plus rapide.
      compressionQuality: genre == GenreFichier.video && !kIsWeb ? 60 : 0,
    );
    if (fichier == null) return null;
    final extension =
        (fichier.extension ??
                switch (genre) {
                  GenreFichier.audio => 'm4a',
                  GenreFichier.video => 'mp4',
                  GenreFichier.document => 'pdf',
                })
            .toLowerCase();
    final ref = storage.ref(
      '$dossier/${genre.name}-${DateTime.now().millisecondsSinceEpoch}.$extension',
    );
    final meta = SettableMetadata(contentType: typeMime(extension, genre));
    final UploadTask envoi;
    if (kIsWeb || fichier.path == null) {
      envoi = ref.putData(await fichier.readAsBytes(), meta);
    } else {
      envoi = ref.putFile(File(fichier.path!), meta);
    }
    envoi.snapshotEvents.listen((s) {
      if (s.totalBytes > 0) {
        progression?.call(s.bytesTransferred / s.totalBytes);
      }
    });
    await envoi;
    return ref.getDownloadURL();
  }

  static String typeMime(String extension, GenreFichier genre) =>
      switch (extension) {
        'mp3' => 'audio/mpeg',
        'm4a' || 'aac' => 'audio/mp4',
        'wav' => 'audio/wav',
        'mov' => 'video/quicktime',
        'mp4' || 'm4v' => 'video/mp4',
        'pdf' => 'application/pdf',
        _ => switch (genre) {
          GenreFichier.audio => 'audio/mp4',
          GenreFichier.video => 'video/mp4',
          GenreFichier.document => 'application/pdf',
        },
      };
}
