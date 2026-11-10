import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';

class StatsRepository {
  final SupabaseClient _supabase;

  StatsRepository(this._supabase);

  /// [ISSUE-11] Fetches stats from network, falls back to local cache if offline.
  Future<Map<String, dynamic>?> getUserStats() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return null;

    final prefs = await SharedPreferences.getInstance();

    try {
      final response = await _supabase
          .from('user_stats')
          .select()
          .eq('user_id', userId)
          .maybeSingle();
          
      if (response != null) {
        // [ISSUE-11] Save to local cache on successful network fetch
        await prefs.setString('cached_stats', jsonEncode(response));
      }
      return response;
    } catch (e) {
      debugPrint('[StatsRepository] Network failed, loading from cache: $e');
      // [ISSUE-11] Return cached data if network fails
      final cached = prefs.getString('cached_stats');
      if (cached != null) {
        return jsonDecode(cached);
      }
      return null;
    }
  }
}