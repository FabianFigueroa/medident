import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary Colors
  static const Color primary = Color(0xFF29ABD8);      // Main Brand Blue (Cyan-like)
  static const Color primaryLight = Color(0xFFB2EBF2); // Soft, light version of primary
  static const Color primaryDark = Color(0xFF00567A);
  static const Color purpleColor = Color(0xFF3D068C);

  // Secondary Colors
  static const Color secondary = Color(0xFFEF233C);      // Vibrant Red
  static const Color secondaryLight = Color(0xFFFFB3C1); // Light Pink
  static const Color secondaryDark = Color(0xFFD90429);  // Dark Red

  // Accent Colors
  static const Color accent = Color(0xFFFFB700);         // Golden Yellow
  static const Color accentLight = Color(0xFFFFC947);    // Light Yellow
  static const Color accentDark = Color(0xFFFF8500);     // Orange

  // Neutral Colors
  static const Color white = Color(0xFFFFFFFF);
  static const Color whiteLigthColor = Color(0xFFF8F4F4); // A very light off-white
  static const Color black = Color(0xFF202124);          // Soft black (dark grey) for text/elements
  static const Color grey50 = Color(0xFFF8F9FA);
  static const Color grey100 = Color(0xFFF1F3F4);
  static const Color grey200 = Color(0xFFE8EAED);
  static const Color grey300 = Color(0xFFDADCE0);
  static const Color grey400 = Color(0xFFBDC1C6);
  static const Color grey500 = Color(0xFF9AA0A6);
  static const Color grey600 = Color(0xFF80868B);
  static const Color grey700 = Color(0xFF5F6368);
  static const Color greyBottomColor = Color(0xFF5F6368);
  static const Color grey800 = Color(0xFF3C4043);
  static const Color grey900 = Color(0xFF202124);          // Deepest grey, same as 'black'
  // Semantic Colors
  static const Color success = Color(0xFF34A853);
  static const Color positive = Color(0xFF34A853);
  static const Color warning = Color(0xFFFBBC04);
  static const Color error = Color(0xFFEA4335);
  static const Color info = Color(0xFF4285F4);           // Standard Blue for informational cues
  static const Color tealColor = Color(0xFF04A597);
  static const Color tealLightColor = Color(0xFF13C6B7);
  static const Color tealMiddleColor = Color(0xFF038A7E);
  static const Color tealDarkColor = Color(0xFF026C63);
  // Background Colors
  static const Color background = Color(0xFFFAFAFA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF5F5F5);

  // Text Colors (Using neutrals for better control)
  static const Color textPrimary = black;
  static const Color textSecondary = grey700;
  static const Color textDisabled = grey500;
  static const Color textOnPrimary = white;
  static const Color textOnSecondary = white;
  static const Color blackLight = grey800; // Adding a lighter black for specific use cases

  // Border Colors
  static const Color border = grey200;
  static const Color borderDark = grey300;

  // Shadow Colors
  static const Color shadow = Color(0x1A000000);
  static const Color shadowDark = Color(0x33000000);

  //////////////////// linear gradients
  static const LinearGradient blueGradientColor = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [AppColors.primary, AppColors.primaryDark],
  );

  static const LinearGradient blueDarkGradientColor = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Colors.transparent, Colors.black26],
  );
}
