import 'dart:math';
import 'dart:ui';
import 'bubble.dart';

class GameState {
  int score = 0;
  int timeLeft = 60;
  int target = 0;
  bool isFrozen = false;
  
  final List<Bubble> bubbles = [];
  Bubble? selectedBubble;

  final Random _random = Random();
  Size _screenSize = Size.zero;

  void startGame(Size screenSize) {
    _screenSize = screenSize;
    score = 0;
    timeLeft = 60;
    isFrozen = false;
    bubbles.clear();
    selectedBubble = null;
    _spawnInitialBubbles();
  }

  void _spawnInitialBubbles() {
    for (int i = 0; i < 6; i++) {
      _spawnBubble();
    }
    _generateNewTarget();
  }

  void _spawnBubble() {
    final value = _random.nextInt(9) + 1;
    const radius = 40.0;
    
    // Spawn within safe bounds (below HUD, above bottom)
    final x = radius + _random.nextDouble() * (_screenSize.width - radius * 2);
    final y = 120 + _random.nextDouble() * (_screenSize.height - 240);
    
    final velocity = Offset(
      (_random.nextDouble() - 0.5) * 150, 
      (_random.nextDouble() - 0.5) * 150,
    );

    bubbles.add(Bubble(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      value: value,
      position: Offset(x, y),
      velocity: velocity,
      radius: radius,
    ));
  }

  void _generateNewTarget() {
    if (bubbles.length >= 2) {
      final b1 = bubbles[_random.nextInt(bubbles.length)];
      final b2 = bubbles[_random.nextInt(bubbles.length)];
      target = b1.value + b2.value;
    } else {
      target = 10;
    }
  }

  bool handleTap(Bubble tapped) {
    if (isFrozen || timeLeft <= 0) return false;

    if (selectedBubble == null) {
      selectedBubble = tapped;
      return false;
    }

    if (selectedBubble!.id == tapped.id) {
      selectedBubble = null;
      return false;
    }

    final sum = selectedBubble!.value + tapped.value;
    final isCorrect = (sum == target);

    if (isCorrect) {
      score += 10;
      final selectedId = selectedBubble!.id;
      bubbles.removeWhere((b) => b.id == selectedId || b.id == tapped.id);
      selectedBubble = null;
      _spawnBubble();
      _spawnBubble();
      _generateNewTarget();
    } else {
      score = (score - 5).clamp(0, 999999);
      selectedBubble = null;
    }

    return isCorrect;
  }
}