import 'package:flutter/material.dart';

class AppTheme {
  // Krem ve taş rengi tonlarıyla minimalist tema
  static const Color primaryCream = Color(0xFFF5EFE6); // Ana krem rengi
  static const Color secondaryCream = Color(0xFFE8DFCA); // Koyu krem rengi
  static const Color accentBrown = Color(0xFFAEAC9C); // Taş/bej rengi aksanı
  static const Color darkText = Color(0xFF3F3F3F); // Koyu metin rengi

  // Define color scheme for the app
  static final lightTheme = ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryCream,
      primary: secondaryCream,
      secondary: accentBrown,
      tertiary: Color(0xFF7D7C73), // Daha koyu taş rengi
      surface: Colors.white,
      background: primaryCream,
      error: Color(0xFFD96666),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: secondaryCream,
      foregroundColor: darkText,
      elevation: 0,
      centerTitle: true,
      shadowColor: Colors.transparent,
    ),
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 0.5,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: secondaryCream.withOpacity(0.3), width: 0.5),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: secondaryCream,
        foregroundColor: darkText,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      ),
    ),
    textTheme: TextTheme(
      displayLarge: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w300,
        color: darkText,
        letterSpacing: -0.5,
      ),
      displayMedium: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w400,
        color: darkText,
        letterSpacing: -0.3,
      ),
      displaySmall: TextStyle(fontSize: 20, fontWeight: FontWeight.w500, color: darkText),
      bodyLarge: TextStyle(fontSize: 16, color: darkText, fontWeight: FontWeight.w400),
      bodyMedium: TextStyle(fontSize: 14, color: darkText.withOpacity(0.9), height: 1.4),
      bodySmall: TextStyle(fontSize: 12, color: darkText.withOpacity(0.7), letterSpacing: 0.2),
      titleLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: accentBrown),
    ),
    iconTheme: IconThemeData(color: accentBrown, size: 24),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: secondaryCream, width: 0.5),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: secondaryCream.withOpacity(0.5), width: 0.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: accentBrown, width: 1),
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: primaryCream,
      labelStyle: TextStyle(color: darkText, fontSize: 12),
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: secondaryCream, width: 0.5),
      ),
    ),
    dividerTheme: DividerThemeData(color: secondaryCream, thickness: 0.5, space: 32),
    useMaterial3: true,
  );

  // Dark theme can be defined here if needed
  static final darkTheme = ThemeData(
    // Dark theme definitions
    colorScheme: ColorScheme.fromSeed(
      seedColor: secondaryCream,
      brightness: Brightness.dark,
      primary: secondaryCream,
      secondary: accentBrown,
      background: Color(0xFF2D2D2D),
      surface: Color(0xFF383838),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Color(0xFF383838),
      foregroundColor: primaryCream,
      elevation: 0,
      centerTitle: true,
    ),
    cardTheme: CardThemeData(
      color: Color(0xFF383838),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: accentBrown.withOpacity(0.2), width: 0.5),
      ),
    ),
    // Additional dark theme configurations
    useMaterial3: true,
  );
}
