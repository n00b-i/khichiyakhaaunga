import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import '../1_foundations/tokens/ui_lab_tokens.dart';
import '../1_foundations/ui_lab_copy.dart';
import '../2_atoms/comebak_icon_3d.dart';
import '../3_molecules/comebak_game_card.dart';
import '../3_molecules/comebak_streak_card.dart';
import '../4_organisms/comebak_header.dart';
import '../4_organisms/comebak_milestone_banner.dart'; // [NEW IMPORT]

// ==============================================================================
// [FLOW] ComebakHomeFlow
// ------------------------------------------------------------------------------
// PURPOSE: The final stitched Home Screen.
// ARCHITECTURE: This page proves our Atoms, Molecules, and Organisms work
// together perfectly. It acts as the blueprint for the production app.
// ==============================================================================
class ComebakHomeFlow extends StatelessWidget {
  const ComebakHomeFlow({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ComebakColors.canvas,
      body: Stack(
        children: [
          // [CREATIVE BG] The soft green atmospheric glow in the top right corner.
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
                    ComebakColors.neonGreen.withValues(alpha: ComebakLayout.opacityAvatarGlow),
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
                  // 1. [ORGANISM] Header
                  ComebakHeader(
                    onProfileTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text(ComebakCopy.navProfile)),
                      );
                    },
                  ),
                  const SizedBox(height: ComebakLayout.spaceXxl),

                  // 2. [MOLECULE] Greeting Text
                  RichText(
                    text: TextSpan(
                      style: ComebakTypography.greeting,
                      children: [
                        const TextSpan(text: ComebakCopy.greetingPrefix, style: TextStyle(color: ComebakColors.textPrimary)),
                        const TextSpan(text: ComebakCopy.greetingHighlight, style: TextStyle(color: ComebakColors.neonGreen)),
                      ],
                    ),
                  ),
                  const SizedBox(height: ComebakLayout.spaceSm),
                  Text(ComebakCopy.greetingSubtitle, style: ComebakTypography.greetingSubtitle),
                  const SizedBox(height: ComebakLayout.spaceXxl),

                  // 3. [MOLECULE] Streak Card (Showing Day 3 Active State)
                  const ComebakStreakCard(
                    title: ComebakCopy.streakDay3Title,
                    subtitle: ComebakCopy.streakDay3Subtitle,
                    icon: LucideIcons.flame,
                    iconColor: ComebakColors.neonOrange,
                    totalXpText: '1,250 XP',
                    deltaXpText: ComebakCopy.xpTodayPositive,
                    deltaXpColor: ComebakColors.neonGreen,
                  ),
                  const SizedBox(height: ComebakLayout.spaceXxl),

                  // 4. [MOLECULE] Section Header
                  Row(
                    children: [
                      Container(
                        width: ComebakLayout.spaceXs, 
                        height: ComebakLayout.spaceXl, 
                        color: ComebakColors.neonGreen, 
                        margin: const EdgeInsets.only(right: ComebakLayout.spaceSm)
                      ),
                      Text(ComebakCopy.sectionMathBurst, style: ComebakTypography.titleLarge),
                    ],
                  ),
                  const SizedBox(height: ComebakLayout.spaceLg),

                  // 5. [MOLECULE] Game Grid
                  _buildGameCard(
                    title: ComebakCopy.gameAddTitle,
                    subtitle: ComebakCopy.gameAddDesc,
                    color: ComebakColors.neonOrange,
                    primaryIcon: LucideIcons.plus,
                    secondaryIcon: LucideIcons.equal,
                  ),
                  const SizedBox(height: ComebakLayout.spaceLg),
                  _buildGameCard(
                    title: ComebakCopy.gameMadTitle,
                    subtitle: ComebakCopy.gameMadDesc,
                    color: ComebakColors.neonGreen,
                    primaryIcon: LucideIcons.x,
                    secondaryIcon: LucideIcons.equal,
                  ),
                  const SizedBox(height: ComebakLayout.spaceLg),
                  _buildGameCard(
                    title: ComebakCopy.gameBodmasTitle,
                    subtitle: ComebakCopy.gameBodmasDesc,
                    color: ComebakColors.neonPurple,
                    primaryIcon: LucideIcons.sigma,
                    secondaryIcon: LucideIcons.divide,
                  ),
                  const SizedBox(height: ComebakLayout.spaceLg),
                  _buildGameCard(
                    title: ComebakCopy.gameSmallTitle,
                    subtitle: ComebakCopy.gameSmallDesc,
                    color: ComebakColors.neonBlue,
                    primaryIcon: LucideIcons.search,
                    secondaryIcon: LucideIcons.hash,
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

  // [DRY PRINCIPLE] Factory method to build Game Cards without repeating the 
  // Icon3D stacking logic 5 times.
  Widget _buildGameCard({
    required String title,
    required String subtitle,
    required Color color,
    required IconData primaryIcon,
    required IconData secondaryIcon,
  }) {
    return ComebakGameCard(
      title: title,
      subtitle: subtitle,
      accentColor: color,
      onTap: () {},
      iconWidget: ComebakIcon3D(
        primaryIcon: primaryIcon,
        secondaryIcon: secondaryIcon,
        color: color,
      ),
    );
  }
}