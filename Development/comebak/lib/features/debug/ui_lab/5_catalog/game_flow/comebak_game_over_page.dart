import 'package:flutter/material.dart';
import '../../1_foundations/tokens/ui_lab_tokens.dart';
import 'widgets/comebak_confetti.dart';

// ==============================================================================
// [SCREEN] ComebakGameOverPage
// ------------------------------------------------------------------------------
// PURPOSE: The post-game results dashboard.
// UX DESIGN:
//   1. The Hero (Score) counts up/down first.
//   2. The Secondary Data (Stats, PB Chip) is completely hidden initially to
//      prevent cognitive overload.
//   3. Once the score finishes counting, the secondary data fades in smoothly.
// ==============================================================================
class ComebakGameOverPage extends StatefulWidget {
  const ComebakGameOverPage({super.key});

  @override
  State<ComebakGameOverPage> createState() => _ComebakGameOverPageState();
}

class _ComebakGameOverPageState extends State<ComebakGameOverPage> {
  // UI Lab state to toggle between different game outcomes
  int _selectedState = 0;

  // Guard variable: prevents stats from rendering until the score animation ends
  bool _isScoreLoaded = false;

  // Mock data representing different game outcomes
  static const _states = [
    _ResultState(
      'NEW PB',
      score: 340,
      isNewPb: true,
      xpChange: 45,
      accuracy: 92,
      bestCombo: 8,
      brokenRecordTime: '45 minutes',
    ),
    _ResultState(
      'NORMAL',
      score: 120,
      isNewPb: false,
      xpChange: 10,
      accuracy: 78,
      bestCombo: 4,
      brokenRecordTime: '',
    ),
    _ResultState(
      'XP LOSS',
      score: -15,
      isNewPb: false,
      xpChange: -15,
      accuracy: 30,
      bestCombo: 1,
      brokenRecordTime: '',
    ),
    _ResultState(
      'ZERO',
      score: 0,
      isNewPb: false,
      xpChange: 0,
      accuracy: 0,
      bestCombo: 0,
      brokenRecordTime: '',
    ),
  ];

  _ResultState get _currentState => _states[_selectedState];

  // When switching states in the UI Lab, reset the load flag so the
  // animation plays again from the start.
  void _handleStateChange(int index) {
    if (index == _selectedState) return;
    setState(() {
      _selectedState = index;
      _isScoreLoaded = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = _currentState;

    return Scaffold(
      backgroundColor: ComebakColors.canvas,
      body: Stack(
        children: [
          // Confetti fires immediately if it's a new PB
          if (state.isNewPb) const Positioned.fill(child: ComebakConfetti()),

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
                    'MAD BURST',
                    style: ComebakTypography.greeting.copyWith(
                      fontSize: 26,
                      color: ComebakColors.textPrimary,
                      letterSpacing: 3.0,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: ComebakLayout.spaceSm),

                  // SUBTITLE
                  Text(
                    'TIME\'S UP',
                    style: ComebakTypography.labelSmall.copyWith(
                      color: ComebakColors.textSecondary,
                      letterSpacing: 8.0,
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                    ),
                  ),

                  const SizedBox(height: ComebakLayout.spaceXxl),

                  // THE HERO: ANIMATED SCORE
                  // This fires the onComplete callback when the math finishes.
                  _AnimatedScoreCounter(
                    targetScore: state.score,
                    onComplete: () {
                      if (mounted) {
                        setState(() => _isScoreLoaded = true);
                      }
                    },
                  ),

                  const SizedBox(height: ComebakLayout.spaceLg),

                  // THE SECONDARY DATA
                  // AnimatedOpacity starts at 0.0, so it is 100% invisible on the
                  // first frame. It holds the layout space (preventing jumps) and
                  // fades to 1.0 ONLY when _isScoreLoaded becomes true.
                  AnimatedOpacity(
                    opacity: _isScoreLoaded ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeOut,
                    child: Column(
                      children: [
                        // PB Badge (Only shows if new PB)
                        if (state.isNewPb) ...[
                          _buildModernPbBadge(),
                          const SizedBox(height: 8),

                          // Broken Record Text (Extracted outside the chip)
                          Text(
                            'Broken after ${state.brokenRecordTime}',
                            style: ComebakTypography.labelSmall.copyWith(
                              color: ComebakColors.neonYellow.withValues(
                                alpha: 0.8,
                              ),
                              fontWeight: FontWeight.w600,
                              fontSize: 11,
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
                                '${state.accuracy}%',
                                ComebakColors.textPrimary,
                              ),
                            ),
                            Expanded(
                              child: _buildCenteredStat(
                                'XP GAINED',
                                '${state.xpChange > 0 ? '+' : ''}${state.xpChange}',
                                state.xpChange > 0
                                    ? ComebakColors.neonGreen
                                    : ComebakColors.vibrantRed,
                              ),
                            ),
                            Expanded(
                              child: _buildCenteredStat(
                                'BEST COMBO',
                                'x${state.bestCombo}',
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
                      // Restart the whole animation cycle
                      onPressed: () => setState(() => _isScoreLoaded = false),
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
                          letterSpacing: 1.0,
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
                          letterSpacing: 1.0,
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
                size: 24,
              ),
            ),
          ),

          // UI LAB STATE SWITCHER
          _buildStateSwitcher(),
        ],
      ),
    );
  }

  // ===========================================================================
  // MODERN PB BADGE (Rounded Pill, Glowing Gold)
  // ===========================================================================
  Widget _buildModernPbBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: ComebakColors.neonYellow.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(ComebakLayout.radiusXl),
        border: Border.all(
          color: ComebakColors.neonYellow.withValues(alpha: 0.8),
          width: 1.5,
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
          const SizedBox(width: 8),
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
  // CENTERED STAT COLUMN (Value on top, label below)
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
          onTap: () => Navigator.pop(context), // Tap overlay to dismiss
          behavior: HitTestBehavior.opaque,
          child: Align(
            alignment: Alignment.bottomCenter,
            child: GestureDetector(
              onTap: () {}, // Prevent taps inside sheet from dismissing
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
                        'Maintain accuracy above 80%, build consecutive correct answers (combos), and finish the round before the timer ends. Higher accuracy and longer combos yield higher XP.',
                      ),
                      const SizedBox(height: ComebakLayout.spaceLg),

                      _buildRuleRow(
                        'WHY IS MY XP NEGATIVE?',
                        'Negative XP is a penalty for poor performance. It occurs when your accuracy falls below 50% or you fail to reach the minimum score threshold for the game.',
                      ),
                      const SizedBox(height: ComebakLayout.spaceLg),

                      _buildRuleRow(
                        'ACCURACY',
                        'Percentage of correct taps versus total taps. Spamming taps without solving lowers this stat.',
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

  // ===========================================================================
  // UI LAB STATE SWITCHER
  // ===========================================================================
  Widget _buildStateSwitcher() {
    return Positioned(
      top: MediaQuery.of(context).padding.top + ComebakLayout.spaceMd,
      left: 0,
      right: 0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(_states.length, (index) {
          final isSelected = _selectedState == index;
          return GestureDetector(
            onTap: () => _handleStateChange(index),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected
                    ? ComebakColors.surfaceElevated
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? ComebakColors.border : Colors.transparent,
                ),
              ),
              child: Text(
                _states[index].label,
                style: ComebakTypography.labelSmall.copyWith(
                  color: isSelected
                      ? ComebakColors.textPrimary
                      : ComebakColors.textSecondary,
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

// ==============================================================================
// ANIMATED SCORE COUNTER
// Handles counting UP for positive, and counting DOWN for negative numbers.
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
    // If the score is 0, we don't need an animation. Just show 0 and complete.
    if (targetScore == 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) => onComplete());
      return _buildText('0', ComebakColors.vibrantRed);
    }

    // Negative scores are red. Positive are white.
    final isNegative = targetScore < 0;
    final color = isNegative
        ? ComebakColors.vibrantRed
        : ComebakColors.textPrimary;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: targetScore.toDouble()),
      duration: const Duration(milliseconds: 1200),
      curve: Curves.easeOutExpo,
      onEnd: onComplete, // Fires exactly when the animation finishes
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

// ==============================================================================
// DATA MODEL
// ==============================================================================
class _ResultState {
  final String label;
  final int score;
  final bool isNewPb;
  final int xpChange;
  final int accuracy;
  final int bestCombo;
  final String brokenRecordTime;

  const _ResultState(
    this.label, {
    required this.score,
    required this.isNewPb,
    required this.xpChange,
    required this.accuracy,
    required this.bestCombo,
    required this.brokenRecordTime,
  });
}
