import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:developer' as developer;

class SessionRepository {
  final SupabaseClient _supabase;

  SessionRepository(this._supabase);

  Future<void> createSession({
    required String sessionId,
    required String userId,
    required String platform,
  }) async {
    try {
      await _supabase.from('user_sessions').insert({
        'id': sessionId,
        'user_id': userId,
        'started_at': DateTime.now().toUtc().toIso8601String(),
        'platform': platform,
      });
    } catch (e) {
      developer.log('Failed to create session: $e', name: 'SessionRepository');
    }
  }

  Future<bool> pushEvents(List<Map<String, dynamic>> events) async {
    if (events.isEmpty) return true;
    try {
      await _supabase.from('events').insert(events);
      return true; 
    } catch (e) {
      developer.log('Failed to push events: $e', name: 'SessionRepository');
      return false; 
    }
  }
}