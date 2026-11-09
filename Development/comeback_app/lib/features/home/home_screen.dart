import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/game_card.dart';
import '../common/coming_soon_screen.dart';

class HomeScreen extends StatelessWidget {
  final String? userName;

  const HomeScreen({super.key, this.userName});

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning';
    if (h < 17) return 'Good afternoon';
    return 'Good evening';
  }

  String _greetingWithName() {
    final base = _greeting();
    return (userName == null || userName!.isEmpty) ? base : '$base, $userName';
  }

  void _openGame(BuildContext context, String gameName) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ComingSoonScreen(gameName: gameName),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: AppSpacing.lg),
              Text(_greetingWithName(), style: AppTextStyles.display),
              SizedBox(height: AppSpacing.xs),
              Text(
                '#Time to go high and higher#',
                style: AppTextStyles.body.copyWith(
                  color: AppColors.textPrimary.withValues(alpha: 0.6),
                ),
              ),
              SizedBox(height: AppSpacing.xl),
              GameCard(
                title: 'Add Burst',
                description: 'Add two numbers to hit the target.',
                icon: Icons.add_circle_outline,
                accentColor: AppColors.vibrantGreen,
                onTap: () => _openGame(context, 'Add Burst'),
              ),
              SizedBox(height: AppSpacing.sm),
              GameCard(
                title: 'Mad Burst',
                description: 'Multiply two numbers to hit the target.',
                icon: Icons.close,
                accentColor: AppColors.vibrantOrange,
                onTap: () => _openGame(context, 'Mad Burst'),
              ),
              SizedBox(height: AppSpacing.sm),
              GameCard(
                title: 'Math Burst',
                description: 'Solve equations fast with the custom numpad.',
                icon: Icons.calculate_outlined,
                accentColor: AppColors.vibrantBlue,
                onTap: () => _openGame(context, 'Math Burst'),
              ),
              SizedBox(height: AppSpacing.sm),
              GameCard(
                title: 'Memory of Saitan',
                description: 'Reveal numbers in the dark with a flashlight.',
                icon: Icons.flashlight_on_outlined,
                accentColor: AppColors.vibrantPurple,
                onTap: () => _openGame(context, 'Memory of Saitan'),
              ),
              SizedBox(height: AppSpacing.lg),
            ],
          ),
        ),
      ),
    );
  }
}
