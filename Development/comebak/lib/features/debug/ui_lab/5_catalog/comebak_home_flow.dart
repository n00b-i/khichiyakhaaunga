import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// [UI LAB TOKENS]
import '../1_foundations/tokens/ui_lab_tokens.dart';
import '../1_foundations/ui_lab_copy.dart';
import '../1_foundations/ui_lab_haptics.dart';

// [UI LAB ATOMS]
import '../2_atoms/comebak_add_burst_icon.dart';
import '../2_atoms/comebak_mad_burst_icon.dart';
import '../2_atoms/comebak_bodmas_burst_icon.dart';
import '../2_atoms/comebak_small_burst_icon.dart';
import '../2_atoms/comebak_devils_memory_icon.dart';
import 'auth_variants/layers/comebak_clay_logo.dart';

// [UI LAB MOLECULES & ORGANISMS]
import '../3_molecules/comebak_game_card.dart';
import '../3_molecules/comebak_streak_card.dart';
import '../4_organisms/comebak_header.dart';

// [FLOWS]
import 'profile_flow/comebak_profile_page.dart';
import 'stats_flow/comebak_stats_page.dart';
import 'streak_debug/streak_debug_panel.dart';
import 'streak_debug/streak_debug_payload.dart';

// [SSOT REPOSITORIES]
import '../../../../core/stats/stats_repository.dart';
import '../../../../core/profile/profile_repository.dart';

// [SSOT GAME CONFIGS]
import '../../../../core/games/configs/game_configs.dart';

// [GAME SCREENS]
import '../../../games/add_burst/add_burst_screen.dart';
import '../../../games/mad_burst/mad_burst_screen.dart';
import '../../../games/bodmas_burst/bodmas_burst_screen.dart';
import '../../../games/number_hunt/number_hunt_screen.dart';
import '../../../games/devils_memory/devils_memory_screen.dart';

// ==============================================================================
// [SCREEN] ComebakHomeFlow
// ------------------------------------------------------------------------------
// PURPOSE: The main authenticated landing screen.
//
// DATA FLOW (SSOT):
//   - totalGames / totalXp  -> user_stats (total_xp is authoritative)
//   - streak                -> profiles.current_streak
//   - today / yesterday XP  -> computed from matches:
//                              xp_per_match = floor(score / 10)
//                              today_xp    = Σ xp_per_match where ended_at is today
//                              yesterday_xp = Σ xp_per_match where ended_at is yesterday
//
// XP FORMULA (locked):
//   `score ~/ 10` per match, then summed. NOT flat-summed then divided —
//   per-match floor loses fractional XP on scores not divisible by 10, which
//   is exactly how the DB trigger populates user_stats.total_xp. Using this
//   formula keeps Home card and Stats page within 0 of each other.
//
// TIMEZONE:
//   The DB trigger uses `Asia/Kolkata` for the "today" boundary. This widget
//   uses the device's local time. For Indian users these are identical.
//   If you ship to non-IST regions, swap `DateTime.now()` for an explicit
//   IST conversion here. Not needed for MVP.
//
// REFRESH:
//   - Every game screen is awaited; when the user pops back, _loadData() re-runs.
//   - Profile cache is cleared in GameRepository.endMatch() so streak is fresh.
// ==============================================================================
class ComebakHomeFlow extends StatefulWidget {
  const ComebakHomeFlow({super.key});

  @override
  State<ComebakHomeFlow> createState() => _ComebakHomeFlowState();
}

class _ComebakHomeFlowState extends State<ComebakHomeFlow> {
  late Future<_HomeData> _dataFuture;
  StreakDebugPayload? _debugPayload;

  // [XP FORMULA] Single source of truth — if the DB formula ever changes,
  // change this one constant and both sides stay in sync.
  static const int _scoreToXpDivisor = 10;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  /// Central loader. Debug payload short-circuits the network path so QA can
  /// preview every state without touching the DB.
  void _loadData() {
    setState(() {
      _dataFuture = _debugPayload != null
          ? Future.value(_HomeData.fromDebug(_debugPayload!))
          : _fetchHomeData();
    });
  }

  /// Fetches stats + profile in parallel, then derives today/yesterday XP from
  /// the matches table. Per-match XP uses `score ~/ 10` (floor) to match the
  /// DB trigger exactly. If the matches query fails (offline), deltas fall
  /// back to 0 so the card never shows a stale fake number.
  Future<_HomeData> _fetchHomeData() async {
    final client = Supabase.instance.client;

    final results = await Future.wait([
      StatsRepository(client).getUserStats(),
      ProfileRepository(client).getProfile(),
    ]);

    final stats = results[0] as Map<String, dynamic>?;
    final profile = results[1] as Map<String, dynamic>?;

    DateTime now = DateTime.now();
    if (_debugPayload?.debugNow != null) {
      now = DateTime.parse(_debugPayload!.debugNow!).toLocal();
    }

    final startToday = DateTime(now.year, now.month, now.day);
    final startYesterday = startToday.subtract(const Duration(days: 1));

    int todayXp = 0;
    int yesterdayXp = 0;
    bool playedToday = false;
    bool playedYesterday = false;

    final userId = client.auth.currentUser?.id;
    if (userId != null) {
      try {
        final rows = await client
            .from('matches')
            .select('score, ended_at')
            .eq('user_id', userId)
            .eq('status', 'completed')
            .gte('ended_at', startYesterday.toUtc().toIso8601String())
            .order('ended_at', ascending: false);

        for (final row in (rows as List)) {
          final ended = DateTime.parse(row['ended_at'] as String).toLocal();
          final rawScore = (row['score'] as int?) ?? 0;
          // [XP FORMULA] Per-match floor. Do NOT change to `sum(score) ~/ 10`
          // — that loses accuracy because floor is not distributive over sum.
          final matchXp = rawScore ~/ _scoreToXpDivisor;

          if (!ended.isBefore(startToday)) {
            todayXp += matchXp;
            playedToday = true;
          } else if (!ended.isBefore(startYesterday)) {
            yesterdayXp += matchXp;
            playedYesterday = true;
          }
        }
      } catch (e) {
        // Offline / query failed: leave deltas at 0. totalXp still comes from
        // the cached user_stats row, so the left side remains correct.
        debugPrint('[HomeFlow] Failed to derive today/yesterday XP: $e');
      }
    }

    return _HomeData(
      stats: stats,
      profile: profile,
      todayXp: todayXp,
      yesterdayXp: yesterdayXp,
      playedToday: playedToday,
      playedYesterday: playedYesterday,
    );
  }

  /// Indian comma grouping (1,25,000). Kept local because only the Home card
  /// uses it; Stats page has its own formatter.
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
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(ComebakLayout.spaceXl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. [ORGANISM] Header
                  ComebakHeader(
                    onProfileTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ComebakProfilePage(),
                      ),
                    ),
                  ),
                  const SizedBox(height: ComebakLayout.spaceXxl),

                  // 2. [GREETING] Long-press to open Debug Panel
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
                    ComebakCopy.greetingSubtitle,
                    style: ComebakTypography.greetingSubtitle,
                  ),
                  const SizedBox(height: ComebakLayout.spaceXxl),

                  // 3. [STREAK CARD] Async Data Resolution
                  FutureBuilder<_HomeData>(
                    future: _dataFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const _StreakCardSkeleton();
                      }
                      if (snapshot.hasError) {
                        return _StreakCardError(onRetry: _loadData);
                      }
                      return _buildStreakCard(snapshot.data!);
                    },
                  ),
                  const SizedBox(height: ComebakLayout.spaceXxl),
                  const SizedBox(height: ComebakLayout.spaceXs),

                  // 4. [GAMES GRID]
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
                  const SizedBox(height: ComebakLayout.spaceXl),

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

                  // 5. [FOOTER] Version + Experimenting in India
                  Center(
                    child: Column(
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const SizedBox(
                              width: ComebakLayout.spaceXl,
                              height: ComebakLayout.spaceXl,
                              child: FittedBox(
                                fit: BoxFit.contain,
                                child: ComebakClayLogo(
                                  pose: 4,
                                  time: 0,
                                  enableSparks: false,
                                ),
                              ),
                            ),
                            const SizedBox(width: ComebakLayout.spaceXs),
                            Text(
                              'Comebak - Your Comeback',
                              style: ComebakTypography.greetingSubtitle
                                  .copyWith(
                                    color: ComebakColors.neonGreen.withValues(
                                      alpha: 0.8,
                                    ),
                                  ),
                            ),
                          ],
                        ),
                        const SizedBox(height: ComebakLayout.spaceXs),
                      ],
                    ),
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
  // [GREETING BUILDER]
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
  // [STREAK CARD BUILDER]
  // ----------------------------------------------------------------------------
  // SSOT RULE:
  //   - totalGames / totalXp  -> data.stats (from user_stats — authoritative)
  //   - streak                -> data.profile
  //   - today / yesterday XP  -> data.todayXp / data.yesterdayXp
  //                              (already XP, not raw score — conversion happened
  //                               in _fetchHomeData with floor(score/10))
  //   - played flags          -> data.playedToday / data.playedYesterday
  // No column named delta_xp_* is trusted here; those are legacy/optional.
  // ============================================================================
  Widget _buildStreakCard(_HomeData data) {
    final int totalGames =
        _debugPayload?.totalGames ?? data.stats?['total_games'] as int? ?? 0;
    final int totalXp =
        _debugPayload?.totalXp ?? data.stats?['total_xp'] as int? ?? 0;
    final int streak =
        _debugPayload?.streak ?? data.profile?['current_streak'] as int? ?? 0;

    DateTime now = DateTime.now();
    if (_debugPayload?.debugNow != null) {
      now = DateTime.parse(_debugPayload!.debugNow!).toLocal();
    }
    final int hour = now.hour;
    final int minute = now.minute;

    final bool playedToday = data.playedToday;
    final bool playedYesterday = data.playedYesterday;
    final int deltaXp = playedToday ? data.todayXp : data.yesterdayXp;

    // [DELTA TEXT] Neutral by default; positive/negative only when a session
    // actually exists. This prevents "0 XP" from looking green when idle.
    String deltaText = ComebakCopy.xpTodayNeutral;
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

    String title = "";
    String subtitle = "";
    IconData icon = LucideIcons.flame;
    Color iconColor = ComebakColors.neonOrange;
    bool showXpRow = true;

    final bool isNegativeXp = totalXp < 0;
    final Color totalXpTextColor = ComebakColors.textPrimary;
    final Color totalXpIconColor = isNegativeXp
        ? ComebakColors.vibrantRed
        : ComebakColors.neonGreen;

    if (totalGames == 0) {
      title = "Ready to start?";
      subtitle = "Your first game awaits.";
      icon = LucideIcons.sparkles;
      iconColor = ComebakColors.neonGreen;
      showXpRow = false;
    } else if (streak == 0) {
      title = "Fumbled! Time to Comebak.";
      subtitle = "Bounce Back, Start Fresh!";
      icon = LucideIcons.rotate_ccw;
      iconColor = ComebakColors.textSecondary;
      showXpRow = true;
    } else {
      if (playedToday) {
        title = "$streak ${streak == 1 ? 'Day' : 'Days'} Streak";
        icon = LucideIcons.flame;
        iconColor = ComebakColors.neonOrange;

        if (totalGames == 1 && streak == 1) {
          if (deltaXp > 0) {
            subtitle = "Great start. Comebak soon!";
          } else {
            subtitle = "Just a start, long way to go!";
          }
        } else {
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
        if (hour < 18) {
          title = "Maintain Momentum!";
          subtitle = "60s all it takes, do it!";
          icon = LucideIcons.flame;
          iconColor = ComebakColors.neonOrange;
        } else if (hour >= 18 && hour < 23) {
          final int hoursLeft = 23 - hour;
          title = "$streak ${streak == 1 ? 'Day' : 'Days'} at risk";
          subtitle = "⏳ ${hoursLeft}h left to save your streak!";
          icon = LucideIcons.hourglass;
          iconColor = ComebakColors.vibrantRed;
        } else {
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

  /// Wraps every game card so that returning from a game triggers a reload.
  /// Without this the card would still show yesterday's numbers until restart.
  Widget _gameCard(
    String title,
    String subtitle,
    Color color,
    Widget icon,
    Future<dynamic> Function() onTap,
  ) {
    return ComebakGameCard(
      title: title,
      subtitle: subtitle,
      accentColor: color,
      onTap: () async {
        ComebakHaptics.tap();
        await onTap();
        if (mounted) _loadData();
      },
      iconWidget: icon,
    );
  }
}

// ------------------------------------------------------------------------------
// [DATA MODEL] _HomeData
// ------------------------------------------------------------------------------
// Carries everything the streak card needs in one immutable object so the
// widget tree has a single source of truth per frame.
// ------------------------------------------------------------------------------
class _HomeData {
  final Map<String, dynamic>? stats;
  final Map<String, dynamic>? profile;
  final int todayXp;
  final int yesterdayXp;
  final bool playedToday;
  final bool playedYesterday;

  const _HomeData({
    required this.stats,
    required this.profile,
    required this.todayXp,
    required this.yesterdayXp,
    required this.playedToday,
    required this.playedYesterday,
  });

  /// Debug path: trusts the injected payload verbatim. `lastPlayedAt` is
  /// parsed only to decide which label ("Today" vs "Yesterday") to render.
  factory _HomeData.fromDebug(StreakDebugPayload d) {
    DateTime now = DateTime.now();
    if (d.debugNow != null) {
      now = DateTime.parse(d.debugNow!).toLocal();
    }

    bool playedToday = false;
    bool playedYesterday = false;
    if (d.lastPlayedAt != null) {
      final last = DateTime.parse(d.lastPlayedAt!).toLocal();
      playedToday =
          last.year == now.year &&
          last.month == now.month &&
          last.day == now.day;
      final y = now.subtract(const Duration(days: 1));
      playedYesterday =
          last.year == y.year && last.month == y.month && last.day == y.day;
    }

    return _HomeData(
      stats: null,
      profile: null,
      todayXp: d.deltaXpToday,
      yesterdayXp: d.deltaXpYesterday,
      playedToday: playedToday,
      playedYesterday: playedYesterday,
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
