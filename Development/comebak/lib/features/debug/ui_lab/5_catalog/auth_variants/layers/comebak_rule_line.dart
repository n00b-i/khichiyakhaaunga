import 'package:flutter/material.dart';
import '../../../1_foundations/tokens/ui_lab_tokens.dart';

class ComebakRuleLine extends StatelessWidget {
  final String line;
  final int charCount;
  final double fontSize;

  const ComebakRuleLine({
    super.key,
    required this.line,
    required this.charCount,
    this.fontSize = 30,
  });

  @override
  Widget build(BuildContext context) {
    final visible = line.substring(0, charCount.clamp(0, line.length));
    final isTyping = charCount < line.length;

    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: visible,
            style: ComebakTypography.greeting.copyWith(
              fontSize: fontSize,
              height: 0.95,
              color: Colors.white, // Pure white for maximum contrast
              fontWeight: FontWeight.w800,
              shadows: [
                // 1. Dark canvas shadow to pop off the gradient
                Shadow(
                  color: ComebakColors.canvas,
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
                // 2. Neon green fog glow for aesthetic
                Shadow(
                  color: ComebakColors.neonGreen.withOpacity(0.3),
                  blurRadius: 20,
                ),
              ],
            ),
          ),
          if (isTyping)
            TextSpan(
              text: '▎',
              style: ComebakTypography.greeting.copyWith(
                fontSize: fontSize,
                height: 0.95,
                color: ComebakColors.neonGreen,
                fontWeight: FontWeight.w300,
              ),
            ),
        ],
      ),
    );
  }
}