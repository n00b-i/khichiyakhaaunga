import 'dart:convert';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:android_id/android_id.dart';
import 'session_repository.dart';
import 'package:flutter/foundation.dart';

class SessionManager {
  static final SessionManager _instance = SessionManager._internal();
  factory SessionManager() => _instance;
  SessionManager._internal();

  SharedPreferences? _prefs;
  late SessionRepository _repository;

  String? _currentSessionId;
  String? _userId;

  List<Map<String, dynamic>> _pendingEvents = [];

  final List<String> _criticalEvents = [
    'game_started',
    'game_completed',
    'logout',
  ];

  String? get currentSessionId => _currentSessionId;

  Future<void> init(String userId) async {
    debugPrint('[SessionManager] init() started for user: $userId');
    _userId = userId;
    _prefs = await SharedPreferences.getInstance();
    _repository = SessionRepository(Supabase.instance.client);

    // [FORCE: COMMENT SYNTAX] Outbox pattern: sync sessions -> events -> matches.
    // This order is critical because matches and events reference session_id.
    await _syncPendingSessions();
    await _syncPendingEvents();
    await _syncPendingMatches();

    _currentSessionId = const Uuid().v4();
    await _prefs?.setString('pending_session_id', _currentSessionId!);

    final telemetryData = await _gatherTelemetry();

    await _repository.createSession(
      sessionId: _currentSessionId!,
      userId: _userId!,
      platform: telemetryData['platform']!,
      deviceData: telemetryData,
    );

    logEvent('app_opened', {
      'device_model': telemetryData['device_model'],
      'os_version': telemetryData['os_version'],
    });

    debugPrint('[SessionManager] init() completed');
  }

  Future<Map<String, dynamic>> _gatherTelemetry() async {
    final deviceInfo = DeviceInfoPlugin();
    final packageInfo = await PackageInfo.fromPlatform();

    Map<String, dynamic> data = {
      'platform': Platform.isIOS ? 'ios' : 'android',
      'app_version': packageInfo.version,
      'build_number': packageInfo.buildNumber,
      'installer_store': packageInfo.installerStore,
      'device_model': 'Unknown',
      'os_version': 'Unknown',
      'device_id': 'Unknown',
    };

    try {
      if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        data.addAll({
          'device_model': iosInfo.utsname.machine,
          'os_version': iosInfo.systemVersion,
          'is_physical_device': iosInfo.isPhysicalDevice,
          'identifier_for_vendor': iosInfo.identifierForVendor,
          'device_id': iosInfo.identifierForVendor ?? 'Unknown',
          'manufacturer': 'Apple',
        });
      } else if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        String androidId = 'Unknown';
        try {
          androidId = await AndroidId().getId() ?? 'Unknown';
        } catch (e) {
          debugPrint('[SessionManager] Failed to get AndroidId: $e');
        }

        data.addAll({
          'device_model': androidInfo.model,
          'os_version': androidInfo.version.release,
          'manufacturer': androidInfo.manufacturer,
          'brand': androidInfo.brand,
          'hardware': androidInfo.hardware,
          'board': androidInfo.board,
          'os_sdk_int': androidInfo.version.sdkInt,
          'is_physical_device': androidInfo.isPhysicalDevice,
          'device_id': androidId,
        });
      }
    } catch (e) {
      debugPrint('[SessionManager] Failed to get device info: $e');
    }

    return data;
  }

  Future<void> logEvent(String name, [Map<String, dynamic>? properties]) async {
    if (_userId == null || _currentSessionId == null) {
      debugPrint('[SessionManager] logEvent($name) skipped: userId or sessionId is null');
      return;
    }

    final event = {
      'session_id': _currentSessionId,
      'user_id': _userId,
      'event_name': name,
      'properties': properties ?? {},
      'created_at': DateTime.now().toUtc().toIso8601String(),
    };

    debugPrint('[SessionManager] Logging event: $name');

    if (_criticalEvents.contains(name)) {
      final success = await _repository.pushEvents([event]);
      if (success) {
        debugPrint('[SessionManager] Critical event pushed instantly: $name');
        return;
      }
      debugPrint('[SessionManager] Failed to push critical event, queuing: $name');
    }

    _pendingEvents.add(event);

    if (_pendingEvents.length > 50) {
      _pendingEvents.removeAt(0);
    }
    await _prefs?.setString('pending_events', jsonEncode(_pendingEvents));
  }

  Future<void> _syncPendingSessions() async {
    if (_prefs == null) return;
    final savedSessions = _prefs!.getString('pending_sessions');
    if (savedSessions != null) {
      final List<dynamic> decoded = jsonDecode(savedSessions);
      final List<Map<String, dynamic>> sessions = decoded.map((e) => Map<String, dynamic>.from(e)).toList();
      if (sessions.isNotEmpty) {
        debugPrint('[SessionManager] Syncing ${sessions.length} offline sessions...');
        try {
          await _repository.pushSessions(sessions);
          await _prefs!.remove('pending_sessions');
          debugPrint('[SessionManager] Offline sessions synced successfully.');
        } catch (e) {
          debugPrint('[SessionManager] Failed to sync offline sessions: $e');
        }
      }
    }
  }

  Future<void> _syncPendingEvents() async {
    final savedEvents = _prefs?.getString('pending_events');
    if (savedEvents != null) {
      final List<dynamic> decoded = jsonDecode(savedEvents);
      _pendingEvents = decoded.map((e) => Map<String, dynamic>.from(e)).toList();

      if (_pendingEvents.isNotEmpty) {
        debugPrint('[SessionManager] Syncing ${_pendingEvents.length} offline events...');
        final success = await _repository.pushEvents(_pendingEvents);
        if (success) {
          _pendingEvents.clear();
          await _prefs?.remove('pending_events');
        }
      }
    }
  }

  Future<void> _syncPendingMatches() async {
    if (_prefs == null) return;
    final savedMatches = _prefs!.getString('pending_matches');
    if (savedMatches != null) {
      final List<dynamic> decoded = jsonDecode(savedMatches);
      final List<Map<String, dynamic>> matches = decoded.map((e) => Map<String, dynamic>.from(e)).toList();
      if (matches.isNotEmpty) {
        debugPrint('[SessionManager] Syncing ${matches.length} offline matches...');
        try {
          await _repository.pushMatches(matches);
          await _prefs!.remove('pending_matches');
          debugPrint('[SessionManager] Offline matches synced successfully.');
        } catch (e) {
          debugPrint('[SessionManager] Failed to sync offline matches: $e');
        }
      }
    }
  }

  Future<void> logout() async {
    debugPrint('[SessionManager] logout() called. userId=$_userId');

    if (_prefs == null) {
      try {
        _prefs = await SharedPreferences.getInstance();
      } catch (e) {
        debugPrint('[SessionManager] Failed to init prefs on logout: $e');
      }
    }

    if (_userId != null) {
      await logEvent('logout');

      if (_pendingEvents.isNotEmpty) {
        debugPrint('[SessionManager] Forced flush on logout: ${_pendingEvents.length} events');
        final success = await _repository.pushEvents(_pendingEvents);
        if (success) {
          _pendingEvents.clear();
          await _prefs?.remove('pending_events');
          debugPrint('[SessionManager] Forced flush successful.');
        }
      }
    }

    _currentSessionId = null;
    _userId = null;
    await _prefs?.remove('pending_session_id');
    debugPrint('[SessionManager] logout() completed');
  }
}