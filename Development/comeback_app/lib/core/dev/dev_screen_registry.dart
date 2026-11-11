import 'package:flutter/material.dart';
import '../../features/games/game_result_screen.dart';
import '../../features/debug/ui_lab/ui_lab_screen.dart';

// Static registry of screens and states exposed to the dev harness panel.
class DevScreenRegistry {
  DevScreenRegistry._();

  static Map<String, Map<String, WidgetBuilder>> get screens => {
        'Game Result': {
          'PB High (Broken 2d 14h ago)': (_) => _gameResult(
                score: 1500,
                accuracy: 95,
                bestCombo: 12,
                isNewPB: true,
                previousPBBrokenAfter: const Duration(days: 2, hours: 14),
              ),
          'PB Low (Broken 5m ago)': (_) => _gameResult(
                score: 50,
                accuracy: 10,
                bestCombo: 1,
                isNewPB: true,
                previousPBBrokenAfter: const Duration(minutes: 5),
              ),
          'Perfect (First PB)': (_) => _gameResult(
                score: 999,
                accuracy: 100,
                bestCombo: 99,
                isNewPB: true,
                previousPBBrokenAfter: null,
              ),
          'Normal (Not PB)': (_) => _gameResult(
                score: 800,
                accuracy: 70,
                bestCombo: 5,
                isNewPB: false,
              ),
          'Negative (Not PB)': (_) => _gameResult(
                score: -40,
                accuracy: 15,
                bestCombo: 0,
                isNewPB: false,
              ),
          'Negative (Not PB)': (_) => _gameResult(
                score: -40,
                accuracy: 15,
                bestCombo: 0,
                isNewPB: false,
              ),
          'Zero (Not PB)': (_) => _gameResult(
                score: 0,
                accuracy: 0,
                bestCombo: 0,
                isNewPB: false,
              ),
        },
        'UI Lab': {
          'Default': (_) => UiLabScreen(),
        },
      };

  static Widget _gameResult({
    required int score,
    required int accuracy,
    required int bestCombo,
    required bool isNewPB,
    Duration? previousPBBrokenAfter,
  }) {
    return GameResultScreen(
      score: score,
      accuracy: accuracy,
      bestCombo: bestCombo,
      isNewPB: isNewPB,
      previousPBBrokenAfter: previousPBBrokenAfter,
      gameBuilder: () => const SizedBox.shrink(),
      debugSuppressAutoAnimations: true,
    );
  }
}
