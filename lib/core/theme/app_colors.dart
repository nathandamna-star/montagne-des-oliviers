import 'package:flutter/material.dart';

/// Couleurs reprises du logo de l'église : bleu profond, vert olive,
/// turquoise et gris ardoise.
abstract final class AppColors {
  static const bleu = Color(0xFF1F4E8C);
  static const bleuClair = Color(0xFF8FB4E6);
  static const olive = Color(0xFF7F9A34);
  static const oliveClair = Color(0xFFB9D16E);
  static const turquoise = Color(0xFF3AA0B5);
  static const ardoise = Color(0xFF2C3440);

  static const fond = Color(0xFFF7F9FA);
  static const carte = Color(0xFFFFFFFF);
  static const texte = ardoise;
  static const texteSecondaire = Color(0xFF5B6570);
  static const bordure = Color(0xFFDDE3E8);

  static const sombreFond = Color(0xFF12171D);
  static const sombreCarte = Color(0xFF1C232B);
  static const sombreTexte = Color(0xFFE8EDF2);
  static const sombreTexteSecondaire = Color(0xFFA9B4BF);
  static const sombreBordure = Color(0xFF2E3843);
}
