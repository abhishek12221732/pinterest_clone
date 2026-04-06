import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // The iconic Pinterest Red
  static const Color pinterestRed = Color(0xFFE60023);

  // --- LIGHT THEME ---
  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      primaryColor: pinterestRed,
      scaffoldBackgroundColor: Colors.white,
      textTheme: GoogleFonts.interTextTheme(ThemeData.light().textTheme),
      colorScheme: const ColorScheme.light(
        primary: pinterestRed,
        secondary: Colors.black,
        surface: Colors.white,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        showSelectedLabels: false,
        showUnselectedLabels: false,
      ),
      // Pinterest removes the default Android ripple effect for a more iOS-like feel
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      useMaterial3: true,
    );
  }

  // --- DARK THEME ---
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: pinterestRed,
      // Pinterest uses true black for OLED screens
      scaffoldBackgroundColor: Colors.black, 
      textTheme: GoogleFonts.interTextTheme(ThemeData.light().textTheme),
      colorScheme: const ColorScheme.dark(
        primary: pinterestRed,
        secondary: Colors.white,
        surface: Colors.black,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.black,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        showSelectedLabels: false,
        showUnselectedLabels: false,
      ),
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      useMaterial3: true,
    );
  }
}