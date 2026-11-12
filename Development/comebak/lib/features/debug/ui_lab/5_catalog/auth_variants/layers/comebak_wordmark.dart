import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../1_foundations/tokens/ui_lab_tokens.dart';

class ComebakWordmark extends StatelessWidget {
  final int charCount;
  final double brightness;
  final double time;

  const ComebakWordmark({
    super.key,
    required this.charCount,
    required this.brightness,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    final tp = TextPainter(
      text: TextSpan(
        text: 'comebak',
        style: ComebakTypography.greeting.copyWith(
          fontSize: 62,
          fontWeight: FontWeight.w800,
          letterSpacing: -1.5,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    return SizedBox(
      width: tp.width,
      height: tp.height,
      child: CustomPaint(
        painter: _WordmarkPainter(
          charCount: charCount,
          brightness: brightness,
          fontSize: 62,
          time: time,
        ),
      ),
    );
  }
}

class _WordmarkPainter extends CustomPainter {
  final int charCount;
  final double brightness;
  final double fontSize;
  final double time;

  _WordmarkPainter({
    required this.charCount,
    required this.brightness,
    required this.fontSize,
    required this.time,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const fullWord = 'comebak';
    final visibleText = fullWord.substring(0, charCount.clamp(0, fullWord.length));
    
    final textStyle = ComebakTypography.greeting.copyWith(
      fontSize: fontSize,
      fontWeight: FontWeight.w800,
      letterSpacing: -1.5,
      color: Colors.white,
    );

    final tp = TextPainter(
      text: TextSpan(
        text: visibleText,
        style: textStyle.copyWith(
          shadows: [
            Shadow(color: ComebakColors.neonGreen.withOpacity(0.5), blurRadius: 24),
          ],
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    final gradient = const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Colors.white, ComebakColors.neonGreen, Colors.white],
    ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.saveLayer(Rect.fromLTWH(0, 0, size.width, size.height), Paint());
    tp.paint(canvas, Offset.zero);
    canvas.drawRect(
      Rect.fromLTWH(0, 0, tp.width, size.height),
      Paint()..blendMode = BlendMode.srcIn..shader = gradient,
    );
    canvas.restore();

    final frameSeed = (time * 20).floor();
    final rnd = math.Random(frameSeed);

    if (charCount > 0 && charCount < fullWord.length) {
      _drawWeldingSparks(canvas, tp.width, size.height / 2, rnd);
    } else if (charCount == fullWord.length && brightness > 0.5) {
      _drawCharacterTendrils(canvas, size, rnd);
    }
  }

  void _drawWeldingSparks(Canvas canvas, double x, double y, math.Random rnd) {
    for (int i = 0; i < 3; i++) {
      final start = Offset(x, y + (rnd.nextDouble() * 10 - 5));
      final end = Offset(
        x + (rnd.nextDouble() * 15 + 5) * (i.isEven ? 1 : -1),
        y + (rnd.nextDouble() * 20 - 10),
      );
      _drawTaperedSpark(canvas, start, end, rnd, Colors.white, 1.2);
    }
  }

  void _drawCharacterTendrils(Canvas canvas, Size size, math.Random rnd) {
    // Pick 2 random characters per frame to spark from
    for (int i = 0; i < 2; i++) {
      final charIndex = rnd.nextInt(7);
      
      // Calculate exact X coordinate of the character
      final charTp = TextPainter(
        text: TextSpan(
          text: 'comebak'.substring(0, charIndex + 1),
          style: ComebakTypography.greeting.copyWith(
            fontSize: fontSize,
            fontWeight: FontWeight.w800,
            letterSpacing: -1.5,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      
      final startX = charTp.width - (charTp.width / (charIndex + 1)) / 2;
      final startY = rnd.nextDouble() > 0.5 ? 0.0 : size.height;
      
      // Short, tight sparks
      final endX = startX + (rnd.nextDouble() * 15 - 7.5);
      final endY = startY + (rnd.nextDouble() > 0.5 ? -1 : 1) * (rnd.nextDouble() * 15 + 5);

      _drawTaperedSpark(
        canvas, 
        Offset(startX, startY), 
        Offset(endX, endY), 
        rnd, 
        ComebakColors.neonGreen, 
        1.0,
      );
    }
  }

  void _drawTaperedSpark(Canvas canvas, Offset start, Offset end, math.Random rnd, Color color, double baseWidth) {
    final path = Path()..moveTo(start.dx, start.dy);
    final mid1X = start.dx + (end.dx - start.dx) * 0.33 + (rnd.nextDouble() * 6 - 3);
    final mid1Y = start.dy + (end.dy - start.dy) * 0.33 + (rnd.nextDouble() * 6 - 3);
    path.lineTo(mid1X, mid1Y);
    path.lineTo(end.dx, end.dy);

    canvas.drawPath(path, Paint()..style = PaintingStyle.stroke..strokeWidth = baseWidth * 3..strokeCap = StrokeCap.round..color = color.withOpacity(0.2)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3));
    canvas.drawPath(path, Paint()..style = PaintingStyle.stroke..strokeWidth = baseWidth..strokeCap = StrokeCap.round..color = color);
    canvas.drawCircle(end, baseWidth * 0.8, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(covariant _WordmarkPainter old) => 
      old.charCount != charCount || old.brightness != brightness || old.time != time;
}