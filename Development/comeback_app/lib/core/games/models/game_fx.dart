import 'dart:ui';
import 'package:flutter/material.dart';

class FloatingText {
  final Offset position;
  final String text;
  final Color color;
  double opacity = 1.0;
  double offsetY = 0.0;

  FloatingText({required this.position, required this.text, required this.color});

  void update(double dt) {
    offsetY -= 50 * dt; // Float upwards
    opacity -= 1.5 * dt; // Fade out
  }
}

class Particle {
  Offset position;
  final Offset velocity;
  final Color color;
  double opacity = 1.0;
  final double size;

  Particle({required this.position, required this.velocity, required this.color, required this.size});

  void update(double dt) {
    position += velocity * dt;
    opacity -= 2.0 * dt;
  }
}