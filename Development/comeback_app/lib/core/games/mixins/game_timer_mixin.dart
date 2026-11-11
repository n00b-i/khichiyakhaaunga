import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import '../models/game_config.dart';

// CONTRACT:
// - Host class needs: on State<T>, SingleTickerProviderStateMixin<T>
// - Host must override: config, isTimerActive, onTimerTick, onTimerUpdate, onTimeUp
// - Mixin owns: _ticker, _lastElapsed, _timeLeft, _handleTick, didChangeAppLifecycleState
// - Host must NOT declare: WidgetsBindingObserver, _ticker, didChangeAppLifecycleState
mixin GameTimerMixin<T extends StatefulWidget> on State<T>, SingleTickerProviderStateMixin<T> {
  late Ticker _ticker;
  Duration _lastElapsed = Duration.zero;
  late Duration _timeLeft;
  late final _TimerObserver _observer;

  GameConfig get config;
  bool get isTimerActive;
  void onTimerTick(double dt);
  void onTimerUpdate(Duration timeLeft);
  void onTimeUp();

  Duration get timeLeft => _timeLeft;

  @override
  void initState() {
    super.initState();
    _timeLeft = config.duration;
    _observer = _TimerObserver(_onLifecycle);
    WidgetsBinding.instance.addObserver(_observer);
    _ticker = createTicker(_handleTick)..start();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(_observer);
    _ticker.dispose();
    super.dispose();
  }

  void _onLifecycle(AppLifecycleState state) {
    if (!config.pauseOnBackground) return;
    if (state == AppLifecycleState.paused) {
      _ticker.stop();
    } else if (state == AppLifecycleState.resumed) {
      if (!_ticker.isActive) _ticker.start();
    }
  }

  void _handleTick(Duration elapsed) {
    if (!isTimerActive) return;
    final dt = (elapsed - _lastElapsed).inMicroseconds / 1000000.0;
    _lastElapsed = elapsed;
    if (dt <= 0 || dt > 0.1) return;
    
    _timeLeft -= Duration(microseconds: (dt * 1000000).round());
    
    if (_timeLeft <= Duration.zero) {
      _timeLeft = Duration.zero;
      // [CRITICAL FIX] Stop the ticker immediately so onTimeUp() only fires ONCE.
      // Without this, the ticker continues at 60fps, causing onTimeUp to fire 60 times a second,
      // which triggers multiple Navigator.pushReplacement calls and breaks the slide animation.
      _ticker.stop(); 
      onTimerUpdate(Duration.zero);
      onTimeUp();
      return;
    }
    
    onTimerUpdate(_timeLeft);
    onTimerTick(dt);
  }
}

// Private observer: inherits default no-op implementations from
// WidgetsBindingObserver, overrides only didChangeAppLifecycleState.
class _TimerObserver with WidgetsBindingObserver {
  final void Function(AppLifecycleState) _onLifecycle;
  _TimerObserver(this._onLifecycle);
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) => _onLifecycle(state);
}