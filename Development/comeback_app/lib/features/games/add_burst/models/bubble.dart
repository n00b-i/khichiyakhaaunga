import 'dart:ui';

class Bubble {
  final String id;
  final int value;
  Offset position;
  Offset velocity;
  final double radius;

  Bubble({
    required this.id,
    required this.value,
    required this.position,
    required this.velocity,
    this.radius = 40.0,
  });

  // Updates the position and handles wall bouncing
  void update(double dt, Size screenSize) {
    position += velocity * dt;

    // Bounce off left and right walls
    if (position.dx - radius < 0) {
      position = Offset(radius, position.dy);
      velocity = Offset(velocity.dx.abs(), velocity.dy);
    } else if (position.dx + radius > screenSize.width) {
      position = Offset(screenSize.width - radius, position.dy);
      velocity = Offset(-velocity.dx.abs(), velocity.dy);
    }

    // Bounce off top and bottom walls (leaving room for HUD and Nav bar)
    if (position.dy - radius < 100) {
      position = Offset(position.dx, radius + 100);
      velocity = Offset(velocity.dx, velocity.dy.abs());
    } else if (position.dy + radius > screenSize.height - 100) {
      position = Offset(position.dx, screenSize.height - radius - 100);
      velocity = Offset(velocity.dx, -velocity.dy.abs());
    }
  }
}