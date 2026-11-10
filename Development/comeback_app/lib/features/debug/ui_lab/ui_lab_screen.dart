import 'package:flutter/material.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/ui/components/comebak_button.dart';
import '../../../core/ui/components/game_card.dart';

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
              const SizedBox(height: AppSpacing.space32),

              // 1. Buttons
              const Text('BUTTONS', style: AppTextStyles.labelSmall),
              const SizedBox(height: AppSpacing.space12),
              ComebakButton(text: 'Primary Button', onPressed: () {}),
              const SizedBox(height: AppSpacing.space8),
              ComebakButton(
                text: 'Secondary Button',
                variant: ComebakButtonVariant.secondary,
                onPressed: () {},
              ),
              const SizedBox(height: AppSpacing.space8),
              ComebakButton(
                text: 'Ghost Button',
                variant: ComebakButtonVariant.ghost,
                onPressed: () {},
              ),
              const SizedBox(height: AppSpacing.space8),
              ComebakButton(
                text: 'Danger Button',
                variant: ComebakButtonVariant.danger,
                onPressed: () {},
              ),
              const SizedBox(height: AppSpacing.space8),
              ComebakButton(
                text: 'Loading',
                isLoading: true,
                onPressed: () {},
              ),
              const SizedBox(height: AppSpacing.space32),

              // 2. Game Cards
              const Text('GAME CARDS', style: AppTextStyles.labelSmall),
              const SizedBox(height: AppSpacing.space12),
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
              const SizedBox(height: AppSpacing.space32),
            ],
          ),
        ),
      ),
    );
  }
}
