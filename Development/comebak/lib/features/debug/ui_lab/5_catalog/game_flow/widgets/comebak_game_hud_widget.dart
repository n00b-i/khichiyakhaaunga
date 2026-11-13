import 'package:flutter/material.dart';
import '../../../1_foundations/tokens/ui_lab_tokens.dart';

// ==============================================================================
// [WIDGET] ComebakGameHudWidget
// ------------------------------------------------------------------------------
// PURPOSE: The stateless, reusable gameplay HUD.
// It accepts real game data (time, score, target) and renders the UI Lab design.
// ==============================================================================
class ComebakGameHudWidget extends StatelessWidget {
  final double timeLeft;
  final int maxTime;
  final int score;
  final int target;
  final String operationPrefix;
  final bool showTarget;

  const ComebakGameHudWidget({
    super.key,
    required this.timeLeft,
    required this.maxTime,
    required this.score,
    required this.target,
    this.operationPrefix = '',
    this.showTarget = true,
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
                      fontSize: 32,
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
                      letterSpacing: 1.5,
                    ),
                  ),
                ],
              ),

              // TARGET (Conditional)
              if (showTarget)
                Column(
                  children: [
                    Text(
                      '$operationPrefix$target',
                      style: ComebakTypography.greeting.copyWith(
                        fontSize: 48,
                        height: 1.0,
                        color: ComebakColors.neonGreen,
                      ),
                    ),
                    Text(
                      'TARGET',
                      style: ComebakTypography.labelSmall.copyWith(
                        color: ComebakColors.textSecondary,
                        letterSpacing: 1.5,
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
                      fontSize: 32,
                      color: ComebakColors.textPrimary,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                  Text(
                    'SCORE',
                    style: ComebakTypography.labelSmall.copyWith(
                      color: ComebakColors.textSecondary,
                      letterSpacing: 1.5,
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
