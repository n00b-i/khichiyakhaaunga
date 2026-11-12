import 'package:flutter/material.dart';
import '../1_foundations/tokens/ui_lab_tokens.dart';

// ==============================================================================
// [ATOM] ComebakFlame3D
// ------------------------------------------------------------------------------
// PURPOSE: A custom-painted 3D flame matching the provided reference image.
// ARCHITECTURE: Uses layered Bezier curves to simulate 3D depth.
// Geometry is relative to size (0.0 to 1.0) and lives here, NOT in tokens.
// Colors and sizes are pulled strictly from tokens.
// ==============================================================================
class ComebakFlame3D extends StatelessWidget {
  final double size;
  
  const ComebakFlame3D({super.key, required this.size});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _FlamePainter(),
      ),
    );
  }
}

class _FlamePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // [LAYER 1: DEEP SHADOW] Red/Orange glow at the base
    final shadowPaint = Paint()
      ..color = ComebakColors.flameShadow.withValues(alpha: 0.5)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, ComebakLayout.flameShadowBlur);
      
    final outerPath = _createOuterFlame(size);
    canvas.drawPath(outerPath, shadowPaint);

    // [LAYER 2: OUTER FLAME] Bright yellow to orange gradient
    final outerGradientPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          ComebakColors.flameYellow,
          ComebakColors.flameOrange,
          ComebakColors.flameRed,
        ],
        stops: [0.0, 0.6, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
      
    canvas.drawPath(outerPath, outerGradientPaint);

    // [LAYER 3: INNER CUTOUT] Dark red/orange core for 3D depth
    final innerPath = _createInnerFlame(size);
    final innerGradientPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          ComebakColors.flameRed,
          ComebakColors.flameShadow,
        ],
      ).createShader(Rect.fromLTWH(0, size.height * 0.4, size.width, size.height * 0.6));

    canvas.drawPath(innerPath, innerGradientPaint);
  }

  // [GEOMETRY] Outer flame shape (The main body)
  Path _createOuterFlame(Size size) {
    final path = Path();
    path.moveTo(size.width * 0.5, size.height * 0.05); // Tip of the flame
    
    // Right curve down
    path.cubicTo(
      size.width * 0.8, size.height * 0.3,
      size.width * 0.9, size.height * 0.6,
      size.width * 0.8, size.height * 0.8,
    );
    // Bottom right curve
    path.cubicTo(
      size.width * 0.7, size.height * 0.95,
      size.width * 0.3, size.height * 0.95,
      size.width * 0.2, size.height * 0.8,
    );
    // Left curve up
    path.cubicTo(
      size.width * 0.1, size.height * 0.6,
      size.width * 0.3, size.height * 0.4,
      size.width * 0.5, size.height * 0.05,
    );
    
    path.close();
    return path;
  }

  // [GEOMETRY] Inner flame shape (The cutout)
  Path _createInnerFlame(Size size) {
    final path = Path();
    path.moveTo(size.width * 0.5, size.height * 0.4); // Inner tip
    
    path.cubicTo(
      size.width * 0.65, size.height * 0.55,
      size.width * 0.7, size.height * 0.75,
      size.width * 0.6, size.height * 0.85,
    );
    path.cubicTo(
      size.width * 0.5, size.height * 0.9,
      size.width * 0.4, size.height * 0.85,
      size.width * 0.35, size.height * 0.75,
    );
    path.cubicTo(
      size.width * 0.3, size.height * 0.6,
      size.width * 0.4, size.height * 0.5,
      size.width * 0.5, size.height * 0.4,
    );
    
    path.close();
    return path;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}