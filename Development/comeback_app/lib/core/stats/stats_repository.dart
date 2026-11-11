import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';
import '../network/connectivity_service.dart';

class StatsRepository {
  final SupabaseClient _supabase;

  StatsRepository(this._supabase);

  static const _cacheKey = 'cached_stats';
  static const _networkTimeout = Duration(seconds: 3);

  // Network-first with offline fast-path and timeout fallback to cache.
  Future<Map<String, dynamic>?> getUserStats() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return null;

    final prefs = await SharedPreferences.getInstance();

    // Fast path: device reports no network -> serve cache immediately.
    if (await ConnectivityService.instance.isOffline()) {
      debugPrint('[StatsRepository] Offline pre-check -> cache');
      return _readCache(prefs);
    }

    try {
      final response = await _supabase
          .from('user_stats')
          .select()
          .eq('user_id', userId)
          .maybeSingle()
          .timeout(_networkTimeout);

      if (response != null) {
        await prefs.setString(_cacheKey, jsonEncode(response));
      }
      return response;
    } catch (e) {
      debugPrint('[StatsRepository] Network/timeout failed -> cache: $e');
      return _readCache(prefs);
    }
  }

  Map<String, dynamic>? _readCache(SharedPreferences prefs) {
    final cached = prefs.getString(_cacheKey);
    if (cached == null) return null;
    try {
      return Map<String, dynamic>.from(jsonDecode(cached) as Map);
    } catch (_) {
      return null;
    }
  }
}
