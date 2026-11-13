import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// [UI LAB TOKENS]
import '../../1_foundations/tokens/ui_lab_tokens.dart';
// [UI LAB ATOMS]
import '../../2_atoms/comebak_flame_3d.dart';
import '../../2_atoms/comebak_xp_icon.dart';
import '../auth_variants/layers/comebak_clay_logo.dart';
// [UI LAB SHEETS]
import '../../3_molecules/comebak_sheets.dart';
// [SSOT REPOSITORIES]
import '../../../../../core/profile/profile_repository.dart';
import '../../../../../core/stats/stats_repository.dart';

class ComebakProfilePage extends StatefulWidget {
  const ComebakProfilePage({super.key});

  @override
  State<ComebakProfilePage> createState() => _ComebakProfilePageState();
}

class _ComebakProfilePageState extends State<ComebakProfilePage> {
  late Future<List<dynamic>> _combinedFuture;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    setState(() {
      _combinedFuture = Future.wait([
        ProfileRepository(Supabase.instance.client).getProfile(),
        StatsRepository(Supabase.instance.client).getUserStats(),
      ]);
    });
  }

  Future<void> _handleLogout() async {
    final bool? confirm = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const ComebakLogoutSheet(),
    );

    if (confirm != true || !mounted) return;

    try {
      await Supabase.instance.client.auth.signOut();
      ProfileRepository.clearCache();
      await ProfileRepository.clearLocalData();

      if (mounted) {
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } catch (e) {
      debugPrint('[ComebakProfilePage] Logout sequence error: $e');
    }
  }

  Future<void> _handleEditName(
    String? currentName,
    DateTime? lastUpdated,
  ) async {
    if (lastUpdated != null) {
      final hoursSince = DateTime.now().difference(lastUpdated).inHours;
      if (hoursSince < 24) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Name can be updated once every 24 hours.',
              style: ComebakTypography.titleMedium.copyWith(
                color: ComebakColors.textPrimary,
              ),
            ),
            backgroundColor: ComebakColors.surfaceElevated,
          ),
        );
        return;
      }
    }

    final newName = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ComebakEditNameSheet(initialName: currentName),
    );

    if (!mounted ||
        newName == null ||
        newName.trim().isEmpty ||
        newName == currentName) {
      return;
    }

    final success = await ProfileRepository(
      Supabase.instance.client,
    ).updateUsername(newName.trim());

    if (mounted) {
      if (success) {
        _loadData();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Name can be updated once every 24 hours.',
              style: ComebakTypography.titleMedium.copyWith(
                color: ComebakColors.textPrimary,
              ),
            ),
            backgroundColor: ComebakColors.surfaceElevated,
          ),
        );
      }
    }
  }

  String _formatJoinDate(String? isoDate) {
    if (isoDate == null) return 'Joined recently';
    try {
      final date = DateTime.parse(isoDate);
      const months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ];
      return 'Joined ${months[date.month - 1]} ${date.year}';
    } catch (e) {
      return 'Joined recently';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ComebakColors.canvas,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: ComebakLayout.spaceXl,
                    ),
                    child: FutureBuilder<List<dynamic>>(
                      key: ValueKey(_combinedFuture),
                      future: _combinedFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(
                              color: ComebakColors.neonGreen,
                            ),
                          );
                        }

                        final profileData =
                            snapshot.data?[0] as Map<String, dynamic>?;
                        final statsData =
                            snapshot.data?[1] as Map<String, dynamic>?;

                        final String userName =
                            (profileData?['name'] as String?)
                                    ?.trim()
                                    .isNotEmpty ==
                                true
                            ? profileData!['name'] as String
                            : 'User';
                        final String userEmail =
                            profileData?['email'] as String? ?? 'No email';
                        final String joinDate = _formatJoinDate(
                          profileData?['created_at'] as String?,
                        );

                        final int totalXp = statsData?['total_xp'] as int? ?? 0;
                        final int streak =
                            profileData?['current_streak'] as int? ?? 0;

                        DateTime? lastUpdated;
                        if (profileData?['name_last_updated'] != null) {
                          lastUpdated = DateTime.parse(
                            profileData!['name_last_updated'] as String,
                          ).toLocal();
                        }

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: ComebakLayout.spaceXxl),
                            Text(
                              'PROFILE',
                              style: ComebakTypography.greeting.copyWith(
                                fontSize:
                                    ComebakLayout.spaceXxl +
                                    ComebakLayout.spaceXs,
                                letterSpacing: -1.0,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: ComebakLayout.spaceXxl),
                            // [IDENTITY BLOCK]
                            Row(
                              children: [
                                Container(
                                  width: ComebakLayout.gameIconSize,
                                  height: ComebakLayout.gameIconSize,
                                  decoration: BoxDecoration(
                                    color: ComebakColors.surface,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: ComebakColors.neonGreen.withValues(
                                        alpha: 0.3,
                                      ),
                                      width: ComebakLayout.borderThick,
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      userName.isNotEmpty
                                          ? userName[0].toUpperCase()
                                          : 'U',
                                      style: ComebakTypography.greeting
                                          .copyWith(
                                            color: ComebakColors.neonGreen,
                                            fontWeight: FontWeight.w800,
                                          ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: ComebakLayout.spaceLg),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        userName,
                                        style: ComebakTypography.titleLarge
                                            .copyWith(
                                              fontWeight: FontWeight.w800,
                                              color: ComebakColors.textPrimary,
                                            ),
                                      ),
                                      const SizedBox(
                                        height: ComebakLayout.spaceXs,
                                      ),
                                      Text(
                                        userEmail,
                                        style: ComebakTypography.bodyMedium
                                            .copyWith(
                                              color:
                                                  ComebakColors.textSecondary,
                                            ),
                                      ),
                                      const SizedBox(
                                        height: ComebakLayout.spaceSm,
                                      ),
                                      Text(
                                        joinDate,
                                        style: ComebakTypography.bodyMedium
                                            .copyWith(
                                              color:
                                                  ComebakColors.textSecondary,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: ComebakLayout.spaceXl),

                            // [STATS INLINE TEXT]
                            Row(
                              children: [
                                ComebakXpIcon(
                                  icon: Icons.bolt,
                                  color: totalXp < 0
                                      ? ComebakColors.vibrantRed
                                      : ComebakColors.neonGreen,
                                  size: ComebakLayout.spaceXl,
                                ),
                                const SizedBox(width: ComebakLayout.spaceXs),
                                Text(
                                  '${_formatIndian(totalXp)} XP',
                                  style: ComebakTypography.titleMedium.copyWith(
                                    color: totalXp < 0
                                        ? ComebakColors.vibrantRed
                                        : ComebakColors.textPrimary,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(width: ComebakLayout.spaceXl),
                                ComebakFlame3D(
                                  size: ComebakLayout.spaceXl,
                                  key: ValueKey('flame_$streak'),
                                ),
                                const SizedBox(width: ComebakLayout.spaceXs),
                                Text(
                                  '$streak ${streak == 1 ? 'Day' : 'Days'}',
                                  style: ComebakTypography.titleMedium.copyWith(
                                    color: ComebakColors.textPrimary,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(
                              height: ComebakLayout.spaceXxl * 1.5,
                            ),

                            // [ACTIONS LIST]
                            Text(
                              'ACCOUNT',
                              style: ComebakTypography.labelSmall.copyWith(
                                color: ComebakColors.textSecondary,
                                letterSpacing: ComebakLayout.borderGradient,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: ComebakLayout.spaceMd),

                            _buildActionRow(
                              icon: LucideIcons.pencil,
                              label: 'Edit Name',
                              onTap: () =>
                                  _handleEditName(userName, lastUpdated),
                            ),
                            _buildActionRow(
                              icon: LucideIcons.log_out,
                              label: 'Logout',
                              isDestructive: true,
                              onTap: _handleLogout,
                            ),

                            const Spacer(),

                            // [VERSION FOOTER WITH LOGO AND EXPERIMENTING]
                            Center(
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const SizedBox(
                                        // [INCREASED SIZE]
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
                                      const SizedBox(
                                        width: ComebakLayout.spaceSm,
                                      ),
                                      Text(
                                        'COMEBAK v1.0.0',
                                        style: ComebakTypography.labelSmall
                                            .copyWith(
                                              color: ComebakColors.neonGreen,
                                              letterSpacing:
                                                  ComebakLayout.spaceXs / 2,
                                            ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: ComebakLayout.spaceLg),
                                  // Text(
                                  //   'Experimenting in India',
                                  //   style: ComebakTypography.sectionTitle
                                  //       .copyWith(
                                  //         color: ComebakColors.neonGreen
                                  //             .withValues(alpha: 0.6),
                                  //       ),
                                  // ),
                                ],
                              ),
                            ),
                            const SizedBox(height: ComebakLayout.spaceXxl),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildActionRow({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    final color = isDestructive
        ? ComebakColors.vibrantRed
        : ComebakColors.textPrimary;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: ComebakLayout.spaceLg),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: ComebakColors.border,
              width: ComebakLayout.borderThin,
            ),
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: ComebakLayout.spaceXl),
            const SizedBox(width: ComebakLayout.spaceLg),
            Expanded(
              child: Text(
                label,
                style: ComebakTypography.titleMedium.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Icon(
              LucideIcons.chevron_right,
              color: isDestructive
                  ? ComebakColors.vibrantRed.withValues(alpha: 0.5)
                  : ComebakColors.textSecondary,
              size: ComebakLayout.spaceXl,
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
