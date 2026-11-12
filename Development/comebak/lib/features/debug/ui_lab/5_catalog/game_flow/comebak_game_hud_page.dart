import 'package:flutter/material.dart';
import '../../1_foundations/tokens/ui_lab_tokens.dart';

class ComebakGameHudPage extends StatefulWidget {
  const ComebakGameHudPage({super.key});

  @override
  State<ComebakGameHudPage> createState() => _ComebakGameHudPageState();
}

class _ComebakGameHudPageState extends State<ComebakGameHudPage> {
  bool _showTarget = true;
  String _operationPrefix = '+';

  // Changed to final since they aren't mutated in the static UI preview
  final int _targetValue = 15;
  final double _timeLeft = 45.0;
  final int _score = 120;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ComebakColors.canvas,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(),
            _buildTimerBar(),
            Expanded(
              child: Center(
                child: Text(
                  'GAME CANVAS\n(Placeholder)',
                  textAlign: TextAlign.center,
                  style: ComebakTypography.bodyMedium.copyWith(
                    color: ComebakColors.textSecondary.withValues(alpha: 0.3),
                  ),
                ),
              ),
            ),
            _buildModeSwitcher(),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    final isLowTime = _timeLeft <= 10.0;
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: ComebakLayout.spaceLg,
        vertical: ComebakLayout.spaceMd,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${_timeLeft.ceil()}s',
                style: ComebakTypography.greeting.copyWith(
                  fontSize: 28,
                  color: isLowTime
                      ? ComebakColors.vibrantRed
                      : ComebakColors.textPrimary,
                ),
              ),
              Text(
                'Time',
                style: ComebakTypography.labelSmall.copyWith(
                  color: ComebakColors.textSecondary,
                ),
              ),
            ],
          ),

          if (_showTarget)
            Column(
              children: [
                Text(
                  '$_operationPrefix$_targetValue',
                  style: ComebakTypography.greeting.copyWith(
                    fontSize: 48,
                    height: 1.0,
                    color: ComebakColors.neonGreen,
                  ),
                ),
                Text(
                  'Target',
                  style: ComebakTypography.labelSmall.copyWith(
                    color: ComebakColors.textSecondary,
                  ),
                ),
              ],
            )
          else
            const SizedBox(width: 48),

          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$_score',
                style: ComebakTypography.greeting.copyWith(
                  fontSize: 28,
                  color: ComebakColors.textPrimary,
                ),
              ),
              Text(
                'Score',
                style: ComebakTypography.labelSmall.copyWith(
                  color: ComebakColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimerBar() {
    final progress = (_timeLeft / 60.0).clamp(0.0, 1.0);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: ComebakLayout.spaceLg),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(ComebakLayout.radiusMd),
        child: Container(
          height: 8,
          width: double.infinity,
          color: ComebakColors.surfaceElevated,
          child: Stack(
            children: [
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      ComebakColors.vibrantRed,
                      ComebakColors.neonPurple, // FIXED: Changed to neonPurple
                      ComebakColors.neonGreen,
                    ],
                    stops: [0.0, 0.5, 1.0],
                  ),
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: FractionallySizedBox(
                  widthFactor: 1.0 - progress,
                  child: Container(color: ComebakColors.surfaceElevated),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModeSwitcher() {
    return Padding(
      padding: const EdgeInsets.all(ComebakLayout.spaceLg),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _ModeButton(
            label: 'Add (+)',
            isActive: _showTarget && _operationPrefix == '+',
            onTap: () => setState(() {
              _showTarget = true;
              _operationPrefix = '+';
            }),
          ),
          const SizedBox(width: ComebakLayout.spaceSm),
          _ModeButton(
            label: 'Mad (x)',
            isActive: _showTarget && _operationPrefix == 'x',
            onTap: () => setState(() {
              _showTarget = true;
              _operationPrefix = 'x';
            }),
          ),
          const SizedBox(width: ComebakLayout.spaceSm),
          _ModeButton(
            label: 'BODMAS',
            isActive: !_showTarget,
            onTap: () => setState(() {
              _showTarget = false;
            }),
          ),
        ],
      ),
    );
  }
}

class _ModeButton extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _ModeButton({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: ComebakLayout.spaceMd,
          vertical: ComebakLayout.spaceSm,
        ),
        decoration: BoxDecoration(
          color: isActive ? ComebakColors.neonGreen : ComebakColors.surface,
          borderRadius: BorderRadius.circular(ComebakLayout.radiusSm),
          border: Border.all(
            color: isActive ? ComebakColors.neonGreen : ComebakColors.border,
          ),
        ),
        child: Text(
          label,
          style: ComebakTypography.labelSmall.copyWith(
            color: isActive
                ? ComebakColors.canvas
                : ComebakColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
