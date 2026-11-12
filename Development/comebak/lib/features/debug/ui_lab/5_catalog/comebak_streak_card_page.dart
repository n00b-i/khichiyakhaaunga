import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import '../1_foundations/tokens/ui_lab_tokens.dart';
import '../1_foundations/ui_lab_copy.dart';
import '../3_molecules/comebak_streak_card.dart';

// [STATE PATTERN] Enum to manage all edge cases for the Streak Card.
enum StreakState {
  firstTime,
  day1Active,
  day3Active,
  milestone7Days,
  milestone30Days,
  milestone100Days,
  activePenalty,
  activeNeutral,
  atRiskStandard,
  criticalUrgency,
  brokenDecay,
  xpFloorReached,
}

class ComebakStreakCardPage extends StatelessWidget {
  const ComebakStreakCardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ComebakColors.canvas,
      appBar: AppBar(
        backgroundColor: ComebakColors.surface,
        title: Text('Streak Card States', style: ComebakTypography.titleLarge),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(ComebakLayout.spaceXl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ...StreakState.values.map((state) {
              return Padding(
                padding: const EdgeInsets.only(bottom: ComebakLayout.spaceXl),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Label showing which state is being rendered
                    Text(
                      state.name.toUpperCase(), 
                      style: ComebakTypography.sectionSubtitle.copyWith(color: ComebakColors.neonGreen)
                    ),
                    const SizedBox(height: ComebakLayout.spaceSm),
                    _buildStreakCardForState(state),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  // [DRY RULE] Maps the enum to the component. The component doesn't know about the enum.
  Widget _buildStreakCardForState(StreakState state) {
    switch (state) {
      case StreakState.firstTime:
        return const ComebakStreakCard(
          title: ComebakCopy.streakFirstTimeTitle,
          subtitle: ComebakCopy.streakFirstTimeSubtitle,
          icon: LucideIcons.sparkles,
          iconColor: ComebakColors.neonGreen,
        );
      case StreakState.day1Active:
        return const ComebakStreakCard(
          title: ComebakCopy.streakDay1Title,
          subtitle: ComebakCopy.streakDay1Subtitle,
          icon: LucideIcons.flame,
          iconColor: ComebakColors.neonOrange,
          totalXpText: '150 XP',
          deltaXpText: ComebakCopy.xpTodayPositive,
          deltaXpColor: ComebakColors.neonGreen,
        );
      case StreakState.day3Active:
        return const ComebakStreakCard(
          title: ComebakCopy.streakDay3Title,
          subtitle: ComebakCopy.streakDay3Subtitle,
          icon: LucideIcons.flame,
          iconColor: ComebakColors.neonOrange,
          totalXpText: '1,250 XP',
          deltaXpText: ComebakCopy.xpTodayPositive,
          deltaXpColor: ComebakColors.neonGreen,
        );
      case StreakState.milestone7Days:
        return const ComebakStreakCard(
          title: ComebakCopy.streak7Title,
          subtitle: "You're unstoppable.", // Pulled from random list in real app
          icon: LucideIcons.award,
          iconColor: ComebakColors.neonYellow,
          totalXpText: '3,500 XP',
          deltaXpText: ComebakCopy.xpTodayPositive,
          deltaXpColor: ComebakColors.neonGreen,
        );
      case StreakState.milestone30Days:
        return const ComebakStreakCard(
          title: ComebakCopy.streak30Title,
          subtitle: "Getting better yaayy!",
          icon: LucideIcons.shield,
          iconColor: ComebakColors.neonBlue,
          totalXpText: '15,000 XP',
          deltaXpText: ComebakCopy.xpTodayPositive,
          deltaXpColor: ComebakColors.neonGreen,
        );
      case StreakState.milestone100Days:
        return const ComebakStreakCard(
          title: ComebakCopy.streak100Title,
          subtitle: "Century soon! Absolute consistency.",
          icon: LucideIcons.crown,
          iconColor: ComebakColors.neonPurple,
          totalXpText: '50,000 XP',
          deltaXpText: ComebakCopy.xpTodayPositive,
          deltaXpColor: ComebakColors.neonGreen,
        );
      case StreakState.activePenalty:
        return const ComebakStreakCard(
          title: ComebakCopy.streakDay3Title,
          subtitle: ComebakCopy.streakDay3Subtitle,
          icon: LucideIcons.flame,
          iconColor: ComebakColors.neonOrange,
          totalXpText: '1,200 XP',
          deltaXpText: ComebakCopy.xpTodayNegative,
          deltaXpColor: ComebakColors.vibrantRed,
        );
      case StreakState.activeNeutral:
        return const ComebakStreakCard(
          title: ComebakCopy.streakDay3Title,
          subtitle: ComebakCopy.streakDay3Subtitle,
          icon: LucideIcons.flame,
          iconColor: ComebakColors.neonOrange,
          totalXpText: '1,250 XP',
          deltaXpText: ComebakCopy.xpTodayNeutral,
          deltaXpColor: ComebakColors.textSecondary,
        );
      case StreakState.atRiskStandard:
        return const ComebakStreakCard(
          title: ComebakCopy.streakAtRiskTitle,
          subtitle: ComebakCopy.streakAtRiskSubtitle,
          icon: LucideIcons.clock,
          iconColor: ComebakColors.neonYellow,
          totalXpText: '1,250 XP',
          deltaXpText: ComebakCopy.xpYesterdayPositive,
          deltaXpColor: ComebakColors.neonGreen,
        );
      case StreakState.criticalUrgency:
        return const ComebakStreakCard(
          title: ComebakCopy.streakCriticalTitle,
          subtitle: ComebakCopy.streakCriticalSubtitle,
          icon: LucideIcons.hourglass,
          iconColor: ComebakColors.vibrantRed,
          totalXpText: '1,250 XP',
          deltaXpText: ComebakCopy.xpYesterdayPositive,
          deltaXpColor: ComebakColors.neonGreen,
        );
      case StreakState.brokenDecay:
        return const ComebakStreakCard(
          title: ComebakCopy.streakBrokenTitle,
          subtitle: ComebakCopy.streakBrokenSubtitle,
          icon: LucideIcons.rotate_ccw,
          iconColor: ComebakColors.textSecondary,
          totalXpText: '1,240 XP',
          deltaXpText: ComebakCopy.xpYesterdayNegative,
          deltaXpColor: ComebakColors.vibrantRed,
        );
      case StreakState.xpFloorReached:
        return const ComebakStreakCard(
          title: ComebakCopy.streakFloorTitle,
          subtitle: ComebakCopy.streakFloorSubtitle,
          icon: LucideIcons.rotate_ccw,
          iconColor: ComebakColors.textSecondary,
          totalXpText: '0 XP',
          deltaXpText: ComebakCopy.xpYesterdayNegative,
          deltaXpColor: ComebakColors.vibrantRed,
        );
    }
  }
}