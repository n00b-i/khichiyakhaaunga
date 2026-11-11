import 'package:flutter/foundation.dart';
import 'bubble.dart';
import 'game_fx.dart';

// [ISSUE-1] Owns mutable board + FX. Drives physics repaints independently of the widget tree.
class BoardPaintState extends ChangeNotifier {
  List<Bubble> bubbles = [];
  final List<FloatingText> floatingTexts = [];
  final List<Particle> particles = [];

  void replaceBubbles(List<Bubble> next) {
    bubbles = next;
    notifyListeners();
  }

  void tickNotify() => notifyListeners();
}
