import 'package:flutter/material.dart';
import '../../1_foundations/tokens/ui_lab_tokens.dart';
import '../../1_foundations/ui_lab_haptics.dart';
import 'comebak_rule_engine.dart';
import 'layers/comebak_fog_layer.dart';
import 'layers/comebak_lava_layer.dart';
import 'layers/comebak_grain_overlay.dart';
import 'layers/comebak_clay_logo.dart';
import 'layers/comebak_rule_hook.dart';
import 'layers/comebak_rule_line.dart';
import 'layers/comebak_vignette.dart';
import 'layers/comebak_wordmark.dart';

class SplashV1RulesV2 extends StatefulWidget {
  final ComebakRule rule;
  final VoidCallback onComplete;

  const SplashV1RulesV2({
    super.key,
    required this.rule,
    required this.onComplete,
  });

  @override
  State<SplashV1RulesV2> createState() => _SplashV1RulesV2State();
}

class _SplashV1RulesV2State extends State<SplashV1RulesV2>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late final AnimationController _ctrl;
  
  late final double _wordmarkEndSec;
  late final double _bottomTextStartSec;
  late final double _bottomTextEndSec;
  late final double _totalDurationSec;

  bool _firedOpen = false;
  bool _firedLogoP4 = false;
  int _lastCharCount = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Sequence timing
    _wordmarkEndSec = 1.3;
    _bottomTextStartSec = _wordmarkEndSec; 
    _bottomTextEndSec = _bottomTextStartSec + 0.5; // 500ms smooth fade
    _totalDurationSec = _bottomTextEndSec + 1.5; // 1.5s hold at the end

    _ctrl = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: (_totalDurationSec * 1000).round()),
    )..addListener(_onTick);

    _ctrl.addStatusListener((status) {
      if (status == AnimationStatus.completed) widget.onComplete();
    });
    
    _ctrl.forward();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _ctrl.removeListener(_onTick);
    _ctrl.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      _ctrl.stop();
    } else if (state == AppLifecycleState.resumed) {
      if (_ctrl.value < 1.0 && _ctrl.value > 0.0) _ctrl.forward();
    }
  }

  void _onTick() {
    final elapsed = _ctrl.value * _totalDurationSec;
    
    if (!_firedOpen) { ComebakHaptics.tap(); _firedOpen = true; }
    if (elapsed >= 1.0 && !_firedLogoP4) { ComebakHaptics.success(); _firedLogoP4 = true; }

    final currentChar = _computeWordmarkCharCount(elapsed);
    if (currentChar > _lastCharCount) {
      ComebakHaptics.tap(); 
      _lastCharCount = currentChar;
    }
  }

  double _smoothstep(double e0, double e1, double x) {
    if (x <= e0) return 0.0;
    if (x >= e1) return 1.0;
    final t = (x - e0) / (e1 - e0);
    return t * t * (3.0 - 2.0 * t);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ComebakColors.canvas,
      body: AnimatedBuilder(
        animation: _ctrl,
        builder: (_, __) => _buildLayers(_ctrl.value),
      ),
    );
  }

  Widget _buildLayers(double t) {
    final elapsed = t * _totalDurationSec;

    final fogAOpacity = _smoothstep(0.0, 0.4, elapsed) * 0.10;
    final fogBOpacity = _smoothstep(0.2, 0.8, elapsed) * 0.08;
    final lavaIntensity = _smoothstep(0.4, 1.0, elapsed);
    final lavaIgnition = _computeLavaIgnition(elapsed);
    
    final hookOpacity = _smoothstep(_bottomTextStartSec, _bottomTextStartSec + 0.3, elapsed);
    final lineOpacity = _smoothstep(_bottomTextStartSec, _bottomTextEndSec, elapsed);
    final wordmarkCharCount = _computeWordmarkCharCount(elapsed);

    return Stack(
      children: [
        const Positioned.fill(child: ColoredBox(color: ComebakColors.canvas)),

        if (fogAOpacity > 0.001)
          Positioned.fill(child: ComebakFogLayer(time: elapsed, opacity: fogAOpacity, tint: ComebakColors.mutedGreen, base: ComebakColors.canvas)),

        if (fogBOpacity > 0.001)
          Positioned.fill(child: ComebakFogLayer(time: elapsed * 1.4, opacity: fogBOpacity, tint: ComebakColors.neonGreen, base: ComebakColors.canvas)),

        if (lavaIntensity > 0.001)
          Positioned.fill(child: ComebakLavaLayer(time: elapsed * 0.7, intensity: lavaIntensity, ignition: lavaIgnition)),

        Center(child: _buildHeroModule(elapsed, wordmarkCharCount)),

        Positioned(
          left: 0, right: 0, bottom: 0, height: 350,
          child: IgnorePointer(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    ComebakColors.canvas.withOpacity(0.0),
                    ComebakColors.canvas.withOpacity(0.95),
                    ComebakColors.canvas,
                  ],
                  stops: const [0.0, 0.3, 1.0],
                ),
              ),
            ),
          ),
        ),

        Positioned.fill(child: ComebakGrainOverlay(time: elapsed, opacity: 0.02)),
        Positioned.fill(child: const ComebakVignette()),

        if (hookOpacity > 0.001)
          Positioned(
            left: ComebakLayout.spaceXl,
            right: ComebakLayout.spaceXl,
            bottom: MediaQuery.of(context).padding.bottom + ComebakLayout.spaceXl,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                ComebakRuleHook(hook: widget.rule.hook, opacity: hookOpacity),
                const SizedBox(height: ComebakLayout.spaceLg),
                ComebakRuleLine(
                  line: widget.rule.line,
                  progress: lineOpacity,
                  fontSize: 30,
                ),
              ],
            ),
          ),

        Positioned(
          top: MediaQuery.of(context).padding.top + ComebakLayout.spaceMd,
          right: ComebakLayout.spaceLg,
          child: TextButton(
            onPressed: () {
              if (_ctrl.isAnimating) _ctrl.stop();
              widget.onComplete();
            },
            child: Text('SKIP', style: ComebakTypography.labelSmall.copyWith(color: ComebakColors.textSecondary, letterSpacing: 2)),
          ),
        ),
      ],
    );
  }

  Widget _buildHeroModule(double elapsed, int wordmarkCharCount) {
    final logoPose = _computeLogoPose(elapsed);
    final logoBrightness = _smoothstep(0.5, 1.0, elapsed);

    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: 180,
      child: Center(
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (logoPose >= 0) ComebakClayLogo(pose: logoPose, time: elapsed),
              const SizedBox(width: 12),
              ComebakWordmark(charCount: wordmarkCharCount, brightness: logoBrightness, time: elapsed),
            ],
          ),
        ),
      ),
    );
  }

  double _computeLavaIgnition(double elapsed) {
    if (elapsed < 0.4) return 0.0;
    if (elapsed < 0.8) return ((elapsed - 0.4) / 0.4).clamp(0.0, 1.0);
    if (elapsed < 1.2) return 1.0;
    final decayed = 1.0 - (elapsed - 1.2) / 2.0 * 0.7;
    return decayed.clamp(0.3, 1.0);
  }

  int _computeLogoPose(double elapsed) {
    if (elapsed < 0.4) return -1;
    if (elapsed >= 1.0) return 4;
    final raw = (elapsed - 0.4) / 0.6 * 5;
    return raw.floor().clamp(0, 4);
  }

  int _computeWordmarkCharCount(double elapsed) {
    if (elapsed < 0.5) return 0;
    if (elapsed >= _wordmarkEndSec) return 7;
    final frac = (elapsed - 0.5) / (_wordmarkEndSec - 0.5);
    return (frac * 7).floor().clamp(0, 7);
  }
}