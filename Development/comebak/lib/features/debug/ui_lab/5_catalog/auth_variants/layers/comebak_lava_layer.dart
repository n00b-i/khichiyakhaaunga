import 'dart:ui' as ui;
import 'package:flutter/material.dart';

// ==============================================================================
// [LAYER] ComebakLavaLayer
// ------------------------------------------------------------------------------
// PURPOSE: Renders shaders/lava.frag — molten green lava with 3-band temp map.
// DISTINCTION vs fog: 4 warp layers (deeper, more molten), 3-band color ramp
//   (char/ember/hot), and `ignition` parameter that drives the hot core band.
// `ignition` is the key orchestration lever:
//   0.0 = lava is crusted, no hot core (frames 0–36)
//   1.0 = lava is molten, hot core blazes (frames ~36–72)
//   0.3 = lava cools back to body-only (frames ~72+)
// UNIFORM ORDER (must match shaders/lava.frag exactly):
//   setFloat(0)  = width
//   setFloat(1)  = height
//   setFloat(2)  = time
//   setFloat(3)  = intensity   (global fade-in 0..1)
//   setFloat(4)  = ignition    (hot core 0..1)
// ==============================================================================
class ComebakLavaLayer extends StatefulWidget {
  final double time;
  final double intensity;
  final double ignition;

  const ComebakLavaLayer({
    super.key,
    required this.time,
    required this.intensity,
    required this.ignition,
  });

  @override
  State<ComebakLavaLayer> createState() => _ComebakLavaLayerState();
}

class _ComebakLavaLayerState extends State<ComebakLavaLayer> {
  ui.FragmentShader? _shader;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final program = await ui.FragmentProgram.fromAsset('shaders/lava.frag');
      if (!mounted) return;
      setState(() => _shader = program.fragmentShader());
    } catch (e) {
      debugPrint('ComebakLavaLayer: shader load failed — $e');
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
        painter: _LavaPainter(
          shader: _shader!,
          time: widget.time,
          intensity: widget.intensity,
          ignition: widget.ignition,
        ),
      ),
    );
  }
}

class _LavaPainter extends CustomPainter {
  final ui.FragmentShader shader;
  final double time;
  final double intensity;
  final double ignition;

  _LavaPainter({
    required this.shader,
    required this.time,
    required this.intensity,
    required this.ignition,
  });

  @override
  void paint(Canvas canvas, Size size) {
    shader.setFloat(0, size.width);
    shader.setFloat(1, size.height);
    shader.setFloat(2, time);
    shader.setFloat(3, intensity);
    shader.setFloat(4, ignition);

    final paint = Paint()..shader = shader;
    canvas.drawRect(Offset.zero & size, paint);
  }

  @override
  bool shouldRepaint(covariant _LavaPainter old) =>
      old.time != time ||
      old.intensity != intensity ||
      old.ignition != ignition;
}