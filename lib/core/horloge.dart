import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Heure de l'app (remplacée dans les tests).
final horlogeProvider = Provider<DateTime Function()>((ref) => DateTime.now);
