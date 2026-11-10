import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:developer' as developer;

class StatsRepository {
  final SupabaseClient _supabase;

  StatsRepository(this._supabase);

  /// [DB-1] Fetches the aggregated stats view for the current user.
  /// Returns a Map if data exists, or null if the user has never played.
  Future<Map<String, dynamic>?> getUserStats() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return null;

    try {
      // [DB-2] Query the user_stats view
      final response = await _supabase
          .from('user_stats')
          .select()
          .eq('user_id', userId)
          .maybeSingle();
          
      developer.log('[StatsRepository] Fetched stats: $response', name: 'StatsRepository');
      return response;
    } catch (e) {
      developer.log('[StatsRepository] Failed to fetch stats: $e', name: 'StatsRepository');
      return null;
    }
  }
}