import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/dev/dev_harness_controller.dart';
import '../../core/dev/dev_haptics.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/ui/components/comebak_button.dart';
import '../../core/ui/components/comebak_chip.dart';

// [ISSUE-22] Game result screen. Full-bleed layout with PB celebration.
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
    Future.delayed(const Duration(milliseconds: 80),
        () => DevHaptics.selectionClick(source: 'GameResult.pb2'));
    Future.delayed(const Duration(milliseconds: 160),
        () => DevHaptics.selectionClick(source: 'GameResult.pb3'));
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
    final scoreColor = widget.score > 0 ? AppColors.primaryAccent : AppColors.danger;
    final brokenRecordText = _formatBrokenRecord(widget.previousPBBrokenAfter);

    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            "Time's Up",
                            style: AppTextStyles.display.copyWith(fontWeight: FontWeight.w800),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: AppSpacing.space24),
                          
                          if (widget.isNewPB) ...[
                            Center(
                              child: ComebakChip(
                                text: 'New Personal Best!',
                                variant: ComebakChipVariant.neon,
                              ).animate().fadeIn(delay: 200.ms).scaleXY(begin: 0.9),
                            ),
                            if (brokenRecordText != null)
                              Padding(
                                padding: const EdgeInsets.only(top: AppSpacing.space8),
                                child: Text(
                                  brokenRecordText,
                                  style: AppTextStyles.labelXSmall.copyWith(color: AppColors.textMuted),
                                  textAlign: TextAlign.center,
                                ).animate().fadeIn(delay: 400.ms),
                              ),
                            const SizedBox(height: AppSpacing.space32),
                          ],

                          TweenAnimationBuilder<double>(
                            tween: Tween<double>(begin: 0, end: widget.score.toDouble()),
                            duration: disableAnimations ? Duration.zero : AppMotion.durationRollup,
                            curve: Curves.easeOutCubic,
                            builder: (context, value, child) {
                              return Text(
                                value.toInt().toString(),
                                style: AppTextStyles.hudLarge.copyWith(color: scoreColor, fontWeight: FontWeight.w900),
                                textAlign: TextAlign.center,
                              );
                            },
                          ),
                          Text(
                            'SCORE',
                            style: AppTextStyles.labelSmall,
                            textAlign: TextAlign.center,
                          ),
                          
                          const SizedBox(height: AppSpacing.space32),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Expanded(
                                child: Column(
                                  children: [
                                    Text('${widget.accuracy}%', style: AppTextStyles.hudMedium),
                                    const Text('Accuracy', style: AppTextStyles.labelSmall),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  children: [
                                    Text('x${widget.bestCombo}', style: AppTextStyles.hudMedium),
                                    const Text('Best Combo', style: AppTextStyles.labelSmall),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.only(
                      left: AppSpacing.space24,
                      right: AppSpacing.space24,
                      bottom: 100, 
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        ComebakButton(
                          text: 'Play Again',
                          variant: ComebakButtonVariant.primary,
                          onPressed: () {
                            if (!_canNavigate()) return;
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(builder: (_) => widget.gameBuilder()),
                            );
                          },
                        ),
                        const SizedBox(height: AppSpacing.space16),
                        ComebakButton(
                          text: 'Go Home',
                          variant: ComebakButtonVariant.ghost,
                          onPressed: () {
                            if (!_canNavigate()) return;
                            Navigator.of(context).popUntil((route) => route.isFirst);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          AnimatedBuilder(
            animation: _goldOverlayController,
            builder: (context, _) {
              if (_goldOverlayController.value == 0) {
                return const SizedBox.shrink();
              }
              final opacity = 0.10 * (1 - _goldOverlayController.value);
              return Positioned.fill(
                child: IgnorePointer(
                  child: Container(color: AppColors.warning.withValues(alpha: opacity)),
                ),
              );
            },
          ),
          
          if (widget.isNewPB && !disableAnimations)
            const Positioned.fill(
              child: IgnorePointer(child: _ConfettiOverlay()),
            ),
        ],
      ),
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
      duration: AppMotion.durationCelebrationSlow,
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
        return CustomPaint(
          painter: _ConfettiPainter(_particles, _controller.value),
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
          AppColors.primaryAccent,
          AppColors.warning,
          AppColors.success,
          AppColors.neon,
        ][random.nextInt(4)];
}

class _ConfettiPainter extends CustomPainter {
  final List<_Particle> particles;
  final double progress;

  _ConfettiPainter(this.particles, this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    for (var p in particles) {
      final dx = cos(p.angle) * p.speed * progress * size.width * 0.8;
      final dy = sin(p.angle) * p.speed * progress * size.height * 0.8 +
          (progress * progress * 200);
      final center = Offset(size.width * p.x + dx, size.height * p.y + dy);
      paint.color = p.color.withValues(alpha: 1.0 - progress);
      canvas.drawCircle(center, p.size, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter oldDelegate) => true;
}
