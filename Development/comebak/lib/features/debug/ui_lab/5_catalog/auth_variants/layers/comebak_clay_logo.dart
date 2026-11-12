import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../1_foundations/tokens/ui_lab_tokens.dart';

class ComebakClayLogo extends StatelessWidget {
  final int pose;
  final double time;

  const ComebakClayLogo({super.key, required this.pose, required this.time});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(48, 64),
      painter: _ClayLogoPainter(pose: pose, time: time),
    );
  }
}

class _ClayLogoPainter extends CustomPainter {
  final int pose;
  final double time;

  _ClayLogoPainter({required this.pose, required this.time});

  static const List<_Pose> _poses = [
    _Pose(scale: 0.60, extrude: 0.0, rotation: 0.00, brightness: 0.30),
    _Pose(scale: 0.75, extrude: 2.0, rotation: 0.14, brightness: 0.55),
    _Pose(scale: 0.90, extrude: 4.0, rotation: -0.07, brightness: 0.75),
    _Pose(scale: 1.00, extrude: 6.0, rotation: 0.03, brightness: 0.95),
    _Pose(scale: 1.00, extrude: 6.0, rotation: 0.00, brightness: 1.00),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final p = _poses[pose.clamp(0, _poses.length - 1)];
    
    canvas.save();
    canvas.translate(size.width / 2, size.height / 2);
    canvas.scale(p.scale);
    canvas.translate(-size.width / 2, -size.height / 2);
    canvas.rotate(p.rotation);

    final path = _buildThunderPath();

    // 1. Extruded shadow
    canvas.drawPath(
      path.shift(Offset(p.extrude, p.extrude)),
      Paint()..color = Colors.black.withOpacity(0.8 * p.brightness),
    );

    // 2. Side face (Deep green shadow, not grey)
    canvas.drawPath(
      path.shift(Offset(p.extrude * 0.5, p.extrude * 0.5)),
      Paint()..color = const Color(0xFF003D16).withOpacity(p.brightness),
    );

    // 3. Front face (Plasma Gradient, not grey)
    final fillGradient = const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF00C853), Color(0xFF00E676), Colors.white],
    ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawPath(
      path,
      Paint()..shader = fillGradient..color = Colors.white.withOpacity(p.brightness),
    );

    // 4. Ambient Occlusion (Bottom inner shadow)
    canvas.save();
    canvas.clipPath(path);
    canvas.drawRect(
      Rect.fromLTWH(0, size.height * 0.7, size.width, size.height),
      Paint()
        ..color = Colors.black.withOpacity(0.4 * p.brightness)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );
    canvas.restore();

    // 5. Specular Highlight (White edge reflection)
    final metrics = path.computeMetrics().toList();
    if (metrics.isNotEmpty) {
      final glossSegment = metrics.first.extractPath(0, metrics.first.length * 0.3);
      canvas.drawPath(
        glossSegment,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.0
          ..strokeCap = StrokeCap.round
          ..color = Colors.white.withOpacity(0.9 * p.brightness)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1),
      );
    }

    // 6. Fractal Plasma
    if (p.brightness > 0.6) {
      canvas.save();
      canvas.clipPath(path);
      final frameSeed = (time * 20).floor();
      final rnd = math.Random(frameSeed);
      for (int i = 0; i < 2; i++) {
        final startX = (size.width * 0.3) + rnd.nextDouble() * (size.width * 0.4);
        _drawFractalBranch(canvas, Offset(startX, -10), Offset(startX + (rnd.nextDouble() * 10 - 5), size.height + 10), rnd, p.brightness, 3);
      }
      canvas.restore();
    }

    // 7. Neon rim
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..strokeJoin = StrokeJoin.round
        ..color = ComebakColors.neonGreen.withOpacity(0.9 * p.brightness),
    );

    canvas.restore();
  }

  void _drawFractalBranch(Canvas canvas, Offset start, Offset end, math.Random rnd, double brightness, int depth) {
    if (depth <= 0) return;
    final path = Path()..moveTo(start.dx, start.dy);
    for (int i = 1; i <= 4; i++) {
      final t = i / 4;
      path.lineTo(start.dx + (end.dx - start.dx) * t + (rnd.nextDouble() * 16 - 8) * (1.0 - t), start.dy + (end.dy - start.dy) * t);
    }
    canvas.drawPath(path, Paint()..style = PaintingStyle.stroke..strokeWidth = 4.0 * (depth / 3)..strokeCap = StrokeCap.round..color = Colors.white.withOpacity(0.5 * brightness)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2));
    canvas.drawPath(path, Paint()..style = PaintingStyle.stroke..strokeWidth = 1.0..strokeCap = StrokeCap.round..color = Colors.white.withOpacity(brightness));
    if (depth > 1) {
      final mid = Offset(start.dx + (end.dx - start.dx) * 0.5, start.dy + (end.dy - start.dy) * 0.5);
      _drawFractalBranch(canvas, mid, Offset(mid.dx - rnd.nextDouble() * 15, mid.dy + rnd.nextDouble() * 15), rnd, brightness, depth - 1);
      _drawFractalBranch(canvas, mid, Offset(mid.dx + rnd.nextDouble() * 15, mid.dy + rnd.nextDouble() * 15), rnd, brightness, depth - 1);
    }
  }

  Path _buildThunderPath() {
    final path = Path();
    path.moveTo(32, 0); path.lineTo(0, 40); path.lineTo(20, 40);
    path.lineTo(12, 64); path.lineTo(48, 24); path.lineTo(28, 24); path.close();
    return path;
  }

  @override
  bool shouldRepaint(covariant _ClayLogoPainter old) => old.pose != pose || old.time != time;
}

class _Pose {
  final double scale; final double extrude; final double rotation; final double brightness;
  const _Pose({required this.scale, required this.extrude, required this.rotation, required this.brightness});
}