import 'package:flutter/material.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/ui/components/comebak_button.dart';
import '../../../core/ui/components/game_card.dart';
import '../../../core/ui/components/section_header.dart';
import '../../../core/ui/components/stat_block.dart';
import '../../../core/ui/components/empty_state.dart';
import '../../../core/ui/components/progress_ring.dart';

class UiLabScreen extends StatelessWidget {
  const UiLabScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.space24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Component Gallery', style: AppTextStyles.display),
              const SectionHeader('Buttons'),
              ComebakButton(text: 'Primary Button', onPressed: () {}),
              const SizedBox(height: AppSpacing.space8),
              ComebakButton(
                text: 'Secondary Button',
                variant: ComebakButtonVariant.secondary,
                onPressed: () {},
              ),
              const SizedBox(height: AppSpacing.space8),
              ComebakButton(
                text: 'Danger Button',
                variant: ComebakButtonVariant.danger,
                onPressed: () {},
              ),

              const SectionHeader('Game Cards'),
              GameCard(
                title: 'Add Burst',
                description: 'Add two numbers to hit the target.',
                icon: Icons.add_circle_outline,
                accentColor: AppColors.gameMath,
                onTap: () {},
              ),
              const SizedBox(height: AppSpacing.space12),
              GameCard(
                title: 'Saitan X',
                description: 'Memorize the grid. Multiply to target.',
                icon: Icons.visibility_outlined,
                accentColor: AppColors.gameSaitan,
                onTap: () {},
              ),

              const SectionHeader('Stats'),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const StatBlock(
                    label: 'Total Games',
                    value: '128',
                    delta: '+12%',
                    isPositiveDelta: true,
                  ),
                  const StatBlock(
                    label: 'Accuracy',
                    value: '84%',
                    delta: '-2%',
                    isPositiveDelta: false,
                  ),
                ],
              ),

              const SectionHeader('Progress'),
              Row(
                children: [
                  ProgressRing(value: 0.25),
                  const SizedBox(width: AppSpacing.space16),
                  ProgressRing(value: 0.75),
                  const SizedBox(width: AppSpacing.space16),
                  ProgressRing(value: 1.0, color: AppColors.success),
                ],
              ),

              const SectionHeader('Empty State'),
              const EmptyState(
                icon: Icons.bar_chart,
                title: 'No stats yet',
                subtitle: 'Play a game to see your stats here.',
              ),
              const SizedBox(height: AppSpacing.space48),
            ],
          ),
        ),
      ),
    );
  }
}
