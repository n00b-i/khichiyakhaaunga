import 'dart:convert';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import 'session_repository.dart';

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

  // Called from AuthGate when the user logs in or the app launches
  Future<void> init(String userId) async {
    _userId = userId;
    _prefs = await SharedPreferences.getInstance();
    _repository = SessionRepository(Supabase.instance.client);

    // 1. Push any events left over from the last session (async, doesn't block UI)
    await _syncPendingEvents();

    // 2. Generate new session for this launch
    _currentSessionId = const Uuid().v4();
    final platform = Platform.isIOS ? 'ios' : 'android';

    // 3. Create session record in DB
    _repository.createSession(
      sessionId: _currentSessionId!,
      userId: _userId!,
      platform: platform,
    );

    // 4. Log the app opened event
    logEvent('app_opened', {'version': '1.0.0'});
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

    // // Cap at 50 to prevent local storage bloat
    // if (_pendingEvents.length > 50) {
    //   _pendingEvents.removeAt(0);
    // }

    await _prefs.setString('pending_events', jsonEncode(_pendingEvents));
  }

  Future<void> _syncPendingEvents() async {
    final savedEvents = _prefs.getString('pending_events');
    if (savedEvents != null) {
      final List<dynamic> decoded = jsonDecode(savedEvents);
      _pendingEvents = decoded.map((e) => Map<String, dynamic>.from(e)).toList();
      
      if (_pendingEvents.isNotEmpty) {
        final success = await _repository.pushEvents(_pendingEvents);
        if (success) {
          _pendingEvents.clear();
          await _prefs.remove('pending_events'); 
        }
      }
    }
  }

  // Call this on logout
  Future<void> logout() async {
    await logEvent('logout');
    await _syncPendingEvents();
    _currentSessionId = null;
    _userId = null;
    _pendingEvents.clear();
    await _prefs.remove('pending_events');
  }
}