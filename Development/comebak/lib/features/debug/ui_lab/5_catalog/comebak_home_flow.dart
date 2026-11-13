import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../../../core/games/configs/game_configs.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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

import 'profile_flow/comebak_profile_page.dart';
import 'stats_flow/comebak_stats_page.dart';
import 'streak_debug/streak_debug_panel.dart';
import 'streak_debug/streak_debug_payload.dart';

import '../../../../core/stats/stats_repository.dart';
import '../../../../core/profile/profile_repository.dart';

import '../../../games/add_burst/add_burst_screen.dart';
import '../../../games/mad_burst/mad_burst_screen.dart';
import '../../../games/bodmas_burst/bodmas_burst_screen.dart';
import '../../../games/number_hunt/number_hunt_screen.dart';
import '../../../games/devils_memory/devils_memory_screen.dart';

class ComebakHomeFlow extends StatefulWidget {
  const ComebakHomeFlow({super.key});

  @override
  State<ComebakHomeFlow> createState() => _ComebakHomeFlowState();
}

class _ComebakHomeFlowState extends State<ComebakHomeFlow> {
  late Future<List<dynamic>> _dataFuture;

  // [DEBUG] Overrides the real DB data if a payload is injected.
  StreakDebugPayload? _debugPayload;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    setState(() {
      if (_debugPayload != null) {
        // Return mock data instantly for UI testing
        _dataFuture = Future.value([null, null]);
      } else {
        // Fetch real data from Supabase (uses in-memory cache)
        _dataFuture = Future.wait([
          StatsRepository(Supabase.instance.client).getUserStats(),
          ProfileRepository(Supabase.instance.client).getProfile(),
        ]);
      }
    });
  }

  /// [INDIAN NUMBER FORMATTER]
  /// Converts 1471 -> "1,471", 147100 -> "1,47,100", -15 -> "-15".
  String _formatIndian(int number) {
    final String sign = number < 0 ? '-' : '';
    String str = number.abs().toString();
    if (str.length <= 3) return '$sign$str';

    final String lastThree = str.substring(str.length - 3);
    String otherNumbers = str.substring(0, str.length - 3);

    if (otherNumbers.length <= 2) return '$sign$otherNumbers,$lastThree';

    String result = '';
    for (int i = otherNumbers.length - 1; i >= 0; i--) {
      result = otherNumbers[i] + result;
      final int distanceFromEnd = otherNumbers.length - i;
      if (distanceFromEnd.isEven && i != 0) result = ',$result';
    }
    return '$sign$result,$lastThree';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ComebakColors.canvas,
      body: Stack(
        children: [
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
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(ComebakLayout.spaceXl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ComebakHeader(
                    onProfileTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ComebakProfilePage(),
                      ),
                    ),
                  ),
                  const SizedBox(height: ComebakLayout.spaceXxl),

                  // 1. [GREETING] Time-Based Logic
                  // Long-press to open the Debug Panel
                  GestureDetector(
                    onLongPress: kDebugMode
                        ? () async {
                            final payload = await showStreakDebugPanel(
                              context,
                              _debugPayload,
                            );
                            setState(() {
                              _debugPayload = payload;
                              _loadData();
                            });
                          }
                        : null,
                    child: _buildGreeting(),
                  ),

                  const SizedBox(height: ComebakLayout.spaceSm),
                  Text(
                    "Giving up should not be an option 🚀",
                    style: ComebakTypography.greetingSubtitle,
                  ),
                  const SizedBox(height: ComebakLayout.spaceXxl),

                  // 2. [STREAK CARD] Async Data Resolution
                  FutureBuilder<List<dynamic>>(
                    future: _dataFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const _StreakCardSkeleton();
                      }
                      if (snapshot.hasError) {
                        return _StreakCardError(onRetry: _loadData);
                      }

                      return _buildStreakCard(
                        snapshot.data?[0] as Map<String, dynamic>?,
                        snapshot.data?[1] as Map<String, dynamic>?,
                      );
                    },
                  ),
                  const SizedBox(height: ComebakLayout.spaceXxl),

                  // 3. [GAMES GRID]
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

                  // ROW 1
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _gameCard(
                          AddBurstConfig.standard.title,
                          AddBurstConfig.standard.instructions,
                          ComebakColors.neonOrange,
                          const ComebakAddBurstIcon(
                            size: ComebakLayout.gameIconSize,
                          ),
                          () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const AddBurstScreen(
                                accentColor: ComebakColors.neonOrange,
                                config: AddBurstConfig.standard,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: ComebakLayout.spaceLg),
                      Expanded(
                        child: _gameCard(
                          MadBurstConfig.standard.title,
                          MadBurstConfig.standard.instructions,
                          ComebakColors.neonGreen,
                          const ComebakMadBurstIcon(
                            size: ComebakLayout.gameIconSize,
                          ),
                          () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const MadBurstScreen(
                                accentColor: ComebakColors.neonGreen,
                                config: MadBurstConfig.standard,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: ComebakLayout.spaceLg),

                  // ROW 2
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _gameCard(
                          BodmasBurstConfig.standard.title,
                          BodmasBurstConfig.standard.instructions,
                          ComebakColors.neonPurple,
                          const ComebakBodmasBurstIcon(
                            size: ComebakLayout.gameIconSize,
                          ),
                          () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const BodmasBurstScreen(
                                accentColor: ComebakColors.neonPurple,
                                config: BodmasBurstConfig.standard,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: ComebakLayout.spaceLg),
                      Expanded(
                        child: _gameCard(
                          NumberHuntConfig.standard.title,
                          NumberHuntConfig.standard.instructions,
                          ComebakColors.neonBlue,
                          const ComebakSmallBurstIcon(
                            size: ComebakLayout.gameIconSize,
                          ),
                          () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const NumberHuntScreen(
                                accentColor: ComebakColors.neonBlue,
                                config: NumberHuntConfig.standard,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: ComebakLayout.spaceLg),

                  // ROW 3
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _gameCard(
                          DevilsMemoryConfig.addition.title,
                          DevilsMemoryConfig.addition.instructions,
                          ComebakColors.vibrantPink,
                          const ComebakDevilsMemoryIcon(
                            size: ComebakLayout.gameIconSize,
                          ),
                          () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const DevilsMemoryScreen(
                                accentColor: ComebakColors.vibrantPink,
                                config: DevilsMemoryConfig.addition,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: ComebakLayout.spaceLg),
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
                  const SizedBox(height: ComebakLayout.spaceXxl * 2),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================================
  // [GREETING BUILDER] - Includes the exclamation mark as requested
  // ============================================================================
  Widget _buildGreeting() {
    DateTime now = DateTime.now();
    if (_debugPayload?.debugNow != null) {
      now = DateTime.parse(_debugPayload!.debugNow!).toLocal();
    }

    final int hour = now.hour;
    String timeString = "morning!";
    if (hour >= 12 && hour < 16) timeString = "afternoon!";
    if (hour >= 16) timeString = "evening!";

    return RichText(
      text: TextSpan(
        style: ComebakTypography.greeting,
        children: [
          const TextSpan(
            text: "Good ",
            style: TextStyle(color: ComebakColors.textPrimary),
          ),
          TextSpan(
            text: timeString,
            style: const TextStyle(color: ComebakColors.neonGreen),
          ),
        ],
      ),
    );
  }

  // ============================================================================
  // [STREAK CARD BUILDER] - The Locked State Engine
  // ============================================================================
  Widget _buildStreakCard(
    Map<String, dynamic>? statsData,
    Map<String, dynamic>? profileData,
  ) {
    // 1. Data Extraction (Debug Payload vs Real DB)
    final int totalGames =
        _debugPayload?.totalGames ?? statsData?['total_games'] as int? ?? 0;
    final int totalXp =
        _debugPayload?.totalXp ?? statsData?['total_xp'] as int? ?? 0;
    final int streak =
        _debugPayload?.streak ?? profileData?['current_streak'] as int? ?? 0;

    // 2. Time Context
    DateTime now = DateTime.now();
    if (_debugPayload?.debugNow != null) {
      now = DateTime.parse(_debugPayload!.debugNow!).toLocal();
    }

    final int hour = now.hour;
    final int minute = now.minute;

    // 3. Played Today / Yesterday Detection
    DateTime? lastPlayed;
    final rawLastPlayed =
        _debugPayload?.lastPlayedAt ??
        statsData?['last_played_at'] as String? ??
        profileData?['last_played_at'] as String?;

    if (rawLastPlayed != null) {
      lastPlayed = DateTime.parse(rawLastPlayed).toLocal();
    }

    bool playedToday = false;
    bool playedYesterday = false;
    if (lastPlayed != null) {
      playedToday =
          lastPlayed.year == now.year &&
          lastPlayed.month == now.month &&
          lastPlayed.day == now.day;
      final yesterday = now.subtract(const Duration(days: 1));
      playedYesterday =
          lastPlayed.year == yesterday.year &&
          lastPlayed.month == yesterday.month &&
          lastPlayed.day == yesterday.day;
    }

    // 4. Delta XP String & Color
    final int deltaXp = playedToday
        ? (_debugPayload?.deltaXpToday ??
              statsData?['delta_xp_today'] as int? ??
              0)
        : (_debugPayload?.deltaXpYesterday ??
              statsData?['delta_xp_yesterday'] as int? ??
              0);

    String deltaText = "0 XP Today";
    Color deltaColor = ComebakColors.textSecondary;

    if (playedToday) {
      if (deltaXp > 0) {
        deltaText = "↑ +${_formatIndian(deltaXp)} XP Today";
        deltaColor = ComebakColors.neonGreen;
      } else if (deltaXp < 0) {
        deltaText = "↓ -${_formatIndian(deltaXp.abs())} XP Today";
        deltaColor = ComebakColors.vibrantRed;
      }
    } else if (playedYesterday) {
      if (deltaXp > 0) {
        deltaText = "↑ +${_formatIndian(deltaXp)} XP Yesterday";
        deltaColor = ComebakColors.neonGreen;
      } else if (deltaXp < 0) {
        deltaText = "↓ -${_formatIndian(deltaXp.abs())} XP Yesterday";
        deltaColor = ComebakColors.vibrantRed;
      } else {
        deltaText = "0 XP Yesterday";
      }
    }

    // 5. State Resolution Variables
    String title = "";
    String subtitle = "";
    IconData icon = LucideIcons.flame;
    Color iconColor = ComebakColors.neonOrange;
    bool showXpRow = true;

    // Total XP colors
    final bool isNegativeXp = totalXp < 0;
    final Color totalXpTextColor = ComebakColors.textPrimary;
    final Color totalXpIconColor = isNegativeXp
        ? ComebakColors.vibrantRed
        : ComebakColors.neonGreen;

    // 6. The State Machine
    if (totalGames == 0) {
      // STATE S1 — FIRST TIME
      title = "Ready to start?";
      subtitle = "Your first game awaits.";
      icon = LucideIcons.sparkles;
      iconColor = ComebakColors.neonGreen;
      showXpRow = false;
    } else if (streak == 0) {
      // STATE S11/S12 — BROKEN / FUMBLED
      title = "Fumbled! Time to Comebak.";
      subtitle = "Bounce Back, Start Fresh!";
      icon = LucideIcons.rotate_ccw;
      iconColor = ComebakColors.textSecondary;
      showXpRow = true;
    } else {
      // ONGOING STREAK (streak > 0)
      if (playedToday) {
        // STATE S2–S8 — ONGOING, PLAYED TODAY
        title = "$streak ${streak == 1 ? 'Day' : 'Days'} Streak";
        icon = LucideIcons.flame;
        iconColor = ComebakColors.neonOrange;

        if (totalGames == 1 && streak == 1) {
          // First ever game
          if (deltaXp > 0) {
            subtitle = "Great start. Comebak soon!";
          } else {
            subtitle = "Just a start, long way to go!";
          }
        } else {
          // Milestone brackets
          if (streak <= 6) {
            subtitle = "Yes!!! This time its personal";
          } else if (streak <= 13) {
            subtitle = "You're becoming unstoppable!";
          } else if (streak <= 29) {
            subtitle = "No compromise on consistency!";
          } else if (streak <= 90) {
            subtitle = "Hell Yeah! Unstoppable!";
          } else if (streak <= 99) {
            subtitle = "Keep pushing, century soon!";
          } else if (streak == 100) {
            subtitle = "Just getting started, kudos!";
          } else {
            subtitle = "This year, Comebak year!!!";
          }
        }
      } else {
        // STATE S9/S10 — ONGOING, NOT PLAYED TODAY
        if (hour < 18) {
          // S9: MAINTAIN MOMENTUM (Before 6 PM)
          title = "Maintain Momentum!";
          subtitle = "60s all it takes, do it!";
          icon = LucideIcons.flame;
          iconColor = ComebakColors.neonOrange;
        } else if (hour >= 18 && hour < 23) {
          // S10: CRITICAL HOURS (6 PM to 11 PM)
          final int hoursLeft = 23 - hour;
          title = "$streak ${streak == 1 ? 'Day' : 'Days'} at risk";
          subtitle = "⏳ ${hoursLeft}h left to save your streak!";
          icon = LucideIcons.hourglass;
          iconColor = ComebakColors.vibrantRed;
        } else {
          // S10: CRITICAL MINUTES (After 11 PM)
          final int minsLeft = 60 - minute;
          title = "$streak ${streak == 1 ? 'Day' : 'Days'} at risk";
          subtitle =
              "⏳ $minsLeft ${minsLeft == 1 ? 'min' : 'mins'} left to save your streak!";
          icon = LucideIcons.hourglass;
          iconColor = ComebakColors.vibrantRed;
        }
      }
    }

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const ComebakStatsPage()),
      ),
      child: ComebakStreakCard(
        title: title,
        subtitle: subtitle,
        icon: icon,
        iconColor: iconColor,
        totalXpText: showXpRow ? '${_formatIndian(totalXp)} XP' : null,
        totalXpColor: totalXpTextColor,
        totalXpIconColor: totalXpIconColor,
        deltaXpText: showXpRow ? deltaText : null,
        deltaXpColor: showXpRow ? deltaColor : null,
      ),
    );
  }

  Widget _gameCard(
    String title,
    String subtitle,
    Color color,
    Widget icon,
    VoidCallback onTap,
  ) {
    return ComebakGameCard(
      title: title,
      subtitle: subtitle,
      accentColor: color,
      onTap: () {
        ComebakHaptics.tap();
        onTap();
      },
      iconWidget: icon,
    );
  }
}

class _StreakCardSkeleton extends StatelessWidget {
  const _StreakCardSkeleton();
  @override
  Widget build(BuildContext context) {
    return Container(
      height: ComebakLayout.cardIconContainer + ComebakLayout.spaceXxl,
      decoration: BoxDecoration(
        color: ComebakColors.surfaceElevated,
        borderRadius: BorderRadius.circular(ComebakLayout.radiusLg),
      ),
    );
  }
}

class _StreakCardError extends StatelessWidget {
  final VoidCallback onRetry;
  const _StreakCardError({required this.onRetry});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(ComebakLayout.spaceLg),
      decoration: BoxDecoration(
        color: ComebakColors.surface,
        borderRadius: BorderRadius.circular(ComebakLayout.radiusLg),
        border: Border.all(color: ComebakColors.border),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Could not load streak.',
            style: ComebakTypography.bodyMedium.copyWith(
              color: ComebakColors.textSecondary,
            ),
          ),
          TextButton(
            onPressed: onRetry,
            child: Text(
              'RETRY',
              style: ComebakTypography.labelSmall.copyWith(
                color: ComebakColors.neonGreen,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
