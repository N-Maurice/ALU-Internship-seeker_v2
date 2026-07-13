import 'package:flutter/material.dart';

/// ALU Venture Connect brand palette, sourced from the product design spec.
abstract final class AppColors {
  static const navy = Color(0xFF003E7E);
  static const navyDark = Color(0xFF002B57);
  static const red = Color(0xFFED1939);

  static const primary = navy;
  static const primaryLight = Color(0xFFE7EDF6);
  static const secondary = red;
  static const secondaryLight = Color(0xFFFFE8EE);

  static const background = Color(0xFFF5F8FE);
  static const surface = Colors.white;
  static const border = Color(0xFFDCE1E8);
  static const borderStrong = Color(0xFFC5CDC3);

  static const textPrimary = Color(0xFF20242A);
  static const textSecondary = Color(0xFF606975);
  static const textMuted = Color(0xFF9CA3AF);

  static const success = Color(0xFF1B8A5A);
  static const successLight = Color(0xFFE3F5EC);
  static const warning = Color(0xFFB8860B);
  static const warningLight = Color(0xFFFBF0DA);
  static const error = red;
  static const errorLight = secondaryLight;
}
