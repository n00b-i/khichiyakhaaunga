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
      debugPrint('[GameRepository] Offline start. Match will be queued on completion: $e');
    }
    
    return matchId;
  }

  // [ISSUE-14] End a match. Returns true if it's a new PB.
  Future<bool> endMatch({
    required String matchId,
    required String gameId,
    required int score,
    required double accuracy,
    required int durationSeconds,
  }) async {
    final userId = _supabase.auth.currentUser?.id;
    final sessionId = SessionManager().currentSessionId;
    if (userId == null) return false;

    bool isNewPB = false;

    // [ISSUE-14] Fetch current PB before saving the new score
    try {
      final statsRes = await _supabase
          .from('user_stats')
          .select('${gameId}_pb')
          .eq('user_id', userId)
          .maybeSingle();
          
      final int? oldPb = statsRes?['${gameId}_pb'] as int?;
      
      // It's a new PB if there was no PB before, or if the new score is strictly higher
      isNewPB = oldPb == null || score > oldPb;
      debugPrint('[GameRepository] Old PB: $oldPb | New Score: $score | isNewPB: $isNewPB');
    } catch (e) {
      debugPrint('[GameRepository] Failed to fetch PB: $e');
    }

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
      
      // [ISSUE-3] Invalidate cached stats so the UI fetches fresh data next time
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('cached_stats');
    } catch (e) {
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

    return isNewPB;
  }
}