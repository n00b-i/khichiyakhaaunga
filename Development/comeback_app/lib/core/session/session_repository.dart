import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';

class SessionRepository {
  final SupabaseClient _supabase;

  SessionRepository(this._supabase);

  Future<void> createSession({
    required String sessionId,
    required String userId,
    required String platform,
    required Map<String, dynamic> deviceData,
  }) async {
    try {
      await _supabase.from('user_sessions').insert({
        'id': sessionId,
        'user_id': userId,
        'started_at': DateTime.now().toUtc().toIso8601String(),
        'platform': platform,
        ...deviceData,
      });
      debugPrint('[SessionRepository] Session created: $sessionId');
    } catch (e) {
      debugPrint('[SessionRepository] Failed to create session: $e');
    }
  }

  Future<bool> pushEvents(List<Map<String, dynamic>> events) async {
    if (events.isEmpty) return true;
    try {
      await _supabase.from('events').insert(events);
      debugPrint('[SessionRepository] Successfully pushed ${events.length} events to Supabase');
      return true; 
    } catch (e) {
      debugPrint('[SessionRepository] Failed to push events: $e');
      return false; 
    }
  }

  // [ISSUE-10] Push queued offline matches using UPSERT.
  Future<void> pushMatches(List<Map<String, dynamic>> matches) async {
    if (matches.isEmpty) return;
    try {
      // Upsert handles both 'in_progress' inserts and 'completed' updates
      await _supabase.from('matches').upsert(matches);
      debugPrint('[SessionRepository] Pushed ${matches.length} offline matches to Supabase.');
    } catch (e) {
      debugPrint('[SessionRepository] Failed to push offline matches: $e');
      rethrow; // Throw so SessionManager knows to keep them in the queue
    }
  }
}