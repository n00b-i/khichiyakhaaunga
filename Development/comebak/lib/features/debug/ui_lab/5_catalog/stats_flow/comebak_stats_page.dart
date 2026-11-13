import 'package:flutter/material.dart';
import '../../1_foundations/tokens/ui_lab_tokens.dart';
import '../../1_foundations/ui_lab_copy.dart';
import '../../1_foundations/ui_lab_haptics.dart';
import '../../2_atoms/comebak_flame_3d.dart';
import '../../2_atoms/comebak_xp_icon.dart';
import '../../2_atoms/comebak_add_burst_icon.dart';
import '../../2_atoms/comebak_mad_burst_icon.dart';
import '../../2_atoms/comebak_bodmas_burst_icon.dart';
import '../../2_atoms/comebak_small_burst_icon.dart';
import '../../2_atoms/comebak_saitan_icon.dart';
import '../../3_molecules/comebak_game_card.dart';
import '../game_flow/comebak_game_hud_page.dart';

enum _StatsState { populated, empty, partial, brokenStreak }

class ComebakStatsPage extends StatefulWidget {
  const ComebakStatsPage({super.key});

  @override
  State<ComebakStatsPage> createState() => _ComebakStatsPageState();
}

class _ComebakStatsPageState extends State<ComebakStatsPage> {
  _StatsState _currentState = _StatsState.populated;

  void _launchGame() {
    ComebakHaptics.tap();
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ComebakGameHudPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ComebakColors.canvas,
      body: Stack(
        children: [
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    ComebakColors.neonGreen.withValues(alpha: 0.08),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: ComebakLayout.spaceXl,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: ComebakLayout.spaceXxl),

                  // HEADER
                  Text(
                    'YOUR STATS',
                    style: ComebakTypography.greeting.copyWith(
                      letterSpacing: -ComebakLayout.spaceXs / 4,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: ComebakLayout.spaceXs),
                  Text(
                    'LIFETIME PERFORMANCE',
                    style: ComebakTypography.labelSmall.copyWith(
                      color: ComebakColors.textSecondary,
                      letterSpacing: ComebakLayout.spaceXs * 0.6,
                    ),
                  ),

                  const SizedBox(height: ComebakLayout.spaceXxl * 1.5),

                  // --- COMPONENT STATES DEMO ---
                  if (_currentState == _StatsState.empty)
                    _buildEmptyState()
                  else ...[
                    Text(
                      'XP STATES',
                      style: ComebakTypography.labelSmall.copyWith(
                        color: ComebakColors.textSecondary,
                        letterSpacing: ComebakLayout.borderGradient,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: ComebakLayout.spaceMd),

                    // 1. Positive State
                    _buildHeroCard(
                      streak: '12',
                      xp: '1,224 XP',
                      xpColor: ComebakColors.textPrimary,
                      flameKey: 'flame_pos',
                    ),
                    const SizedBox(height: ComebakLayout.spaceMd),

                    // 2. Zero State
                    _buildHeroCard(
                      streak: '0',
                      xp: '0 XP',
                      xpColor: ComebakColors.textSecondary, // Muted
                      flameKey: 'flame_zero',
                    ),
                    const SizedBox(height: ComebakLayout.spaceMd),

                    // 3. Negative State
                    _buildHeroCard(
                      streak: '0',
                      xp: '-500 XP',
                      xpColor: ComebakColors.vibrantRed, // Red
                      flameKey: 'flame_neg',
                    ),

                    const SizedBox(height: ComebakLayout.spaceXxl * 1.5),

                    // LEDGER
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'BY CHALLENGE',
                          style: ComebakTypography.labelSmall.copyWith(
                            color: ComebakColors.textSecondary,
                            letterSpacing: ComebakLayout.borderGradient,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          'PERSONAL BEST',
                          style: ComebakTypography.labelSmall.copyWith(
                            color: ComebakColors.textSecondary,
                            letterSpacing: ComebakLayout.borderGradient,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: ComebakLayout.spaceMd),

                    _buildLedgerRow(
                      'Add Burst',
                      '142',
                      const ComebakAddBurstIcon(size: ComebakLayout.spaceXxl),
                      isLocked: false,
                      onTap: _launchGame,
                    ),
                    _buildLedgerRow(
                      'Mad Burst',
                      '340',
                      const ComebakMadBurstIcon(size: ComebakLayout.spaceXxl),
                      isLocked: false,
                      isHighest: true,
                      onTap: _launchGame,
                    ),
                    _buildLedgerRow(
                      'BODMAS Burst',
                      '210',
                      const ComebakBodmasBurstIcon(
                        size: ComebakLayout.spaceXxl,
                      ),
                      isLocked: _currentState == _StatsState.partial,
                      onTap: _launchGame,
                    ),
                    _buildLedgerRow(
                      'Number Hunt',
                      '185',
                      const ComebakSmallBurstIcon(size: ComebakLayout.spaceXxl),
                      isLocked: _currentState == _StatsState.partial,
                      onTap: _launchGame,
                    ),
                    _buildLedgerRow(
                      'Devil\'s Memory',
                      '95',
                      const ComebakSaitanIcon(size: ComebakLayout.spaceXxl),
                      isLocked: true,
                      onTap: _launchGame,
                    ),
                  ],

                  const SizedBox(height: ComebakLayout.spaceXxl * 2),
                ],
              ),
            ),
          ),

          _buildStateSwitcher(),
        ],
      ),
    );
  }

  // ===========================================================================
  // HERO CARD (Now accepts parameters to show all states)
  // ===========================================================================
  Widget _buildHeroCard({
    required String streak, 
    required String xp, 
    required Color xpColor,
    required String flameKey,
  }) {
    return Container(
      padding: const EdgeInsets.all(ComebakLayout.spaceLg),
      decoration: BoxDecoration(
        color: ComebakColors.surface,
        borderRadius: BorderRadius.circular(ComebakLayout.radiusLg),
        border: Border.all(color: ComebakColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Streak
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ComebakFlame3D(size: ComebakLayout.spaceXxl, key: ValueKey(flameKey)),
              const SizedBox(width: ComebakLayout.spaceSm),
              Text(
                '$streak DAYS',
                style: ComebakTypography.titleLarge.copyWith(
                  color: streak == '0'
                      ? ComebakColors.textSecondary
                      : ComebakColors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),

          // Total XP
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const ComebakXpIcon(
                icon: Icons.bolt,
                color: ComebakColors.neonGreen,
                size: ComebakLayout.spaceXl + ComebakLayout.spaceXs,
              ),
              const SizedBox(width: ComebakLayout.spaceSm),
              Text(
                xp,
                style: ComebakTypography.titleLarge.copyWith(
                  color: xpColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // EMPTY STATE
  // ===========================================================================
  Widget _buildEmptyState() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: ComebakLayout.spaceXxl),
        Center(
          child: Column(
            children: [
              const ComebakFlame3D(size: ComebakLayout.gameIconSize),
              const SizedBox(height: ComebakLayout.spaceLg),
              Text(
                'Challenge Yourself Now!',
                style: ComebakTypography.greeting.copyWith(
                  fontSize: 28,
                  color: ComebakColors.textPrimary,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -1.0,
                ),
              ),
              const SizedBox(height: ComebakLayout.spaceXs),
              Text(
                'Play your first game to see your stats.',
                textAlign: TextAlign.center,
                style: ComebakTypography.bodyMedium.copyWith(
                  color: ComebakColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: ComebakLayout.spaceXxl * 2),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ComebakGameCard(
                title: ComebakCopy.gameSmallTitle,
                subtitle: ComebakCopy.gameSmallDesc,
                accentColor: ComebakColors.neonBlue,
                onTap: _launchGame,
                iconWidget: ComebakSmallBurstIcon(
                  size: ComebakLayout.gameIconSize,
                ),
              ),
            ),
            const SizedBox(width: ComebakLayout.spaceLg),
            Expanded(
              child: ComebakGameCard(
                title: ComebakCopy.gameBodmasTitle,
                subtitle: ComebakCopy.gameBodmasDesc,
                accentColor: ComebakColors.neonPurple,
                onTap: _launchGame,
                iconWidget: ComebakBodmasBurstIcon(
                  size: ComebakLayout.gameIconSize,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: ComebakLayout.spaceXxl),
      ],
    );
  }

  // ===========================================================================
  // LEDGER ROW
  // ===========================================================================
  Widget _buildLedgerRow(
    String gameName,
    String highScore,
    Widget icon, {
    required bool isLocked,
    required VoidCallback onTap,
    bool isHighest = false,
  }) {
    return GestureDetector(
      onTap: isLocked ? null : onTap,
      behavior: HitTestBehavior.opaque,
      child: Opacity(
        opacity: isLocked ? 0.4 : 1.0,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: ComebakLayout.spaceLg),
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(color: ComebakColors.border, width: 1),
            ),
          ),
          child: Row(
            children: [
              icon,
              const SizedBox(width: ComebakLayout.spaceLg),
              Expanded(
                child: Text(
                  gameName,
                  style: ComebakTypography.titleMedium.copyWith(
                    color: ComebakColors.textPrimary,
                  ),
                ),
              ),
              if (isLocked)
                const Icon(
                  Icons.lock_outline,
                  color: ComebakColors.textSecondary,
                  size: ComebakLayout.spaceLg,
                )
              else
                Text(
                  highScore,
                  style: ComebakTypography.titleLarge.copyWith(
                    color: isHighest
                        ? ComebakColors.neonGreen
                        : ComebakColors.textPrimary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // DEV STATE SWITCHER
  // ===========================================================================
  Widget _buildStateSwitcher() {
    return Positioned(
      top: MediaQuery.of(context).padding.top + ComebakLayout.spaceSm,
      right: ComebakLayout.spaceLg,
      child: PopupMenuButton<_StatsState>(
        icon: const Icon(Icons.more_horiz, color: ComebakColors.textSecondary),
        color: ComebakColors.surfaceElevated,
        onSelected: (state) => setState(() => _currentState = state),
        itemBuilder: (context) => [
          const PopupMenuItem(
            value: _StatsState.populated,
            child: Text('All States (Demo)'),
          ),
          const PopupMenuItem(
            value: _StatsState.empty,
            child: Text('Empty (New User)'),
          ),
          const PopupMenuItem(
            value: _StatsState.brokenStreak,
            child: Text('Broken Streak (0 Days)'),
          ),
          const PopupMenuItem(
            value: _StatsState.partial,
            child: Text('Partial (Locked)'),
          ),
        ],
      ),
    );
  }
}
