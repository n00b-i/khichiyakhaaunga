import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import '../../1_foundations/tokens/ui_lab_tokens.dart';
import '../../3_molecules/comebak_sheets.dart';
import '../stats_flow/comebak_stats_page.dart';

// ==============================================================================
// [SCREEN] ComebakProfilePage
// ------------------------------------------------------------------------------
// PURPOSE: The user's identity and account management screen.
// DESIGN: Editorial, minimal. Strictly uses ComebakLayout and ComebakTypography
// tokens for all spacing, sizing, and text styles.
// ==============================================================================
class ComebakProfilePage extends StatelessWidget {
  const ComebakProfilePage({super.key});

  // In production, these come from Supabase/Cache
  static const String _userName = 'Deevanshu';
  static const String _userEmail = 'deevanshu@gmail.com';
  static const String _joinDate = 'Joined Oct 2023';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ComebakColors.canvas,
      body: Stack(
        children: [
          // Signature Ambient Glow (Top Right) - Tokenized size
          Positioned(
            top: -ComebakLayout.spaceXxl * 3,
            right: -ComebakLayout.spaceXxl * 3,
            child: Container(
              width: ComebakLayout.bgGlowSize,
              height: ComebakLayout.bgGlowSize,
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
                  const SizedBox(height: ComebakLayout.spaceXxl),

                  // IDENTITY BLOCK
                  Row(
                    children: [
                      // Avatar - Sized using tokens
                      Container(
                        width:
                            ComebakLayout.cardIconContainer +
                            ComebakLayout.spaceMd,
                        height:
                            ComebakLayout.cardIconContainer +
                            ComebakLayout.spaceMd,
                        decoration: BoxDecoration(
                          color: ComebakColors.surfaceElevated,
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
                            _userName[0].toUpperCase(),
                            style: ComebakTypography.greeting.copyWith(
                              color: ComebakColors.neonGreen,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: ComebakLayout.spaceLg),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _userName,
                              style: ComebakTypography.titleLarge.copyWith(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: ComebakLayout.spaceXs),
                            Text(
                              _userEmail,
                              style: ComebakTypography.bodyMedium.copyWith(
                                color: ComebakColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: ComebakLayout.spaceXs / 2),
                            Text(
                              _joinDate,
                              style: ComebakTypography.labelSmall.copyWith(
                                color: ComebakColors.textSecondary.withValues(
                                  alpha: 0.6,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: ComebakLayout.spaceXxl * 1.5),

                  // STATS GATEWAY (Mini Card)
                  GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ComebakStatsPage(),
                      ),
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(ComebakLayout.spaceLg),
                      decoration: BoxDecoration(
                        color: ComebakColors.surface,
                        borderRadius: BorderRadius.circular(
                          ComebakLayout.radiusLg,
                        ),
                        border: Border.all(color: ComebakColors.border),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(
                              ComebakLayout.spaceSm,
                            ),
                            decoration: BoxDecoration(
                              color: ComebakColors.neonGreen.withValues(
                                alpha: 0.1,
                              ),
                              borderRadius: BorderRadius.circular(
                                ComebakLayout.radiusSm,
                              ),
                            ),
                            child: const Icon(
                              Icons.bar_chart, // Material Icon fallback
                              color: ComebakColors.neonGreen,
                              size: ComebakLayout.spaceXl,
                            ),
                          ),
                          const SizedBox(width: ComebakLayout.spaceLg),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Performance Stats',
                                  style: ComebakTypography.titleMedium.copyWith(
                                    color: ComebakColors.textPrimary,
                                  ),
                                ),
                                Text(
                                  'View your lifetime records',
                                  style: ComebakTypography.labelSmall.copyWith(
                                    color: ComebakColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(
                            LucideIcons.chevron_right,
                            color: ComebakColors.textSecondary,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: ComebakLayout.spaceXxl * 1.5),

                  // ACTIONS LIST (Editorial Hairlines)
                  Text(
                    'ACCOUNT',
                    style: ComebakTypography.labelSmall.copyWith(
                      color: ComebakColors.textSecondary,
                      letterSpacing: ComebakLayout.spaceXs / 2,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: ComebakLayout.spaceMd),

                  _buildActionRow(
                    icon: LucideIcons.pencil,
                    label: 'Edit Name',
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (_) =>
                            const ComebakEditNameSheet(initialName: _userName),
                      );
                    },
                  ),

                  _buildActionRow(
                    icon: LucideIcons.log_out,
                    label: 'Logout',
                    isDestructive: true,
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (_) => const ComebakLogoutSheet(),
                      );
                    },
                  ),

                  const SizedBox(height: ComebakLayout.spaceXxl * 2),

                  // APP VERSION / FOOTER
                  Center(
                    child: Text(
                      'COMEBAK v1.0.0',
                      style: ComebakTypography.labelSmall.copyWith(
                        color: ComebakColors.textSecondary.withValues(
                          alpha: 0.3,
                        ),
                        letterSpacing: ComebakLayout.spaceXs / 2,
                      ),
                    ),
                  ),
                  const SizedBox(height: ComebakLayout.spaceXxl),
                ],
              ),
            ),
          ),
        ],
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
        decoration: const BoxDecoration(
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
}
