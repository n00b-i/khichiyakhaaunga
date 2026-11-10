import 'package:flutter/material.dart';

// [PHASE 2: TOKEN LOCK]
// Single source of truth for all design tokens.
// Legacy aliases are kept here so existing screens compile while we refactor.

class AppSpacing {
  AppSpacing._();
  // New 8pt grid
  static const double space2 = 2;
  static const double space4 = 4;
  static const double space8 = 8;
  static const double space12 = 12;
  static const double space16 = 16;
  static const double space20 = 20;
  static const double space24 = 24;
  static const double space32 = 32;
  static const double space40 = 40;
  static const double space48 = 48;

  // Legacy aliases
  static const double xxs = space4;
  static const double xs = space8;
  static const double sm = space12;
  static const double md = space16;
  static const double lg = space24;
  static const double xl = space32;
}

class AppColors {
  AppColors._();
  
  // New contract tokens
  static const Color canvas = Color(0xFF0B0F19);
  static const Color surfaceElevated = Color(0xFF1A1D27);
  static const Color surfaceOverlay = Color(0xFF232734);
  static const Color borderSubtle = Color(0xFF2A2D3A);
  static const Color textPrimary = Color(0xFFF5F5F5);
  static const Color textSecondary = Color(0xFFA0A0A0);
  static const Color textMuted = Color(0xFF6B7280);
  static const Color primaryAccent = Color(0xFF00B386);
  static const Color onPrimary = Color(0xFF0B0F19);
  static const Color primaryPressed = Color(0xFF009973);
  static const Color primaryDisabled = Color(0xFF1A5C4A);
  static const Color danger = Color(0xFFFF4D4D);
  static const Color dangerPressed = Color(0xFFCC3D3D);
  static const Color success = Color(0xFF34D399);
  static const Color warning = Color(0xFFFBBF24);
  static const Color info = Color(0xFF60A5FA);

  // Legacy aliases
  static const Color background = canvas;
  static const Color surface = surfaceElevated;
  static const Color border = borderSubtle;
  static const Color primary = primaryAccent;
  static const Color vibrantRed = danger;
  static const Color vibrantGreen = success;
  static const Color vibrantOrange = warning;
  static const Color vibrantBlue = info;
  static const Color vibrantPurple = Color(0xFFB388FF);
  static const Color vibrantYellow = Color(0xFFFFD600);
  static const Color vibrantPink = Color(0xFFFF4081);
  static const Color saitanGrid = Color(0xFF0A0A0A);
}

class AppSizes {
  AppSizes._();
  static const double iconSm = 24;
  static const double iconMd = 32;
  static const double iconLg = 48;
  static const double avatar = 64;
  static const double islandHeight = 64;
  static const double tabIcon = 24;
}

class AppRadius {
  AppRadius._();
  static const double radiusSmall = 8;
  static const double radiusMedium = 14;
  static const double radiusLarge = 20;
  
  // Legacy aliases
  static const double card = radiusMedium;
  static const double sheet = radiusLarge;
  static const double pill = 999;
}

class AppTextStyles {
  AppTextStyles._();
  static const String fontFamily = 'Inter';

  static const TextStyle display = TextStyle(
    fontFamily: fontFamily, fontSize: 34, fontWeight: FontWeight.w600, height: 1.2, color: AppColors.textPrimary,
  );
  static const TextStyle titleLarge = TextStyle(
    fontFamily: fontFamily, fontSize: 22, fontWeight: FontWeight.w600, height: 1.3, color: AppColors.textPrimary,
  );
  static const TextStyle titleMedium = TextStyle(
    fontFamily: fontFamily, fontSize: 18, fontWeight: FontWeight.w600, height: 1.3, color: AppColors.textPrimary,
  );
  static const TextStyle hud = TextStyle(
    fontFamily: fontFamily, fontSize: 32, fontWeight: FontWeight.w700, color: AppColors.textPrimary, fontFeatures: [FontFeature.tabularFigures()],
  );
  static const TextStyle body = TextStyle(
    fontFamily: fontFamily, fontSize: 16, fontWeight: FontWeight.w400, height: 1.5, color: AppColors.textPrimary,
  );
  static const TextStyle bodyMedium = TextStyle(
    fontFamily: fontFamily, fontSize: 14, fontWeight: FontWeight.w400, height: 1.5, color: AppColors.textSecondary,
  );
  static const TextStyle labelSmall = TextStyle(
    fontFamily: fontFamily, fontSize: 12, fontWeight: FontWeight.w600, height: 1.2, letterSpacing: 1.2, color: AppColors.textMuted,
  );
}

class AppMotion {
  AppMotion._();
  
  // New tokens
  static const Duration durationFast = Duration(milliseconds: 100);
  static const Duration durationNormal = Duration(milliseconds: 250);
  static const Duration durationSlow = Duration(milliseconds: 400);
  static const Duration durationCelebration = Duration(milliseconds: 1200);

  static const Curve curvePress = Curves.easeOutCubic;
  static const Curve curveEnter = Curves.easeOutBack;
  static const Curve curveProgress = Curves.easeOutExpo;

  // Legacy aliases for compilation bridge
  static const int correctMs = 180;
  static const int wrongMs = 80;
  static const int transitionMinMs = 180;
  static const int transitionMaxMs = 220;
  static const Curve curve = Curves.easeOut;
}
