import 'dart:convert';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart'; // [1] New import
import 'session_repository.dart';
import 'dart:developer' as developer;

class SessionManager {
  static final SessionManager _instance = SessionManager._internal();
  factory SessionManager() => _instance;
  SessionManager._internal();

  late SharedPreferences _prefs;
  late SessionRepository _repository;
  
  String? _currentSessionId;
  String? _userId;
  List<Map<String, dynamic>> _pendingEvents = [];

  String? get currentSessionId => _currentSessionId;

  Future<void> init(String userId) async {
    _userId = userId;
    _prefs = await SharedPreferences.getInstance();
    _repository = SessionRepository(Supabase.instance.client);

    developer.log('[SessionManager] Init started for user: $userId', name: 'SessionManager');

    // [2] Sync events from the previous session
    await _syncPendingEvents();

    // [3] Generate new session ID
    _currentSessionId = const Uuid().v4();
    await _prefs.setString('pending_session_id', _currentSessionId!);

    // [4] Gather all telemetry data
    final telemetryData = await _gatherTelemetry();

    // [5] Create session record in DB
    _repository.createSession(
      sessionId: _currentSessionId!,
      userId: _userId!,
      platform: telemetryData['platform']!,
      deviceData: telemetryData,
    );

    // [6] Log the app opened event
    logEvent('app_opened', {
      'device_model': telemetryData['device_model'],
      'os_version': telemetryData['os_version'],
    });
  }

  // [7] New method to collect all possible device and app info
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
    };

    try {
      if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        data.addAll({
          'device_model': iosInfo.utsname.machine, // e.g., iPhone13,2
          'os_version': iosInfo.systemVersion,
          'is_physical_device': iosInfo.isPhysicalDevice,
          'identifier_for_vendor': iosInfo.identifierForVendor,
          'manufacturer': 'Apple', // Fixed for iOS
        });
      } else if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        data.addAll({
          'device_model': androidInfo.model,
          'os_version': androidInfo.version.release,
          'manufacturer': androidInfo.manufacturer,
          'brand': androidInfo.brand,
          'hardware': androidInfo.hardware,
          'board': androidInfo.board,
          'os_sdk_int': androidInfo.version.sdkInt,
          'is_physical_device': androidInfo.isPhysicalDevice,
        });
      }
    } catch (e) {
      developer.log('[SessionManager] Failed to get device info: $e', name: 'SessionManager');
    }

    return data;
  }

  Future<void> logEvent(String name, [Map<String, dynamic>? properties]) async {
    if (_userId == null || _currentSessionId == null) return;

    final event = {
      'session_id': _currentSessionId,
      'user_id': _userId,
      'event_name': name,
      'properties': properties ?? {},
      'created_at': DateTime.now().toUtc().toIso8601String(),
    };

    _pendingEvents.add(event);
    developer.log('[SessionManager] Event logged: $name', name: 'SessionManager');

    if (_pendingEvents.length > 50) {
      _pendingEvents.removeAt(0);
    }

    await _prefs.setString('pending_events', jsonEncode(_pendingEvents));
  }

  Future<void> _syncPendingEvents() async {
    final savedEvents = _prefs.getString('pending_events');

    if (savedEvents != null) {
      final List<dynamic> decoded = jsonDecode(savedEvents);
      _pendingEvents = decoded.map((e) => Map<String, dynamic>.from(e)).toList();
      
      if (_pendingEvents.isNotEmpty) {
        developer.log('[SessionManager] Found ${_pendingEvents.length} pending events. Pushing to Supabase...', name: 'SessionManager');
        final success = await _repository.pushEvents(_pendingEvents);
        if (success) {
          _pendingEvents.clear();
          await _prefs.remove('pending_events'); 
          developer.log('[SessionManager] Pending events cleared from local storage.', name: 'SessionManager');
        }
      }
    }
  }

  Future<void> logout() async {
    await logEvent('logout');
    await _syncPendingEvents();
    _currentSessionId = null;
    _userId = null;
    _pendingEvents.clear();
    await _prefs.remove('pending_events');
    await _prefs.remove('pending_session_id');
    developer.log('[SessionManager] User logged out.', name: 'SessionManager');
  }
}