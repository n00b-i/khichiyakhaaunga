#version 460 core
#include <flutter/runtime_effect.glsl>

// ==============================================================================
// lava.frag — Molten green lava with 3-band temperature mapping
// Reference: Molten Core luminance mapping (char → ember → hot 3-band ramp).
// Stage 2 of the splash (L3). Same FBM family as fog but 4 warp layers (deeper)
// and temperature bands instead of flat tint.
// Uniforms (5 floats):
//   [0,1] uSize.xy
//   [2]   uTime
//   [3]   uIntensity  (global 0..1 — controls when lava fades in)
//   [4]   uIgnition   (0..1 — controls the HOT CORE band, snaps to 1 at ignition)
// Performance: 3 octaves + 4 warp layers. Target < 4ms on Android test device.
// The extra warp layer over fog is why the lava reads as "molten" not "hazy".
// ==============================================================================

precision mediump float;

uniform vec2 uSize;
uniform float uTime;
uniform float uIntensity;
uniform float uIgnition;

out vec4 fragColor;

float hash12(vec2 p) {
  vec3 p3 = fract(vec3(p.xyx) * 0.1031);
  p3 += dot(p3, p3.yzx + 33.33);
  return fract((p3.x + p3.y) * p3.z);
}

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

// 3 octaves — lava needs less micro-detail than fog; saves GPU headroom
// for the extra warp layer.
float fbm3(vec2 p) {
  float v = 0.0;
  float a = 0.5;
  mat2 rot = mat2(0.80, 0.60, -0.60, 0.80);
  v += a * noise(p); p = rot * p * 2.01; a *= 0.5;
  v += a * noise(p); p = rot * p * 2.03; a *= 0.5;
  v += a * noise(p);
  return v;
}

vec2 fbm2(vec2 p) {
  return vec2(fbm3(p), fbm3(p + vec2(1.7, 9.2)));
}

void main() {
  vec2 uv = FlutterFragCoord().xy / uSize.y;
  float t = uTime;

  // --- 4-layer domain warp --------------------------------------------------
  // One more layer than fog. This is the difference between "motion blur
  // over a static noise" (3 layers) and "something molten" (4 layers).
  vec2 q = fbm2(uv * 2.0 + t * 0.70);
  vec2 r = fbm2(uv * 2.0 + q * 1.40 + t * 0.90);
  vec2 s = fbm2(uv * 2.0 + r * 1.80 + vec2(8.3, 2.8));
  float pattern = fbm3(uv * 2.0 + s);

  // --- 3-band temperature mapping -------------------------------------------
  // char: deep green-black crust
  // ember: mid green — the body of the lava
  // hot: near-white green — the ignition core, gated by uIgnition
  vec3 char_ = vec3(0.010, 0.050, 0.030);
  vec3 ember = vec3(0.000, 0.780, 0.450);
  vec3 hot   = vec3(0.720, 0.960, 0.880);

  // Bands overlap via smoothstep — no hard edges between temperature regions.
  float b1 = smoothstep(0.00, 0.35, pattern);
  float b2 = smoothstep(0.35, 0.65, pattern);
  float b3 = smoothstep(0.65, 1.00, pattern) * uIgnition;

  vec3 col = char_ * b1 + ember * b2 + hot * b3;
  col *= uIntensity;

  fragColor = vec4(col, 1.0);
}