import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

// Core Dev & Harness
import '../../core/dev/dev_harness_controller.dart';
import '../../core/dev/dev_haptics.dart';

// UI Lab Tokens (SSOT)
import '../debug/ui_lab/1_foundations/tokens/ui_lab_tokens.dart';

class GameResultScreen extends StatefulWidget {
  final int score;
  final int accuracy;
  final int bestCombo;
  final bool isNewPB;
  final Duration? previousPBBrokenAfter;
  final Widget Function() gameBuilder;
  final bool debugSuppressAutoAnimations;

  const GameResultScreen({
    super.key,
    required this.score,
    required this.accuracy,
    required this.bestCombo,
    required this.isNewPB,
    this.previousPBBrokenAfter,
    required this.gameBuilder,
    this.debugSuppressAutoAnimations = false,
  });

  @override
  State<GameResultScreen> createState() => _GameResultScreenState();
}

class _GameResultScreenState extends State<GameResultScreen>
    with SingleTickerProviderStateMixin {
  DateTime? _lastTap;
  late final AnimationController _goldOverlayController;
  int _lastReplayTick = 0;

  @override
  void initState() {
    super.initState();
    _goldOverlayController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _lastReplayTick = DevHarnessController.instance.replayTick;
    DevHarnessController.instance.addListener(_onDevChanged);
    if (widget.isNewPB && !widget.debugSuppressAutoAnimations) {
      _triggerCelebration();
    }
  }

  @override
  void dispose() {
    DevHarnessController.instance.removeListener(_onDevChanged);
    _goldOverlayController.dispose();
    super.dispose();
  }

  void _onDevChanged() {
    final tick = DevHarnessController.instance.replayTick;
    if (tick != _lastReplayTick) {
      _lastReplayTick = tick;
      if (widget.isNewPB) _triggerCelebration();
    }
  }

  void _triggerCelebration() {
    _goldOverlayController.forward(from: 0);
    DevHaptics.selectionClick(source: 'GameResult.pb1');
    Future.delayed(
      const Duration(milliseconds: 80),
      () => DevHaptics.selectionClick(source: 'GameResult.pb2'),
    );
    Future.delayed(
      const Duration(milliseconds: 160),
      () => DevHaptics.selectionClick(source: 'GameResult.pb3'),
    );
  }

  bool _canNavigate() {
    final now = DateTime.now();
    if (_lastTap != null && now.difference(_lastTap!).inMilliseconds < 300) {
      return false;
    }
    _lastTap = now;
    DevHaptics.selectionClick(source: 'GameResult.navigate');
    return true;
  }

  String? _formatBrokenRecord(Duration? d) {
    if (d == null) return null;
    if (d.inSeconds < 60) return 'Record broken after ${d.inSeconds} seconds';
    if (d.inMinutes < 60) return 'Record broken after ${d.inMinutes} minutes';
    if (d.inHours < 24) return 'Record broken after ${d.inHours} hours';
    return 'Record broken after ${d.inDays} ${d.inDays == 1 ? 'Day' : 'Days'}';
  }

  @override
  Widget build(BuildContext context) {
    final disableAnimations = MediaQuery.disableAnimationsOf(context);
    final showCelebration =
        widget.isNewPB && widget.score > 0 && !disableAnimations;
    final brokenRecordText = _formatBrokenRecord(widget.previousPBBrokenAfter);

    return Scaffold(
      backgroundColor: ComebakColors.canvas,
      body: Stack(
        children: [
          // [LAYER 1: MAIN CONTENT]
          SafeArea(
            // [ARCHITECTURE: LAYOUT SAFETY]
            // We use LayoutBuilder + SingleChildScrollView + IntrinsicHeight.
            // This guarantees that on smaller screens (iPhone SE) or with large
            // accessibility fonts, the content becomes scrollable instead of
            // throwing a "RenderFlex Overflow" error.
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: IntrinsicHeight(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: ComebakLayout.spaceXl,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // [SPACER: TOP ANCHOR]
                            const Spacer(flex: 2),

                            // TITLE
                            Text(
                              "Time's Up",
                              style: ComebakTypography.greeting.copyWith(
                                fontWeight: FontWeight.w800,
                                color: ComebakColors.textPrimary,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: ComebakLayout.spaceXl),

                            // PB BANNER
                            if (showCelebration) ...[
                              Center(
                                child:
                                    Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: ComebakLayout.spaceLg,
                                            vertical: ComebakLayout.spaceSm,
                                          ),
                                          decoration: BoxDecoration(
                                            color: ComebakColors.neonYellow
                                                .withValues(alpha: 0.15),
                                            borderRadius: BorderRadius.circular(
                                              ComebakLayout.radiusXl,
                                            ),
                                            border: Border.all(
                                              color: ComebakColors.neonYellow
                                                  .withValues(alpha: 0.8),
                                              width: ComebakLayout.borderThick,
                                            ),
                                          ),
                                          child: Text(
                                            'New Personal Best!',
                                            style: ComebakTypography.labelSmall
                                                .copyWith(
                                                  color:
                                                      ComebakColors.neonYellow,
                                                  fontWeight: FontWeight.w800,
                                                ),
                                          ),
                                        )
                                        .animate()
                                        .fadeIn(delay: 200.ms)
                                        .scaleXY(begin: 0.9),
                              ),
                              if (brokenRecordText != null)
                                Padding(
                                  padding: const EdgeInsets.only(
                                    top: ComebakLayout.spaceSm,
                                  ),
                                  child: Text(
                                    brokenRecordText,
                                    style: ComebakTypography.labelSmall
                                        .copyWith(
                                          color: ComebakColors.textSecondary,
                                        ),
                                    textAlign: TextAlign.center,
                                  ).animate().fadeIn(delay: 400.ms),
                                ),
                              const SizedBox(height: ComebakLayout.spaceXxl),
                            ],

                            // SCORE ROLLUP
                            _ScoreRollup(
                              score: widget.score,
                              disableAnimations: disableAnimations,
                            ),

                            Text(
                              'SCORE',
                              style: ComebakTypography.labelSmall.copyWith(
                                color: ComebakColors.textSecondary,
                                letterSpacing: ComebakLayout.borderGradient,
                              ),
                              textAlign: TextAlign.center,
                            ),

                            const SizedBox(height: ComebakLayout.spaceXxl),

                            // STATS ROW
                            Row(
                              children: [
                                Expanded(
                                  flex: 1,
                                  child: Column(
                                    children: [
                                      Text(
                                        '${widget.accuracy}%',
                                        style: ComebakTypography.titleLarge,
                                      ),
                                      Text(
                                        'Accuracy',
                                        style: ComebakTypography.labelSmall
                                            .copyWith(
                                              color:
                                                  ComebakColors.textSecondary,
                                            ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: ComebakLayout.spaceLg),
                                Expanded(
                                  flex: 1,
                                  child: Column(
                                    children: [
                                      Text(
                                        'x${widget.bestCombo}',
                                        style: ComebakTypography.titleLarge,
                                      ),
                                      Text(
                                        'Best Combo',
                                        style: ComebakTypography.labelSmall
                                            .copyWith(
                                              color:
                                                  ComebakColors.textSecondary,
                                            ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),

                            // [SPACER: BOTTOM ANCHOR]
                            const Spacer(flex: 3),

                            // ACTION BUTTONS
                            SizedBox(
                              height: ComebakLayout.buttonHeight,
                              width: double.infinity,
                              child: TextButton(
                                onPressed: () {
                                  if (!_canNavigate()) return;
                                  Navigator.of(context).pushReplacement(
                                    MaterialPageRoute(
                                      builder: (_) => widget.gameBuilder(),
                                    ),
                                  );
                                },
                                style: TextButton.styleFrom(
                                  backgroundColor: ComebakColors.neonGreen,
                                  foregroundColor: ComebakColors.canvas,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                      ComebakLayout.radiusMd,
                                    ),
                                  ),
                                ),
                                child: Text(
                                  'Play Again',
                                  style: ComebakTypography.titleMedium.copyWith(
                                    color: ComebakColors.canvas,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: ComebakLayout.spaceMd),

                            SizedBox(
                              height: ComebakLayout.buttonHeight,
                              width: double.infinity,
                              child: TextButton(
                                onPressed: () {
                                  if (!_canNavigate()) return;
                                  Navigator.of(
                                    context,
                                  ).popUntil((route) => route.isFirst);
                                },
                                style: TextButton.styleFrom(
                                  backgroundColor:
                                      ComebakColors.surfaceElevated,
                                  foregroundColor: ComebakColors.textPrimary,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                      ComebakLayout.radiusMd,
                                    ),
                                  ),
                                ),
                                child: Text(
                                  'Go Home',
                                  style: ComebakTypography.titleMedium.copyWith(
                                    color: ComebakColors.textPrimary,
                                  ),
                                ),
                              ),
                            ),

                            // [UX IMPROVEMENT: THUMB ZONE]
                            // Lifts the buttons up by exactly one button height.
                            // The IntrinsicHeight absorbs this safely without breaking
                            // the layout or pushing content off-screen.
                            const SizedBox(height: ComebakLayout.buttonHeight),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // [LAYER 2: GOLD OVERLAY]
          AnimatedBuilder(
            animation: _goldOverlayController,
            builder: (context, _) {
              if (_goldOverlayController.value == 0) {
                return const SizedBox.shrink();
              }
              final opacity = 0.10 * (1 - _goldOverlayController.value);
              return Positioned.fill(
                child: IgnorePointer(
                  child: Container(
                    color: ComebakColors.neonYellow.withValues(alpha: opacity),
                  ),
                ),
              );
            },
          ),

          // [LAYER 3: CONFETTI]
          if (showCelebration)
            const Positioned.fill(
              child: IgnorePointer(
                child: RepaintBoundary(child: _ConfettiOverlay()),
              ),
            ),
        ],
      ),
    );
  }
}

// [ISSUE-30] Isolated score rollup. By isolating the TweenAnimationBuilder into its own
// widget, its 60fps rebuilds do not trigger layout recalculations for the entire screen.
class _ScoreRollup extends StatelessWidget {
  final int score;
  final bool disableAnimations;

  const _ScoreRollup({required this.score, required this.disableAnimations});

  @override
  Widget build(BuildContext context) {
    final scoreColor = score > 0
        ? ComebakColors.neonGreen
        : ComebakColors.vibrantRed;

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: score.toDouble()),
      duration: disableAnimations
          ? Duration.zero
          : const Duration(milliseconds: 1200),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Text(
          value.toInt().toString(),
          style: ComebakTypography.greeting.copyWith(
            fontSize: ComebakLayout.spaceXxl * 3.75, // 120
            color: scoreColor,
            fontWeight: FontWeight.w900,
            height: 0.9,
            letterSpacing: -ComebakLayout.spaceXs / 2,
          ),
          textAlign: TextAlign.center,
        );
      },
    );
  }
}

class _ConfettiOverlay extends StatefulWidget {
  const _ConfettiOverlay();
  @override
  State<_ConfettiOverlay> createState() => _ConfettiOverlayState();
}

class _ConfettiOverlayState extends State<_ConfettiOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<_Particle> _particles;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _particles = List.generate(120, (index) => _Particle(_random));
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return ClipRect(
          child: CustomPaint(
            painter: _ConfettiPainter(_particles, _controller.value),
          ),
        );
      },
    );
  }
}

class _Particle {
  final double x, y, angle, speed, size;
  final Color color;

  _Particle(Random random)
    : x = random.nextDouble(),
      y = 0.5,
      angle = random.nextDouble() * 2 * pi,
      speed = 0.5 + random.nextDouble(),
      size = 4 + random.nextDouble() * 4,
      color = [
        ComebakColors.neonGreen,
        ComebakColors.neonYellow,
        ComebakColors.vibrantRed,
      ][random.nextInt(3)];
}

class _ConfettiPainter extends CustomPainter {
  final List<_Particle> particles;
  final double progress;

  _ConfettiPainter(this.particles, this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.clipRect(Offset.zero & size);

    final paint = Paint()..style = PaintingStyle.fill;
    for (var p in particles) {
      final dx = cos(p.angle) * p.speed * progress * size.width * 0.8;
      final dy =
          sin(p.angle) * p.speed * progress * size.height * 0.8 +
          (progress * progress * 200);
      final center = Offset(size.width * p.x + dx, size.height * p.y + dy);
      paint.color = p.color.withValues(alpha: 1.0 - progress);
      canvas.drawCircle(center, p.size, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter oldDelegate) => true;
}
