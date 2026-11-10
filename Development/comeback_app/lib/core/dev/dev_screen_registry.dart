import 'package:flutter/material.dart';
import '../../features/games/game_result_screen.dart';
import '../../features/debug/ui_lab/ui_lab_screen.dart';

// Static registry of screens and states exposed to the dev harness panel.
class DevScreenRegistry {
  DevScreenRegistry._();

  static Map<String, Map<String, WidgetBuilder>> get screens => {
        'Game Result': {
          'PB High': (_) =>
              _gameResult(score: 1500, accuracy: 95, bestCombo: 12, isNewPB: true),
          'PB Low': (_) =>
              _gameResult(score: 50, accuracy: 10, bestCombo: 1, isNewPB: true),
          'Perfect': (_) =>
              _gameResult(score: 999, accuracy: 100, bestCombo: 99, isNewPB: true),
          'Normal': (_) =>
              _gameResult(score: 800, accuracy: 70, bestCombo: 5, isNewPB: false),
          'Zero': (_) =>
              _gameResult(score: 0, accuracy: 0, bestCombo: 0, isNewPB: false),
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
  }) {
    return GameResultScreen(
      score: score,
      accuracy: accuracy,
      bestCombo: bestCombo,
      isNewPB: isNewPB,
      gameBuilder: () => const SizedBox.shrink(),
      debugSuppressAutoAnimations: true,
    );
  }
}
