import 'package:flutter/material.dart';

class SpecialColors {
  static const Color gold = Color(0xFFFFD700);
  static const Color silver = Color(0xFFC0C0C0);
  static const Color bronze = Color(0xFFCD7F32);
  static const lightThemeColor = Color.fromARGB(255, 213, 212, 200);
  static const darkThemeColor = Color.fromARGB(255, 105, 96, 85);
  static const closeButton = Colors.red;
  static const commentTextcolor = Colors.black;
  
  static final bookSelectedColor = Colors.brown.shade400;
  static final bookDefaultColor = Colors.grey.shade400;
  static final closeButtonBackground = Colors.black.withOpacity(0.3);
}

ColorScheme darktheme = ColorScheme.fromSeed(
  seedColor: SpecialColors.darkThemeColor,
  dynamicSchemeVariant: DynamicSchemeVariant.neutral,
  brightness: Brightness.dark
);

ColorScheme lighttheme = ColorScheme.fromSeed(
  seedColor: SpecialColors.lightThemeColor,
  dynamicSchemeVariant: DynamicSchemeVariant.neutral,
  brightness: Brightness.light
);
