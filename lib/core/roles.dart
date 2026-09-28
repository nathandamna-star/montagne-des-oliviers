import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Vrai si la personne connectée a au moins un rôle de responsable
/// (secrétariat, trésorier, responsable de groupe, pasteur). Branché sur les
/// custom claims Firebase à l'étape 2 ; faux en attendant.
final estResponsableProvider = Provider<bool>((ref) => false);
