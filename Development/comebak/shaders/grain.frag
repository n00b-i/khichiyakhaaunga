#version 460 core
#include <flutter/runtime_effect.glsl>

// ==============================================================================
// grain.frag — 12fps film grain overlay
// Stage 3 of the splash (L11). Sits on top of everything, blend=overlay @ 3%.
// The 12fps quantization is intentional — matches the claymation stepped
// cadence of the logo animation. Grain at 60fps reads as noise; grain at
// 12fps reads as film.
// Uniforms (4 floats):
//   [0,1] uSize.xy
//   [2]   uTime
//   [3]   uOpacity  (0..1 — 0.03 typical)
// Performance: single hash per pixel. Sub-ms.
// ==============================================================================

precision mediump float;

uniform vec2 uSize;
uniform float uTime;
uniform float uOpacity;

out vec4 fragColor;

float hash12(vec2 p) {
  vec3 p3 = fract(vec3(p.xyx) * 0.1031);
  p3 += dot(p3, p3.yzx + 33.33);
  return fract((p3.x + p3.y) * p3.z);
}

void main() {
  // 12fps quantization: floor(uTime * 12.0) steps the frame index.
  // Do NOT floor the coords — grain needs per-pixel variance, not blocks.
  float frame = floor(uTime * 12.0);
  vec2 uv = floor(FlutterFragCoord().xy);
  float g = hash12(uv + frame);

  // Single-channel grain, alpha-composited over the scene at low opacity
  fragColor = vec4(vec3(g), uOpacity);
}