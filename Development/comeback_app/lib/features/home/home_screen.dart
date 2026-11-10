import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/game_card.dart';
import '../games/add_burst/add_burst_screen.dart';
import '../games/mad_burst/mad_burst_screen.dart';
import '../games/math_burst/math_burst_screen.dart';
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
          padding: EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: AppSpacing.lg),
              Text(_greetingWithName(), style: AppTextStyles.display, softWrap: true),
              SizedBox(height: AppSpacing.xs),
              Text('Time to go high and higher', style: AppTextStyles.body.copyWith(color: AppColors.textPrimary.withValues(alpha: 0.6)), softWrap: true),
              SizedBox(height: AppSpacing.xl),

              // --- CATEGORY 1: MATH BURST ---
              Text('MATH BURST', style: AppTextStyles.body.copyWith(color: AppColors.vibrantOrange, fontWeight: FontWeight.w700, letterSpacing: 1.5)),
              SizedBox(height: AppSpacing.sm),
              
              GameCard(
                title: 'Add Burst',
                description: 'Add two numbers to hit the target.',
                icon: Icons.add_circle_outline,
                accentColor: AppColors.vibrantOrange,
                onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AddBurstScreen(accentColor: AppColors.vibrantOrange))),
              ),
              SizedBox(height: AppSpacing.sm),
              
              GameCard(
                title: 'Mad Burst',
                description: 'Multiply two numbers to hit the target.',
                icon: Icons.close,
                accentColor: AppColors.vibrantOrange,
                onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const MadBurstScreen(accentColor: AppColors.vibrantOrange))),
              ),
              SizedBox(height: AppSpacing.sm),
              
              GameCard(
                title: 'BODMAS Burst',
                description: 'Solve maximum BODMAS problems.',
                icon: Icons.calculate_outlined,
                accentColor: AppColors.vibrantOrange,
                onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const MathBurstScreen(accentColor: AppColors.vibrantOrange))),
              ),
              SizedBox(height: AppSpacing.sm),
              
              GameCard(
                title: 'Small Burst',
                description: 'Find the smallest number.',
                icon: Icons.search,
                accentColor: AppColors.vibrantOrange,
                onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const NumberHuntScreen(accentColor: AppColors.vibrantOrange))),
              ),

              SizedBox(height: AppSpacing.xl),

              // --- CATEGORY 2: SAITAN'S MEMORY ---
              Text('SAITAN\'S MEMORY', style: AppTextStyles.body.copyWith(color: AppColors.vibrantPurple, fontWeight: FontWeight.w700, letterSpacing: 1.5)),
              SizedBox(height: AppSpacing.sm),

              GameCard(
                title: 'Saitan +',
                description: 'Memorize the grid in the dark. Add to target.',
                icon: Icons.flashlight_on_outlined,
                accentColor: AppColors.vibrantPurple,
                onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const MemoryOfSaitanScreen(isMultiplication: false, accentColor: AppColors.vibrantPurple))),
              ),
              SizedBox(height: AppSpacing.sm),

              GameCard(
                title: 'Saitan X',
                description: 'Memorize the grid in the dark. Multiply to target.',
                icon: Icons.flashlight_on_outlined,
                accentColor: AppColors.vibrantPurple,
                onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const MemoryOfSaitanScreen(isMultiplication: true, accentColor: AppColors.vibrantPurple))),
              ),
              
              SizedBox(height: AppSpacing.lg * 2),
            ],
          ),
        ),
      ),
    );
  }
}