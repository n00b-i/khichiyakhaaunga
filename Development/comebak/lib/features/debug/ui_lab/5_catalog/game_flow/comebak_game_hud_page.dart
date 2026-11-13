import 'dart:async';
import 'package:flutter/material.dart';
import '../../1_foundations/tokens/ui_lab_tokens.dart';

class ComebakGameHudPage extends StatefulWidget {
  const ComebakGameHudPage({super.key});

  @override
  State<ComebakGameHudPage> createState() => _ComebakGameHudPageState();
}

class _ComebakGameHudPageState extends State<ComebakGameHudPage> {
  double _timeLeft = 60.0;
  int _score = 0;
  Timer? _timer;

  int _activeMode = 0;
  bool _showTarget = true;
  String _operationPrefix = '+';
  int _targetValue = 15;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(ComebakMotion.press, (timer) {
      if (!mounted) return;
      setState(() {
        if (_timeLeft > 0) {
          _timeLeft -= 0.1;
        } else {
          _timer?.cancel();
          _timeLeft = 0;
        }
      });
    });
  }

  void _resetGame() {
    setState(() {
      _timeLeft = 60.0;
      _score = 0;
    });
    _startTimer();
  }

  void _switchMode(int mode) {
    setState(() {
      _activeMode = mode;
      switch (mode) {
        case 0:
          _showTarget = true;
          _operationPrefix = '+';
          _targetValue = 15;
          break;
        case 1:
          _showTarget = true;
          _operationPrefix = 'x';
          _targetValue = 24;
          break;
        case 2:
        case 3:
        case 4:
          _showTarget = false;
          break;
      }
    });
    _resetGame();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ComebakColors.canvas,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopHud(),
            _buildTimerBar(),
            Expanded(child: _buildGameCanvas()),
            _buildModeSwitcher(),
          ],
        ),
      ),
    );
  }

  Widget _buildTopHud() {
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
                  fontSize: ComebakLayout.spaceXxl,
                  color: isLowTime
                      ? ComebakColors.vibrantRed
                      : ComebakColors.textPrimary,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
              Text(
                'TIME',
                style: ComebakTypography.labelSmall.copyWith(
                  color: ComebakColors.textSecondary,
                  letterSpacing: ComebakLayout.borderGradient,
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
                    fontSize: ComebakLayout.buttonHeight,
                    height: 1.0,
                    color: ComebakColors.neonGreen,
                  ),
                ),
                Text(
                  'TARGET',
                  style: ComebakTypography.labelSmall.copyWith(
                    color: ComebakColors.textSecondary,
                    letterSpacing: ComebakLayout.borderGradient,
                  ),
                ),
              ],
            )
          else
            const SizedBox(width: ComebakLayout.buttonHeight),

          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$_score',
                style: ComebakTypography.greeting.copyWith(
                  fontSize: ComebakLayout.spaceXxl,
                  color: ComebakColors.textPrimary,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
              Text(
                'SCORE',
                style: ComebakTypography.labelSmall.copyWith(
                  color: ComebakColors.textSecondary,
                  letterSpacing: ComebakLayout.borderGradient,
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
                      ComebakColors.neonPurple,
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

  Widget _buildGameCanvas() {
    return GestureDetector(
      onTap: () {
        if (_timeLeft > 0) {
          setState(() => _score += 10);
        }
      },
      child: Container(
        color: Colors.transparent,
        child: Center(
          child: Text(
            'GAME CANVAS\n\nTap anywhere to simulate a match\n(Score +10)',
            textAlign: TextAlign.center,
            style: ComebakTypography.bodyMedium.copyWith(
              color: ComebakColors.textSecondary.withValues(alpha: 0.3),
              height: 1.5,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModeSwitcher() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: ComebakLayout.spaceLg),
      decoration: BoxDecoration(
        color: ComebakColors.surface,
        border: Border(top: BorderSide(color: ComebakColors.border)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _ModeButton(
            label: 'ADD (+)',
            isActive: _activeMode == 0,
            onTap: () => _switchMode(0),
          ),
          _ModeButton(
            label: 'MAD (x)',
            isActive: _activeMode == 1,
            onTap: () => _switchMode(1),
          ),
          _ModeButton(
            label: 'BODMAS',
            isActive: _activeMode == 2,
            onTap: () => _switchMode(2),
          ),
          _ModeButton(
            label: 'HUNT',
            isActive: _activeMode == 3,
            onTap: () => _switchMode(3),
          ),
          _ModeButton(
            label: 'MEMORY',
            isActive: _activeMode == 4,
            onTap: () => _switchMode(4),
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
          color: isActive ? ComebakColors.neonGreen : Colors.transparent,
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
            fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
