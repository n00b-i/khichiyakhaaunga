import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../models/board_paint_state.dart';
import '../models/bubble.dart';
import '../models/game_fx.dart';

class BubblePainter extends CustomPainter {
  // [ISSUE-1] The board state acts as a Listenable. When it calls notifyListeners(), 
  // the CustomPaint repaints without triggering a widget rebuild.
  final BoardPaintState? board;
  
  // Legacy fields kept temporarily for number_hunt_screen.dart so we don't break it.
  final List<Bubble>? bubbles;
  final List<FloatingText>? floatingTexts;
  final List<Particle>? particles;

  BubblePainter({
    this.board,
    this.bubbles,
    this.floatingTexts,
    this.particles,
  }) : super(repaint: board); // [ISSUE-1] Pass board to repaint to bypass build phase.

  @override
  void paint(Canvas canvas, Size size) {
    // Fallback to legacy lists if board is null (used by number_hunt)
    final activeBubbles = board?.bubbles ?? bubbles ?? [];
    final activeFloatingTexts = board?.floatingTexts ?? floatingTexts ?? [];
    final activeParticles = board?.particles ?? particles ?? [];

    final fillPaint = Paint();
    final borderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    for (final bubble in activeBubbles) {
      final rect = Rect.fromCircle(center: bubble.position, radius: bubble.radius);

      Color borderColor = AppColors.border;
      List<Color> gradientColors = [AppColors.surface, AppColors.background];

      if (bubble.isWrong) {
        borderColor = AppColors.vibrantRed;
        gradientColors = [AppColors.surface, AppColors.vibrantRed.withValues(alpha: 0.2)];
      } else if (bubble.isSelected) {
        borderColor = AppColors.primary;
        gradientColors = [AppColors.surface, AppColors.primary.withValues(alpha: 0.2)];
      }

      fillPaint.shader = RadialGradient(
        center: const Alignment(-0.3, -0.3),
        colors: gradientColors,
      ).createShader(rect);
      borderPaint.color = borderColor;

      canvas.drawCircle(bubble.position, bubble.radius, fillPaint);
      canvas.drawCircle(bubble.position, bubble.radius, borderPaint);

      final textPainter = TextPainter(
        text: TextSpan(
          text: bubble.value.toString(),
          style: AppTextStyles.hud.copyWith(fontSize: 28),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      textPainter.paint(canvas, bubble.position - Offset(textPainter.width / 2, textPainter.height / 2));
    }

    for (final p in activeParticles) {
      final paint = Paint()..color = p.color.withValues(alpha: p.opacity.clamp(0.0, 1.0));
      canvas.drawCircle(p.position, p.size, paint);
    }

    for (final t in activeFloatingTexts) {
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

      textPainter.paint(canvas, Offset(t.position.dx - textPainter.width / 2, t.position.dy + t.offsetY));
    }
  }

  @override
  // [ISSUE-1] We return false because repaints are driven purely by the BoardPaintState Listenable.
  // This prevents redundant repaints when the widget tree rebuilds for other reasons (e.g., countdown).
  bool shouldRepaint(covariant BubblePainter oldDelegate) => false;
}