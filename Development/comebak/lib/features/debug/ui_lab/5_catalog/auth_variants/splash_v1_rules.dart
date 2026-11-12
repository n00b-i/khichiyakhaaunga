import 'package:flutter/material.dart';
import '../../1_foundations/tokens/ui_lab_tokens.dart';

// ==============================================================================
// [VARIANT 1 — SPLASH] "THE RULES"
// ------------------------------------------------------------------------------
// Concept: Wireframe isometric clay bar draws itself, then fills.
// Copy: "THE FIRST RULE OF COMEBAK — you do not chase the streak."
// Runtime: 2.6s hardcoded, skip button always visible.
// ==============================================================================
class SplashV1Rules extends StatefulWidget {
  final VoidCallback onComplete;
  const SplashV1Rules({super.key, required this.onComplete});

  @override
  State<SplashV1Rules> createState() => _SplashV1RulesState();
}

class _SplashV1RulesState extends State<SplashV1Rules>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    )
      ..addStatusListener((s) {
        if (s == AnimationStatus.completed) widget.onComplete();
      })
      ..forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ComebakColors.canvas,
      body: Stack(
        children: [
          // Ambient radial glow — top-right, neon green, very low opacity
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _ctrl,
              builder: (_, _) {
                final t = Curves.easeOut.transform(
                  (_ctrl.value * 2).clamp(0.0, 1.0),
                );
                return DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: const Alignment(0.35, -0.45),
                      radius: 1.2,
                      colors: [
                        ComebakColors.neonGreen.withValues(alpha: 0.14 * t),
                        ComebakColors.canvas,
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Center hero — isometric clay bar
          Center(
            child: SizedBox(
              width: 160,
              height: 160,
              child: AnimatedBuilder(
                animation: _ctrl,
                builder: (_, _) => CustomPaint(
                  painter: _IsoBarPainter(
                    drawT: Curves.easeOut.transform(
                      (_ctrl.value * 2.5).clamp(0.0, 1.0),
                    ),
                    fillT: Curves.easeInOut.transform(
                      ((_ctrl.value - 0.4) * 3.33).clamp(0.0, 1.0),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Bottom-left copy block
          Positioned(
            left: ComebakLayout.spaceXl,
            right: ComebakLayout.spaceXl,
            bottom: ComebakLayout.spaceXxl * 2,
            child: AnimatedBuilder(
              animation: _ctrl,
              builder: (_, _) {
                final t = Curves.easeOut.transform(
                  ((_ctrl.value - 0.55) / 0.3).clamp(0.0, 1.0),
                );
                return Opacity(
                  opacity: t,
                  child: Transform.translate(
                    offset: Offset(0, 14 * (1 - t)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'THE FIRST RULE OF COMEBAK',
                          style: ComebakTypography.labelSmall.copyWith(
                            color: ComebakColors.textSecondary,
                            letterSpacing: 2.2,
                          ),
                        ),
                        const SizedBox(height: ComebakLayout.spaceSm),
                        Text(
                          'you do not chase\nthe streak.',
                          style: ComebakTypography.greeting.copyWith(
                            fontSize: 30,
                            height: 1.05,
                            color: ComebakColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Skip
          Positioned(
            top: MediaQuery.of(context).padding.top + ComebakLayout.spaceMd,
            right: ComebakLayout.spaceLg,
            child: TextButton(
              onPressed: widget.onComplete,
              child: Text(
                'SKIP',
                style: ComebakTypography.labelSmall.copyWith(
                  color: ComebakColors.textSecondary,
                  letterSpacing: 2,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ==============================================================================
// [PAINTER] Isometric clay bar — top rhombus + 2 side faces
// ==============================================================================
class _IsoBarPainter extends CustomPainter {
  final double drawT;
  final double fillT;
  _IsoBarPainter({required this.drawT, required this.fillT});

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 160.0;
    final cx = size.width / 2;
    final cy = size.height / 2;

    final w = 90 * s;
    final h = 50 * s;
    final ext = 40 * s;

    // Top rhombus
    final top = Path()
      ..moveTo(cx, cy - h / 2)
      ..lineTo(cx + w / 2, cy)
      ..lineTo(cx, cy + h / 2)
      ..lineTo(cx - w / 2, cy)
      ..close();

    // Left face
    final left = Path()
      ..moveTo(cx - w / 2, cy)
      ..lineTo(cx, cy + h / 2)
      ..lineTo(cx, cy + h / 2 + ext)
      ..lineTo(cx - w / 2, cy + ext)
      ..close();

    // Right face
    final right = Path()
      ..moveTo(cx, cy + h / 2)
      ..lineTo(cx + w / 2, cy)
      ..lineTo(cx + w / 2, cy + ext)
      ..lineTo(cx, cy + h / 2 + ext)
      ..close();

    // Stroke pass — clay bevel
    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2 * s
      ..strokeJoin = StrokeJoin.round
      ..color = ComebakColors.neonGreen.withValues(alpha: 0.9 * drawT);

    // Fill passes — three faces, three shades
    final fillTop = Paint()
      ..style = PaintingStyle.fill
      ..color = ComebakColors.neonGreen.withValues(alpha: 0.35 * fillT);
    final fillLeft = Paint()
      ..style = PaintingStyle.fill
      ..color = ComebakColors.mutedGreen.withValues(alpha: 0.45 * fillT);
    final fillRight = Paint()
      ..style = PaintingStyle.fill
      ..color = ComebakColors.mutedGreen.withValues(alpha: 0.7 * fillT);

    // Scale-in draw
    canvas.save();
    canvas.translate(cx, cy);
    canvas.scale(0.85 + 0.15 * drawT);
    canvas.translate(-cx, -cy);

    canvas.drawPath(top, fillTop);
    canvas.drawPath(left, fillLeft);
    canvas.drawPath(right, fillRight);
    canvas.drawPath(top, stroke);
    canvas.drawPath(left, stroke);
    canvas.drawPath(right, stroke);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _IsoBarPainter old) =>
      old.drawT != drawT || old.fillT != fillT;
}