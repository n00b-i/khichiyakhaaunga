import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../1_foundations/ui_lab_haptics.dart';
import '../../3_molecules/comebak_game_card.dart';
import '../../../../games/add_burst/add_burst_screen.dart';
import '../../../../games/mad_burst/mad_burst_screen.dart';
import '../../../../games/bodmas_burst/bodmas_burst_screen.dart';
import '../../../../games/number_hunt/number_hunt_screen.dart';
import '../../../../games/devils_memory/devils_memory_screen.dart';
import '../../1_foundations/tokens/ui_lab_tokens.dart';
import '../../2_atoms/comebak_flame_3d.dart';
import '../../2_atoms/comebak_xp_icon.dart';
import '../../2_atoms/comebak_add_burst_icon.dart';
import '../../2_atoms/comebak_mad_burst_icon.dart';
import '../../2_atoms/comebak_bodmas_burst_icon.dart';
import '../../2_atoms/comebak_small_burst_icon.dart';
import '../../2_atoms/comebak_devils_memory_icon.dart';
import '../../../../../core/stats/stats_repository.dart';
import '../../../../../core/profile/profile_repository.dart';
// [SSOT] Game Configs for the empty state cards
import '../../../../../core/games/configs/game_configs.dart';

// ==============================================================================
// [SCREEN] ComebakStatsPage
// ------------------------------------------------------------------------------
// PURPOSE: Production-ready stats dashboard.
// FIXES APPLIED:
// - AC-5: Removed the bug icon and dev popup menu.
// - AC-6: Commented out and removed all mock data logic (_DevStatsState).
// ==============================================================================
class ComebakStatsPage extends StatefulWidget {
  const ComebakStatsPage({super.key});

  @override
  State<ComebakStatsPage> createState() => _ComebakStatsPageState();
}

class _ComebakStatsPageState extends State<ComebakStatsPage> {
  late Future<List<dynamic>> _combinedFuture;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    // [AC-6] Always fetch real data. Mock logic purged.
    setState(() {
      _combinedFuture = Future.wait([
        StatsRepository(Supabase.instance.client).getUserStats(),
        ProfileRepository(Supabase.instance.client).getProfile(),
      ]);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ComebakColors.canvas,
      body: Stack(
        children: [
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
          // [AC-5] Bug icon and PopupMenuButton removed.
        ],
      ),
    );
  }
}

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
    final int addPb = statsData['add_burst_pb'] as int? ?? 0;
    final int madPb = statsData['mad_burst_pb'] as int? ?? 0;
    final int bodmasPb = statsData['bodmas_burst_pb'] as int? ?? 0;
    final int smallPb = statsData['small_burst_pb'] as int? ?? 0;
    final int devilsPb = statsData['saitan_add_pb'] as int? ?? 0;

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

        _buildLedgerRow(
          context,
          'Add Burst',
          addPb,
          const ComebakAddBurstIcon(size: ComebakLayout.spaceXxl),
          addPb == maxPb && addPb > 0,
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
        _buildLedgerRow(
          context,
          'Mad Burst',
          madPb,
          const ComebakMadBurstIcon(size: ComebakLayout.spaceXxl),
          madPb == maxPb && madPb > 0,
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
        _buildLedgerRow(
          context,
          'School Math',
          bodmasPb,
          const ComebakBodmasBurstIcon(size: ComebakLayout.spaceXxl),
          bodmasPb == maxPb && bodmasPb > 0,
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
        _buildLedgerRow(
          context,
          'Small Burst',
          smallPb,
          const ComebakSmallBurstIcon(size: ComebakLayout.spaceXxl),
          smallPb == maxPb && smallPb > 0,
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
        _buildLedgerRow(
          context,
          'Devil\'s Memory',
          devilsPb,
          const ComebakDevilsMemoryIcon(size: ComebakLayout.spaceXxl),
          devilsPb == maxPb && devilsPb > 0,
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
}

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
                        config: NumberHuntConfig.standard,
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
                        config: BodmasBurstConfig.standard,
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
