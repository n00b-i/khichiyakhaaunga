import 'package:flutter/material.dart';

// ==============================================================================
// [ATOM] ComebakXpIcon
// ------------------------------------------------------------------------------
// PURPOSE: A semantic wrapper for the XP (Zap) icon.
// ARCHITECTURE: Previously this created a neon glow effect, but based on design
// feedback, it has been simplified to render a clean, solid filled icon.
// ==============================================================================
class ComebakXpIcon extends StatelessWidget {
  final IconData icon;
  final Color color;
  final double size;

  const ComebakXpIcon({
    super.key,
    required this.icon,
    required this.color,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    // [DESIGN] Simply renders the passed icon. 
    // If a filled icon (like Icons.bolt) is passed, it will render filled.
    return Icon(
      icon,
      color: color,
      size: size,
    );
  }
}