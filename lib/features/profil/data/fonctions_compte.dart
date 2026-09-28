import 'dart:convert';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ErreurCompte implements Exception {
  const ErreurCompte(this.code);

  /// « dernier-admin », « commande-a-retirer », « reseau » ou « inconnue ».
  final String code;
}

/// Export et suppression du compte (RGPD), faits par le serveur.
abstract interface class FonctionsCompte {
  /// Toutes les données de la personne, en JSON lisible.
  Future<String> exporterMesDonnees();

  Future<void> supprimerMonCompte();
}

class FonctionsCompteFirebase implements FonctionsCompte {
  FonctionsCompteFirebase(this.fonctions);

  final FirebaseFunctions fonctions;

  Future<Object?> _appeler(String nom) async {
    try {
      return (await fonctions
              .httpsCallable(
                nom,
                options: HttpsCallableOptions(
                  timeout: const Duration(minutes: 5),
                ),
              )
              .call<Object?>())
          .data;
    } on FirebaseFunctionsException catch (e) {
      final details = e.details;
      final code = details is Map ? details['code'] : null;
      throw ErreurCompte(switch (e.code) {
        'failed-precondition' when code is String => code,
        'unavailable' || 'deadline-exceeded' => 'reseau',
        _ => 'inconnue',
      });
    }
  }

  @override
  Future<String> exporterMesDonnees() async =>
      const JsonEncoder.withIndent('  ')
          .convert(await _appeler('exporterMesDonnees'));

  @override
  Future<void> supprimerMonCompte() => _appeler('supprimerMonCompte');
}

final fonctionsCompteProvider = Provider<FonctionsCompte>(
  (ref) => FonctionsCompteFirebase(
    FirebaseFunctions.instanceFor(region: 'europe-west1'),
  ),
);
