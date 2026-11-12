import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../1_foundations/tokens/ui_lab_tokens.dart';

class ComebakWordmark extends StatelessWidget {
  final int charCount;
  final double brightness;
  final double time;
  final bool enableSparks;

  const ComebakWordmark({
    super.key,
    required this.charCount,
    required this.brightness,
    required this.time,
    this.enableSparks = true,
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
          enableSparks: enableSparks,
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
  final bool enableSparks;

  _WordmarkPainter({
    required this.charCount,
    required this.brightness,
    required this.fontSize,
    required this.time,
    required this.enableSparks,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const fullWord = 'comebak';
    final visibleText = fullWord.substring(
      0,
      charCount.clamp(0, fullWord.length),
    );

    final textStyle = ComebakTypography.greeting.copyWith(
      fontSize: fontSize,
      fontWeight: FontWeight.w800,
      letterSpacing: -1.5,
      color: Colors.white,
    );

    // REMOVED the Shadow array here to kill the glow on the Login screen
    final tp = TextPainter(
      text: TextSpan(text: visibleText, style: textStyle),
      textDirection: TextDirection.ltr,
    )..layout();

    final angle = time * 0.5;
    final gradient = LinearGradient(
      begin: Alignment(math.cos(angle), math.sin(angle)),
      end: Alignment(-math.cos(angle), -math.sin(angle)),
      colors: const [Colors.white, ComebakColors.neonGreen, Colors.white],
    ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.saveLayer(Rect.fromLTWH(0, 0, size.width, size.height), Paint());
    tp.paint(canvas, Offset.zero);
    canvas.drawRect(
      Rect.fromLTWH(0, 0, tp.width, size.height),
      Paint()
        ..blendMode = BlendMode.srcIn
        ..shader = gradient,
    );
    canvas.restore();

    if (enableSparks) {
      // Splash screen spark logic would go here if re-enabled
    }
  }

  @override
  bool shouldRepaint(covariant _WordmarkPainter old) =>
      old.charCount != charCount ||
      old.brightness != brightness ||
      old.time != time ||
      old.enableSparks != enableSparks;
}
