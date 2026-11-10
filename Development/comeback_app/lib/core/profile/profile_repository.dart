import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';

class ProfileRepository {
  final SupabaseClient _supabase;

  ProfileRepository(this._supabase);

  /// [DB-1] Fetches the user's profile from the `profiles` table.
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

  /// [DB-2] Updates the username and sets the cooldown timestamp to NOW.
  Future<bool> updateUsername(String newUsername) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return false;

    try {
      await _supabase.from('profiles').update({
        'username': newUsername,
        'username_last_updated': DateTime.now().toUtc().toIso8601String(),
      }).eq('id', userId);
      
      debugPrint('[ProfileRepository] Username updated successfully: $newUsername');
      return true;
    } catch (e) {
      debugPrint('[ProfileRepository] Failed to update username: $e');
      return false;
    }
  }
}