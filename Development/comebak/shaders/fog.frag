#version 460 core
#include <flutter/runtime_effect.glsl>

// ==============================================================================
// fog.frag — Domain-warped FBM fog
// Reference: Inigo Quilez domain warping (3-layer warp, 4-octave FBM).
// Stage 1 of the splash (L1 + L2). Green tint over dark canvas.
// Uniforms (12 floats — Flutter packs in declaration order):
//   [0,1]   uSize.xy
//   [2]     uTime
//   [3]     uOpacity
//   [4..7]  uTint  (rgba, drawn as rgb — alpha ignored)
//   [8..11] uBase  (rgba, drawn as rgb — alpha ignored)
// Performance: 4 octaves + 3 warp layers. Target < 3ms on Android test device.
// ==============================================================================

precision mediump float;

uniform vec2 uSize;
uniform float uTime;
uniform float uOpacity;
uniform vec4 uTint;
uniform vec4 uBase;

out vec4 fragColor;

// Hash — Dave Hoskins style, avoids sin() precision issues on mobile GPUs
float hash12(vec2 p) {
  vec3 p3 = fract(vec3(p.xyx) * 0.1031);
  p3 += dot(p3, p3.yzx + 33.33);
  return fract((p3.x + p3.y) * p3.z);
}

// Value noise with Hermite smoothstep — standard FBM base
float noise(vec2 p) {
  vec2 i = floor(p);
  vec2 f = fract(p);
  vec2 u = f * f * (3.0 - 2.0 * f);
  return mix(
    mix(hash12(i + vec2(0.0, 0.0)), hash12(i + vec2(1.0, 0.0)), u.x),
    mix(hash12(i + vec2(0.0, 1.0)), hash12(i + vec2(1.0, 1.0)), u.x),
    u.y
  );
}

// 4-octave FBM with rotation matrix + varying lacunarity
// The rotation (0.8, 0.6, -0.6, 0.8) decorrelates octaves.
// Lacunarity alternates 2.01 / 2.03 / 2.01 / 2.04 to avoid grid artifacts
// that uniform lacunarity of 2.0 produces.
float fbm4(vec2 p) {
  float v = 0.0;
  float a = 0.5;
  mat2 rot = mat2(0.80, 0.60, -0.60, 0.80);
  v += a * noise(p); p = rot * p * 2.01; a *= 0.5;
  v += a * noise(p); p = rot * p * 2.03; a *= 0.5;
  v += a * noise(p); p = rot * p * 2.01; a *= 0.5;
  v += a * noise(p);
  return v;
}

// 2D vector FBM — returns a warp vector, not a scalar.
// Two FBM evaluations offset by a prime-ish vector give independent
// x/y components for organic drift instead of pure translation.
vec2 fbm2(vec2 p) {
  return vec2(fbm4(p), fbm4(p + vec2(1.7, 9.2)));
}

void main() {
  // Aspect-correct: divide by HEIGHT so fog scale stays consistent
  // across portrait/landscape without stretching.
  vec2 uv = FlutterFragCoord().xy / uSize.y;
  float t = uTime;

  // --- Triple domain warp (the fog signature) -------------------------
  // q = warp layer 1 (slow drift)
  // r = warp layer 2 (q displaces coordinates, t*0.22 gives counter-drift)
  // pattern = final FBM sampled at warped coordinates
  vec2 q = fbm2(uv + t * 0.15);
  vec2 r = fbm2(uv + q + t * 0.22 + vec2(1.7, 9.2));
  float pattern = fbm4(uv + r);

  // Smoothstep mask — keeps fog in bands instead of uniform haze.
  // 0.20–0.80 range prevents both "always empty" and "always full".
  float mask = smoothstep(0.20, 0.80, pattern);

  // Final blend — base to tint by masked opacity
  vec3 col = mix(uBase.rgb, uTint.rgb, mask * uOpacity);

  fragColor = vec4(col, 1.0);
}