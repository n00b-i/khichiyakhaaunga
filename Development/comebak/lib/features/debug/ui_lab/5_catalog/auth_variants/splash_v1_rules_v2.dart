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
  
  late final double _typingStartSec;
  late final double _typingEndSec;
  late final double _totalDurationSec;

  bool _firedOpen = false;
  bool _firedLogoP4 = false;
  int _lastCharCount = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // 1s intro + (characters * 40ms) + 1s hold
    _typingStartSec = 1.0;
    _typingEndSec = _typingStartSec + (widget.rule.line.length * 0.04); 
    _totalDurationSec = _typingEndSec + 1.0;

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

    // Micro-haptics for wordmark typing
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
    
    final hookOpacity = _smoothstep(_typingStartSec, _typingStartSec + 0.2, elapsed);
    final lineCharCount = _computeLineCharCount(elapsed);
    final wordmarkCharCount = _computeWordmarkCharCount(elapsed);

    return Stack(
      children: [
        // 1. CANVAS BASE
        const Positioned.fill(child: ColoredBox(color: ComebakColors.canvas)),

        // 2. FOG A
        if (fogAOpacity > 0.001)
          Positioned.fill(child: ComebakFogLayer(time: elapsed, opacity: fogAOpacity, tint: ComebakColors.mutedGreen, base: ComebakColors.canvas)),

        // 3. FOG B
        if (fogBOpacity > 0.001)
          Positioned.fill(child: ComebakFogLayer(time: elapsed * 1.4, opacity: fogBOpacity, tint: ComebakColors.neonGreen, base: ComebakColors.canvas)),

        // 4. LAVA BED
        if (lavaIntensity > 0.001)
          Positioned.fill(child: ComebakLavaLayer(time: elapsed * 0.7, intensity: lavaIntensity, ignition: lavaIgnition)),

        // 5. HERO MODULE (Thunder Bolt & Wordmark Inline)
        Center(child: _buildHeroModule(elapsed, wordmarkCharCount)),

        // 6. DARK GRADIENT FOR TEXT READABILITY
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          height: 350, // Taller gradient for better coverage
          child: IgnorePointer(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    ComebakColors.canvas.withOpacity(0.0),
                    ComebakColors.canvas.withOpacity(0.95), // Darker to block fog
                    ComebakColors.canvas,
                  ],
                  stops: const [0.0, 0.3, 1.0],
                ),
              ),
            ),
          ),
        ),

        // 7. GRAIN OVERLAY
        Positioned.fill(child: ComebakGrainOverlay(time: elapsed, opacity: 0.02)),

        // 8. VIGNETTE
        Positioned.fill(child: const ComebakVignette()),

        // 9. TEXT BLOCK (Moved to TOP of stack for absolute readability)
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
                  charCount: lineCharCount,
                  fontSize: 30,
                ),
              ],
            ),
          ),

        // 10. SKIP BUTTON
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
        // FittedBox prevents overflow on smaller screens (like iPhone SE)
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Thunder Bolt Logo
              if (logoPose >= 0)
                ComebakClayLogo(pose: logoPose),
              
              // Tight gap (12px) instead of the old huge padding
              const SizedBox(width: 12),

              // Fluid Wordmark (78pt)
              ComebakWordmark(
                charCount: wordmarkCharCount,
                brightness: logoBrightness,
              ),
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

  int _computeLineCharCount(double elapsed) {
    if (elapsed < _typingStartSec) return 0;
    if (elapsed >= _typingEndSec) return widget.rule.line.length;
    final frac = (elapsed - _typingStartSec) / (_typingEndSec - _typingStartSec);
    return (frac * widget.rule.line.length).floor().clamp(0, widget.rule.line.length);
  }

  int _computeWordmarkCharCount(double elapsed) {
    // Wordmark types between 0.5s and 1.3s
    if (elapsed < 0.5) return 0;
    if (elapsed >= 1.3) return 7; // "comebak" = 7 chars
    final frac = (elapsed - 0.5) / 0.8;
    return (frac * 7).floor().clamp(0, 7);
  }
}