import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ErreurPaiement implements Exception {
  const ErreurPaiement(this.code);

  /// « invalide », « refuse », « reseau » ou « inconnue ».
  final String code;
}

/// Commande enregistrée par le serveur ; [url] : page de paiement en ligne.
typedef CommandePassee = ({String id, Uri? url});

/// Paiements passant par le serveur (Cloud Functions et Stripe).
abstract interface class PaiementsEnLigne {
  /// Page de paiement Stripe d'un don (carte ou Bancontact ; carte pour un
  /// don mensuel).
  Future<Uri> payerDon({
    required double montant,
    required String affectation,
    required bool mensuel,
  });

  /// Commande de livres ; [mode] : « virement » ou « en_ligne ».
  Future<CommandePassee> passerCommande({
    required Map<String, int> lignes,
    required String mode,
  });

  Future<void> arreterDonMensuel(String id);
}

class PaiementsFirebase implements PaiementsEnLigne {
  PaiementsFirebase(this.fonctions);

  final FirebaseFunctions fonctions;

  Future<Map<String, dynamic>> _appeler(String nom, Object donnees) async {
    try {
      final r = await fonctions.httpsCallable(nom).call<Object?>(donnees);
      return Map<String, dynamic>.from(r.data as Map? ?? const {});
    } on FirebaseFunctionsException catch (e) {
      throw ErreurPaiement(switch (e.code) {
        'invalid-argument' => 'invalide',
        'permission-denied' || 'unauthenticated' => 'refuse',
        'unavailable' || 'deadline-exceeded' => 'reseau',
        _ => 'inconnue',
      });
    }
  }

  @override
  Future<Uri> payerDon({
    required double montant,
    required String affectation,
    required bool mensuel,
  }) async {
    final r = await _appeler('payerDon', {
      'montant': montant,
      'affectation': affectation,
      'mensuel': mensuel,
    });
    return Uri.parse(r['url'] as String);
  }

  @override
  Future<CommandePassee> passerCommande({
    required Map<String, int> lignes,
    required String mode,
  }) async {
    final r = await _appeler('passerCommande', {
      'mode': mode,
      'lignes': [
        for (final e in lignes.entries) {'livreId': e.key, 'quantite': e.value},
      ],
    });
    final url = r['url'] as String?;
    return (id: r['id'] as String, url: url == null ? null : Uri.parse(url));
  }

  @override
  Future<void> arreterDonMensuel(String id) =>
      _appeler('arreterDonMensuel', {'id': id});
}

final paiementsEnLigneProvider = Provider<PaiementsEnLigne>(
  (ref) =>
      PaiementsFirebase(FirebaseFunctions.instanceFor(region: 'europe-west1')),
);

/// Sur iPhone, Apple demande que les dons se fassent hors de l'app (dans
/// Safari) : l'écran des dons ouvre alors le site de l'église.
final donsDansLeNavigateurProvider = Provider<bool>(
  (ref) => !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS,
);
