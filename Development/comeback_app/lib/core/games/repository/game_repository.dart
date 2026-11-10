import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../../session/session_manager.dart';
import 'dart:developer' as developer;

class GameRepository {
  final SupabaseClient _supabase;
  final _uuid = const Uuid();

  GameRepository(this._supabase);

  // 1. Start a match
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

      // Log event
      SessionManager().logEvent('game_started', {'game_id': gameId});
      
      return matchId;
    } catch (e) {
      developer.log('Failed to start match: $e', name: 'GameRepository');
      return null;
    }
  }

  // 2. End a match
  Future<void> endMatch({
    required String matchId,
    required String gameId,
    required int score,
    required double accuracy,
    required int durationSeconds,
  }) async {
    try {
      await _supabase.from('matches').update({
        'status': 'completed',
        'score': score,
        'accuracy': accuracy,
        'duration_seconds': durationSeconds,
        'ended_at': DateTime.now().toUtc().toIso8601String(),
      }).eq('id', matchId);

      // Log event
      SessionManager().logEvent('game_completed', {
        'game_id': gameId,
        'score': score,
        'accuracy': accuracy,
        'duration': durationSeconds,
      });
      
    } catch (e) {
      developer.log('Failed to end match: $e', name: 'GameRepository');
    }
  }
}