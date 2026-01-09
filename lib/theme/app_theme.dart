import 'package:flutter/material.dart';

/// Dark-first theme configuration - Matching Figma design tokens
class AppTheme {
  // Background Colors - Matching Figma theme.css
  static const Color backgroundPrimary = Color(0xFF0A0A0A); // --background: #0a0a0a
  static const Color backgroundSecondary = Color(0xFF1A1A1A); // --card: #1a1a1a
  static const Color backgroundTertiary = Color(0xFF2A2A2A); // --secondary: #2a2a2a
  static const Color backgroundHover = Color(0xFF2A2A2A); // --secondary for hover
  
  // Accent Colors - Cyan from Figma
  static const Color accentPrimary = Color(0xFF00D9FF); // --primary: #00d9ff
  static const Color accentHover = Color(0xFF00B8D9); // Slightly darker cyan
  static const Color accentSubtle = Color.fromRGBO(0, 217, 255, 0.1); // --primary/10
  
  // Text Colors - Matching Figma
  static const Color textPrimary = Color(0xFFF5F5F5); // --foreground: #f5f5f5
  static const Color textSecondary = Color(0xFF999999); // --muted-foreground: #999999
  static const Color textTertiary = Color(0xFF999999); // --muted-foreground
  
  // Status Colors - Matching Figma
  static const Color error = Color(0xFFFF3B30); // --destructive: #ff3b30
  static const Color success = Color(0xFF00FF88); // --chart-4: #00ff88
  static const Color warning = Color(0xFFFFAA00); // --chart-5: #ffaa00
  
  // Border Colors
  static const Color borderColor = Color(0xFF2A2A2A); // --border: #2a2a2a
  
  // Legacy aliases for backward compatibility
  static const Color nearBlack = backgroundPrimary;
  static const Color darkSurface = backgroundSecondary;
  static const Color darkSurfaceVariant = backgroundTertiary;
  static const Color accentColor = accentPrimary;
  static const Color accentColorDark = accentHover;
  static const Color errorColor = error;
  static const Color successColor = success;
  static const Color dividerColor = borderColor;
  
  /// Get dark theme
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: false,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: backgroundPrimary,
      primaryColor: accentPrimary,
      fontFamily: 'system-ui', // --font-family-primary
      colorScheme: const ColorScheme.dark(
        primary: accentPrimary,
        secondary: accentPrimary,
        surface: backgroundSecondary,
        background: backgroundPrimary,
        error: error,
        onPrimary: nearBlack,
        onSecondary: nearBlack,
        onSurface: textPrimary,
        onBackground: textPrimary,
        onError: textPrimary,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: backgroundPrimary,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: textPrimary),
        titleTextStyle: TextStyle(
          color: textPrimary,
          fontSize: 20, // --font-size-xl
          fontWeight: FontWeight.w500, // --font-weight-medium
        ),
      ),
      cardTheme: CardThemeData(
        color: backgroundSecondary,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12), // --radius: 0.75rem
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accentPrimary,
          foregroundColor: backgroundPrimary,
          elevation: 0,
          minimumSize: const Size(0, 48), // --button-height
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16), // --button-padding
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12), // --radius: 0.75rem
          ),
          textStyle: const TextStyle(
            fontSize: 15, // --button-font-size
            fontWeight: FontWeight.w500, // --font-weight-medium
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: accentPrimary,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          textStyle: const TextStyle(
            fontSize: 15, // --button-font-size
            fontWeight: FontWeight.w500, // --font-weight-medium
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: backgroundSecondary, // --input-background
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12), // --radius: 0.75rem
          borderSide: const BorderSide(color: borderColor, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: borderColor, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: accentPrimary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: error, width: 1),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16, // --input-padding-x
          vertical: 12, // --input-padding-y
        ),
        hintStyle: const TextStyle(
          color: textTertiary,
          fontSize: 15, // --input-font-size
        ),
        labelStyle: const TextStyle(
          color: textSecondary,
          fontSize: 15, // --input-font-size
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: dividerColor,
        thickness: 1,
        space: 1,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: backgroundSecondary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12), // --radius: 0.75rem
        ),
        titleTextStyle: const TextStyle(
          color: textPrimary,
          fontSize: 20, // --font-size-xl
          fontWeight: FontWeight.w600, // --font-weight-semibold
        ),
        contentTextStyle: const TextStyle(
          color: textSecondary,
          fontSize: 14, // --font-size-base
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: backgroundSecondary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(12)), // --radius: 0.75rem
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: backgroundSecondary,
        contentTextStyle: const TextStyle(
          color: textPrimary,
          fontSize: 14, // --font-size-base
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12), // --radius: 0.75rem
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

