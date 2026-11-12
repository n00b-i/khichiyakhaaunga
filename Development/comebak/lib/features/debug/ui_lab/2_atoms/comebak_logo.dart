import 'package:flutter/material.dart';
import '../1_foundations/tokens/ui_lab_tokens.dart';

// [ATOM] The core brand logo. Echo Loop representing resilience.
// [DRY RULE] CustomPaint for zero asset weight. All math derived from ComebakLayout.
class ComebakLogo extends StatelessWidget {
  const ComebakLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: ComebakLayout.logoSize,
      height: ComebakLayout.logoSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: ComebakColors.neonGreen.withValues(alpha: ComebakLayout.opacityIconBg),
      ),
      child: CustomPaint(
        painter: _EchoLoopPainter(),
      ),
    );
  }
}

class _EchoLoopPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // [RULE 1] Zero hardcoded widths or blurs.
    final glowPaint = Paint()
      ..color = ComebakColors.neonGreen
      ..strokeWidth = ComebakLayout.logoStrokeGlowWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(
        BlurStyle.normal, 
        ComebakLayout.logoBlurRadius
      ); 

    final solidPaint = Paint()
      ..color = ComebakColors.neonGreen
      ..strokeWidth = ComebakLayout.logoStrokeSolidWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // [RULE 1] Path math uses tokens to remain responsive.
    final path = Path();
    path.moveTo(size.width * ComebakLayout.logoStartX, size.height * ComebakLayout.logoStartY);
    path.quadraticBezierTo(
      size.width * ComebakLayout.logoCp1X, size.height * ComebakLayout.logoCp1Y, 
      size.width * ComebakLayout.logoCp2X, size.height * ComebakLayout.logoCp2Y
    );
    path.quadraticBezierTo(
      size.width * ComebakLayout.logoCp3X, size.height * ComebakLayout.logoCp3Y, 
      size.width * ComebakLayout.logoCp4X, size.height * ComebakLayout.logoCp4Y
    );

    canvas.drawPath(path, glowPaint);
    canvas.drawPath(path, solidPaint);
    
    canvas.drawCircle(
      Offset(size.width * ComebakLayout.logoDotX, size.height * ComebakLayout.logoDotY), 
      ComebakLayout.logoDotGlowRadius, 
      glowPaint
    );
    canvas.drawCircle(
      Offset(size.width * ComebakLayout.logoDotX, size.height * ComebakLayout.logoDotY), 
      ComebakLayout.logoDotSolidRadius, 
      solidPaint..style = PaintingStyle.fill
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}