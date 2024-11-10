import 'package:flutter/material.dart';

class AppColors {
  // Dark Mode Colors
  static const Color darkBackground = Color(0xFF111827);
  static const Color darkContrast = Color(0xFF1F2937);
  static const Color darkText = Colors.white;
  static const Color darkAccent = Color(0xFFE7D49E);

  // Light Mode Colors
  static const Color lightBackground = Color(0xFFF3F4F6);
  static const Color lightContrast = Color(0xFFFFFFFF);
  static const Color lightText = Colors.black87;
  static const Color lightAccent = Color(0xFFE7D49E);

  // Create ThemeData for Dark Mode
  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: darkBackground,
    primaryColor: darkAccent,
    colorScheme: const ColorScheme.dark(
      primary: darkAccent,
      secondary: darkText,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: darkBackground,
      foregroundColor: darkAccent,
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: darkText),
      bodyMedium: TextStyle(color: darkText),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: darkAccent,
        foregroundColor: darkBackground,
      ),
    ),
    cardTheme: const CardTheme(
      color: darkContrast,
    ),
    inputDecorationTheme: InputDecorationTheme(
      fillColor: darkBackground.withOpacity(0.5),
      filled: true,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: darkAccent),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: darkAccent, width: 2),
      ),
      labelStyle: const TextStyle(color: darkText),
      prefixIconColor: darkAccent,
    ),
  );

  // Create ThemeData for Light Mode
  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: lightBackground,
    cardColor: lightContrast,
    primaryColor: lightAccent,
    colorScheme: const ColorScheme.light(
      primary: lightAccent,
      secondary: lightText,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: lightBackground,
      foregroundColor: lightAccent,
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: lightText),
      bodyMedium: TextStyle(color: lightText),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: lightAccent,
        foregroundColor: lightBackground,
      ),
    ),
    cardTheme: const CardTheme(
      color: lightContrast,
    ),
    inputDecorationTheme: InputDecorationTheme(
      fillColor: Colors.white,
      filled: true,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: lightAccent),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: lightAccent, width: 2),
      ),
      labelStyle: const TextStyle(color: lightText),
      prefixIconColor: lightAccent,
    ),
  );
}
