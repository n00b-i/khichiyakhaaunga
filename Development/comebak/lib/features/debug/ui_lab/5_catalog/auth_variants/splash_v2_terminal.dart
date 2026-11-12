import 'package:flutter/material.dart';
import '../../1_foundations/tokens/ui_lab_tokens.dart';

// ==============================================================================
// [VARIANT 2 — SPLASH] "TERMINAL"
// ------------------------------------------------------------------------------
// Concept: Typewriter boot sequence. Monospace soul, scanline overlay.
// Copy: "$ comebak.boot / > init ... ok / > press play."
// Runtime: 2.8s hardcoded. Skip button always visible.
// ==============================================================================
class SplashV2Terminal extends StatefulWidget {
  final VoidCallback onComplete;
  const SplashV2Terminal({super.key, required this.onComplete});

  @override
  State<SplashV2Terminal> createState() => _SplashV2TerminalState();
}

class _SplashV2TerminalState extends State<SplashV2Terminal>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  // Boot lines — each appears one after the next
  static const _lines = <String>[
    r'$ comebak.boot',
    r'> init ... ok',
    r'> rules ... loaded',
    r'> games ... 5 / ready',
    r'> streak ... reset',
    r'> press play.',
  ];

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    )
      ..addStatusListener((s) {
        if (s == AnimationStatus.completed) widget.onComplete();
      })
      ..forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ComebakColors.canvas,
      body: SafeArea(
        child: Stack(
          children: [
            // Scanline — 60 alternating rows, very low opacity
            IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: List.generate(
                      60,
                      (i) => i.isEven
                          ? ComebakColors.border.withValues(alpha: 0.05)
                          : Colors.transparent,
                    ),
                  ),
                ),
              ),
            ),

            // Boot sequence
            Padding(
              padding: const EdgeInsets.all(ComebakLayout.spaceXl),
              child: AnimatedBuilder(
                animation: _ctrl,
                builder: (_, _) {
                  final visible = (_ctrl.value * _lines.length)
                      .floor()
                      .clamp(0, _lines.length);
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: ComebakLayout.spaceXxl),
                      for (var i = 0; i < visible; i++)
                        Padding(
                          padding: const EdgeInsets.only(
                            bottom: ComebakLayout.spaceMd,
                          ),
                          child: Text(
                            _lines[i],
                            style: ComebakTypography.bodyMedium.copyWith(
                              color: i == _lines.length - 1
                                  ? ComebakColors.neonGreen
                                  : ComebakColors.textSecondary,
                              fontFamily: 'monospace',
                              fontSize: 14,
                            ),
                          ),
                        ),
                      // Blinking cursor
                      if (visible < _lines.length ||
                          (_ctrl.value * 6).floor().isEven)
                        Container(
                          width: 10,
                          height: 16,
                          color: ComebakColors.neonGreen,
                        ),
                    ],
                  );
                },
              ),
            ),

            // Skip
            Positioned(
              top: ComebakLayout.spaceMd,
              right: ComebakLayout.spaceLg,
              child: TextButton(
                onPressed: widget.onComplete,
                child: Text(
                  'SKIP',
                  style: ComebakTypography.labelSmall.copyWith(
                    color: ComebakColors.textSecondary,
                    letterSpacing: 2,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}