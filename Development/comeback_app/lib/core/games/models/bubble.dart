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

  Bubble({
    required this.value,
    required this.position,
    required this.velocity,
    this.radius = 40.0,
  });

  // The topBound and bottomBound are now relative to the play area
  // (0 and playAreaSize.height).
  void update(double dt, Size playAreaSize, double topBound, double bottomBound) {
    position += velocity * dt;

    // Left and Right boundaries
    if (position.dx - radius < 0) {
      position = Offset(radius, position.dy);
      velocity = Offset(velocity.dx.abs(), velocity.dy);
    } else if (position.dx + radius > playAreaSize.width) {
      position = Offset(playAreaSize.width - radius, position.dy);
      velocity = Offset(-velocity.dx.abs(), velocity.dy);
    }

    // Top Boundary
    if (position.dy - radius < topBound) {
      position = Offset(position.dx, topBound + radius);
      velocity = Offset(velocity.dx, velocity.dy.abs());
    } 
    // Bottom Boundary
    else if (position.dy + radius > bottomBound) {
      position = Offset(position.dx, bottomBound - radius);
      velocity = Offset(velocity.dx, -velocity.dy.abs());
    }
  }
}

// Collision resolution remains the same
void resolveBubbleCollisions(List<Bubble> bubbles) {
  const padding = 2.0;
  for (int i = 0; i < bubbles.length; i++) {
    for (int j = i + 1; j < bubbles.length; j++) {
      final a = bubbles[i];
      final b = bubbles[j];
      final minDist = a.radius + b.radius + padding;
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