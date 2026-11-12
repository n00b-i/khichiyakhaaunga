import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/theme/app_theme.dart';
import '../../core/stats/stats_repository.dart';

class StatsScreen extends StatefulWidget {
  final ValueNotifier<int> refreshTrigger;
  const StatsScreen({super.key, required this.refreshTrigger});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  late StatsRepository _statsRepo;
  Future<Map<String, dynamic>?>? _statsFuture;

  @override
  void initState() {
    super.initState();
    _statsRepo = StatsRepository(Supabase.instance.client);
    _fetchStats();
    widget.refreshTrigger.addListener(_fetchStats);
  }

  @override
  void dispose() {
    widget.refreshTrigger.removeListener(_fetchStats);
    super.dispose();
  }

  void _fetchStats() {
    setState(() {
      _statsFuture = _statsRepo.getUserStats();
    });
  }

  String _formatTime(int seconds) {
    if (seconds == 0) return '0s';
    if (seconds < 60) return '${seconds}s';
    final m = seconds ~/ 60;
    final s = seconds % 60;
    if (m < 60) return '${m}m ${s}s';
    final h = m ~/ 60;
    return '${h}h ${m % 60}m';
  }

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
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              );
            }

            final data = snapshot.data;
            if (data == null) {
              return Center(
                child: Text(
                  'No data available.\nPlay a game to get started!',
                  style: AppTextStyles.body.copyWith(color: AppColors.textPrimary),
                  textAlign: TextAlign.center,
                ),
              );
            }

            final int totalGames = data['total_games'] ?? 0;
            final int totalTime = data['total_time_seconds'] ?? 0;
            final Map<String, int?> pbs = {
              'Add Burst': data['add_burst_pb'],
              'Mad Burst': data['mad_burst_pb'],
              'BODMAS Burst': data['bodmas_burst_pb'],
              'Small Burst': data['small_burst_pb'],
              'Saitan +': data['saitan_add_pb'],
              'Saitan X': data['saitan_mul_pb'],
            };

            return RefreshIndicator(
              onRefresh: () async => _fetchStats(),
              color: AppColors.primary,
              backgroundColor: AppColors.surface,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: AppSpacing.lg),
                    const Text('Your Stats', style: AppTextStyles.display),
                    const SizedBox(height: AppSpacing.xl),
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
                    ...pbs.entries.map(
                      (e) => _PbRow(
                        gameTitle: e.key,
                        bestScore: e.value,
                        formatNumber: _formatNumber,
                      ),
                    ),
                  ],
                ),
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
    return Container(
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
    final displayScore = bestScore != null ? formatNumber(bestScore!) : '—';
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color:AppColors.surface,
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
