import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:developer' as developer;

class SessionRepository {
  final SupabaseClient _supabase;

  SessionRepository(this._supabase);

  // [1] Accepts a flexible map for all device/app telemetry
  Future<void> createSession({
    required String sessionId,
    required String userId,
    required String platform,
    required Map<String, dynamic> deviceData, // [2] New parameter
  }) async {
    try {
      await _supabase.from('user_sessions').insert({
        'id': sessionId,
        'user_id': userId,
        'started_at': DateTime.now().toUtc().toIso8601String(),
        'platform': platform,
        ...deviceData, // [3] Spread the telemetry data into the insert
      });
      developer.log('Session created successfully: $sessionId', name: 'SessionRepository');
    } catch (e) {
      developer.log('Failed to create session: $e', name: 'SessionRepository');
    }
  }

  Future<bool> pushEvents(List<Map<String, dynamic>> events) async {
    if (events.isEmpty) return true;
    try {
      await _supabase.from('events').insert(events);
      developer.log('Pushed ${events.length} events to Supabase', name: 'SessionRepository');
      return true; 
    } catch (e) {
      developer.log('Failed to push events: $e', name: 'SessionRepository');
      return false; 
    }
  }
}