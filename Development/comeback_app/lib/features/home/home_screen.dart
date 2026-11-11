import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/game_card.dart';
import '../../core/games/configs/game_configs.dart';
import '../games/add_burst/add_burst_screen.dart';
import '../games/mad_burst/mad_burst_screen.dart';
import '../games/bodmas_burst/bodmas_burst_screen.dart';
import '../games/number_hunt/number_hunt_screen.dart';
import '../games/memory_of_saitan/memory_of_saitan_screen.dart';

class HomeScreen extends StatelessWidget {
  final String? userName;
  const HomeScreen({super.key, this.userName});

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning';
    if (h < 16) return 'Good afternoon';
    return 'Good evening';
  }

  String _greetingWithName() {
    final base = _greeting();
    return (userName == null || userName!.isEmpty) ? base : '$base, $userName';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: AppSpacing.lg),
              Text(_greetingWithName(), style: AppTextStyles.display, softWrap: true),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Time to go high and higher',
                style: AppTextStyles.body.copyWith(color: AppColors.textPrimary.withValues(alpha: 0.6)),
                softWrap: true,
              ),
              const SizedBox(height: AppSpacing.xl),
              // --- CATEGORY 1: MATH BURST ---
              Text(
                'MATH BURST',
                style: AppTextStyles.body.copyWith(
                  color: AppColors.vibrantOrange,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              // [ISSUE-27] Consuming GameConfig as single source of truth for titles and instructions.
              GameCard(
                title: AddBurstConfig.standard.title,
                description: AddBurstConfig.standard.instructions,
                icon: Icons.add_circle_outline,
                accentColor: AppColors.vibrantOrange,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const AddBurstScreen(accentColor: AppColors.vibrantOrange)),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              GameCard(
                title: MadBurstConfig.standard.title,
                description: MadBurstConfig.standard.instructions,
                icon: Icons.close,
                accentColor: AppColors.vibrantOrange,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const MadBurstScreen(accentColor: AppColors.vibrantOrange)),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              GameCard(
                title: BodmasBurstConfig.standard.title,
                description: BodmasBurstConfig.standard.instructions,
                icon: Icons.calculate_outlined,
                accentColor: AppColors.vibrantOrange,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const BodmasBurstScreen(accentColor: AppColors.vibrantOrange)),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              GameCard(
                title: NumberHuntConfig.standard.title,
                description: NumberHuntConfig.standard.instructions,
                icon: Icons.search,
                accentColor: AppColors.vibrantOrange,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const NumberHuntScreen(accentColor: AppColors.vibrantOrange)),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              // --- CATEGORY 2: SAITAN'S MEMORY ---
              Text(
                'SAITAN\'S MEMORY',
                style: AppTextStyles.body.copyWith(
                  color: AppColors.vibrantPurple,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              GameCard(
                title: SaitanConfig.addition.title,
                description: SaitanConfig.addition.instructions,
                icon: Icons.flashlight_on_outlined,
                accentColor: AppColors.vibrantPurple,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const MemoryOfSaitanScreen(accentColor: AppColors.vibrantPurple)),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              GameCard(
                title: SaitanConfig.multiplication.title,
                description: SaitanConfig.multiplication.instructions,
                icon: Icons.flashlight_on_outlined,
                accentColor: AppColors.vibrantPurple,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const MemoryOfSaitanScreen(
                      isMultiplication: true,
                      accentColor: AppColors.vibrantPurple,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}