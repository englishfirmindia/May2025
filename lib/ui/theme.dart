import 'package:flutter/material.dart';

// Custom theme extension for additional colors
class CustomThemeColors extends ThemeExtension<CustomThemeColors> {
  final Color shadowColor;
  final Color linkTextColor;
  final Color weakPasswordColor;
  final Color mediumPasswordColor;
  final Color strongPasswordColor;

  CustomThemeColors({
    required this.shadowColor,
    required this.linkTextColor,
    required this.weakPasswordColor,
    required this.mediumPasswordColor,
    required this.strongPasswordColor,
  });

  @override
  CustomThemeColors copyWith({
    Color? shadowColor,
    Color? linkTextColor,
    Color? weakPasswordColor,
    Color? mediumPasswordColor,
    Color? strongPasswordColor,
  }) {
    return CustomThemeColors(
      shadowColor: shadowColor ?? this.shadowColor,
      linkTextColor: linkTextColor ?? this.linkTextColor,
      weakPasswordColor: weakPasswordColor ?? this.weakPasswordColor,
      mediumPasswordColor: mediumPasswordColor ?? this.mediumPasswordColor,
      strongPasswordColor: strongPasswordColor ?? this.strongPasswordColor,
    );
  }

  @override
  CustomThemeColors lerp(ThemeExtension<CustomThemeColors>? other, double t) {
    if (other is! CustomThemeColors) {
      return this;
    }
    return CustomThemeColors(
      shadowColor: Color.lerp(shadowColor, other.shadowColor, t)!,
      linkTextColor: Color.lerp(linkTextColor, other.linkTextColor, t)!,
      weakPasswordColor: Color.lerp(weakPasswordColor, other.weakPasswordColor, t)!,
      mediumPasswordColor: Color.lerp(mediumPasswordColor, other.mediumPasswordColor, t)!,
      strongPasswordColor: Color.lerp(strongPasswordColor, other.strongPasswordColor, t)!,
    );
  }
}

final ThemeData appTheme = ThemeData(
  primarySwatch: Colors.deepPurple,
  scaffoldBackgroundColor: Colors.white,
  cardTheme: CardTheme(
    elevation: 4.0,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
    color: Colors.white.withValues(alpha: 0.9),
    shadowColor: Colors.blue[200]!.withValues(alpha: 0.3),
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.white,
    foregroundColor: Colors.black,
    elevation: 0,
    titleTextStyle: TextStyle(
      color: Colors.black,
      fontSize: 20,
      fontWeight: FontWeight.bold,
    ),
  ),
  textTheme: const TextTheme(
    headlineLarge: TextStyle(
      fontSize: 26,
      fontWeight: FontWeight.bold,
      color: Color.fromARGB(255, 5, 5, 5),
    ),
    bodyMedium: TextStyle(fontSize: 16, color: Colors.black87),
  ),
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: Colors.blue[600],
    ),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.deepPurple,
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      padding: const EdgeInsets.symmetric(vertical: 16),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: Colors.white,
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    prefixIconColor: Colors.black,
  ),
  extensions: [
    CustomThemeColors(
      shadowColor: Colors.blue[200]!.withValues(alpha: 0.3),
      linkTextColor: Colors.blue[600]!,
      weakPasswordColor: Colors.red,
      mediumPasswordColor: Colors.orange,
      strongPasswordColor: Colors.green[700]!,
    ),
  ],
);