import 'package:flutter/material.dart';
import '../../../../../core/games/configs/game_configs.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// UI Lab Foundations
import '../../1_foundations/tokens/ui_lab_tokens.dart';
import '../../1_foundations/ui_lab_haptics.dart';

// UI Lab Atoms
import '../../2_atoms/comebak_flame_3d.dart';
import '../../2_atoms/comebak_xp_icon.dart';
import '../../2_atoms/comebak_add_burst_icon.dart';
import '../../2_atoms/comebak_mad_burst_icon.dart';
import '../../2_atoms/comebak_bodmas_burst_icon.dart';
import '../../2_atoms/comebak_small_burst_icon.dart';
import '../../2_atoms/comebak_devils_memory_icon.dart';

// UI Lab Molecules
import '../../3_molecules/comebak_game_card.dart';

// Repositories (SSOT for data)
import '../../../../../core/stats/stats_repository.dart';
import '../../../../../core/profile/profile_repository.dart';

// Game Screens (for row tap navigation)
import '../../../../games/add_burst/add_burst_screen.dart';
import '../../../../games/mad_burst/mad_burst_screen.dart';
import '../../../../games/bodmas_burst/bodmas_burst_screen.dart';
import '../../../../games/number_hunt/number_hunt_screen.dart';
import '../../../../games/devils_memory/devils_memory_screen.dart';

// ==============================================================================
// [DEV STATE MACHINE]
// Covers every possible edge case for QA without touching the database.
// ==============================================================================
enum _DevStatsState {
  db,
  empty,
  populated,
  negativeXp,
  zeroStreak,
  negativeScores,
  hugeNumbers,
  playedButZero,
  oneGamePlayed,
}

// ==============================================================================
// [HELPER] Indian Number Formatter (Lakh / Crore grouping)
// ------------------------------------------------------------------------------
// Converts 1042 -> "1,042", 147100 -> "1,47,100", -15 -> "-15".
// This is the standard Indian numbering system, NOT the Western grouping.
// ==============================================================================
String _formatIndian(int number) {
  final String sign = number < 0 ? '-' : '';
  String str = number.abs().toString();

  if (str.length <= 3) return '$sign$str';

  final String lastThree = str.substring(str.length - 3);
  String otherNumbers = str.substring(0, str.length - 3);

  if (otherNumbers.length <= 2) {
    return '$sign$otherNumbers,$lastThree';
  }

  // Group the remaining digits in pairs (Indian system: 2,2,2...)
  String result = '';
  for (int i = otherNumbers.length - 1; i >= 0; i--) {
    result = otherNumbers[i] + result;
    final int distanceFromEnd = otherNumbers.length - i;
    if (distanceFromEnd.isEven && i != 0) {
      result = ',$result';
    }
  }

  return '$sign$result,$lastThree';
}

class ComebakStatsPage extends StatefulWidget {
  const ComebakStatsPage({super.key});

  @override
  State<ComebakStatsPage> createState() => _ComebakStatsPageState();
}

class _ComebakStatsPageState extends State<ComebakStatsPage> {
  _DevStatsState _devState = _DevStatsState.db;
  late Future<List<dynamic>> _combinedFuture;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  /// [DATA FETCH]
  /// Real DB path uses Future.wait to fetch stats + profile in parallel.
  /// Dev path returns instant mock data for UI testing.
  void _loadData() {
    setState(() {
      if (_devState == _DevStatsState.db) {
        _combinedFuture = Future.wait([
          StatsRepository(Supabase.instance.client).getUserStats(),
          ProfileRepository(Supabase.instance.client).getProfile(),
        ]);
      } else {
        _combinedFuture = Future.value(_getMockData());
      }
    });
  }

  // [MOCK DATA FACTORY] — used only by the Dev Bug Menu
  List<dynamic> _getMockData() {
    switch (_devState) {
      case _DevStatsState.empty:
        return [
          {
            'total_games': 0,
            'total_xp': 0,
            'add_burst_pb': 0,
            'mad_burst_pb': 0,
            'bodmas_burst_pb': 0,
            'small_burst_pb': 0,
            'saitan_add_pb': 0,
          },
          {'current_streak': 0},
        ];
      case _DevStatsState.negativeXp:
        return [
          {
            'total_games': 5,
            'total_xp': -15,
            'add_burst_pb': 10,
            'mad_burst_pb': 20,
            'bodmas_burst_pb': 0,
            'small_burst_pb': 15,
            'saitan_add_pb': 0,
          },
          {'current_streak': 0},
        ];
      case _DevStatsState.zeroStreak:
        return [
          {
            'total_games': 12,
            'total_xp': 450,
            'add_burst_pb': 150,
            'mad_burst_pb': 200,
            'bodmas_burst_pb': 50,
            'small_burst_pb': 300,
            'saitan_add_pb': 100,
          },
          {'current_streak': 0},
        ];
      case _DevStatsState.negativeScores:
        return [
          {
            'total_games': 3,
            'total_xp': -45,
            'add_burst_pb': -20,
            'mad_burst_pb': -10,
            'bodmas_burst_pb': 0,
            'small_burst_pb': -15,
            'saitan_add_pb': 0,
          },
          {'current_streak': 0},
        ];
      case _DevStatsState.hugeNumbers:
        return [
          {
            'total_games': 9999,
            'total_xp': 147100,
            'add_burst_pb': 99999,
            'mad_burst_pb': 88888,
            'bodmas_burst_pb': 77777,
            'small_burst_pb': 66666,
            'saitan_add_pb': 55555,
          },
          {'current_streak': 365},
        ];
      case _DevStatsState.playedButZero:
        return [
          {
            'total_games': 5,
            'total_xp': 0,
            'add_burst_pb': 0,
            'mad_burst_pb': 0,
            'bodmas_burst_pb': 0,
            'small_burst_pb': 0,
            'saitan_add_pb': 0,
          },
          {'current_streak': 0},
        ];
      case _DevStatsState.oneGamePlayed:
        return [
          {
            'total_games': 1,
            'total_xp': 15,
            'add_burst_pb': 150,
            'mad_burst_pb': null,
            'bodmas_burst_pb': null,
            'small_burst_pb': null,
            'saitan_add_pb': null,
          },
          {'current_streak': 1},
        ];
      default:
        return [
          {
            'total_games': 84,
            'total_xp': 1471,
            'add_burst_pb': 460,
            'mad_burst_pb': 640,
            'bodmas_burst_pb': 490,
            'small_burst_pb': 1042,
            'saitan_add_pb': 90,
          },
          {'current_streak': 4},
        ];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ComebakColors.canvas,
      body: Stack(
        children: [
          // Creative BG Glow (Top-Right)
          Positioned(
            top: -ComebakLayout.bgGlowSize / 4,
            right: -ComebakLayout.bgGlowSize / 4,
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
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: IntrinsicHeight(
                      child: Padding(
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
                                fontSize:
                                    ComebakLayout.spaceXxl +
                                    ComebakLayout.spaceXs,
                                letterSpacing: -1.0,
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
                            const SizedBox(
                              height: ComebakLayout.spaceXxl * 1.5,
                            ),

                            // ASYNC DATA RESOLUTION
                            Expanded(
                              child: FutureBuilder<List<dynamic>>(
                                future: _combinedFuture,
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return const _StatsSkeleton();
                                  }

                                  if (snapshot.hasError) {
                                    return _StatsError(onRetry: _loadData);
                                  }

                                  final statsData =
                                      snapshot.data?[0]
                                          as Map<String, dynamic>?;
                                  final profileData =
                                      snapshot.data?[1]
                                          as Map<String, dynamic>?;

                                  final matchesPlayed =
                                      statsData?['total_games'] as int? ?? 0;
                                  final totalXp =
                                      statsData?['total_xp'] as int? ?? 0;
                                  final streak =
                                      profileData?['current_streak'] as int? ??
                                      0;

                                  // EMPTY STATE: New user OR all-zero data
                                  if (statsData == null || matchesPlayed == 0) {
                                    return const _StatsEmpty();
                                  }

                                  return _StatsPopulated(
                                    statsData: statsData,
                                    totalXp: totalXp,
                                    streak: streak,
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // DEV STATE SWITCHER (Bug Icon)
          Positioned(
            top: MediaQuery.of(context).padding.top + ComebakLayout.spaceMd,
            right: ComebakLayout.spaceLg,
            child: PopupMenuButton<_DevStatsState>(
              icon: const Icon(
                Icons.bug_report,
                color: ComebakColors.textSecondary,
              ),
              color: ComebakColors.surfaceElevated,
              onSelected: (state) {
                _devState = state;
                _loadData();
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: _DevStatsState.db,
                  child: Text('Real DB Data'),
                ),
                const PopupMenuItem(
                  value: _DevStatsState.empty,
                  child: Text('Empty (New User)'),
                ),
                const PopupMenuItem(
                  value: _DevStatsState.populated,
                  child: Text('Populated (Normal)'),
                ),
                const PopupMenuItem(
                  value: _DevStatsState.zeroStreak,
                  child: Text('Zero Streak'),
                ),
                const PopupMenuItem(
                  value: _DevStatsState.negativeXp,
                  child: Text('Negative XP'),
                ),
                const PopupMenuItem(
                  value: _DevStatsState.negativeScores,
                  child: Text('Negative Scores'),
                ),
                const PopupMenuItem(
                  value: _DevStatsState.hugeNumbers,
                  child: Text('Huge Numbers (Lakh/Crore)'),
                ),
                const PopupMenuItem(
                  value: _DevStatsState.playedButZero,
                  child: Text('Played but Zero'),
                ),
                const PopupMenuItem(
                  value: _DevStatsState.oneGamePlayed,
                  child: Text('One Game Played'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ==============================================================================
// [WIDGET] _StatsPopulated
// ==============================================================================
class _StatsPopulated extends StatelessWidget {
  final Map<String, dynamic> statsData;
  final int totalXp;
  final int streak;

  const _StatsPopulated({
    required this.statsData,
    required this.totalXp,
    required this.streak,
  });

  @override
  Widget build(BuildContext context) {
    // Extract all 5 PBs (Devil's Memory uses saitan_add_pb only)
    final int addPb = statsData['add_burst_pb'] as int? ?? 0;
    final int madPb = statsData['mad_burst_pb'] as int? ?? 0;
    final int bodmasPb = statsData['bodmas_burst_pb'] as int? ?? 0;
    final int smallPb = statsData['small_burst_pb'] as int? ?? 0;
    final int devilsPb = statsData['saitan_add_pb'] as int? ?? 0;

    // Dynamic highlight: find the max value
    final int maxPb = [
      addPb,
      madPb,
      bodmasPb,
      smallPb,
      devilsPb,
    ].reduce((a, b) => a > b ? a : b);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // HERO CARD
        Container(
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
                  ComebakFlame3D(size: 32, key: ValueKey('flame_$streak')),
                  const SizedBox(width: ComebakLayout.spaceSm),
                  Text(
                    '$streak ${streak == 1 ? 'DAY' : 'DAYS'}',
                    style: ComebakTypography.titleLarge.copyWith(
                      color: streak == 0
                          ? ComebakColors.textSecondary
                          : ComebakColors.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              // XP
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ComebakXpIcon(
                      icon: Icons.bolt,
                      color: totalXp < 0
                          ? ComebakColors.vibrantRed
                          : ComebakColors.neonGreen,
                      size: 28,
                    ),
                    const SizedBox(width: ComebakLayout.spaceSm),
                    Flexible(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          '${_formatIndian(totalXp)} XP',
                          style: ComebakTypography.titleLarge.copyWith(
                            color: totalXp < 0
                                ? ComebakColors.vibrantRed
                                : ComebakColors.textPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: ComebakLayout.spaceXxl * 1.5),

        // LEDGER HEADER
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'CHALLENGES',
              style: ComebakTypography.labelSmall.copyWith(
                color: ComebakColors.textSecondary,
                letterSpacing: 1.5,
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(
              'PERSONAL BEST',
              style: ComebakTypography.labelSmall.copyWith(
                color: ComebakColors.textSecondary,
                letterSpacing: 1.5,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        const SizedBox(height: ComebakLayout.spaceMd),

        // LEDGER ROWS
        // [COMMA FIX] Every highScore is now passed as int and formatted via _formatIndian.
        // [COLOR FIX] Negative PB = Red, Highest PB = Green, Default = White.
        _buildLedgerRow(
          context,
          'Add Burst',
          addPb,
          const ComebakAddBurstIcon(size: ComebakLayout.spaceXxl),
          addPb == maxPb && addPb > 0,
          () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  const AddBurstScreen(accentColor: ComebakColors.neonOrange),
            ),
          ),
        ),
        _buildLedgerRow(
          context,
          'Mad Burst',
          madPb,
          const ComebakMadBurstIcon(size: ComebakLayout.spaceXxl),
          madPb == maxPb && madPb > 0,
          () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  const MadBurstScreen(accentColor: ComebakColors.neonGreen),
            ),
          ),
        ),
        _buildLedgerRow(
          context,
          'BODMAS Burst',
          bodmasPb,
          const ComebakBodmasBurstIcon(size: ComebakLayout.spaceXxl),
          bodmasPb == maxPb && bodmasPb > 0,
          () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const BodmasBurstScreen(
                accentColor: ComebakColors.neonPurple,
              ),
            ),
          ),
        ),
        _buildLedgerRow(
          context,
          'Number Hunt',
          smallPb,
          const ComebakSmallBurstIcon(size: ComebakLayout.spaceXxl),
          smallPb == maxPb && smallPb > 0,
          () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  const NumberHuntScreen(accentColor: ComebakColors.neonBlue),
            ),
          ),
        ),
        _buildLedgerRow(
          context,
          'Devils Memory',
          devilsPb,
          const ComebakDevilsMemoryIcon(size: ComebakLayout.spaceXxl),
          devilsPb == maxPb && devilsPb > 0,
          () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const DevilsMemoryScreen(
                accentColor: ComebakColors.vibrantPink,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLedgerRow(
    BuildContext context,
    String gameName,
    int highScore,
    Widget icon,
    bool isHighest,
    VoidCallback onTap,
  ) {
    // [COLOR LOGIC]
    // 1. Negative PB → Vibrant Red (penalty, losing)
    // 2. Highest PB → Neon Green (achievement)
    // 3. Default → White (neutral)
    final Color scoreColor;
    if (highScore < 0) {
      scoreColor = ComebakColors.vibrantRed;
    } else if (isHighest) {
      scoreColor = ComebakColors.neonGreen;
    } else {
      scoreColor = ComebakColors.textPrimary;
    }

    return GestureDetector(
      onTap: () {
        ComebakHaptics.tap();
        onTap();
      },
      behavior: HitTestBehavior.opaque,
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
            // [COMMA FIX] Indian numbering system applied here
            Text(
              _formatIndian(highScore),
              style: ComebakTypography.titleLarge.copyWith(
                color: scoreColor,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==============================================================================
// [WIDGET] _StatsEmpty
// ==============================================================================
class _StatsEmpty extends StatelessWidget {
  const _StatsEmpty();

  @override
  Widget build(BuildContext context) {
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
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: ComebakTypography.bodyMedium.copyWith(
                    color: ComebakColors.textSecondary,
                    height: 1.5,
                  ),
                  children: [
                    const TextSpan(text: "Let's take first step toward "),
                    TextSpan(
                      text: "comebak.",
                      style: const TextStyle(
                        color: ComebakColors.neonGreen,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
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
                title: NumberHuntConfig.standard.title,
                subtitle: NumberHuntConfig.standard.instructions,
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
            const SizedBox(width: ComebakLayout.spaceLg),
            Expanded(
              child: ComebakGameCard(
                title: BodmasBurstConfig.standard.title,
                subtitle: BodmasBurstConfig.standard.instructions,
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
          ],
        ),
        const SizedBox(height: ComebakLayout.spaceXxl),
      ],
    );
  }
}

// ==============================================================================
// [WIDGET] _StatsSkeleton
// ==============================================================================
class _StatsSkeleton extends StatelessWidget {
  const _StatsSkeleton();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 80,
          decoration: BoxDecoration(
            color: ComebakColors.surfaceElevated,
            borderRadius: BorderRadius.circular(ComebakLayout.radiusLg),
          ),
        ),
        const SizedBox(height: ComebakLayout.spaceXxl * 1.5),
        for (int i = 0; i < 5; i++) ...[
          Container(
            height: 64,
            decoration: BoxDecoration(
              color: ComebakColors.surfaceElevated,
              borderRadius: BorderRadius.circular(ComebakLayout.radiusSm),
            ),
          ),
          const SizedBox(height: ComebakLayout.spaceMd),
        ],
      ],
    );
  }
}

// ==============================================================================
// [WIDGET] _StatsError
// ==============================================================================
class _StatsError extends StatelessWidget {
  final VoidCallback onRetry;
  const _StatsError({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Could not load stats.',
            style: ComebakTypography.bodyMedium.copyWith(
              color: ComebakColors.textSecondary,
            ),
          ),
          const SizedBox(height: ComebakLayout.spaceLg),
          SizedBox(
            height: ComebakLayout.buttonHeight,
            child: TextButton(
              onPressed: onRetry,
              style: TextButton.styleFrom(
                backgroundColor: ComebakColors.surfaceElevated,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(ComebakLayout.radiusMd),
                ),
              ),
              child: Text(
                'RETRY',
                style: ComebakTypography.labelSmall.copyWith(
                  color: ComebakColors.textPrimary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
