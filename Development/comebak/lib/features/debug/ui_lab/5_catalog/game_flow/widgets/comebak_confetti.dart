import 'dart:math';
import 'package:flutter/material.dart';
import '../../../1_foundations/tokens/ui_lab_tokens.dart'; // Correct import path

class ComebakConfetti extends StatefulWidget {
  final bool isActive;
  final Duration duration;

  const ComebakConfetti({
    super.key,
    this.isActive = true,
    this.duration = const Duration(seconds: 3),
  });

  @override
  State<ComebakConfetti> createState() => _ComebakConfettiState();
}

class _ComebakConfettiState extends State<ComebakConfetti>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late List<_ConfettiParticle> _particles;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: widget.duration)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) setState(() {});
      });
    _particles = _generateParticles();
    if (widget.isActive) _ctrl.forward();
  }

  List<_ConfettiParticle> _generateParticles() {
    final rnd = Random();
    return List.generate(60, (index) {
      return _ConfettiParticle(
        angle: rnd.nextDouble() * 2 * pi,
        speed: 100 + rnd.nextDouble() * 250,
        rotation: rnd.nextDouble() * 2 * pi,
        rotationSpeed: (rnd.nextDouble() - 0.5) * 10,
        color: [
          ComebakColors.neonGreen,
          ComebakColors.neonYellow,
          ComebakColors.vibrantRed,
        ][rnd.nextInt(3)],
      );
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isActive || _ctrl.isDismissed) return const SizedBox.shrink();

    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, child) {
        return CustomPaint(
          painter: _ConfettiPainter(
            progress: _ctrl.value,
            particles: _particles,
          ),
        );
      },
    );
  }
}

class _ConfettiParticle {
  final double angle;
  final double speed;
  final double rotation;
  final double rotationSpeed;
  final Color color;

  _ConfettiParticle({
    required this.angle,
    required this.speed,
    required this.rotation,
    required this.rotationSpeed,
    required this.color,
  });
}

class _ConfettiPainter extends CustomPainter {
  final double progress;
  final List<_ConfettiParticle> particles;

  _ConfettiPainter({required this.progress, required this.particles});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.4);
    final elapsed = progress * 3.0;
    final paint = Paint();

    for (final p in particles) {
      final x = center.dx + cos(p.angle) * p.speed * elapsed;
      final y =
          center.dy +
          sin(p.angle) * p.speed * elapsed +
          0.5 * 200 * elapsed * elapsed;

      final alpha = (1.0 - (progress - 0.7) / 0.3).clamp(0.0, 1.0);
      if (alpha <= 0) continue;

      paint.color = p.color.withValues(alpha: alpha);

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(p.rotation + p.rotationSpeed * elapsed);
      canvas.drawRect(
        Rect.fromCenter(center: Offset.zero, width: 6, height: 10),
        paint..style = PaintingStyle.fill,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter old) =>
      old.progress != progress;
}
