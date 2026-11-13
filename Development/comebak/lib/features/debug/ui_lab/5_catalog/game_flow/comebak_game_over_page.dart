import 'package:flutter/material.dart';
import '../../1_foundations/tokens/ui_lab_tokens.dart';
import 'widgets/comebak_confetti.dart';

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
            // [ARCHITECTURE: LAYOUT SAFETY]
            // LayoutBuilder + SingleChildScrollView + IntrinsicHeight allows
            // the screen to scroll if it runs out of space (e.g., on iPhone SE
            // or with massive accessibility fonts), preventing RenderFlex overflow.
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
                            // [TOKEN] letterSpacing derived from spaceXs (4) * 0.75 = 3.0
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
                            // [TOKEN] letterSpacing derived from spaceSm (8) * 0.75 = 6.0
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

                            // PRIMARY ACTION
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
                            const SizedBox(height: ComebakLayout.spaceMd),

                            // SECONDARY ACTION
                            SizedBox(
                              height: ComebakLayout.buttonHeight,
                              width: double.infinity,
                              child: TextButton(
                                onPressed: () => Navigator.popUntil(
                                  context,
                                  (route) => route.isFirst,
                                ),
                                style: TextButton.styleFrom(
                                  backgroundColor:
                                      ComebakColors.surfaceElevated,
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

                            // [UX: THUMB ZONE LIFT]
                            // Lifts the buttons up by exactly one button height.
                            // IntrinsicHeight absorbs this safely without breaking
                            // the layout or pushing content off-screen.
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
            // [TOKEN] blurRadius = spaceMd (12)
            blurRadius: ComebakLayout.spaceMd,
            // [TOKEN] spreadRadius = borderThin (1)
            spreadRadius: ComebakLayout.borderThin,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // [TOKEN] Icon size = spaceLg (16)
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
              // [TOKEN] letterSpacing = borderGradient (1.5)
              letterSpacing: ComebakLayout.borderGradient,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCenteredStat(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          value,
          style: ComebakTypography.greeting.copyWith(
            color: color,
            fontWeight: FontWeight.w800,
            // [TOKEN] fontSize = spaceXl (24)
            fontSize: ComebakLayout.spaceXl,
            height: 1.0,
          ),
        ),
        // [TOKEN] Vertical gap = spaceSm (8)
        const SizedBox(height: ComebakLayout.spaceSm),
        Text(
          label,
          style: ComebakTypography.labelSmall.copyWith(
            color: ComebakColors.textSecondary,
            // [TOKEN] letterSpacing = borderGradient (1.5)
            letterSpacing: ComebakLayout.borderGradient,
            // [TOKEN] fontSize = spaceSm + spaceXs/2 (10)
            fontSize: ComebakLayout.spaceSm + ComebakLayout.spaceXs / 2,
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
        // [TOKEN] fontSize = spaceXxl * 3.75 (120)
        fontSize: ComebakLayout.spaceXxl * 3.75,
        height: 0.9,
        color: color,
        fontWeight: FontWeight.w800,
        // [TOKEN] letterSpacing = -(spaceXs / 2) (-2.0)
        letterSpacing: -ComebakLayout.spaceXs / 2,
      ),
    );
  }
}
