import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';

class SessionRepository {
  final SupabaseClient _supabase;

  SessionRepository(this._supabase);

  // [FORCE: COMMENT SYNTAX] Try network first. If it fails, queue locally.
  Future<void> createSession({
    required String sessionId,
    required String userId,
    required String platform,
    required Map<String, dynamic> deviceData,
  }) async {
    final payload = {
      'id': sessionId,
      'user_id': userId,
      'started_at': DateTime.now().toUtc().toIso8601String(),
      'platform': platform,
      ...deviceData,
    };

    try {
      await _supabase.from('user_sessions').insert(payload);
      debugPrint('[SessionRepository] Session created online: $sessionId');
    } catch (e) {
      debugPrint('[SessionRepository] Offline session. Queuing: $e');
      await _queueSession(payload);
    }
  }

  // [FORCE: COMMENT SYNTAX] Save failed session to SharedPreferences.
  Future<void> _queueSession(Map<String, dynamic> payload) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('pending_sessions');
    List<dynamic> pending = raw != null ? jsonDecode(raw) : [];
    pending.add(payload);
    await prefs.setString('pending_sessions', jsonEncode(pending));
  }

  // [FORCE: COMMENT SYNTAX] Drain queued sessions on next launch.
  Future<void> pushSessions(List<Map<String, dynamic>> sessions) async {
    if (sessions.isEmpty) return;
    try {
      await _supabase.from('user_sessions').upsert(sessions);
      debugPrint('[SessionRepository] Pushed ${sessions.length} offline sessions.');
    } catch (e) {
      debugPrint('[SessionRepository] Failed to push sessions: $e');
      rethrow; // Keep in queue
    }
  }

  Future<bool> pushEvents(List<Map<String, dynamic>> events) async {
    if (events.isEmpty) return true;
    try {
      await _supabase.from('events').insert(events);
      debugPrint('[SessionRepository] Pushed ${events.length} events.');
      return true;
    } catch (e) {
      debugPrint('[SessionRepository] Failed to push events: $e');
      return false;
    }
  }

  Future<void> pushMatches(List<Map<String, dynamic>> matches) async {
    if (matches.isEmpty) return;
    try {
      await _supabase.from('matches').upsert(matches);
      debugPrint('[SessionRepository] Pushed ${matches.length} offline matches.');
    } catch (e) {
      debugPrint('[SessionRepository] Failed to push matches: $e');
      rethrow;
    }
  }
}