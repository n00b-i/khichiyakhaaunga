import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
  static const Color transparent = Color(0x00000000);
  static const Color mutedGreen = Color(0xFF2E7D32);
  static const Color mutedRed = Color(0xFFC62828);

  // Flame
  static const Color flameYellow = Color(0xFFFFD600);
  static const Color flameOrange = Color(0xFFFF9800);
  static const Color flameRed = Color(0xFFFF5252);
  static const Color flameShadow = Color(0xFFFF3D00);

  // Add Burst
  static const Color addTopStart = Color(0xFFFFCA28);
  static const Color addTopEnd = Color(0xFFFFA000);
  static const Color addLeftStart = Color(0xFFFF9800);
  static const Color addLeftEnd = Color(0xFFE65100);
  static const Color addRightStart = Color(0xFFD84315);
  static const Color addRightEnd = Color(0xFFBF360C);
  static const Color addBaseLeft = Color(0xFFBF360C);
  static const Color addBaseRight = Color(0xFF8C2A08);
  static const Color addTextDeep = Color(0xFF8C2A08);
  static const Color addTextMid = Color(0xFFE65100);

  // Mad Burst
  static const Color madTopStart = Color(0xFF69F0AE);
  static const Color madTopEnd = Color(0xFF00E676);
  static const Color madLeftStart = Color(0xFF00C853);
  static const Color madLeftEnd = Color(0xFF009624);
  static const Color madRightStart = Color(0xFF008D36);
  static const Color madRightEnd = Color(0xFF005E24);
  static const Color madBaseLeft = Color(0xFF005E24);
  static const Color madBaseRight = Color(0xFF003D16);
  static const Color madTextDeep = Color(0xFF003D16);
  static const Color madTextMid = Color(0xFF009624);

  // BODMAS
  static const Color bodmasTopStart = Color(0xFFD4C9FF);
  static const Color bodmasTopEnd = Color(0xFFA899FF);
  static const Color bodmasLeftStart = Color(0xFF8C7DF2);
  static const Color bodmasLeftEnd = Color(0xFF5E4BB5);
  static const Color bodmasRightStart = Color(0xFF4B3D99);
  static const Color bodmasRightEnd = Color(0xFF32286B);
  static const Color bodmasBaseLeft = Color(0xFF32286B);
  static const Color bodmasBaseRight = Color(0xFF1F1745);
  static const Color bodmasTextDeep = Color(0xFF1F1745);
  static const Color bodmasTextMid = Color(0xFF5E4BB5);

  // Small Burst
  static const Color smallTopStart = Color(0xFF80D8FF);
  static const Color smallTopEnd = Color(0xFF40C4FF);
  static const Color smallLeftStart = Color(0xFF0091EA);
  static const Color smallLeftEnd = Color(0xFF0066CC);
  static const Color smallRightStart = Color(0xFF005CB2);
  static const Color smallRightEnd = Color(0xFF003D7A);
  static const Color smallBaseLeft = Color(0xFF003D7A);
  static const Color smallBaseRight = Color(0xFF00284F);
  static const Color smallTextDeep = Color(0xFF00284F);
  static const Color smallTextMid = Color(0xFF0066CC);

  // Saitan
  static const Color saitanTopStart = Color(0xFFFF80AB);
  static const Color saitanTopEnd = Color(0xFFF50057);
  static const Color saitanLeftStart = Color(0xFFC51162);
  static const Color saitanLeftEnd = Color(0xFF880E4F);
  static const Color saitanRightStart = Color(0xFF4A148C);
  static const Color saitanRightEnd = Color(0xFF311B92);
  static const Color saitanBaseLeft = Color(0xFF311B92);
  static const Color saitanBaseRight = Color(0xFF1A0033);
  static const Color saitanTextDeep = Color(0xFF1A0033);
  static const Color saitanTextMid = Color(0xFF880E4F);
}

class ComebakLayout {
  ComebakLayout._();
  static const double spaceXs = 4.0;
  static const double spaceSm = 8.0;
  static const double spaceMd = 12.0;
  static const double spaceLg = 16.0;
  static const double spaceXl = 24.0;
  static const double spaceXxl = 32.0;
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
  static const double borderThin = 1.0;
  static const double borderThick = 1.2;
  static const double borderGradient = 1.5;
  static const double opacityLocked = 0.5;
  static const double opacityBorderAccent = 0.4;
  static const double opacityIconBg = 0.15;
  static const double opacityShadow = 0.2;
  static const double opacityGradientStart = 0.7;
  static const double opacityGradientEnd = 0.4;
  static const double opacityPressScale = 0.97;
  static const double opacityAvatarGlow = 0.15;
  static const Offset offsetIconSecondary = Offset(16, 12);
  static const Offset offsetIconPrimary = Offset(-6, -6);
  static const Offset offsetIconShadow = Offset(3, 4);
  static const Offset offsetBgGlow = Offset(150, -150);
  static const double buttonHeight = 48.0;
  static const double flameShadowBlur = 12.0;
  static const double gameIconSize = 80.0;
  static const double gameCardHeight = 180.0; 
  
  static const double isoCubeWidth = 70.0;
  static const double isoCubeHeight = 40.0;
  static const double isoCubeExtrusion = 30.0;
  static const double isoSmallCubeScale = 0.6;
  static const Offset isoSmallCubeOffset = Offset(45, 25);
  static const double isoEdgeSoftness = 8.0;
  static const double isoTextOffset = 4.0;

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