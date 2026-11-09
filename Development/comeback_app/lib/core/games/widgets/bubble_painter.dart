import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../models/bubble.dart';
import '../models/game_fx.dart';

class BubblePainter extends CustomPainter {
  final List<Bubble> bubbles;
  final List<FloatingText> floatingTexts;
  final List<Particle> particles;

  BubblePainter({
    required this.bubbles,
    required this.floatingTexts,
    required this.particles,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Draw Bubbles
    for (var bubble in bubbles) {
      final rect = Rect.fromCircle(center: bubble.position, radius: bubble.radius);
      
      // Determine colors based on state
      Color borderColor = AppColors.border;
      List<Color> gradientColors = [
        AppColors.surface,
        AppColors.background,
      ];

      if (bubble.isWrong) {
        borderColor = AppColors.vibrantRed;
        gradientColors = [AppColors.surface, AppColors.vibrantRed.withValues(alpha: 0.2)];
      } else if (bubble.isSelected) {
        borderColor = AppColors.primary;
        gradientColors = [AppColors.surface, AppColors.primary.withValues(alpha: 0.2)];
      }

      // Glassmorphism gradient
      final fillPaint = Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.3, -0.3), // 3D highlight effect
          colors: gradientColors,
        ).createShader(rect);

      final borderPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0
        ..color = borderColor;

      canvas.drawCircle(bubble.position, bubble.radius, fillPaint);
      canvas.drawCircle(bubble.position, bubble.radius, borderPaint);

      // Draw Text
      final textPainter = TextPainter(
        text: TextSpan(
          text: bubble.value.toString(),
          style: AppTextStyles.hud.copyWith(fontSize: 28),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      
      textPainter.paint(
        canvas,
        bubble.position - Offset(textPainter.width / 2, textPainter.height / 2),
      );
    }

    // 2. Draw Particles
    for (var p in particles) {
      final paint = Paint()..color = p.color.withValues(alpha: p.opacity.clamp(0.0, 1.0));
      canvas.drawCircle(p.position, p.size, paint);
    }

    // 3. Draw Floating Text
    for (var t in floatingTexts) {
      final textPainter = TextPainter(
        text: TextSpan(
          text: t.text,
          style: AppTextStyles.hud.copyWith(
            fontSize: 24,
            color: t.color.withValues(alpha: t.opacity.clamp(0.0, 1.0)),
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      textPainter.paint(
        canvas,
        Offset(t.position.dx - textPainter.width / 2, t.position.dy + t.offsetY),
      );
    }
  }

  @override
  bool shouldRepaint(covariant BubblePainter oldDelegate) => true;
}