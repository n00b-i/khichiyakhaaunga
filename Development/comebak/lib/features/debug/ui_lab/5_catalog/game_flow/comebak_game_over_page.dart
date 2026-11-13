import 'package:flutter/material.dart';
import '../../1_foundations/tokens/ui_lab_tokens.dart';
import 'widgets/comebak_confetti.dart';

// ==============================================================================
// [SCREEN] ComebakGameOverPage
// ------------------------------------------------------------------------------
// PURPOSE: The production post-game results dashboard.
// DESIGN:
//   1. Hero Score (animated count up).
//   2. Secondary data (Stats, PB Chip) hidden until score finishes.
//   3. Strict token adherence.
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
  // Guard: prevents stats from rendering until the score animation ends
  bool _isScoreLoaded = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ComebakColors.canvas,
      body: Stack(
        children: [
          // Confetti fires immediately if it's a new PB
          if (widget.isNewPb) const Positioned.fill(child: ComebakConfetti()),

          SafeArea(
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
                      letterSpacing: ComebakLayout.spaceSm,
                      fontWeight: FontWeight.w800,
                    ),
                  ),

                  const SizedBox(height: ComebakLayout.spaceXxl),

                  // THE HERO: ANIMATED SCORE
                  _AnimatedScoreCounter(
                    targetScore: widget.score,
                    onComplete: () {
                      if (mounted) {
                        setState(() => _isScoreLoaded = true);
                      }
                    },
                  ),

                  const SizedBox(height: ComebakLayout.spaceLg),

                  // THE SECONDARY DATA
                  // AnimatedOpacity starts at 0.0 and holds layout space.
                  // It fades to 1.0 ONLY when _isScoreLoaded becomes true.
                  AnimatedOpacity(
                    opacity: _isScoreLoaded ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeOut,
                    child: Column(
                      children: [
                        // PB Badge (Only shows if new PB)
                        if (widget.isNewPb) ...[
                          _buildModernPbBadge(),
                          const SizedBox(height: ComebakLayout.spaceSm),

                          if (widget.previousPBBrokenAfter != null)
                            Text(
                              'Broken after ${widget.previousPBBrokenAfter}',
                              style: ComebakTypography.labelSmall.copyWith(
                                color: ComebakColors.neonYellow.withValues(
                                  alpha: 0.8,
                                ),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          const SizedBox(height: ComebakLayout.spaceXxl),
                        ] else ...[
                          const SizedBox(height: ComebakLayout.spaceXxl),
                        ],

                        // CENTERED STATS ROW
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

                  // ACTIONS
                  SizedBox(
                    height: ComebakLayout.buttonHeight,
                    width: double.infinity,
                    child: TextButton(
                      onPressed: () {
                        // Replace current route with a fresh game
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
                  const SizedBox(height: ComebakLayout.spaceMd),

                  SizedBox(
                    height: ComebakLayout.buttonHeight,
                    width: double.infinity,
                    child: TextButton(
                      onPressed: () =>
                          Navigator.popUntil(context, (route) => route.isFirst),
                      style: TextButton.styleFrom(
                        backgroundColor: ComebakColors.surfaceElevated,
                        foregroundColor: ComebakColors.textPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            ComebakLayout.radiusMd,
                          ),
                        ),
                      ),
                      child: Text(
                        'GO HOME',
                        style: ComebakTypography.titleMedium.copyWith(
                          color: ComebakColors.textPrimary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: ComebakLayout.spaceXl),
                ],
              ),
            ),
          ),

          // HELP ICON (Opens XP Rules)
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

  // ===========================================================================
  // MODERN PB BADGE (Rounded Pill, Glowing Gold)
  // ===========================================================================
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
            blurRadius: 12,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.emoji_events_rounded,
            size: 16,
            color: ComebakColors.neonYellow,
          ),
          const SizedBox(width: ComebakLayout.spaceSm),
          Text(
            'PERSONAL BEST',
            style: ComebakTypography.labelSmall.copyWith(
              color: ComebakColors.neonYellow,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // CENTERED STAT COLUMN
  // ===========================================================================
  Widget _buildCenteredStat(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          value,
          style: ComebakTypography.greeting.copyWith(
            color: color,
            fontWeight: FontWeight.w800,
            fontSize: 24,
            height: 1.0,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: ComebakTypography.labelSmall.copyWith(
            color: ComebakColors.textSecondary,
            letterSpacing: 1.5,
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  // ===========================================================================
  // BOTTOM SHEET: XP RULES
  // ===========================================================================
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

// ==============================================================================
// ANIMATED SCORE COUNTER
// ==============================================================================
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
        fontSize: 120,
        height: 0.9,
        color: color,
        fontWeight: FontWeight.w800,
        letterSpacing: -2.0,
      ),
    );
  }
}
