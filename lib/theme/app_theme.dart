import 'package:flutter/material.dart';

/// Dark-first theme configuration - Matching Figma design tokens
class AppTheme {
  // Background Colors
  static const Color backgroundPrimary = Color(0xFF0F0F0F); // --background-primary
  static const Color backgroundSecondary = Color(0xFF1A1A1A); // --background-secondary
  static const Color backgroundTertiary = Color(0xFF121212); // --background-tertiary
  static const Color backgroundQuaternary = Color(0xFF151515); // --background-quaternary
  static const Color backgroundHover = Color(0xFF202020); // --background-hover
  
  // Accent Colors
  static const Color accentPrimary = Color(0xFF059669); // --accent-primary
  static const Color accentHover = Color(0xFF047857); // --accent-hover
  static const Color accentDark = Color(0xFF065F46); // --accent-dark
  static const Color accentLight = Color(0xFF10B981); // --accent-light
  static const Color accentSubtle = Color.fromRGBO(5, 150, 105, 0.1); // --accent-subtle
  
  // Text Colors
  static const Color textPrimary = Color(0xFFFFFFFF); // --text-primary
  static const Color textSecondary = Color(0xFF71717A); // --text-secondary
  static const Color textTertiary = Color(0xFF52525B); // --text-tertiary
  static const Color textQuaternary = Color(0xFF3F3F46); // --text-quaternary
  static const Color textDisabled = Color(0xFF27272A); // --text-disabled
  
  // Status Colors
  static const Color error = Color(0xFFDC2626); // --error
  static const Color success = Color(0xFF059669); // --success
  static const Color warning = Color(0xFFF59E0B); // --warning
  
  // Legacy aliases for backward compatibility
  static const Color nearBlack = backgroundPrimary;
  static const Color darkSurface = backgroundSecondary;
  static const Color darkSurfaceVariant = backgroundHover;
  static const Color accentColor = accentPrimary;
  static const Color accentColorDark = accentHover;
  static const Color errorColor = error;
  static const Color successColor = success;
  static const Color dividerColor = Color(0xFF3A3A3A);
  
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
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.zero, // --border-radius-none
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accentPrimary,
          foregroundColor: backgroundPrimary,
          elevation: 0,
          minimumSize: const Size(0, 48), // --button-height
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16), // --button-padding
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.zero, // --button-border-radius
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
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.zero, // --input-border-radius
          borderSide: BorderSide.none,
        ),
        enabledBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.zero, // --input-border-radius
          borderSide: BorderSide.none,
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.zero, // --input-border-radius
          borderSide: BorderSide(color: accentPrimary, width: 2),
        ),
        errorBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.zero, // --input-border-radius
          borderSide: BorderSide(color: error, width: 1),
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
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.zero, // --border-radius-none
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
          borderRadius: BorderRadius.zero, // --border-radius-none
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: backgroundHover,
        contentTextStyle: const TextStyle(
          color: textPrimary,
          fontSize: 14, // --font-size-base
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.zero, // --border-radius-none
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

