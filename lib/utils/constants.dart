import 'package:flutter/material.dart';

/// App constants - Matching Figma design tokens
class AppConstants {
  // Animation durations
  static const Duration fastTransition = Duration(milliseconds: 150); // --transition-fast
  static const Duration normalTransition = Duration(milliseconds: 200); // --transition-normal
  static const Duration slowTransition = Duration(milliseconds: 300); // --transition-slow
  
  // TOTP defaults
  static const int defaultDigits = 6;
  static const int defaultPeriod = 30;
  
  // Border Radius
  static const double borderRadiusNone = 0.0; // --border-radius-none
  static const double borderRadiusSm = 4.0; // --border-radius-sm
  static const double borderRadiusMd = 8.0; // --border-radius-md
  static const double borderRadiusLg = 12.0; // --border-radius-lg
  static const double borderRadiusXl = 16.0; // --border-radius-xl
  static const double borderRadiusFull = 9999.0; // --border-radius-full
  
  // Screen Padding
  static const double screenPaddingX = 24.0; // --screen-padding-x
  static const double screenPaddingTop = 24.0; // --screen-padding-top
  static const double screenPaddingBottom = 16.0; // --screen-padding-bottom
  static const EdgeInsets screenPadding = EdgeInsets.fromLTRB(
    screenPaddingX,
    screenPaddingTop,
    screenPaddingX,
    screenPaddingBottom,
  );
  
  // Component Gaps
  static const double gapXs = 8.0; // --gap-xs
  static const double gapSm = 12.0; // --gap-sm
  static const double gapMd = 16.0; // --gap-md
  static const double gapLg = 24.0; // --gap-lg
  static const double gapXl = 32.0; // --gap-xl
  
  // Component Padding
  static const double paddingXs = 8.0; // --padding-xs
  static const double paddingSm = 12.0; // --padding-sm
  static const double paddingMd = 16.0; // --padding-md
  static const double paddingLg = 24.0; // --padding-lg
  static const double paddingXl = 32.0; // --padding-xl
  
  // Tile/Card Padding
  static const double tilePadding = 16.0; // --tile-padding
  static const double cardPadding = 24.0; // --card-padding
  static const EdgeInsets tilePaddingInsets = EdgeInsets.all(tilePadding);
  
  // Button
  static const double buttonHeight = 48.0; // --button-height
  static const double buttonPaddingX = 16.0; // --button-padding-x
  static const double buttonPaddingY = 16.0; // --button-padding-y
  static const double buttonFontSize = 15.0; // --button-font-size
  static const double buttonBorderRadius = 0.0; // --button-border-radius
  
  // FAB
  static const double fabSize = 56.0; // --fab-size
  static const double fabPositionBottom = 24.0; // --fab-position-bottom
  static const double fabPositionRight = 24.0; // --fab-position-right
  static const double fabBorderRadius = 0.0; // --fab-border-radius
  static const double fabIconSize = 24.0; // --fab-icon-size
  static const double expandedFabSize = 48.0;
  static const double expandedFabSpacing = 12.0; // --gap-sm
  
  // Authenticator Tile
  static const double tileBorderRadius = 0.0; // --tile-border-radius
  static const double tileGap = 12.0; // --tile-gap
  static const double tileIconSize = 24.0; // --tile-icon-size
  static const double tileCodeSize = 32.0; // --tile-code-size
  static const double tileCountdownHeight = 2.0; // --tile-countdown-height
  
  // Input Fields
  static const double inputPaddingX = 16.0; // --input-padding-x
  static const double inputPaddingY = 12.0; // --input-padding-y
  static const double inputBorderRadius = 0.0; // --input-border-radius
  static const double inputFontSize = 15.0; // --input-font-size
  
  // Countdown Bar
  static const double countdownHeight = 2.0; // --countdown-height
  
  // Grid Layout
  static const int gridColumns = 2; // --grid-columns
  static const double gridGap = 16.0; // --grid-gap
  static const double gridItemPadding = 24.0; // --grid-item-padding
  
  // Typography - Font Sizes
  static const double fontSizeXs = 12.0; // --font-size-xs
  static const double fontSizeSm = 13.0; // --font-size-sm
  static const double fontSizeBase = 14.0; // --font-size-base
  static const double fontSizeMd = 15.0; // --font-size-md
  static const double fontSizeLg = 16.0; // --font-size-lg
  static const double fontSizeXl = 20.0; // --font-size-xl
  static const double fontSize2xl = 24.0; // --font-size-2xl
  static const double fontSize3xl = 32.0; // --font-size-3xl
  static const double fontSize4xl = 48.0; // --font-size-4xl
  
  // Typography - Font Weights
  static const FontWeight fontWeightLight = FontWeight.w300; // --font-weight-light
  static const FontWeight fontWeightNormal = FontWeight.w400; // --font-weight-normal
  static const FontWeight fontWeightMedium = FontWeight.w500; // --font-weight-medium
  static const FontWeight fontWeightSemibold = FontWeight.w600; // --font-weight-semibold
  static const FontWeight fontWeightBold = FontWeight.w700; // --font-weight-bold
  
  // Legacy spacing aliases
  static const double spacingSmall = gapXs;
  static const double spacingMedium = gapMd;
  static const double spacingLarge = gapLg;
  
  const AppConstants._();
}

