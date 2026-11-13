import 'package:flutter/material.dart';
import '../../../1_foundations/tokens/ui_lab_tokens.dart';

// ==============================================================================
// [WIDGET] ComebakGameHudWidget
// ------------------------------------------------------------------------------
// PURPOSE: The stateless, reusable gameplay HUD.
// [DESIGN] The `operationPrefix` (e.g., '+', 'x') has been removed.
// The target label ('SUM', 'PRODUCT') already provides the necessary context,
// so showing the symbol before the number was redundant visual clutter.
// ==============================================================================
class ComebakGameHudWidget extends StatelessWidget {
  final double timeLeft;
  final int maxTime;
  final int score;
  final int target;
  final bool showTarget;
  final String? targetLabel;

  const ComebakGameHudWidget({
    super.key,
    required this.timeLeft,
    required this.maxTime,
    required this.score,
    required this.target,
    this.showTarget = true,
    this.targetLabel,
  });

  @override
  Widget build(BuildContext context) {
    final isLowTime = timeLeft <= 10.0;
    final progress = (timeLeft / maxTime).clamp(0.0, 1.0);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: ComebakLayout.spaceLg,
            vertical: ComebakLayout.spaceMd,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // TIME
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${timeLeft.ceil()}s',
                    style: ComebakTypography.greeting.copyWith(
                      fontSize: ComebakLayout.spaceXxl,
                      color: isLowTime
                          ? ComebakColors.vibrantRed
                          : ComebakColors.textPrimary,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                  Text(
                    'TIME',
                    style: ComebakTypography.labelSmall.copyWith(
                      color: ComebakColors.textSecondary,
                      letterSpacing: ComebakLayout.borderGradient,
                    ),
                  ),
                ],
              ),

              // TARGET (Conditional)
              if (showTarget)
                Column(
                  children: [
                    Text(
                      '$target', // Just the number now
                      style: ComebakTypography.greeting.copyWith(
                        fontSize: ComebakLayout.buttonHeight,
                        height: 1.0,
                        color: ComebakColors.neonGreen,
                      ),
                    ),
                    Text(
                      (targetLabel ?? 'TARGET').toUpperCase(),
                      style: ComebakTypography.labelSmall.copyWith(
                        color: ComebakColors.textSecondary,
                        letterSpacing: ComebakLayout.borderGradient,
                      ),
                    ),
                  ],
                )
              else
                const SizedBox(width: ComebakLayout.buttonHeight),

              // SCORE
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '$score',
                    style: ComebakTypography.greeting.copyWith(
                      fontSize: ComebakLayout.spaceXxl,
                      color: ComebakColors.textPrimary,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                  Text(
                    'SCORE',
                    style: ComebakTypography.labelSmall.copyWith(
                      color: ComebakColors.textSecondary,
                      letterSpacing: ComebakLayout.borderGradient,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        // TIMER BAR
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: ComebakLayout.spaceLg,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(ComebakLayout.radiusMd),
            child: Container(
              height: 8,
              width: double.infinity,
              color: ComebakColors.surfaceElevated,
              child: Stack(
                children: [
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          ComebakColors.vibrantRed,
                          ComebakColors.neonPurple,
                          ComebakColors.neonGreen,
                        ],
                        stops: [0.0, 0.5, 1.0],
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: FractionallySizedBox(
                      widthFactor: 1.0 - progress,
                      child: Container(color: ComebakColors.surfaceElevated),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
