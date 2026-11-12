import 'package:flutter/material.dart';

class UiLabColors {
  UiLabColors._();

  // [ARCHITECTURE] Tinted dark canvas (#0B0F19) instead of pure black.
  // Pure black causes text halation (bleeding) for astigmatic users. 
  // A deep blue-black reduces eye strain during long gaming sessions.
  static const Color canvas = Color(0xFF0B0F19);
  
  // [ARCHITECTURE] Elevated surface for cards, separated from the canvas.
  static const Color surface = Color(0xFF151A27);
  static const Color surfaceElevated = Color(0xFF1E2538);
  static const Color border = Color(0xFF2C3549);
  
  // [UX] High contrast for primary text, muted for secondary to establish hierarchy.
  static const Color textPrimary = Color(0xFFF5F5F5);
  static const Color textSecondary = Color(0xFF8A94A6);

  // [DESIGN] Neon palette used to differentiate game categories via 
  // the Von Restorff Effect (distinctive colors are more memorable).
  static const Color neonGreen = Color(0xFF00E676);
  static const Color neonOrange = Color(0xFFFF9800);
  static const Color neonPurple = Color(0xFFB388FF);
  static const Color neonBlue = Color(0xFF00E5FF);
  static const Color neonYellow = Color(0xFFFFD600);
  static const Color vibrantPink = Color(0xFFFF4081);

   // [ADDED] Missing color for error/negative states
  static const Color vibrantRed = Color(0xFFFF5252);
}