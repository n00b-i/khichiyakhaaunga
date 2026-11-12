import 'package:flutter/services.dart';

class ComebakHaptics {
  ComebakHaptics._();

  static Future<void> tap() async {
    await HapticFeedback.lightImpact();
  }

  static Future<void> success() async {
    await HapticFeedback.mediumImpact();
  }

  static Future<void> error() async {
    await HapticFeedback.heavyImpact();
  }
}