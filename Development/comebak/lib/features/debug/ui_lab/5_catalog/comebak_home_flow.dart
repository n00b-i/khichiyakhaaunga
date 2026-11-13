import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import '../1_foundations/tokens/ui_lab_tokens.dart';
import '../1_foundations/ui_lab_copy.dart';
import '../1_foundations/ui_lab_haptics.dart';
import '../2_atoms/comebak_add_burst_icon.dart';
import '../2_atoms/comebak_mad_burst_icon.dart';
import '../2_atoms/comebak_bodmas_burst_icon.dart';
import '../2_atoms/comebak_small_burst_icon.dart';
import '../2_atoms/comebak_devils_memory_icon.dart';
import '../3_molecules/comebak_game_card.dart';
import '../3_molecules/comebak_streak_card.dart';
import '../4_organisms/comebak_header.dart';
import '../4_organisms/comebak_milestone_banner.dart';
import 'profile_flow/comebak_profile_page.dart';
import 'stats_flow/comebak_stats_page.dart';

// ==============================================================================
// [GAME ENGINE IMPORTS]
// These are the actual playable games. The Home screen routes to these.
// ==============================================================================
import '../../../games/add_burst/add_burst_screen.dart';
import '../../../games/mad_burst/mad_burst_screen.dart';
import '../../../games/bodmas_burst/bodmas_burst_screen.dart';
import '../../../games/number_hunt/number_hunt_screen.dart';
import '../../../games/devils_memory/devils_memory_screen.dart';

// ==============================================================================
// [FLOW] ComebakHomeFlow
// ------------------------------------------------------------------------------
// PURPOSE: The final stitched Home Screen.
// ARCHITECTURE: Uses the 2-column grid layout and the 3D CustomPainter icons.
// NAVIGATION:
// - Header Profile Tap -> ComebakProfilePage
// - Streak Card Tap -> ComebakStatsPage
// - Game Card Tap -> Actual Playable Game Screen
// ==============================================================================
class ComebakHomeFlow extends StatelessWidget {
  const ComebakHomeFlow({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ComebakColors.canvas,
      body: Stack(
        children: [
          // [CREATIVE BG] Soft green atmospheric glow
          Positioned(
            top: ComebakLayout.offsetBgGlow.dy,
            right: ComebakLayout.offsetBgGlow.dx,
            child: Container(
              width: ComebakLayout.bgGlowSize,
              height: ComebakLayout.bgGlowSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    ComebakColors.neonGreen.withValues(
                      alpha: ComebakLayout.opacityAvatarGlow,
                    ),
                    ComebakColors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // [MAIN CONTENT] Scrollable safe area.
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(ComebakLayout.spaceXl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. [ORGANISM] Header (Profile Tap -> Profile Page)
                  ComebakHeader(
                    onProfileTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ComebakProfilePage(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: ComebakLayout.spaceXxl),

                  // 2. [MOLECULE] Greeting Text
                  RichText(
                    text: TextSpan(
                      style: ComebakTypography.greeting,
                      children: [
                        const TextSpan(
                          text: ComebakCopy.greetingPrefix,
                          style: TextStyle(color: ComebakColors.textPrimary),
                        ),
                        const TextSpan(
                          text: ComebakCopy.greetingHighlight,
                          style: TextStyle(color: ComebakColors.neonGreen),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: ComebakLayout.spaceSm),
                  Text(
                    ComebakCopy.greetingSubtitle,
                    style: ComebakTypography.greetingSubtitle,
                  ),
                  const SizedBox(height: ComebakLayout.spaceXxl),

                  // 3. [MOLECULE] Streak Card (Tap -> Stats Page)
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ComebakStatsPage(),
                        ),
                      );
                    },
                    child: const ComebakStreakCard(
                      title: ComebakCopy.streakDay3Title,
                      subtitle: ComebakCopy.streakDay3Subtitle,
                      icon: LucideIcons.flame,
                      iconColor: ComebakColors.neonOrange,
                      totalXpText: '1,250 XP',
                      deltaXpText: ComebakCopy.xpTodayPositive,
                      deltaXpColor: ComebakColors.neonGreen,
                    ),
                  ),
                  const SizedBox(height: ComebakLayout.spaceXxl),

                  // 4. [MOLECULE] Section Header
                  Row(
                    children: [
                      Container(
                        width: ComebakLayout.spaceXs,
                        height: ComebakLayout.spaceXl,
                        color: ComebakColors.neonGreen,
                        margin: const EdgeInsets.only(
                          right: ComebakLayout.spaceSm,
                        ),
                      ),
                      Text(
                        ComebakCopy.sectionMathBurst,
                        style: ComebakTypography.titleLarge,
                      ),
                    ],
                  ),
                  const SizedBox(height: ComebakLayout.spaceLg),

                  // 5. [GRID] 2-Column Game Grid
                  // ROW 1: Add & Mad
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: ComebakGameCard(
                          title: ComebakCopy.gameAddTitle,
                          subtitle: ComebakCopy.gameAddDesc,
                          accentColor: ComebakColors.neonOrange,
                          onTap: () {
                            ComebakHaptics.tap();
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const AddBurstScreen(
                                  accentColor: ComebakColors.neonOrange,
                                ),
                              ),
                            );
                          },
                          iconWidget: ComebakAddBurstIcon(
                            size: ComebakLayout.gameIconSize,
                          ),
                        ),
                      ),
                      const SizedBox(width: ComebakLayout.spaceLg),
                      Expanded(
                        child: ComebakGameCard(
                          title: ComebakCopy.gameMadTitle,
                          subtitle: ComebakCopy.gameMadDesc,
                          accentColor: ComebakColors.neonGreen,
                          onTap: () {
                            ComebakHaptics.tap();
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const MadBurstScreen(
                                  accentColor: ComebakColors.neonGreen,
                                ),
                              ),
                            );
                          },
                          iconWidget: ComebakMadBurstIcon(
                            size: ComebakLayout.gameIconSize,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: ComebakLayout.spaceLg),

                  // ROW 2: BODMAS & Number Hunt
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: ComebakGameCard(
                          title: ComebakCopy.gameBodmasTitle,
                          subtitle: ComebakCopy.gameBodmasDesc,
                          accentColor: ComebakColors.neonPurple,
                          onTap: () {
                            ComebakHaptics.tap();
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const BodmasBurstScreen(
                                  accentColor: ComebakColors.neonPurple,
                                ),
                              ),
                            );
                          },
                          iconWidget: ComebakBodmasBurstIcon(
                            size: ComebakLayout.gameIconSize,
                          ),
                        ),
                      ),
                      const SizedBox(width: ComebakLayout.spaceLg),
                      Expanded(
                        child: ComebakGameCard(
                          title: ComebakCopy.gameSmallTitle,
                          subtitle: ComebakCopy.gameSmallDesc,
                          accentColor: ComebakColors.neonBlue,
                          onTap: () {
                            ComebakHaptics.tap();
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const NumberHuntScreen(
                                  accentColor: ComebakColors.neonBlue,
                                ),
                              ),
                            );
                          },
                          iconWidget: ComebakSmallBurstIcon(
                            size: ComebakLayout.gameIconSize,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: ComebakLayout.spaceLg),

                  // ROW 3: Devil's Memory & Locked Game
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: ComebakGameCard(
                          title: ComebakCopy.gameDevilsMemoryTitle,
                          subtitle: ComebakCopy.gameDevilsMemoryDesc,
                          accentColor: ComebakColors.vibrantPink,
                          onTap: () {
                            ComebakHaptics.tap();
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const DevilsMemoryScreen(
                                  accentColor: ComebakColors.vibrantPink,
                                ),
                              ),
                            );
                          },
                          iconWidget: ComebakDevilsMemoryIcon(
                            size: ComebakLayout.gameIconSize,
                          ),
                        ),
                      ),
                      const SizedBox(width: ComebakLayout.spaceLg),
                      // [LOCKED GAME] Fills the empty grid slot
                      Expanded(
                        child: ComebakGameCard(
                          title: 'Locked Game',
                          subtitle: 'Coming soon to Comebak.',
                          accentColor: ComebakColors.textSecondary,
                          isLocked: true,
                          onTap: () {},
                          iconWidget: const SizedBox(),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: ComebakLayout.spaceXxl),

                  // 6. [ORGANISM] Milestone Banner
                  ComebakMilestoneBanner(
                    onViewProgress: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('View Progress Tapped')),
                      );
                    },
                  ),
                  const SizedBox(height: ComebakLayout.spaceXxl),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
