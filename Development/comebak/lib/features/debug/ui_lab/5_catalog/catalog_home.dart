import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import '../1_foundations/tokens/ui_lab_tokens.dart';
import '../1_foundations/ui_lab_copy.dart';
import '../3_molecules/comebak_sheets.dart';
import 'comebak_home_flow.dart';
import 'comebak_streak_card_page.dart';
import 'comebak_button_test_page.dart';
import 'comebak_foundations_page.dart';
import 'comebak_game_card_page.dart';
import 'game_flow/comebak_game_hud_page.dart';
import 'game_flow/comebak_game_over_page.dart';
import 'stats_flow/comebak_stats_page.dart';

// Auth Variants Imports
import 'auth_variants/comebak_auth_variants_page.dart';
import 'auth_variants/splash_v1_rules_v2.dart';
import 'auth_variants/comebak_rule_engine.dart';
import 'auth_variants/login_v1_rules.dart';

class ComebakCatalogHome extends StatelessWidget {
  const ComebakCatalogHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ComebakColors.canvas,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(ComebakLayout.spaceXl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: ComebakLayout.spaceXl),
              Text(ComebakCopy.catalogTitle, style: ComebakTypography.greeting),
              const SizedBox(height: ComebakLayout.spaceXxl),

              // ==================================================================
              // [COMPONENTS]
              // ==================================================================
              Text('COMPONENTS', style: ComebakTypography.sectionSubtitle),
              const SizedBox(height: ComebakLayout.spaceSm),
              _CatalogTile(
                title: ComebakCopy.catalogStreak,
                icon: LucideIcons.flame,
                onTap: () => Navigator.push(
                  context,
                  FadeRoute(page: const ComebakStreakCardPage()),
                ),
              ),
              const SizedBox(height: ComebakLayout.spaceXl),

              // ==================================================================
              // [OVERLAYS]
              // ==================================================================
              Text('OVERLAYS', style: ComebakTypography.sectionSubtitle),
              const SizedBox(height: ComebakLayout.spaceSm),
              _CatalogTile(
                title: ComebakCopy.catalogFoundationsPage,
                icon: LucideIcons.palette,
                onTap: () => Navigator.push(
                  context,
                  FadeRoute(page: const ComebakFoundationsPage()),
                ),
              ),
              _CatalogTile(
                title: ComebakCopy.catalogGameCardPage,
                icon: LucideIcons.gamepad_2,
                onTap: () => Navigator.push(
                  context,
                  FadeRoute(page: const ComebakGameCardPage()),
                ),
              ),
              _CatalogTile(
                title: 'Button Layout Tests',
                icon: LucideIcons.layout_dashboard,
                onTap: () => Navigator.push(
                  context,
                  FadeRoute(page: const ComebakButtonTestPage()),
                ),
              ),
              _CatalogTile(
                title: 'Edit Name Sheet',
                icon: LucideIcons.pencil,
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (_) =>
                        const ComebakEditNameSheet(initialName: 'deevanshu'),
                  );
                },
              ),
              _CatalogTile(
                title: 'Logout Sheet',
                icon: LucideIcons.log_out,
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (_) => const ComebakLogoutSheet(),
                  );
                },
              ),
              const SizedBox(height: ComebakLayout.spaceXl),

              // ==================================================================
              // [FLOWS]
              // ==================================================================
              Text('FULL SCREENS', style: ComebakTypography.sectionSubtitle),
              const SizedBox(height: ComebakLayout.spaceSm),

              _CatalogTile(
                title: 'THE RULES (Full Flow)',
                icon: LucideIcons.flame,
                onTap: () async {
                  final engine = ComebakRuleEngine();
                  final rule = await engine.pickRule();
                  if (!context.mounted) return;

                  Navigator.push(
                    context,
                    FadeRoute(
                      page: SplashV1RulesV2(
                        rule: rule,
                        onComplete: () {
                          Navigator.pushReplacement(
                            context,
                            FadeRoute(
                              page: LoginV1Rules(
                                onGoogleSignIn: () {
                                  Navigator.of(
                                    context,
                                  ).popUntil((route) => route.isFirst);
                                },
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  );
                },
              ),

              _CatalogTile(
                title: 'GAMEPLAY HUD',
                icon: LucideIcons.timer,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ComebakGameHudPage(),
                  ),
                ),
              ),

              _CatalogTile(
                title: 'GAME SCORE SCREEN',
                icon: LucideIcons.trophy,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ComebakGameOverPage(),
                  ),
                ),
              ),

              _CatalogTile(
                title: 'STATS SCREEN',
                icon: LucideIcons.chart_bar,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ComebakStatsPage()),
                ),
              ),

              _CatalogTile(
                title: 'AUTH VARIANTS (6)',
                icon: LucideIcons.layers,
                onTap: () => Navigator.push(
                  context,
                  FadeRoute(page: const ComebakAuthVariantsPage()),
                ),
              ),

              _CatalogTile(
                title: ComebakCopy.catalogHome,
                icon: LucideIcons.house,
                onTap: () => Navigator.push(
                  context,
                  FadeRoute(page: const ComebakHomeFlow()),
                ),
              ),
              const SizedBox(height: ComebakLayout.spaceXl),
            ],
          ),
        ),
      ),
    );
  }
}

class _CatalogTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  const _CatalogTile({
    required this.title,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: ComebakLayout.spaceMd),
        padding: const EdgeInsets.all(ComebakLayout.spaceLg),
        decoration: BoxDecoration(
          color: ComebakColors.surface,
          borderRadius: BorderRadius.circular(ComebakLayout.radiusLg),
          border: Border.all(
            color: ComebakColors.border,
            width: ComebakLayout.borderThin,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: ComebakColors.neonGreen,
              size: ComebakLayout.spaceXl,
            ),
            const SizedBox(width: ComebakLayout.spaceLg),
            Expanded(child: Text(title, style: ComebakTypography.titleMedium)),
            const Icon(
              LucideIcons.chevron_right,
              color: ComebakColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}

class FadeRoute<T> extends PageRouteBuilder<T> {
  final Widget page;

  FadeRoute({required this.page})
    : super(
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 600),
        barrierDismissible: false,
        barrierColor: Colors.transparent,
        opaque: false,
      );
}
