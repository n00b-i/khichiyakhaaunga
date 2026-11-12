import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

enum HapticKind { selection, light, medium }

class HapticEvent {
  final DateTime timestamp;
  final HapticKind kind;
  final String source;
  HapticEvent(this.timestamp, this.kind, this.source);
}

// Bounded log of recent haptic events. Debug-only writer.
final ValueNotifier<List<HapticEvent>> devHapticLog = ValueNotifier([]);

// Centralised haptic entrypoint. Forwards to platform haptics and, in debug
// mode, records the event for the dev harness panel.
class DevHaptics {
  DevHaptics._();

  static void selectionClick({required String source}) {
    HapticFeedback.selectionClick();
    if (kDebugMode) _record(HapticKind.selection, source);
  }

  static void lightImpact({required String source}) {
    HapticFeedback.lightImpact();
    if (kDebugMode) _record(HapticKind.light, source);
  }

  static void mediumImpact({required String source}) {
    HapticFeedback.mediumImpact();
    if (kDebugMode) _record(HapticKind.medium, source);
  }

  static void _record(HapticKind kind, String source) {
    final list = List<HapticEvent>.from(devHapticLog.value)
      ..add(HapticEvent(DateTime.now(), kind, source));
    if (list.length > 20) list.removeAt(0);
    devHapticLog.value = list;
  }
}
