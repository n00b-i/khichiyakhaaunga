import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/tokens/ui_lab_colors.dart';

class UiLabSpacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 24.0;
  static const double xxl = 32.0;
}

class UiLabSizes {
  static const double iconCirclePadding = 10.0;
  static const double iconPrimaryBox = 42.0;
  static const double iconSecondaryBox = 24.0;
  static const double iconPrimaryRadius = 10.0;
  static const double iconSecondaryRadius = 6.0;
  
  static const double cardIconContainer = 60.0; 
  static const double iconPrimary = 24.0;
  static const double iconSecondary = 12.0;
  static const double lockIcon = 28.0;
  static const double dividerHeight = 40.0;
  static const double dividerWidth = 1.0;
  static const double borderThin = 1.0;
  static const double borderThick = 1.2;
  static const double cardGradientBorder = 1.5;
  
  // [HEADER & LOGO]
  static const double logoSize = 32.0;
  static const double avatarRadius = 20.0;
  static const double avatarIconSize = 20.0;
  static const double avatarGlowBlur = 12.0;
  static const double bgGlowSize = 400.0;
}

class UiLabRadii {
  static const double card = 16.0;
  static const double gameCard = 20.0;
  static const double gameCardInner = 18.5;
}

class UiLabDurations {
  static const Duration press = Duration(milliseconds: 100);
  static const Duration fade = Duration(milliseconds: 200);
}

class UiLabOpacities {
  static const double locked = 0.5;
  static const double borderAccent = 0.4;
  static const double iconBg = 0.15;
  static const double shadow = 0.2;
  static const double gradientStart = 0.7;
  static const double gradientEnd = 0.4;
  static const double pressScale = 0.97;
  static const double avatarGradientStart = 0.2;
  static const double avatarBorder = 0.3;
  static const double avatarGlow = 0.15;
}

class UiLabOffsets {
  static const Offset iconSecondary = Offset(16, 12);
  static const Offset iconPrimary = Offset(-6, -6);
  static const Offset iconShadow = Offset(3, 4);
  static const double iconSecondaryRotation = 0.2;
  static const double iconGlowBlur = 10.0;
  static const Offset bgGlowOffset = Offset(150, -150);
}

class UiLabLogo {
  static const double strokeGlowWidth = 3.0;
  static const double strokeSolidWidth = 2.0;
  static const double blurRadius = 3.0;
  
  static const double startX = 0.2;
  static const double startY = 0.7;
  static const double cp1X = 0.2;
  static const double cp1Y = 0.2;
  static const double cp2X = 0.8;
  static const double cp2Y = 0.2;
  static const double cp3X = 0.8;
  static const double cp3Y = 0.7;
  static const double cp4X = 0.4;
  static const double cp4Y = 0.8;
  
  static const double dotX = 0.4;
  static const double dotY = 0.8;
  static const double dotGlowRadius = 3.5;
  static const double dotSolidRadius = 2.0;
}

class UiLabTypography {
  static TextStyle get titleLarge => GoogleFonts.urbanist(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white);
  static TextStyle get titleMedium => GoogleFonts.urbanist(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white);
  static TextStyle get bodyMedium => GoogleFonts.urbanist(fontSize: 13, fontWeight: FontWeight.w600, color: UiLabColors.textSecondary);
  static TextStyle get labelSmall => GoogleFonts.urbanist(fontSize: 12, fontWeight: FontWeight.w600, color: UiLabColors.neonGreen);
  
  // [SCREEN TYPOGRAPHY]
  static TextStyle get brand => GoogleFonts.urbanist(fontSize: 22, fontWeight: FontWeight.w800, color: Colors.white);
  static TextStyle get greeting => GoogleFonts.urbanist(fontSize: 36, fontWeight: FontWeight.w800);
  static TextStyle get greetingSubtitle => GoogleFonts.urbanist(fontSize: 16, fontWeight: FontWeight.w600, color: UiLabColors.textSecondary);
  static TextStyle get sectionTitle => GoogleFonts.urbanist(fontSize: 14, fontWeight: FontWeight.w800, color: UiLabColors.neonGreen, letterSpacing: 1.2);
  static TextStyle get sectionSubtitle => GoogleFonts.urbanist(fontSize: 12, fontWeight: FontWeight.w600, color: UiLabColors.textSecondary);
}