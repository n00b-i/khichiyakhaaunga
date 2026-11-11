import 'package:flutter/material.dart';
import '../../../core/theme/app_tokens.dart';

// [ISSUE-31] Shared countdown overlay used by all game screens.
class GameCountdownOverlay extends StatelessWidget {
  final int count;
  final String title;
  final String instructions;
  final Color accentColor;

  const GameCountdownOverlay({
    super.key,
    required this.count,
    required this.title,
    required this.instructions,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Container(
        color: AppColors.canvas,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$count',
                style: AppTextStyles.countdown,
              ),
              const SizedBox(height: AppSpacing.space24),
              Text(
                title,
                style: AppTextStyles.hud.copyWith(color: accentColor),
              ),
              const SizedBox(height: AppSpacing.space16),
              Text(
                instructions,
                style: AppTextStyles.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// [ISSUE-31] Shared instruction bar at the bottom of every game.
class GameInstructionBar extends StatelessWidget {
  final String text;

  const GameInstructionBar({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: AppSpacing.space24,
      left: AppSpacing.space16,
      right: AppSpacing.space16,
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textMuted),
      ),
    );
  }
}

// [ISSUE-31] Shared play area wrapper. Encapsulates Positioned bounds, hit-testing, and RepaintBoundary.
class GamePlayArea extends StatelessWidget {
  final Widget painter;
  final void Function(TapDownDetails) onTapDown;

  const GamePlayArea({
    super.key,
    required this.painter,
    required this.onTapDown,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: AppSizes.playAreaTop,
      bottom: AppSizes.playAreaBottom,
      left: 0,
      right: 0,
      child: GestureDetector(
        onTapDown: onTapDown,
        behavior: HitTestBehavior.opaque,
        child: RepaintBoundary(child: painter),
      ),
    );
  }
}
