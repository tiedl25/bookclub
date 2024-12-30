import 'package:flutter/material.dart';

class SpecialColors {
  static const Color gold = Color(0xFFFFD700);
  static const Color silver = Color(0xFFC0C0C0);
  static const Color bronze = Color(0xFFCD7F32);
  static const backgroundColor = Color.fromARGB(255, 242, 240, 227);
  static const themeColor = Color.fromARGB(255, 18, 65, 135);
  static final bookSelectedColor = Colors.brown.shade400;
  static final bookDefaultColor = Colors.grey.shade400;
  
}

ColorScheme colorScheme = ColorScheme.fromSeed(
  seedColor: SpecialColors.themeColor,
  surface: SpecialColors.backgroundColor,
);
