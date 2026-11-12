import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../1_foundations/tokens/ui_lab_tokens.dart';

class ComebakWordmark extends StatelessWidget {
  final int charCount;
  final double brightness;

  const ComebakWordmark({
    super.key,
    required this.charCount,
    required this.brightness,
  });

  @override
  Widget build(BuildContext context) {
    const word = 'comebak';
    final visibleText = word.substring(0, charCount.clamp(0, word.length));
    
    return ShaderMask(
      shaderCallback: (Rect bounds) {
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            ComebakColors.neonGreen,
            Colors.white,
          ],
        ).createShader(bounds);
      },
      child: CustomPaint(
        painter: _MicroLightningPainter(
          text: visibleText,
          totalChars: word.length,
          charCount: charCount,
          brightness: brightness,
        ),
        child: Text(
          visibleText,
          style: ComebakTypography.greeting.copyWith(
            fontSize: 78, // 1.5x size increase
            fontWeight: FontWeight.w800,
            letterSpacing: -2.0,
            color: Colors.white, 
            shadows: [
              Shadow(
                color: ComebakColors.neonGreen.withOpacity(0.5),
                blurRadius: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MicroLightningPainter extends CustomPainter {
  final String text;
  final int totalChars;
  final int charCount;
  final double brightness;

  _MicroLightningPainter({
    required this.text,
    required this.totalChars,
    required this.charCount,
    required this.brightness,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (charCount == 0 || charCount >= totalChars) return;

    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: ComebakTypography.greeting.copyWith(
          fontSize: 78, // Matching size
          fontWeight: FontWeight.w800,
          letterSpacing: -2.0,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    final boundaryX = tp.width;
    final boundaryY = size.height / 2;

    final rnd = math.Random(charCount);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0 // Thicker bolt for larger text
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = Colors.white.withOpacity(brightness)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);

    for (int i = 0; i < 3; i++) {
      final path = Path()..moveTo(boundaryX, boundaryY);
      final dx = (rnd.nextDouble() * 20 + 10) * (i.isEven ? 1 : -1);
      final dy = (rnd.nextDouble() * 30) - 15;
      
      path.lineTo(boundaryX + dx, boundaryY + dy);
      path.lineTo(boundaryX + dx + 5, boundaryY + dy + (rnd.nextDouble() * 20 - 10));
      
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _MicroLightningPainter old) => 
      old.charCount != charCount || old.brightness != brightness;
}