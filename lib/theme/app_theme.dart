import 'package:flutter/material.dart';

class AppTheme {
  // Colors matching the Figma design
  static const Color background = Color(0xFFF9FAFB); // gray-50
  static const Color white = Color(0xFFFFFFFF);
  static const Color gray100 = Color(0xFFF3F4F6);
  static const Color gray300 = Color(0xFFD1D5DB);
  static const Color gray400 = Color(0xFF9CA3AF);
  static const Color gray500 = Color(0xFF6B7280);
  static const Color gray600 = Color(0xFF4B5563);
  static const Color gray700 = Color(0xFF374151);
  static const Color gray900 = Color(0xFF111827);
  
  // Status colors
  static const Color greenStatus = Color(0xFF22C55E);
  static const Color yellowStatus = Color(0xFFEAB308);
  static const Color redStatus = Color(0xFFEF4444);
  
  // Chart colors
  static const Color blue500 = Color(0xFF3B82F6);
  static const Color red500 = Color(0xFFEF4444);
  static const Color amber500 = Color(0xFFF59E0B);
  static const Color green500 = Color(0xFF22C55E);
  static const Color purple500 = Color(0xFFA855F7);
  static const Color orange500 = Color(0xFFF97316);
  
  // Alert type colors
  static const Color waterQualityColor = Color(0xFF3B82F6);
  static const Color fishHealthColor = Color(0xFFF97316);
  
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: background,
      colorScheme: ColorScheme.light(
        primary: gray900,
        secondary: gray600,
        surface: white,
        background: background,
        error: redStatus,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: white,
        foregroundColor: gray900,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: gray900,
          fontSize: 18,
          fontWeight: FontWeight.w500,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: white,
        selectedItemColor: gray900,
        unselectedItemColor: gray400,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      cardTheme: CardTheme(
        color: white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: gray300, width: 2),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: gray300,
        thickness: 1,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.all(white),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return gray900;
          }
          return gray300;
        }),
      ),
    );
  }
}
