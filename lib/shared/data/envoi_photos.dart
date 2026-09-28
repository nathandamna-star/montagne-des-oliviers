import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

/// Choisir une photo et l'envoyer dans Storage. Isolé derrière une interface
/// pour les tests.
abstract interface class EnvoiPhotos {
  /// Choisit une image dans la galerie et l'envoie à [chemin] ; renvoie son
  /// adresse, ou null si la personne a annulé.
  Future<String?> choisirEtEnvoyer(String chemin);
}

class EnvoiPhotosFirebase implements EnvoiPhotos {
  EnvoiPhotosFirebase(this.storage);

  final FirebaseStorage storage;

  @override
  Future<String?> choisirEtEnvoyer(String chemin) async {
    final image = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 1600,
      imageQuality: 80,
    );
    if (image == null) return null;
    final ref = storage.ref(chemin);
    await ref.putData(
      await image.readAsBytes(),
      SettableMetadata(contentType: 'image/jpeg'),
    );
    return ref.getDownloadURL();
  }
}
