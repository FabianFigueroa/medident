import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ─────────────────────────────────────────
//  APP THEME  —  Estilo Apple / iOS 17
//  Colores del sistema Apple Human Interface Guidelines
// ─────────────────────────────────────────

class AppColors {
  // Apple System Colors (iOS 17)
  static const Color blue       = Color(0xFF007AFF);
  static const Color green      = Color(0xFF34C759);
  static const Color indigo     = Color(0xFF5856D6);
  static const Color orange     = Color(0xFFFF9500);
  static const Color pink       = Color(0xFFFF2D55);
  static const Color purple     = Color(0xFFAF52DE);
  static const Color red        = Color(0xFFFF3B30);
  static const Color teal       = Color(0xFF5AC8FA);
  static const Color yellow     = Color(0xFFFFCC00);
  static const Color mint       = Color(0xFF00C7BE);

  // Apple Grays (Light mode)
  static const Color gray1      = Color(0xFF8E8E93);
  static const Color gray2      = Color(0xFFAEAEB2);
  static const Color gray3      = Color(0xFFC7C7CC);
  static const Color gray4      = Color(0xFFD1D1D6);
  static const Color gray5      = Color(0xFFE5E5EA);
  static const Color gray6      = Color(0xFFF2F2F7);

  // Backgrounds
  static const Color systemBackground        = Color(0xFFFFFFFF);
  static const Color secondarySystemBackground = Color(0xFFF2F2F7);
  static const Color tertiarySystemBackground = Color(0xFFFFFFFF);
  static const Color groupedBackground       = Color(0xFFF2F2F7);

  // Labels
  static const Color label          = Color(0xFF000000);
  static const Color secondaryLabel = Color(0xFF3C3C43); // 60% opacity
  static const Color tertiaryLabel  = Color(0xFF3C3C43); // 30% opacity
  static const Color quaternaryLabel= Color(0xFF3C3C43); // 18% opacity

  // Semantic fills
  static const Color separator      = Color(0x4A3C3C43);
  static const Color opaqueSeparator= Color(0xFFC6C6C8);

  // Status colors (backgrounds — usados en las tarjetas de citas)
  static const Color completedBg    = Color(0xFFE8F5EE);
  static const Color inProgressBg   = Color(0xFFFFF3E0);
  static const Color cancelledBg    = Color(0xFFFCE8E8);
  static const Color newApptBg      = Color(0xFFE8F0FF);
  static const Color confirmedBg    = Color(0xFFEEEEFF);
}

class AppTypography {
  // SF Pro equivalente con Google Fonts o system font
  static const String fontFamily = '.SF Pro Display';
  static const String fontFamilyText = '.SF Pro Text';

  // Large Title — 34pt Bold
  static const TextStyle largeTitle = TextStyle(
    fontSize: 34,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.37,
    color: AppColors.label,
    height: 1.2,
  );

  // Title 1 — 28pt Regular
  static const TextStyle title1 = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.36,
    color: AppColors.label,
  );

  // Title 2 — 22pt Regular
  static const TextStyle title2 = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.35,
    color: AppColors.label,
  );

  // Title 3 — 20pt Regular
  static const TextStyle title3 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.38,
    color: AppColors.label,
  );

  // Headline — 17pt SemiBold
  static const TextStyle headline = TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.41,
    color: AppColors.label,
  );

  // Body — 17pt Regular
  static const TextStyle body = TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.41,
    color: AppColors.label,
  );

  // Callout — 16pt Regular
  static const TextStyle callout = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.32,
    color: AppColors.label,
  );

  // Subheadline — 15pt Regular
  static const TextStyle subheadline = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.24,
    color: AppColors.label,
  );

  // Footnote — 13pt Regular
  static const TextStyle footnote = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.08,
    color: AppColors.secondaryLabel,
  );

  // Caption 1 — 12pt Regular
  static const TextStyle caption1 = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    color: AppColors.secondaryLabel,
  );

  // Caption 2 — 11pt Regular
  static const TextStyle caption2 = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.07,
    color: AppColors.tertiaryLabel,
  );
}

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      fontFamily: 'SF Pro Display',
      colorScheme: const ColorScheme.light(
        primary: AppColors.blue,
        secondary: AppColors.indigo,
        surface: AppColors.systemBackground,
        background: AppColors.groupedBackground,
        error: AppColors.red,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: AppColors.label,
        onBackground: AppColors.label,
        onError: Colors.white,
      ),
      scaffoldBackgroundColor: AppColors.groupedBackground,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarBrightness: Brightness.light,
          statusBarIconBrightness: Brightness.dark,
        ),
        titleTextStyle: TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.41,
          color: AppColors.label,
        ),
        iconTheme: IconThemeData(color: AppColors.blue),
      ),
      cardTheme: CardThemeData(
        color: AppColors.systemBackground,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(color: AppColors.separator, width: 0.5),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────
//  SPACINGS  (en línea con Apple 8pt grid)
// ─────────────────────────────────────────
class AppSpacing {
  static const double xs  = 4.0;
  static const double sm  = 8.0;
  static const double md  = 12.0;
  static const double lg  = 16.0;
  static const double xl  = 20.0;
  static const double xxl = 24.0;
  static const double xxxl= 32.0;
}

// ─────────────────────────────────────────
//  BORDER RADIUS
// ─────────────────────────────────────────
class AppRadius {
  static const double xs   = 6.0;
  static const double sm   = 10.0;
  static const double md   = 14.0;
  static const double lg   = 18.0;
  static const double xl   = 22.0;
  static const double xxl  = 28.0;
  static const double pill = 999.0;
}
