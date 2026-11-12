import 'package:flutter/material.dart';
import '../../../1_foundations/tokens/ui_lab_tokens.dart';

class ComebakRuleLine extends StatelessWidget {
  final String line;
  final double progress; // 0.0 to 1.0 (Opacity)
  final double fontSize;

  const ComebakRuleLine({
    super.key,
    required this.line,
    required this.progress,
    this.fontSize = 30,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: progress.clamp(0.0, 1.0),
      child: Text(
        line,
        style: ComebakTypography.greeting.copyWith(
          fontSize: fontSize,
          height: 1.05, // Slightly taller for smooth multi-line
          color: Colors.white,
          fontWeight: FontWeight.w800,
          shadows: [
            Shadow(
              color: ComebakColors.canvas,
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
            Shadow(
              color: ComebakColors.neonGreen.withOpacity(0.3),
              blurRadius: 20,
            ),
          ],
        ),
      ),
    );
  }
}