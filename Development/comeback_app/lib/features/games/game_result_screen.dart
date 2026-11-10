import 'package:flutter/material.dart';
import 'package:fossui/fossui.dart';
import '../../core/theme/app_theme.dart';

class GameResultScreen extends StatelessWidget {
  final int score;
  final int accuracy;
  final int bestCombo;
  final bool isNewPB; // [ISSUE-14] Added parameter
  final Widget Function() gameBuilder;

  const GameResultScreen({
    super.key,
    required this.score,
    required this.accuracy,
    required this.bestCombo,
    this.isNewPB = false, // Defaults to false
    required this.gameBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Time\'s Up', style: AppTextStyles.display),
              const SizedBox(height: AppSpacing.lg),
              
              // [ISSUE-14] Display PB Badge
              if (isNewPB)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: FossBadge(
                    label: const Text('New Personal Best!'),
                    variant: FossBadgeVariant.success,
                  ),
                ),

              Text(
                score.toString(),
                style: AppTextStyles.hud.copyWith(
                  fontSize: 80,
                  color: score > 0 ? AppColors.primary : AppColors.vibrantRed,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              const Text('SCORE', style: AppTextStyles.body),
              const SizedBox(height: AppSpacing.xl * 2),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildStat('Accuracy', '$accuracy%'),
                  _buildStat('Best Combo', 'x$bestCombo'),
                ],
              ),
              const SizedBox(height: AppSpacing.xl * 3),
              FossButton(
                onPressed: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => gameBuilder()),
                  );
                },
                child: const Text('Play Again'),
              ),
              const SizedBox(height: AppSpacing.md),
              TextButton(
                onPressed: () {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                child: Text(
                  'Done',
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.textPrimary.withValues(alpha: 0.6),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStat(String label, String value) {
    return Column(
      children: [
        Text(value, style: AppTextStyles.hud),
        Text(
          label,
          style: AppTextStyles.body.copyWith(
            color: AppColors.textPrimary.withValues(alpha: 0.6),
          ),
        ),
      ],
    );
  }
}