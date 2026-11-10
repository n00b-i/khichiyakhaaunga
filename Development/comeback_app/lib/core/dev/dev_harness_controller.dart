import 'dart:ui' show Size;
import 'package:flutter/foundation.dart';
import 'dev_haptics.dart';

// Global state for the dev harness. Singleton, debug-only entry point.
class DevHarnessController extends ChangeNotifier {
  DevHarnessController._();
  static final DevHarnessController instance = DevHarnessController._();

  bool _paused = false;
  double _speed = 1.0;
  Size? _viewport;
  double _textScale = 1.0;
  bool _showGrid = false;
  int _replayTick = 0;

  bool get paused => _paused;
  double get speed => _speed;
  Size? get viewport => _viewport;
  double get textScale => _textScale;
  bool get showGrid => _showGrid;
  int get replayTick => _replayTick;
  ValueListenable<List<HapticEvent>> get hapticLog => devHapticLog;

  void setPaused(bool v) {
    if (_paused == v) return;
    _paused = v;
    notifyListeners();
  }

  void setSpeed(double v) {
    if (_speed == v) return;
    _speed = v;
    notifyListeners();
  }

  void setViewport(Size? v) {
    if (_viewport == v) return;
    _viewport = v;
    notifyListeners();
  }

  void setTextScale(double v) {
    if (_textScale == v) return;
    _textScale = v;
    notifyListeners();
  }

  void setShowGrid(bool v) {
    if (_showGrid == v) return;
    _showGrid = v;
    notifyListeners();
  }

  void triggerReplay() {
    _replayTick++;
    notifyListeners();
  }
}
