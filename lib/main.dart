import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app.dart';
import 'core/firebase/firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // Les polices sont incluses dans l'app (assets/google_fonts).
  GoogleFonts.config.allowRuntimeFetching = false;
  runApp(const ProviderScope(child: MontagneDesOliviersApp()));
}
