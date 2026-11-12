import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// [ARCHITECTURE] The Single Source of Truth for all design values.
// [RULE 1 & 2] No hardcoded numbers. Grouped logically.
class ComebakColors {
  ComebakColors._();
  static const Color canvas = Color(0xFF0B0F19);
  static const Color surface = Color(0xFF151A27);
  static const Color surfaceElevated = Color(0xFF1E2538);
  static const Color border = Color(0xFF2C3549);
  
  static const Color textPrimary = Color(0xFFF5F5F5);
  static const Color textSecondary = Color(0xFF8A94A6);

  static const Color neonGreen = Color(0xFF00E676);
  static const Color neonOrange = Color(0xFFFF9800);
  static const Color neonPurple = Color(0xFFB388FF);
  static const Color neonBlue = Color(0xFF00E5FF);
  static const Color neonYellow = Color(0xFFFFD600);
  static const Color vibrantRed = Color(0xFFFF5252);
  static const Color vibrantPink = Color(0xFFFF4081);
  static const Color pureWhite = Color(0xFFFFFFFF);
  static const Color flameYellow = Color(0xFFFFD600);
  static const Color flameOrange = Color(0xFFFF9800);
  static const Color flameRed = Color(0xFFFF5252);
  static const Color flameShadow = Color(0xFFFF3D00);
  static const Color transparent = Color(0x00000000);
}

class ComebakLayout {
  ComebakLayout._();
  
  // Spacing
  static const double spaceXs = 4.0;
  static const double spaceSm = 8.0;
  static const double spaceMd = 12.0;
  static const double spaceLg = 16.0;
  static const double spaceXl = 24.0;
  static const double spaceXxl = 32.0;

  // Sizes & Radii
  static const double radiusSm = 6.0;
  static const double radiusMd = 10.0;
  static const double radiusLg = 16.0;
  static const double radiusXl = 20.0;
  static const double radiusInner = 18.5;
  
  static const double iconBoxPrimary = 42.0;
  static const double iconBoxSecondary = 24.0;
  static const double cardIconContainer = 60.0;
  static const double avatarSize = 40.0;
  static const double logoSize = 32.0;
  static const double bgGlowSize = 400.0;

  // Borders & Dividers
  static const double borderThin = 1.0;
  static const double borderThick = 1.2;
  static const double borderGradient = 1.5;

  // Opacities
  static const double opacityLocked = 0.5;
  static const double opacityBorderAccent = 0.4;
  static const double opacityIconBg = 0.15;
  static const double opacityShadow = 0.2;
  static const double opacityGradientStart = 0.7;
  static const double opacityGradientEnd = 0.4;
  static const double opacityPressScale = 0.97;
  static const double opacityAvatarGlow = 0.15;

  // Offsets
  static const Offset offsetIconSecondary = Offset(16, 12);
  static const Offset offsetIconPrimary = Offset(-6, -6);
  static const Offset offsetIconShadow = Offset(3, 4);
  static const Offset offsetBgGlow = Offset(150, -150);

  // [RULE 1] Logo Geometry & Math (Strictly eliminates CustomPaint hardcoding)
  static const double iconRotationAngle = 0.2;
  static const double logoStartX = 0.2;
  static const double logoStartY = 0.7;
  static const double logoCp1X = 0.2;
  static const double logoCp1Y = 0.2;
  static const double logoCp2X = 0.8;
  static const double logoCp2Y = 0.2;
  static const double logoCp3X = 0.8;
  static const double logoCp3Y = 0.7;
  static const double logoCp4X = 0.4;
  static const double logoCp4Y = 0.8;
  static const double logoDotX = 0.4;
  static const double logoDotY = 0.8;
  static const double logoDotGlowRadius = 3.5;
  static const double logoDotSolidRadius = 2.0;
  static const double logoStrokeGlowWidth = 3.0;
  static const double logoStrokeSolidWidth = 2.0;
  static const double logoBlurRadius = 3.0;
  static const double neonGlowBlur = 6.0;
  static const double flameShadowBlur = 12.0;


}

class ComebakMotion {
  ComebakMotion._();
  static const Duration press = Duration(milliseconds: 100);
  static const Duration fade = Duration(milliseconds: 200);
  static const double blurRadius = 10.0;
}

class ComebakTypography {
  ComebakTypography._();
  static TextStyle get brand => GoogleFonts.urbanist(fontSize: 22, fontWeight: FontWeight.w800, color: ComebakColors.textPrimary);
  static TextStyle get greeting => GoogleFonts.urbanist(fontSize: 36, fontWeight: FontWeight.w800);
  static TextStyle get greetingSubtitle => GoogleFonts.urbanist(fontSize: 16, fontWeight: FontWeight.w600, color: ComebakColors.textSecondary);
  
  static TextStyle get titleLarge => GoogleFonts.urbanist(fontSize: 18, fontWeight: FontWeight.w700, color: ComebakColors.textPrimary);
  static TextStyle get titleMedium => GoogleFonts.urbanist(fontSize: 16, fontWeight: FontWeight.w700, color: ComebakColors.textPrimary);
  static TextStyle get bodyMedium => GoogleFonts.urbanist(fontSize: 13, fontWeight: FontWeight.w600, color: ComebakColors.textSecondary);
  static TextStyle get labelSmall => GoogleFonts.urbanist(fontSize: 12, fontWeight: FontWeight.w600, color: ComebakColors.neonGreen);
  
  static TextStyle get sectionTitle => GoogleFonts.urbanist(fontSize: 14, fontWeight: FontWeight.w800, color: ComebakColors.neonGreen, letterSpacing: 1.2);
  static TextStyle get sectionSubtitle => GoogleFonts.urbanist(fontSize: 12, fontWeight: FontWeight.w600, color: ComebakColors.textSecondary);
}