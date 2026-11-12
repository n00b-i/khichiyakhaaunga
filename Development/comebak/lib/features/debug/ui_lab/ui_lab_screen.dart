import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import '../../../../core/theme/tokens/ui_lab_colors.dart';
import 'components/ui_icon_3d.dart';
import 'components/ui_lab_cards.dart';
import 'tokens/ui_lab_tokens.dart';

enum StreakState {
  firstTime, day1Active, day3Active, milestone7Days, milestone30Days,
  milestone100Days, activePenalty, activeNeutral, atRiskStandard,
  criticalUrgency, brokenDecay, xpFloorReached,
}

class UiLabScreen extends StatelessWidget {
  const UiLabScreen({super.key});

  String _getMilestoneCopy(int days) {
    final copies = [
      "You're unstoppable.", "Getting better yaayy!", "On a roll. Keep going.",
      "Look at you go!", "Absolute consistency.",
    ];
    return copies[Random().nextInt(copies.length)];
  }

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(
        textScaler: const TextScaler.linear(0.85), 
      ),
      child: Scaffold(
        backgroundColor: UiLabColors.canvas,
        body: Stack(
          children: [
            // [CREATIVE BG] The green atmospheric glow behind the profile icon
            Positioned(
              top: UiLabOffsets.bgGlowOffset.dy,
              right: UiLabOffsets.bgGlowOffset.dx,
              child: Container(
                width: UiLabSizes.bgGlowSize,
                height: UiLabSizes.bgGlowSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      UiLabColors.neonGreen.withValues(alpha: UiLabOpacities.avatarGlow),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(UiLabSpacing.xl),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ==========================================
                    // 1. HEADER
                    // ==========================================
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const _ComebakLogo(),
                            const SizedBox(width: UiLabSpacing.sm),
                            Text('Comebak', style: UiLabTypography.brand),
                          ],
                        ),
                        // [UX] Plain icon, no circle, no border.
                        const Icon(
                          LucideIcons.user, 
                          color: Colors.white, 
                          size: UiLabSizes.avatarIconSize,
                        ),
                      ],
                    ),
                    const SizedBox(height: UiLabSpacing.xxl),

                    // ==========================================
                    // 2. GREETING
                    // ==========================================
                    RichText(
                      text: TextSpan(
                        style: UiLabTypography.greeting,
                        children: [
                          const TextSpan(text: 'Good ', style: TextStyle(color: Colors.white)),
                          TextSpan(text: 'evening!', style: TextStyle(color: UiLabColors.neonGreen)),
                        ],
                      ),
                    ),
                    const SizedBox(height: UiLabSpacing.sm),
                    Text('Time to go high and higher 🚀', style: UiLabTypography.greetingSubtitle),
                    const SizedBox(height: UiLabSpacing.xxl),

                    // ==========================================
                    // 3. STREAK STATES GALLERY
                    // ==========================================
                    Text('STREAK STATES GALLERY', style: UiLabTypography.sectionTitle),
                    const SizedBox(height: UiLabSpacing.md),
                    ...StreakState.values.map((state) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: UiLabSpacing.xl),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(state.name.toUpperCase(), style: UiLabTypography.sectionSubtitle),
                            const SizedBox(height: UiLabSpacing.sm),
                            _buildStreakCardForState(state),
                          ],
                        ),
                      );
                    }),

                    const SizedBox(height: UiLabSpacing.lg),
                    
                    // ==========================================
                    // 4. ALL GAMES LISTING
                    // ==========================================
                    Text('GAME LIST (ALL 5 GAMES)', style: UiLabTypography.sectionTitle),
                    const SizedBox(height: UiLabSpacing.md),
                    
                    _buildGameCard(
                      title: 'Add Burst',
                      subtitle: 'Add two numbers to hit the target.',
                      color: UiLabColors.neonOrange,
                      primaryIcon: LucideIcons.plus,
                      secondaryIcon: LucideIcons.equal, 
                    ),
                    const SizedBox(height: UiLabSpacing.lg),
                    _buildGameCard(
                      title: 'Mad Burst',
                      subtitle: 'Multiply two numbers to hit the target.',
                      color: UiLabColors.neonGreen,
                      primaryIcon: LucideIcons.x,
                      secondaryIcon: LucideIcons.equal,
                    ),
                    const SizedBox(height: UiLabSpacing.lg),
                    _buildGameCard(
                      title: 'BODMAS Burst',
                      subtitle: 'Solve maximum BODMAS problems.',
                      color: UiLabColors.neonPurple,
                      primaryIcon: LucideIcons.sigma,
                      secondaryIcon: LucideIcons.divide,
                    ),
                    const SizedBox(height: UiLabSpacing.lg),
                    _buildGameCard(
                      title: 'Small Burst',
                      subtitle: 'Find the smallest number.',
                      color: UiLabColors.neonBlue,
                      primaryIcon: LucideIcons.search,
                      secondaryIcon: LucideIcons.hash,
                    ),
                    const SizedBox(height: UiLabSpacing.lg),
                    _buildGameCard(
                      title: 'Memory of Saitan',
                      subtitle: 'Remember the sequence. Don\'t blink.',
                      color: UiLabColors.vibrantPink,
                      primaryIcon: LucideIcons.brain,
                      secondaryIcon: LucideIcons.eye,
                    ),
                    const SizedBox(height: UiLabSpacing.xxl),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStreakCardForState(StreakState state) {
    switch (state) {
      case StreakState.firstTime:
        return const UiLabStreakCard(
          title: 'Ready to start?', subtitle: 'Your first game awaits.',
          icon: LucideIcons.sparkles, iconColor: UiLabColors.neonGreen,
        );
      case StreakState.day1Active:
        return const UiLabStreakCard(
          title: 'Day 1. A new beginning.', subtitle: 'Great start. Come back tomorrow!',
          icon: LucideIcons.flame, iconColor: UiLabColors.neonOrange,
          totalXpText: '150 XP', deltaXpText: '↑ +150 XP Today', deltaXpColor: UiLabColors.neonGreen,
        );
      case StreakState.day3Active:
        return const UiLabStreakCard(
          title: '3 Days Streak', subtitle: "You're on fire! Keep the chain alive.",
          icon: LucideIcons.flame, iconColor: UiLabColors.neonOrange,
          totalXpText: '1,250 XP', deltaXpText: '↑ +180 XP Today', deltaXpColor: UiLabColors.neonGreen,
        );
      case StreakState.milestone7Days:
        return UiLabStreakCard(
          title: '7 Days Streak!', subtitle: _getMilestoneCopy(7),
          icon: LucideIcons.award, iconColor: UiLabColors.neonYellow,
          totalXpText: '3,500 XP', deltaXpText: '↑ +200 XP Today', deltaXpColor: UiLabColors.neonGreen,
        );
      case StreakState.milestone30Days:
        return UiLabStreakCard(
          title: '30 Days Streak!', subtitle: _getMilestoneCopy(30),
          icon: LucideIcons.shield, iconColor: UiLabColors.neonBlue,
          totalXpText: '15,000 XP', deltaXpText: '↑ +300 XP Today', deltaXpColor: UiLabColors.neonGreen,
        );
      case StreakState.milestone100Days:
        return UiLabStreakCard(
          title: '100 Days Streak!', subtitle: 'Century soon! ${_getMilestoneCopy(100)}',
          icon: LucideIcons.crown, iconColor: UiLabColors.neonPurple,
          totalXpText: '50,000 XP', deltaXpText: '↑ +500 XP Today', deltaXpColor: UiLabColors.neonGreen,
        );
      case StreakState.activePenalty:
        return const UiLabStreakCard(
          title: '3 Days Streak', subtitle: 'Keep the chain alive.',
          icon: LucideIcons.flame, iconColor: UiLabColors.neonOrange,
          totalXpText: '1,200 XP', deltaXpText: '↓ -50 XP Today', deltaXpColor: UiLabColors.vibrantRed,
        );
      case StreakState.activeNeutral:
        return const UiLabStreakCard(
          title: '3 Days Streak', subtitle: 'Keep the chain alive.',
          icon: LucideIcons.flame, iconColor: UiLabColors.neonOrange,
          totalXpText: '1,250 XP', deltaXpText: '0 XP Today', deltaXpColor: UiLabColors.textSecondary,
        );
      case StreakState.atRiskStandard:
        return const UiLabStreakCard(
          title: 'Don\'t lose momentum!', subtitle: 'Play today to keep your streak.',
          icon: LucideIcons.clock, iconColor: UiLabColors.neonYellow,
          totalXpText: '1,250 XP', deltaXpText: '↑ +30 XP Yesterday', deltaXpColor: UiLabColors.neonGreen,
        );
      case StreakState.criticalUrgency:
        return const UiLabStreakCard(
          title: '3 Days at risk!', subtitle: '⏳ 2h left to save your streak!',
          icon: LucideIcons.hourglass, iconColor: UiLabColors.vibrantRed,
          totalXpText: '1,250 XP', deltaXpText: '↑ +30 XP Yesterday', deltaXpColor: UiLabColors.neonGreen,
        );
      case StreakState.brokenDecay:
        return const UiLabStreakCard(
          title: 'Fumbled. Time to Comebak.', subtitle: 'Every master was once a disaster.',
          icon: LucideIcons.rotate_ccw, iconColor: UiLabColors.textSecondary,
          totalXpText: '1,240 XP', deltaXpText: '↓ -10 XP Yesterday', deltaXpColor: UiLabColors.vibrantRed,
        );
      case StreakState.xpFloorReached:
        return const UiLabStreakCard(
          title: 'Fumbled. Time to Comebak.', subtitle: 'Bounce back. Start fresh.', 
          icon: LucideIcons.rotate_ccw, iconColor: UiLabColors.textSecondary,
          totalXpText: '0 XP', deltaXpText: '↓ -10 XP Yesterday', deltaXpColor: UiLabColors.vibrantRed,
        );
    }
  }

  Widget _buildGameCard({
    required String title, required String subtitle, required Color color,
    required IconData primaryIcon, required IconData secondaryIcon, bool isLocked = false,
  }) {
    return UiLabGameCard(
      title: title, subtitle: subtitle, accentColor: color, isLocked: isLocked,
      iconWidget: UiLabIcon3D(primaryIcon: primaryIcon, secondaryIcon: secondaryIcon, color: color),
    );
  }
}

// ==========================================
// COMEBAK LOGO (ECHO LOOP)
// ==========================================
class _ComebakLogo extends StatelessWidget {
  const _ComebakLogo();
  @override
  Widget build(BuildContext context) {
    return Container(
      width: UiLabSizes.logoSize, height: UiLabSizes.logoSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: UiLabColors.neonGreen.withValues(alpha: UiLabOpacities.iconBg),
      ),
      child: CustomPaint(painter: _EchoLoopPainter()),
    );
  }
}

class _EchoLoopPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final glowPaint = Paint()
      ..color = UiLabColors.neonGreen
      ..strokeWidth = UiLabLogo.strokeGlowWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, UiLabLogo.blurRadius); 

    final solidPaint = Paint()
      ..color = UiLabColors.neonGreen
      ..strokeWidth = UiLabLogo.strokeSolidWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    path.moveTo(size.width * UiLabLogo.startX, size.height * UiLabLogo.startY);
    path.quadraticBezierTo(
      size.width * UiLabLogo.cp1X, size.height * UiLabLogo.cp1Y, 
      size.width * UiLabLogo.cp2X, size.height * UiLabLogo.cp2Y
    );
    path.quadraticBezierTo(
      size.width * UiLabLogo.cp3X, size.height * UiLabLogo.cp3Y, 
      size.width * UiLabLogo.cp4X, size.height * UiLabLogo.cp4Y
    );

    canvas.drawPath(path, glowPaint);
    canvas.drawPath(path, solidPaint);
    
    canvas.drawCircle(Offset(size.width * UiLabLogo.dotX, size.height * UiLabLogo.dotY), UiLabLogo.dotGlowRadius, glowPaint);
    canvas.drawCircle(Offset(size.width * UiLabLogo.dotX, size.height * UiLabLogo.dotY), UiLabLogo.dotSolidRadius, solidPaint..style = PaintingStyle.fill);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}