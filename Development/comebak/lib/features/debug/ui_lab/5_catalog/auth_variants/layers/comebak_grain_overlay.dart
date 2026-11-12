import 'dart:ui' as ui;
import 'package:flutter/material.dart';

class ComebakGrainOverlay extends StatefulWidget {
  final double time;
  final double opacity;
  const ComebakGrainOverlay({super.key, required this.time, this.opacity = 0.03});

  @override
  State<ComebakGrainOverlay> createState() => _ComebakGrainOverlayState();
}

class _ComebakGrainOverlayState extends State<ComebakGrainOverlay> {
  ui.FragmentShader? _shader;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final program = await ui.FragmentProgram.fromAsset('shaders/grain.frag');
      if (!mounted) return;
      setState(() => _shader = program.fragmentShader());
    } catch (e) {
      if (mounted) setState(() => _failed = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_failed || _shader == null) return const SizedBox.shrink();
    return IgnorePointer(
      child: SizedBox.expand(
        child: CustomPaint(
          painter: _GrainPainter(shader: _shader!, time: widget.time, opacity: widget.opacity),
        ),
      ),
    );
  }
}

class _GrainPainter extends CustomPainter {
  final ui.FragmentShader shader;
  final double time;
  final double opacity;

  _GrainPainter({required this.shader, required this.time, required this.opacity});

  @override
  void paint(Canvas canvas, Size size) {
    shader.setFloat(0, size.width);
    shader.setFloat(1, size.height);
    shader.setFloat(2, time);
    shader.setFloat(3, opacity);

    // CRUCIAL: softLight blends the noise with the scene rather than stamping over it.
    final paint = Paint()
      ..shader = shader
      ..blendMode = BlendMode.softLight;

    canvas.drawRect(Offset.zero & size, paint);
  }

  @override
  bool shouldRepaint(covariant _GrainPainter old) => old.time != time || old.opacity != opacity;
}