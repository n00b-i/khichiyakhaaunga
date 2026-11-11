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

  // [ISSUE-30] Animation states
  // scale: drives both the visual size and the physics collision radius. 
  // A scale of 0.0 means the bubble is invisible and ignores physics.
  // isExiting: flags the bubble to be removed from the board once scale reaches 0.
  double scale = 1.0;
  bool isExiting = false;

  Bubble({
    required this.value,
    required this.position,
    required this.velocity,
    this.radius = 40.0,
    this.scale = 1.0, 
  });

  // [ISSUE-30] Main physics tick.
  // If the bubble is exiting, we skip physics entirely so it can shrink in place.
  void update(double dt, Size playAreaSize, double topBound, double bottomBound) {
    if (isExiting) return;

    // [ISSUE-30] Smoothly scale IN (entry animation).
    // 4.0 means it takes roughly 0.25 seconds to reach full size (1.0 / 4.0).
    if (scale < 1.0) {
      scale = (scale + (dt * 4.0)).clamp(0.0, 1.0);
    }

    position += velocity * dt;

    // [ISSUE-30] Use the scaled radius for boundary checks so the bubble doesn't visually clip out of bounds while growing.
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

  // [ISSUE-30] Called when a correct match is made. Flags the bubble to start shrinking.
  void startExiting() {
    isExiting = true;
    isSelected = false; // Clear selection state so it doesn't paint as selected while dying.
  }

  // [ISSUE-30] Drives the death animation (exit).
  // 5.0 means it takes roughly 0.20 seconds to shrink to nothing.
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
      
      // [ISSUE-30] Ignore exiting bubbles in collision resolution. 
      // This prevents dying bubbles from violently pushing survivors as they shrink.
      if (a.isExiting || b.isExiting) continue;

      // [ISSUE-30] Use scaled radius so growing bubbles push each other correctly.
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