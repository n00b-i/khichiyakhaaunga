import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/primary_button.dart';
import 'add_burst/add_burst_screen.dart';

class GameResultScreen extends StatelessWidget {
  final int score;
  final int accuracy;
  final int bestCombo;

  const GameResultScreen({
    super.key,
    required this.score,
    required this.accuracy,
    required this.bestCombo,
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
              const SizedBox(height: AppSpacing.xl),
              Text(
                score.toString(),
                style: AppTextStyles.hud.copyWith(
                  fontSize: 80,
                  // Show red if score is 0 or negative
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
              PrimaryButton(
                text: 'Play Again',
                onPressed: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => const AddBurstScreen()),
                  );
                },
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