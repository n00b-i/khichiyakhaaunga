import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter/foundation.dart';
import '../../session/session_manager.dart';
import '../../stats/stats_repository.dart'; // [ISSUE-9] Import for cache invalidation

class MatchResult {
  final bool isNewPB;
  final Duration? previousPBBrokenAfter;
  const MatchResult({required this.isNewPB, this.previousPBBrokenAfter});
}

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

  // [ISSUE-14] End a match. Returns MatchResult with isNewPB and previousPBBrokenAfter.
  Future<MatchResult?> endMatch({
    required String matchId,
    required String gameId,
    required int score,
    required double accuracy,
    required int durationSeconds,
  }) async {
    final userId = _supabase.auth.currentUser?.id;
    final sessionId = SessionManager().currentSessionId;
    if (userId == null) return null;

    bool isNewPB = false;
    Duration? previousPBBrokenAfter;

    // [ISSUE-14] Fetch current PB before saving the new score
    try {
      final statsRes = await _supabase
          .from('user_stats')
          .select('${gameId}_pb')
          .eq('user_id', userId)
          .maybeSingle();

      final int? oldPb = statsRes?['${gameId}_pb'] as int?;
      isNewPB = oldPb == null || score > oldPb;

      if (isNewPB && oldPb != null && oldPb > 0) {
        final prevMatch = await _supabase
            .from('matches')
            .select('ended_at')
            .eq('user_id', userId)
            .eq('game_id', gameId)
            .eq('status', 'completed')
            .eq('score', oldPb)
            .order('ended_at', ascending: false)
            .limit(1)
            .maybeSingle();

        if (prevMatch != null && prevMatch['ended_at'] != null) {
          final prevDate = DateTime.parse(prevMatch['ended_at']).toUtc();
          previousPBBrokenAfter = DateTime.now().toUtc().difference(prevDate);
        }
      }
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

      // [ISSUE-9] Invalidate in-memory cache so StatsScreen fetches fresh data once.
      StatsRepository(_supabase).invalidateCache();
      
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

    return MatchResult(isNewPB: isNewPB, previousPBBrokenAfter: previousPBBrokenAfter);
  }
}