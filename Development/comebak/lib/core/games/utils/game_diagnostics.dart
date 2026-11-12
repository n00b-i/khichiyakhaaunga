import 'package:flutter/foundation.dart';
import '../models/bubble.dart';

class GameDiagnostics {
  static void printMaxScore(String gameName, int maxActions, int pointsPerAction) {
    if (!kDebugMode) return;
    final maxScore = (maxActions * pointsPerAction) + (maxActions * 2);
    debugPrint('📊 [$gameName] Theoretical Max Score (60s): ~$maxScore');
  }

  static void logGameStart(String gameName) {
    if (!kDebugMode) return;
    debugPrint('🎮 [$gameName] GAME STARTED');
  }

  static void logTargetCheck(String gameName, int target, List<Bubble> bubbles, bool isAddition) {
    if (!kDebugMode) return;
    
    final values = bubbles.map((b) => b.value).toList();
    bool hasValidPair = false;
    
    for (int i = 0; i < values.length; i++) {
      for (int j = i + 1; j < values.length; j++) {
        if (isAddition ? (values[i] + values[j] == target) : (values[i] * values[j] == target)) {
          hasValidPair = true;
          break;
        }
      }
    }

    if (hasValidPair) {
      debugPrint('✅ [$gameName] Target: $target | Bubbles: $values | Valid Pair: YES');
    } else {
      debugPrint('🚨 [$gameName] ERROR: Target $target has NO valid pair in $values. TARGET IS IMPOSSIBLE.');
    }
  }

  static void logTap(String gameName, int val1, int val2, bool isCorrect, int newScore) {
    if (!kDebugMode) return;
    final mathSymbol = gameName.contains('Mad') ? 'x' : '+';
    debugPrint('👉 [$gameName] Tapped $val1 and $val2 | Math: $val1 $mathSymbol $val2 | Result: ${isCorrect ? 'CORRECT' : 'WRONG'} | Score: $newScore');
  }
}