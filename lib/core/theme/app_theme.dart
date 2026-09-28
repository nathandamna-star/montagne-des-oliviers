import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// Thème : Montserrat pour les titres (comme le logo), Nunito Sans pour le texte.
abstract final class AppTheme {
  static const rayonCarte = 20.0;
  static const rayonBouton = 14.0;
  static const tailleTactileMin = 48.0;

  static ThemeData get clair => _construire(
    const ColorScheme(
      brightness: Brightness.light,
      primary: AppColors.bleu,
      onPrimary: Colors.white,
      secondary: AppColors.olive,
      onSecondary: Colors.white,
      error: Color(0xFFB3261E),
      onError: Colors.white,
      surface: AppColors.fond,
      onSurface: AppColors.texte,
      onSurfaceVariant: AppColors.texteSecondaire,
      surfaceContainerLowest: AppColors.carte,
      surfaceContainerLow: AppColors.carte,
      surfaceContainer: AppColors.carte,
      outline: AppColors.bordure,
      outlineVariant: AppColors.bordure,
    ),
  );

  static ThemeData get sombre => _construire(
    const ColorScheme(
      brightness: Brightness.dark,
      primary: AppColors.bleuClair,
      onPrimary: AppColors.texte,
      secondary: AppColors.oliveClair,
      onSecondary: AppColors.ardoise,
      error: Color(0xFFF2B8B5),
      onError: Color(0xFF601410),
      surface: AppColors.sombreFond,
      onSurface: AppColors.sombreTexte,
      onSurfaceVariant: AppColors.sombreTexteSecondaire,
      surfaceContainerLowest: AppColors.sombreCarte,
      surfaceContainerLow: AppColors.sombreCarte,
      surfaceContainer: AppColors.sombreCarte,
      outline: AppColors.sombreBordure,
      outlineVariant: AppColors.sombreBordure,
    ),
  );

  static ThemeData _construire(ColorScheme couleurs) {
    final base = ThemeData(colorScheme: couleurs, useMaterial3: true);
    final texte = GoogleFonts.nunitoSansTextTheme(base.textTheme);
    final titres = GoogleFonts.montserratTextTheme(base.textTheme);
    TextStyle? titre(TextStyle? s) => s?.copyWith(fontWeight: FontWeight.w600);
    final textTheme = texte
        .copyWith(
          displayLarge: titre(titres.displayLarge),
          displayMedium: titre(titres.displayMedium),
          displaySmall: titre(titres.displaySmall),
          headlineLarge: titre(titres.headlineLarge),
          headlineMedium: titre(titres.headlineMedium),
          headlineSmall: titre(titres.headlineSmall),
          titleLarge: titres.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        )
        .apply(bodyColor: couleurs.onSurface, displayColor: couleurs.onSurface);

    final forme = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(rayonBouton),
    );
    const tailleMin = Size(tailleTactileMin, tailleTactileMin);

    return base.copyWith(
      textTheme: textTheme,
      scaffoldBackgroundColor: couleurs.surface,
      appBarTheme: AppBarTheme(
        backgroundColor: couleurs.surface,
        foregroundColor: couleurs.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: textTheme.titleLarge,
      ),
      cardTheme: CardThemeData(
        color: couleurs.surfaceContainerLowest,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(rayonCarte),
          side: BorderSide(color: couleurs.outline),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(minimumSize: tailleMin, shape: forme),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: tailleMin,
          shape: forme,
          side: BorderSide(color: couleurs.outline),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(minimumSize: tailleMin, shape: forme),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: couleurs.surfaceContainerLowest,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(rayonBouton),
          borderSide: BorderSide(color: couleurs.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(rayonBouton),
          borderSide: BorderSide(color: couleurs.outline),
        ),
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: couleurs.surfaceContainerLowest,
        indicatorColor: couleurs.primary.withValues(alpha: 0.14),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: couleurs.surfaceContainerLowest,
        indicatorColor: couleurs.primary.withValues(alpha: 0.14),
        labelTextStyle: WidgetStatePropertyAll(textTheme.labelSmall),
      ),
    );
  }
}
