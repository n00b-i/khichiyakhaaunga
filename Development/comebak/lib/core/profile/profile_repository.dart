import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';

// ==============================================================================
// [REPOSITORY] ProfileRepository
// ------------------------------------------------------------------------------
// PURPOSE: Data access layer for the `profiles` table.
// CACHING: A static `_inMemoryProfile` cache ensures the profile is fetched
//          from Supabase only ONCE per app session. Subsequent calls return
//          the cached map instantly. This aligns with the session-level
//          data fetching strategy to minimize DB calls.
// ==============================================================================
class ProfileRepository {
  final SupabaseClient _supabase;

  ProfileRepository(this._supabase);

  // [CACHE] In-memory store for the profile row. Cleared on logout or
  // explicit invalidation. Survives tab switches and background/foreground.
  static Map<String, dynamic>? _inMemoryProfile;

  /// [DB-1] Fetches the user's profile from the `profiles` table.
  /// Returns the row including `name`, `current_streak`, and `name_last_updated`.
  Future<Map<String, dynamic>?> getProfile() async {
    // [CACHE HIT] Return instantly if we already fetched in this session.
    if (_inMemoryProfile != null) {
      debugPrint('[ProfileRepository] Returning cached profile');
      return _inMemoryProfile;
    }

    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return null;

    try {
      final response = await _supabase
          .from('profiles')
          .select()
          .eq('id', userId)
          .maybeSingle();

      debugPrint('[ProfileRepository] Fetched profile: $response');
      _inMemoryProfile = response; // [CACHE WRITE] Store for subsequent reads.
      return response;
    } catch (e) {
      debugPrint('[ProfileRepository] Failed to fetch profile: $e');
      return null;
    }
  }

  /// [ISSUE-13] Updates the display name and sets the cooldown timestamp to NOW.
  /// Returns true on success, false on network or RLS failure.
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

      // [CACHE INVALIDATION] Force a fresh fetch on the next getProfile() call
      // because the name (and potentially streak) changed.
      _inMemoryProfile = null;

      debugPrint('[ProfileRepository] Name updated: $newName');
      return true;
    } catch (e) {
      debugPrint('[ProfileRepository] Failed to update name: $e');
      return false;
    }
  }

  /// [CACHE CONTROL] Explicitly clears the in-memory profile cache.
  /// Call this on logout to prevent data leaking between accounts.
  static void clearCache() {
    _inMemoryProfile = null;
  }
}
