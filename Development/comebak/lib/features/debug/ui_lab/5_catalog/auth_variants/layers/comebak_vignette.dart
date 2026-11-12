import 'package:flutter/material.dart';
import '../../../1_foundations/tokens/ui_lab_tokens.dart';

// ==============================================================================
// [LAYER] ComebakVignette
// ------------------------------------------------------------------------------
// PURPOSE: Radial gradient that darkens the edges, brightens the center.
// NARRATIVE ROLE: The "camera lens" of the splash. Without it, the fog and
//   lava shaders fill the frame edge-to-edge and the composition feels flat.
//   With it, the eye is pulled to the center where the logo + quote live.
// WHY A GRADIENT, NOT A SHADER:
//   A radial gradient is one of the cheapest operations Flutter offers — it
//   precomputes the color table. Zero per-frame GPU cost. There's no reason
//   to pay shader cost for what a gradient does identically.
// STACK POSITION: Sits at Z=1.00, above everything except grain. It is the
//   second-to-last layer the user "sees through" before the grain texture.
// COLOR RULES:
//   - Center: fully transparent (shows the scene through)
//   - Edges: canvas at 60% opacity (darkens, but doesn't fully obscure)
//   - Never pure black. Master.txt §8 rule — colored shadows only.
// ==============================================================================
class ComebakVignette extends StatelessWidget {
  /// Multiplier on the edge darkening. 1.0 = designed strength, 0.0 = no vignette.
  final double strength;

  /// Radius of the bright center. 0.5 = classic, 0.7 = wider center, softer edges.
  final double centerRadius;

  const ComebakVignette({
    super.key,
    this.strength = 1.0,
    this.centerRadius = 0.65,
  });

  @override
  Widget build(BuildContext context) {
    final edgeOpacity = (0.60 * strength).clamp(0.0, 0.60);
    return IgnorePointer(
      child: SizedBox.expand(
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              // Slightly below center — the logo sits a touch above the
              // visual center due to the quote block below it.
              center: const Alignment(0.0, -0.15),
              radius: centerRadius,
              colors: [
                // Inner stop: fully transparent — scene shows through unmodified
                ComebakColors.canvas.withOpacity(0.0),
                // Mid stop: 8% canvas — gentle falloff begins here
                ComebakColors.canvas.withOpacity(edgeOpacity * 0.15),
                // Outer stop: full edge opacity — corners are the darkest
                ComebakColors.canvas.withOpacity(edgeOpacity),
              ],
              stops: const [0.0, 0.55, 1.0],
            ),
          ),
        ),
      ),
    );
  }
}