import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter/foundation.dart';
import '../../session/session_manager.dart';

class GameRepository {
  final SupabaseClient _supabase;
  final _uuid = const Uuid();

  GameRepository(this._supabase);

  // [ISSUE-10] Start a match. Generates a UUID locally first.
  Future<String?> startMatch(String gameId) async {
    final userId = _supabase.auth.currentUser?.id;
    
    // [FIX] Properly import SessionManager to get the active session ID.
    final sessionId = SessionManager().currentSessionId;
    
    if (userId == null || sessionId == null) return null;

    final matchId = _uuid.v4();

    try {
      await _supabase.from('matches').insert({
        'id': matchId,
        'user_id': userId,
        'session_id': sessionId,
        'game_id': gameId,
        'status': 'in_progress',
        'started_at': DateTime.now().toUtc().toIso8601String(),
      });
      debugPrint('[GameRepository] Match started online: $matchId');
    } catch (e) {
      // [ISSUE-10] Offline fallback: Ignore the network error. 
      // The game continues with the local matchId and we queue it on completion.
      debugPrint('[GameRepository] Offline start. Match will be queued on completion: $e');
    }
    
    return matchId;
  }

  // [ISSUE-10] End a match. Queues the payload if offline.
  Future<void> endMatch({
    required String matchId,
    required String gameId,
    required int score,
    required double accuracy,
    required int durationSeconds,
  }) async {
    final userId = _supabase.auth.currentUser?.id;
    final sessionId = SessionManager().currentSessionId;
    if (userId == null) return;

    final endedAt = DateTime.now().toUtc().toIso8601String();
    
    try {
      await _supabase.from('matches').update({
        'status': 'completed',
        'score': score,
        'accuracy': accuracy,
        'duration_seconds': durationSeconds,
        'ended_at': endedAt,
      }).eq('id', matchId);
      
      debugPrint('[GameRepository] Match completed online: $matchId');
    } catch (e) {
      // [ISSUE-10] Offline fallback: Queue the entire match object.
      debugPrint('[GameRepository] Network failed on match end. Queuing for sync: $e');
      
      final prefs = await SharedPreferences.getInstance();
      final pendingRaw = prefs.getString('pending_matches');
      List<dynamic> pendingMatches = pendingRaw != null ? jsonDecode(pendingRaw) : [];
      
      final payload = {
        'id': matchId,
        'user_id': userId,
        'session_id': sessionId,
        'game_id': gameId,
        'status': 'completed',
        'score': score,
        'accuracy': accuracy,
        'duration_seconds': durationSeconds,
        'started_at': DateTime.now().subtract(Duration(seconds: durationSeconds)).toUtc().toIso8601String(),
        'ended_at': endedAt,
      };

      pendingMatches.add(payload);
      await prefs.setString('pending_matches', jsonEncode(pendingMatches));
    }
  }
}