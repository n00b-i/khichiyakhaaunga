import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ==============================================================================
// [REPOSITORY] ProfileRepository
// ------------------------------------------------------------------------------
// PURPOSE: Single Source of Truth (SSOT) for user profile data.
// STRATEGY:
// 1. In-Memory Cache (_inMemoryProfile): For instant UI updates within a session.
// 2. Local Storage (SharedPreferences): For persistence across app restarts.
// 3. Remote DB (Supabase): The ultimate authority, fetched only when necessary.
// ==============================================================================
class ProfileRepository {
  final SupabaseClient _supabase;
  ProfileRepository(this._supabase);

  // [CACHE] Static in-memory store. Cleared on logout or explicit invalidation.
  static Map<String, dynamic>? _inMemoryProfile;

  // [LOCAL STORAGE KEYS] Centralized keys to prevent typos and ensure DRY.
  static const String _prefsNameKey = 'profile_name';
  static const String _prefsEmailKey = 'profile_email';
  static const String _prefsJoinDateKey = 'profile_join_date';

  /// [FETCH LOGIC] Retrieves profile data with a strict fallback hierarchy:
  /// 1. In-Memory Cache -> 2. Local Storage -> 3. Remote Supabase Fetch.
  Future<Map<String, dynamic>?> getProfile() async {
    // [OPTIMIZATION] Return cached data instantly if available in this session.
    if (_inMemoryProfile != null) return _inMemoryProfile;

    final prefs = await SharedPreferences.getInstance();
    final userId = _supabase.auth.currentUser?.id;

    // [FALLBACK] If no user is logged in, try to serve stale data from local storage.
    if (userId == null) {
      return prefs.getString(_prefsNameKey) != null
          ? {
              'name': prefs.getString(_prefsNameKey),
              'email': prefs.getString(_prefsEmailKey),
              'join_date': prefs.getString(_prefsJoinDateKey),
            }
          : null;
    }

    try {
      // [REMOTE FETCH] Query the 'profiles' table. Adjust 'created_at' if your column is named differently.
      final response = await _supabase
          .from('profiles')
          .select()
          .eq('id', userId)
          .maybeSingle();

      if (response != null) {
        _inMemoryProfile = response; // [CACHE WRITE] Update memory.

        // [LOCAL SYNC] Persist critical fields to SharedPreferences for offline/fast-load support.
        await prefs.setString(_prefsNameKey, response['name'] ?? '');
        await prefs.setString(_prefsEmailKey, response['email'] ?? '');
        await prefs.setString(_prefsJoinDateKey, response['created_at'] ?? '');
      }
      return response;
    } catch (e) {
      debugPrint(
        '[ProfileRepository] Remote fetch failed, falling back to local: $e',
      );
      // [RESILIENCE] If remote fails, serve the last known good state from local storage.
      return prefs.getString(_prefsNameKey) != null
          ? {
              'name': prefs.getString(_prefsNameKey),
              'email': prefs.getString(_prefsEmailKey),
              'join_date': prefs.getString(_prefsJoinDateKey),
            }
          : null;
    }
  }

  /// [MUTATION] Updates username remotely and invalidates all caches immediately.
  Future<bool> updateUsername(String newName) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return false;
    try {
      await _supabase
          .from('profiles')
          .update({
            'name': newName,
            'name_last_updated': DateTime.now().toUtc().toIso8601String(),
          })
          .eq('id', userId);

      _inMemoryProfile = null; // [INVALIDATION] Force a fresh fetch next time.
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _prefsNameKey,
        newName,
      ); // [LOCAL UPDATE] Keep local storage in sync.
      return true;
    } catch (e) {
      debugPrint('[ProfileRepository] Name update failed: $e');
      return false;
    }
  }

  /// [CACHE CONTROL] Clears the in-memory cache.
  static void clearCache() => _inMemoryProfile = null;

  /// [LOGOUT PURGE] Atomically removes all user-specific data from local storage.
  static Future<void> clearLocalData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefsNameKey);
    await prefs.remove(_prefsEmailKey);
    await prefs.remove(_prefsJoinDateKey);
  }
}
