import 'package:flutter/material.dart';

class SpecialColors {
  static const Color gold = Color(0xFFFFD700);
  static const Color silver = Color(0xFFC0C0C0);
  static const Color bronze = Color(0xFFCD7F32);
  static const themeColor = Color.fromARGB(255, 213, 212, 200);
  static const closeButton = Colors.red;
  
  static final bookSelectedColor = Colors.brown.shade400;
  static final bookDefaultColor = Colors.grey.shade400;
  static final closeButtonBackground = Colors.black.withOpacity(0.3);
}

ColorScheme colorScheme = ColorScheme.fromSeed(
  seedColor: SpecialColors.themeColor,
  dynamicSchemeVariant: DynamicSchemeVariant.neutral
);
