import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart'; // [ADDED] For chevron_left
import '../../1_foundations/tokens/ui_lab_tokens.dart';
import '../../2_atoms/comebak_xp_icon.dart'; // [ADDED] For the XP icon
import 'widgets/comebak_confetti.dart';

// ==============================================================================
// [SCREEN] ComebakGameOverPage
// ------------------------------------------------------------------------------
// PURPOSE: Production results dashboard.
// FIXES APPLIED:
// - Replaced "GO HOME" with a top-left back button.
// - Added a top-right help icon that opens the XP rules bottom sheet.
// - Added the 3D XP Icon to the "XP GAINED" stat.
// ==============================================================================
class ComebakGameOverPage extends StatefulWidget {
  final int score;
  final int accuracy;
  final int bestCombo;
  final int xpChange;
  final bool isNewPb;
  final String? previousPBBrokenAfter;
  final String gameName;
  final Widget Function() gameBuilder;

  const ComebakGameOverPage({
    super.key,
    required this.score,
    required this.accuracy,
    required this.bestCombo,
    required this.xpChange,
    required this.isNewPb,
    required this.gameName,
    required this.gameBuilder,
    this.previousPBBrokenAfter,
  });

  @override
  State<ComebakGameOverPage> createState() => _ComebakGameOverPageState();
}

class _ComebakGameOverPageState extends State<ComebakGameOverPage> {
  bool _isScoreLoaded = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ComebakColors.canvas,
      body: Stack(
        children: [
          if (widget.isNewPb) const Positioned.fill(child: ComebakConfetti()),

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
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Spacer(flex: 2),

                            // GAME NAME
                            Text(
                              widget.gameName.toUpperCase(),
                              style: ComebakTypography.greeting.copyWith(
                                color: ComebakColors.textPrimary,
                                letterSpacing: ComebakLayout.spaceXs * 0.75,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: ComebakLayout.spaceSm),

                            // SUBTITLE
                            Text(
                              'TIME\'S UP',
                              style: ComebakTypography.labelSmall.copyWith(
                                color: ComebakColors.textSecondary,
                                letterSpacing: ComebakLayout.spaceSm * 0.75,
                                fontWeight: FontWeight.w800,
                              ),
                            ),

                            const SizedBox(height: ComebakLayout.spaceXxl),

                            // HERO SCORE
                            _AnimatedScoreCounter(
                              targetScore: widget.score,
                              onComplete: () {
                                if (mounted) {
                                  setState(() => _isScoreLoaded = true);
                                }
                              },
                            ),

                            const SizedBox(height: ComebakLayout.spaceLg),

                            // STATS & BADGES
                            AnimatedOpacity(
                              opacity: _isScoreLoaded ? 1.0 : 0.0,
                              duration: const Duration(milliseconds: 500),
                              curve: Curves.easeOut,
                              child: Column(
                                children: [
                                  if (widget.isNewPb) ...[
                                    _buildModernPbBadge(),
                                    const SizedBox(
                                      height: ComebakLayout.spaceSm,
                                    ),

                                    if (widget.previousPBBrokenAfter != null)
                                      Text(
                                        'Broken after ${widget.previousPBBrokenAfter}',
                                        style: ComebakTypography.labelSmall
                                            .copyWith(
                                              color: ComebakColors.neonYellow
                                                  .withValues(alpha: 0.8),
                                              fontWeight: FontWeight.w600,
                                            ),
                                      ),
                                    const SizedBox(
                                      height: ComebakLayout.spaceXxl,
                                    ),
                                  ] else ...[
                                    const SizedBox(
                                      height: ComebakLayout.spaceXxl,
                                    ),
                                  ],

                                  // 3-COLUMN STATS ROW
                                  Row(
                                    children: [
                                      Expanded(
                                        child: _buildCenteredStat(
                                          'ACCURACY',
                                          '${widget.accuracy}%',
                                          ComebakColors.textPrimary,
                                        ),
                                      ),
                                      Expanded(
                                        child: _buildCenteredStat(
                                          'XP GAINED',
                                          '${widget.xpChange > 0 ? '+' : ''}${widget.xpChange}',
                                          widget.xpChange > 0
                                              ? ComebakColors.neonGreen
                                              : ComebakColors.vibrantRed,
                                          // [FIX] XP Icon added
                                          iconWidget: ComebakXpIcon(
                                            icon: Icons.bolt,
                                            color: widget.xpChange > 0
                                                ? ComebakColors.neonGreen
                                                : ComebakColors.vibrantRed,
                                            size: ComebakLayout.spaceLg,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: _buildCenteredStat(
                                          'BEST COMBO',
                                          'x${widget.bestCombo}',
                                          ComebakColors.textPrimary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            const Spacer(flex: 3),

                            // PRIMARY ACTION (PLAY AGAIN)
                            // [FIX] Removed "GO HOME" button
                            SizedBox(
                              height: ComebakLayout.buttonHeight,
                              width: double.infinity,
                              child: TextButton(
                                onPressed: () {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => widget.gameBuilder(),
                                    ),
                                  );
                                },
                                style: TextButton.styleFrom(
                                  backgroundColor: ComebakColors.neonGreen,
                                  foregroundColor: ComebakColors.canvas,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                      ComebakLayout.radiusMd,
                                    ),
                                  ),
                                ),
                                child: Text(
                                  'PLAY AGAIN',
                                  style: ComebakTypography.titleMedium.copyWith(
                                    color: ComebakColors.canvas,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ),

                            // [UX: THUMB ZONE LIFT]
                            const Spacer(flex: 2),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // [FIX] BACK BUTTON (Top Left)
          Positioned(
            top: MediaQuery.of(context).padding.top + ComebakLayout.spaceMd,
            left: ComebakLayout.spaceLg,
            child: IconButton(
              icon: const Icon(
                LucideIcons.chevron_left,
                color: ComebakColors.textPrimary,
              ),
              onPressed: () =>
                  Navigator.of(context).popUntil((route) => route.isFirst),
            ),
          ),

          // [FIX] HELP ICON (Top Right)
          Positioned(
            top: MediaQuery.of(context).padding.top + ComebakLayout.spaceMd,
            right: ComebakLayout.spaceLg,
            child: GestureDetector(
              onTap: () => _showRulesSheet(context),
              child: const Icon(
                Icons.help_outline,
                color: ComebakColors.textSecondary,
                size: ComebakLayout.spaceXl,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernPbBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: ComebakLayout.spaceLg,
        vertical: ComebakLayout.spaceSm,
      ),
      decoration: BoxDecoration(
        color: ComebakColors.neonYellow.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(ComebakLayout.radiusXl),
        border: Border.all(
          color: ComebakColors.neonYellow.withValues(alpha: 0.8),
          width: ComebakLayout.borderThick,
        ),
        boxShadow: [
          BoxShadow(
            color: ComebakColors.neonYellow.withValues(alpha: 0.2),
            blurRadius: ComebakLayout.spaceMd,
            spreadRadius: ComebakLayout.borderThin,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.emoji_events_rounded,
            size: ComebakLayout.spaceLg,
            color: ComebakColors.neonYellow,
          ),
          const SizedBox(width: ComebakLayout.spaceSm),
          Text(
            'PERSONAL BEST',
            style: ComebakTypography.labelSmall.copyWith(
              color: ComebakColors.neonYellow,
              fontWeight: FontWeight.w900,
              letterSpacing: ComebakLayout.borderGradient,
            ),
          ),
        ],
      ),
    );
  }

  // [FIX] Added optional iconWidget parameter
  Widget _buildCenteredStat(
    String label,
    String value,
    Color color, {
    Widget? iconWidget,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              value,
              style: ComebakTypography.greeting.copyWith(
                color: color,
                fontWeight: FontWeight.w800,
                fontSize: ComebakLayout.spaceXl,
                height: 1.0,
              ),
            ),
            if (iconWidget != null) ...[
              const SizedBox(width: ComebakLayout.spaceXs),
              iconWidget,
            ],
          ],
        ),
        const SizedBox(height: ComebakLayout.spaceSm),
        Text(
          label,
          style: ComebakTypography.labelSmall.copyWith(
            color: ComebakColors.textSecondary,
            letterSpacing: ComebakLayout.borderGradient,
            fontSize: ComebakLayout.spaceSm + ComebakLayout.spaceXs / 2,
          ),
        ),
      ],
    );
  }

  // [FIX] Added XP Rules Bottom Sheet
  void _showRulesSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.8),
      builder: (context) {
        return GestureDetector(
          onTap: () => Navigator.pop(context),
          behavior: HitTestBehavior.opaque,
          child: Align(
            alignment: Alignment.bottomCenter,
            child: GestureDetector(
              onTap: () {},
              child: Container(
                padding: const EdgeInsets.all(ComebakLayout.spaceXl),
                decoration: const BoxDecoration(
                  color: ComebakColors.surface,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(ComebakLayout.radiusXl),
                  ),
                ),
                child: SafeArea(
                  top: false,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'SCORING RULES',
                            style: ComebakTypography.titleLarge.copyWith(
                              letterSpacing: 1.5,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: const Icon(
                              Icons.close,
                              color: ComebakColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: ComebakLayout.spaceXl),

                      _buildRuleRow(
                        'HOW TO EARN POSITIVE XP',
                        'Maintain accuracy above 80%, build consecutive correct answers (combos), and finish the round before the timer ends.',
                      ),
                      const SizedBox(height: ComebakLayout.spaceLg),

                      _buildRuleRow(
                        'WHY IS MY XP NEGATIVE?',
                        'Negative XP is a penalty for poor performance. It occurs when your accuracy falls below 50% or you fail to reach the minimum score threshold.',
                      ),
                      const SizedBox(height: ComebakLayout.spaceLg),

                      _buildRuleRow(
                        'ACCURACY',
                        'Percentage of correct taps versus total taps. Spamming taps lowers this stat.',
                      ),
                      const SizedBox(height: ComebakLayout.spaceLg),

                      _buildRuleRow(
                        'BEST COMBO',
                        'The longest uninterrupted streak of correct answers in a single session.',
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildRuleRow(String title, String desc) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: ComebakTypography.labelSmall.copyWith(
            color: ComebakColors.neonGreen,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          desc,
          style: ComebakTypography.bodyMedium.copyWith(
            color: ComebakColors.textSecondary,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}

class _AnimatedScoreCounter extends StatelessWidget {
  final int targetScore;
  final VoidCallback onComplete;

  const _AnimatedScoreCounter({
    required this.targetScore,
    required this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    if (targetScore == 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) => onComplete());
      return _buildText('0', ComebakColors.vibrantRed);
    }

    final isNegative = targetScore < 0;
    final color = isNegative
        ? ComebakColors.vibrantRed
        : ComebakColors.textPrimary;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: targetScore.toDouble()),
      duration: const Duration(milliseconds: 1200),
      curve: Curves.easeOutExpo,
      onEnd: onComplete,
      builder: (context, value, child) {
        return _buildText(value.round().toString(), color);
      },
    );
  }

  Widget _buildText(String value, Color color) {
    return Text(
      value,
      style: ComebakTypography.greeting.copyWith(
        fontSize: ComebakLayout.spaceXxl * 3.75,
        height: 0.9,
        color: color,
        fontWeight: FontWeight.w800,
        letterSpacing: -ComebakLayout.spaceXs / 2,
      ),
    );
  }
}
