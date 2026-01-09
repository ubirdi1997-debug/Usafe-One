import 'package:flutter/material.dart';

/// App constants
class AppConstants {
  // Animation durations
  static const Duration fastTransition = Duration(milliseconds: 150);
  static const Duration normalTransition = Duration(milliseconds: 300);
  
  // TOTP defaults
  static const int defaultDigits = 6;
  static const int defaultPeriod = 30;
  
  // UI constants
  static const double tileBorderRadius = 12.0;
  static const double fabSize = 56.0;
  static const double expandedFabSize = 48.0;
  static const double expandedFabSpacing = 16.0;
  
  // Padding
  static const EdgeInsets screenPadding = EdgeInsets.all(16.0);
  static const EdgeInsets tilePadding = EdgeInsets.all(16.0);
  
  // Spacing
  static const double spacingSmall = 8.0;
  static const double spacingMedium = 16.0;
  static const double spacingLarge = 24.0;
  
  const AppConstants._();
}

