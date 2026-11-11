import 'dart:math';
import 'dart:ui';

class Bubble {
  static int _idCounter = 0;
  final int id = _idCounter++;
  
  final int value;
  Offset position;
  Offset velocity;
  final double radius;
  
  bool isSelected = false;
  bool isWrong = false;
  
  // [ISSUE-30] Added isMatched to allow instant green coloring before the shrink animation.
  bool isMatched = false;

  // [ISSUE-30] Animation states
  double scale = 1.0;
  bool isExiting = false;

  Bubble({
    required this.value,
    required this.position,
    required this.velocity,
    this.radius = 40.0,
    this.scale = 1.0, 
  });

  void update(double dt, Size playAreaSize, double topBound, double bottomBound) {
    if (isExiting) return;

    if (scale < 1.0) {
      scale = (scale + (dt * 4.0)).clamp(0.0, 1.0);
    }

    position += velocity * dt;
    final currentRadius = radius * scale;

    if (position.dx - currentRadius < 0) {
      position = Offset(currentRadius, position.dy);
      velocity = Offset(velocity.dx.abs(), velocity.dy);
    } else if (position.dx + currentRadius > playAreaSize.width) {
      position = Offset(playAreaSize.width - currentRadius, position.dy);
      velocity = Offset(-velocity.dx.abs(), velocity.dy);
    }

    if (position.dy - currentRadius < topBound) {
      position = Offset(position.dx, topBound + currentRadius);
      velocity = Offset(velocity.dx, velocity.dy.abs());
    } 
    else if (position.dy + currentRadius > bottomBound) {
      position = Offset(position.dx, bottomBound - currentRadius);
      velocity = Offset(velocity.dx, -velocity.dy.abs());
    }
  }

  // [ISSUE-30] Added isMatched = true so the painter instantly switches to the success color.
  void startExiting() {
    isExiting = true;
    isMatched = true; 
    isSelected = false; 
  }

  void updateExit(double dt) {
    if (isExiting && scale > 0.0) {
      scale = (scale - (dt * 5.0)).clamp(0.0, 1.0);
    }
  }
}

void resolveBubbleCollisions(List<Bubble> bubbles) {
  const padding = 2.0;
  for (int i = 0; i < bubbles.length; i++) {
    for (int j = i + 1; j < bubbles.length; j++) {
      final a = bubbles[i];
      final b = bubbles[j];
      
      if (a.isExiting || b.isExiting) continue;

      final minDist = (a.radius * a.scale) + (b.radius * b.scale) + padding;
      final dx = b.position.dx - a.position.dx;
      final dy = b.position.dy - a.position.dy;
      final distSq = dx * dx + dy * dy;

      if (distSq < minDist * minDist) {
        final dist = sqrt(distSq);
        final nx = dist < 0.001 ? 1.0 : dx / dist;
        final ny = dist < 0.001 ? 0.0 : dy / dist;
        final push = (minDist - dist) * 0.5;
        
        a.position -= Offset(nx * push, ny * push);
        b.position += Offset(nx * push, ny * push);

        final relVx = b.velocity.dx - a.velocity.dx;
        final relVy = b.velocity.dy - a.velocity.dy;
        final relDotNormal = relVx * nx + relVy * ny;

        if (relDotNormal < 0) {
          final impulse = relDotNormal;
          a.velocity += Offset(impulse * nx, impulse * ny);
          b.velocity -= Offset(impulse * nx, impulse * ny);
        }
      }
    }
  }
}