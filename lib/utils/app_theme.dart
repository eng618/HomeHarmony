import 'package:flutter/material.dart';

final Color kPrimaryColor = const Color(0xFF2A9D8F); // Forest green
final Color kSecondaryColor = const Color(0xFFE4C1F9); // Soft lavender
final Color kAccentColor = const Color(0xFFF48C06); // Bright orange
final Color kNeutralLight = const Color(0xFFE8ECEF); // Light gray
final Color kNeutralDark = const Color(0xFF264653); // Deep navy

ThemeData buildAppTheme({bool darkMode = false}) {
  final brightness = darkMode ? Brightness.dark : Brightness.light;
  final background = darkMode ? kNeutralDark : kNeutralLight;
  final onBackground = darkMode ? kNeutralLight : kNeutralDark;
  final surface = darkMode ? kNeutralDark : Colors.white;
  final onSurface = darkMode ? kNeutralLight : kNeutralDark;
  final appBarBg = darkMode ? kNeutralDark : kPrimaryColor;
  final appBarFg = darkMode ? kAccentColor : Colors.white;

  return ThemeData(
    colorScheme: ColorScheme(
      brightness: brightness,
      primary: kPrimaryColor,
      onPrimary: Colors.white,
      secondary: kSecondaryColor,
      onSecondary: kNeutralDark,
      error: Colors.red,
      onError: Colors.white,
      surface: surface,
      onSurface: onSurface,
    ),
    primaryColor: kPrimaryColor,
    scaffoldBackgroundColor: background,
    appBarTheme: AppBarTheme(
      backgroundColor: appBarBg,
      foregroundColor: appBarFg,
      elevation: 0,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: kAccentColor,
        foregroundColor: Colors.white,
        textStyle: const TextStyle(fontWeight: FontWeight.bold),
      ),
    ),
    textTheme: TextTheme(
      bodyLarge: TextStyle(color: onSurface),
      bodyMedium: TextStyle(color: onSurface),
      titleLarge: TextStyle(color: onSurface),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: kPrimaryColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: kAccentColor, width: 2),
      ),
      labelStyle: TextStyle(color: onSurface),
    ),
  );
}
