import 'package:flutter/material.dart';

/// Paleta baseada no print de referência do app.
/// TODO: migrar para Theme.of(context).colorScheme quando o design system
/// desse app for definido (seguindo o padrão já usado no Koffe/SantosOne).
class AppColors {
  static const headerStart = Color(0xFF5B2A1E);
  static const headerEnd = Color(0xFF3F1B12);
  static const background = Color(0xFFFBF3E6);
  static const cardBackground = Colors.white;
  static const gold = Color(0xFFF2B705);
  static const goldDark = Color(0xFFD99A00);
  static const textDark = Color(0xFF3B2417);
  static const textMuted = Color(0xFF8C7A6B);
  static const danger = Color(0xFFC0392B);
  static const success = Color(0xFF3F8C4B);
  static const border = Color(0x1A5B2A1E);
}
