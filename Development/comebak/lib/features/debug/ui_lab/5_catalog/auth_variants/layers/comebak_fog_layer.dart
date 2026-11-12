import 'dart:ui' as ui;
import 'package:flutter/material.dart';

// ==============================================================================
// [LAYER] ComebakFogLayer
// ------------------------------------------------------------------------------
// PURPOSE: Renders shaders/fog.frag across the full widget area.
// STATELESS FROM ORCHESTRATOR POV: All animation state (time, opacity) is
//   passed in from the parent. This widget owns ONLY the GPU shader lifecycle
//   (load once, cache, reuse) — no AnimationController, no timers.
// FALLBACK: If shader load fails, returns SizedBox.shrink(). Splash continues
//   without fog. Never blocks the timeline.
// UNIFORM ORDER (must match shaders/fog.frag exactly):
//   setFloat(0)  = width
//   setFloat(1)  = height
//   setFloat(2)  = time
//   setFloat(3)  = opacity
//   setFloat(4..7)   = tint.rgba
//   setFloat(8..11)  = base.rgba
// ==============================================================================
class ComebakFogLayer extends StatefulWidget {
  /// Raw time in seconds (linear, non-repeating). Drives FBM evolution.
  final double time;

  /// Global opacity 0..1. Parent ramps this in/out.
  final double opacity;

  /// Fog body color (usually a green tint at low opacity).
  final Color tint;

  /// Base color the fog blends toward (usually canvas).
  final Color base;

  const ComebakFogLayer({
    super.key,
    required this.time,
    required this.opacity,
    required this.tint,
    required this.base,
  });

  @override
  State<ComebakFogLayer> createState() => _ComebakFogLayerState();
}

class _ComebakFogLayerState extends State<ComebakFogLayer> {
  ui.FragmentShader? _shader;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final program = await ui.FragmentProgram.fromAsset('shaders/fog.frag');
      if (!mounted) return;
      setState(() => _shader = program.fragmentShader());
    } catch (e) {
      // Do not crash the splash — log and continue without fog.
      debugPrint('ComebakFogLayer: shader load failed — $e');
      if (mounted) setState(() => _failed = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_failed || _shader == null) {
      return const SizedBox.shrink();
    }
    return SizedBox.expand(
      child: CustomPaint(
        painter: _FogPainter(
          shader: _shader!,
          time: widget.time,
          opacity: widget.opacity,
          tint: widget.tint,
          base: widget.base,
        ),
      ),
    );
  }
}

class _FogPainter extends CustomPainter {
  final ui.FragmentShader shader;
  final double time;
  final double opacity;
  final Color tint;
  final Color base;

  _FogPainter({
    required this.shader,
    required this.time,
    required this.opacity,
    required this.tint,
    required this.base,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Order MUST match uniform declaration in fog.frag.
    shader.setFloat(0, size.width);
    shader.setFloat(1, size.height);
    shader.setFloat(2, time);
    shader.setFloat(3, opacity);
    shader.setFloat(4, tint.r);
    shader.setFloat(5, tint.g);
    shader.setFloat(6, tint.b);
    shader.setFloat(7, tint.a);
    shader.setFloat(8, base.r);
    shader.setFloat(9, base.g);
    shader.setFloat(10, base.b);
    shader.setFloat(11, base.a);

    final paint = Paint()..shader = shader;
    canvas.drawRect(Offset.zero & size, paint);
  }

  @override
  bool shouldRepaint(covariant _FogPainter old) =>
      old.time != time ||
      old.opacity != opacity ||
      old.tint != tint ||
      old.base != base;
}