import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class GameHud extends StatelessWidget {
  final double timeLeft;
  final int maxTime;
  final int target;
  final int score;
  final String operationPrefix; // '+' for Add, 'x' for Mad, '=' for Math

  const GameHud({
    super.key,
    required this.timeLeft,
    required this.maxTime,
    required this.target,
    required this.score,
    this.operationPrefix = '', // Default is empty
  });

  @override
  Widget build(BuildContext context) {
    final progress = (timeLeft / maxTime).clamp(0.0, 1.0);
    final isLowTime = timeLeft <= 10.0;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // Time
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${timeLeft.ceil()}s',
                  style: AppTextStyles.hud.copyWith(
                    color: isLowTime ? AppColors.vibrantRed : AppColors.textPrimary,
                  ),
                ),
                Text(
                  'Time',
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.textPrimary.withValues(alpha: 0.6),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            
            // Target
            Column(
              children: [
                Text(
                  '$operationPrefix$target', // <--- PREFIX APPLIED HERE
                  style: AppTextStyles.display.copyWith(
                    color: AppColors.primary,
                    fontSize: 48,
                    height: 1.0,
                  ),
                ),
                Text(
                  'Target',
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.textPrimary.withValues(alpha: 0.6),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            
            // Score
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  score.toString(),
                  style: AppTextStyles.hud,
                ),
                Text(
                  'Score',
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.textPrimary.withValues(alpha: 0.6),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
        
        const SizedBox(height: AppSpacing.sm),

        // Gradient Timer Bar
        ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.pill),
          child: Container(
            height: 8,
            width: double.infinity,
            color: AppColors.surface,
            child: Stack(
              children: [
                Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.vibrantRed, 
                        AppColors.vibrantPurple, 
                        AppColors.vibrantGreen
                      ],
                      stops: [0.0, 0.5, 1.0],
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: FractionallySizedBox(
                    widthFactor: 1.0 - progress,
                    child: Container(color: AppColors.surface),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}