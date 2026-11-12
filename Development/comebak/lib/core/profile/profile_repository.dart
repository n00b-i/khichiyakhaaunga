import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';

class ProfileRepository {
  final SupabaseClient _supabase;

  ProfileRepository(this._supabase);

  // [DB-1] Fetches the user's profile from the `profiles` table.
  // Returns the row including `name` and `name_last_updated`.
  // [ISSUE-21] Doc corrected: live column is `name`, not `username`.
  Future<Map<String, dynamic>?> getProfile() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return null;

    try {
      final response = await _supabase
          .from('profiles')
          .select()
          .eq('id', userId)
          .maybeSingle();

      debugPrint('[ProfileRepository] Fetched profile: $response');
      return response;
    } catch (e) {
      debugPrint('[ProfileRepository] Failed to fetch profile: $e');
      return null;
    }
  }

  // [ISSUE-13] Updates the display name and sets the cooldown timestamp to NOW.
  // Returns true on success, false on network or RLS failure.
  // [ISSUE-21] Was writing `username` / `username_last_updated` which do not exist
  // in the live schema (PGRST204). Live targets are `name` / `name_last_updated`.
  // Method name kept for caller compatibility at profile_screen.dart:87.
  Future<bool> updateUsername(String newName) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return false;

    try {
      await _supabase.from('profiles').update({
        'name': newName,
        'name_last_updated': DateTime.now().toUtc().toIso8601String(),
      }).eq('id', userId);

      debugPrint('[ProfileRepository] Name updated: $newName');
      return true;
    } catch (e) {
      debugPrint('[ProfileRepository] Failed to update name: $e');
      return false;
    }
  }
}