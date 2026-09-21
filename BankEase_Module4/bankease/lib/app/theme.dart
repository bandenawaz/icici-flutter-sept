import 'package:flutter/material.dart';

abstract final class AppTheme {
  static const Color brandGreen = Color(0xFF0E6B5C);

  static final ThemeData light = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(seedColor: brandGreen),
  );
}
