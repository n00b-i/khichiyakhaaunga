import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  // S-06 E4: Time format rules (0s -> "0s", <60s -> "{n}s", <60min -> "{m}m {s}s", >=60min -> "{h}h {m}m")
  String _formatTime(int seconds) {
    if (seconds == 0) return '0s';
    if (seconds < 60) return '${seconds}s';
    final m = seconds ~/ 60;
    final s = seconds % 60;
    if (m < 60) return '${m}m ${s}s';
    final h = m ~/ 60;
    return '${h}h ${m % 60}m';
  }

  // S-06 E3/E5: Thousands separator for large numbers (e.g., 10,000)
  String _formatNumber(int num) {
    return num.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );
  }

  @override
  Widget build(BuildContext context) {
    // Note: For now, this uses the empty-state hardcoded values to match S-06 E1.
    // Later, these will be wired to Supabase.
    const int totalGames = 0;
    const int totalTimeSeconds = 0;
    final Map<String, int?> pbs = {
      'Add Burst': null,
      'Mad Burst': null,
      'Math Burst': null,
      'Memory of Saitan': null,
    };

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppSpacing.lg),
              const Text('Your Stats', style: AppTextStyles.display),
              const SizedBox(height: AppSpacing.xl),

              // S-06 V5: Total Games and Total Time side-by-side
              Row(
                children: [
                  Expanded(
                    child: _StatTile(
                      label: 'Total Games',
                      value: _formatNumber(totalGames),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: _StatTile(
                      label: 'Total Time',
                      value: _formatTime(totalTimeSeconds),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: AppSpacing.xl),
              const Text(
                'Personal Bests',
                style: AppTextStyles.body,
              ),
              const SizedBox(height: AppSpacing.md),

              // S-06 V6/V7: Personal bests (4 rows)
              ...pbs.entries.map((entry) => _PbRow(
                    gameTitle: entry.key,
                    bestScore: entry.value,
                    formatNumber: _formatNumber,
                  )),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final String label;
  final String value;

  const _StatTile({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    // S-06 V2: Surface fill, border, radius 12.
    // S-06 I3: Screen reader announces as one node.
    return Semantics(
      label: '$label: $value',
      excludeSemantics: true,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.card),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: AppTextStyles.body.copyWith(
                color: AppColors.textPrimary.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(value, style: AppTextStyles.hud),
          ],
        ),
      ),
    );
  }
}

class _PbRow extends StatelessWidget {
  final String gameTitle;
  final int? bestScore;
  final String Function(int) formatNumber;

  const _PbRow({
    required this.gameTitle,
    required this.bestScore,
    required this.formatNumber,
  });

  @override
  Widget build(BuildContext context) {
    // S-06 V8: Empty values render as "—" (never blank).
    final displayScore = bestScore != null ? formatNumber(bestScore!) : '—';

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(gameTitle, style: AppTextStyles.body),
          Text(displayScore, style: AppTextStyles.hud.copyWith(fontSize: 24)),
        ],
      ),
    );
  }
}
