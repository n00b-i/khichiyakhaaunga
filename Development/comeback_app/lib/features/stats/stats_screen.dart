import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/theme/app_theme.dart';
import '../../core/stats/stats_repository.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  late StatsRepository _statsRepo;
  Future<Map<String, dynamic>?>? _statsFuture;

  @override
  void initState() {
    super.initState();
    // [UI-1] Initialize repository and fetch stats on mount
    _statsRepo = StatsRepository(Supabase.instance.client);
    _statsFuture = _statsRepo.getUserStats();
  }

  // AC (S-06 E4): Time format rules
  String _formatTime(int seconds) {
    if (seconds == 0) return '0s';
    if (seconds < 60) return '${seconds}s';
    final m = seconds ~/ 60;
    final s = seconds % 60;
    if (m < 60) return '${m}m ${s}s';
    final h = m ~/ 60;
    return '${h}h ${m % 60}m';
  }

  // AC (S-06 E3/E5): Thousands separator
  String _formatNumber(int num) {
    return num.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: FutureBuilder<Map<String, dynamic>?>(
          future: _statsFuture,
          builder: (context, snapshot) {
            // [UI-2] Loading State (S-06 B4)
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              );
            }

            // [UI-3] Error or No Data State
            if (snapshot.hasError || snapshot.data == null) {
              return Center(
                child: Text(
                  'Unable to load stats.',
                  style: AppTextStyles.body.copyWith(color: AppColors.textPrimary),
                ),
              );
            }

            final data = snapshot.data!;
            
            // [UI-4] Safely parse data from the SQL View
            final int totalGames = data['total_games'] ?? 0;
            final int totalTime = data['total_time_seconds'] ?? 0;
            
            // Map the SQL view columns to the UI Personal Bests
            final Map<String, int?> pbs = {
              'Add Burst': data['add_burst_pb'],
              'Mad Burst': data['mad_burst_pb'],
              'BODMAS Burst': data['bodmas_burst_pb'],
              'Small Burst': data['small_burst_pb'],
              'Saitan +': data['saitan_add_pb'],
              'Saitan X': data['saitan_mul_pb'],
            };

            return SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: AppSpacing.lg),
                  const Text('Your Stats', style: AppTextStyles.display),
                  const SizedBox(height: AppSpacing.xl),

                  // [UI-5] Total Games and Total Time
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
                          value: _formatTime(totalTime),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: AppSpacing.xl),
                  const Text('Personal Bests', style: AppTextStyles.body),
                  const SizedBox(height: AppSpacing.md),

                  // [UI-6] List of Personal Bests
                  ...pbs.entries.map((entry) => _PbRow(
                        gameTitle: entry.key,
                        bestScore: entry.value,
                        formatNumber: _formatNumber,
                      )),
                ],
              ),
            );
          },
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
    // AC (S-06 V8): Empty values render as "—"
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
          Text(
            displayScore, 
            style: AppTextStyles.hud.copyWith(
              fontSize: 24,
              color: bestScore != null ? AppColors.textPrimary : AppColors.border,
            ),
          ),
        ],
      ),
    );
  }
}