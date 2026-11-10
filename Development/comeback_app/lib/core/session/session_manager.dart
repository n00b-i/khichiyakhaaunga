import 'dart:convert';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:android_id/android_id.dart';
import 'session_repository.dart';
import 'package:flutter/foundation.dart'; // Used for debugPrint RCA logs

/// **SessionManager**
/// 
/// **Responsibility:**
/// - Generates a new `session_id` on every app launch (cold start).
/// - Captures device telemetry (model, OS, unique device ID) without permissions.
/// - Queues events locally to prevent data loss if the network drops.
/// - Pushes critical events (game start/end, logout) to Supabase instantly.
/// - Batches non-critical events (app opened) for the next app launch to save API limits.
/// 
/// **Architecture:** Singleton pattern to ensure one source of truth for the active session.
class SessionManager {
  // [1] Singleton setup.
  static final SessionManager _instance = SessionManager._internal();
  factory SessionManager() => _instance;
  SessionManager._internal();

  // [2] Nullable _prefs. This prevents a 'LateInitializationError' crash 
  // if the user taps Logout before SharedPreferences finishes initializing on cold start.
  SharedPreferences? _prefs; 
  late SessionRepository _repository;
  
  String? _currentSessionId;
  String? _userId;
  
  // [3] Offline Queue: If a non-critical event is logged, it goes here.
  // If the app closes before the next launch, these events are saved to SharedPreferences.
  List<Map<String, dynamic>> _pendingEvents = [];

  // [4] Critical events bypass the queue and hit the DB immediately.
  // This is necessary for real-time debugging of core gameplay and auth flows.
  final List<String> _criticalEvents = [
    'game_started',
    'game_completed',
    'logout',
  ];

  String? get currentSessionId => _currentSessionId;

  /// [5] Called by AuthGate immediately after a valid Supabase session is detected.
  Future<void> init(String userId) async {
    debugPrint('[SessionManager] init() started for user: $userId');
    _userId = userId;
    
    // Load local storage
    _prefs = await SharedPreferences.getInstance();
    _repository = SessionRepository(Supabase.instance.client);

    // [5.1] Push any events that failed to send in the previous session.
    await _syncPendingEvents();

    // [5.2] Generate a new unique session ID for this app launch.
    _currentSessionId = const Uuid().v4();
    await _prefs?.setString('pending_session_id', _currentSessionId!);

    // [5.3] Fetch device telemetry (no permissions required).
    final telemetryData = await _gatherTelemetry();

    // [5.4] Create the session record in the database.
    await _repository.createSession(
      sessionId: _currentSessionId!,
      userId: _userId!,
      platform: telemetryData['platform']!,
      deviceData: telemetryData,
    );

    // [5.5] Log the app_opened event. This is a non-critical event, so it gets queued.
    logEvent('app_opened', {
      'device_model': telemetryData['device_model'],
      'os_version': telemetryData['os_version'],
    });
    
    debugPrint('[SessionManager] init() completed');
  }

  /// [6] Gathers deep device information using `device_info_plus`, `package_info_plus`, and `android_id`.
  /// None of these require runtime permissions from the user.
  Future<Map<String, dynamic>> _gatherTelemetry() async {
    final deviceInfo = DeviceInfoPlugin();
    final packageInfo = await PackageInfo.fromPlatform();
    
    // Base defaults
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
        
        // [6.1] Extract the true Android SSAID (Unique Device ID).
        // We do NOT use androidInfo.id, because that returns the Build ID (e.g., UP1A.231005.007).
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

  /// [7] Core logging mechanism.
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

    // [7.1] Critical events are pushed instantly.
    if (_criticalEvents.contains(name)) {
      final success = await _repository.pushEvents([event]);
      if (success) {
        debugPrint('[SessionManager] Critical event pushed instantly: $name');
        return; // Exit early, no need to queue.
      }
      debugPrint('[SessionManager] Failed to push critical event, queuing: $name');
    }

    // [7.2] Non-critical events (or failed critical events) go to the local queue.
    _pendingEvents.add(event);
    
    // [7.3] Cap queue at 50 items to prevent SharedPreferences bloat.
    if (_pendingEvents.length > 50) {
      _pendingEvents.removeAt(0);
    }
    await _prefs?.setString('pending_events', jsonEncode(_pendingEvents));
  }

  /// [8] Pushes locally queued events to Supabase.
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

  /// [9] Called from the Profile Screen.
  Future<void> logout() async {
    debugPrint('[SessionManager] logout() called. userId=$_userId');
    
    // [9.1] Safety check: If _prefs is null (race condition), initialize it now.
    if (_prefs == null) {
      try {
        _prefs = await SharedPreferences.getInstance();
      } catch (e) {
        debugPrint('[SessionManager] Failed to init prefs on logout: $e');
      }
    }

    if (_userId != null) {
      // [9.2] Log the logout event.
      await logEvent('logout');
      
      // [9.3] Force push ALL remaining queued events before the token is destroyed.
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
    
    // [9.4] Clear local state.
    _currentSessionId = null;
    _userId = null;
    await _prefs?.remove('pending_session_id');
    debugPrint('[SessionManager] logout() completed');
  }
}