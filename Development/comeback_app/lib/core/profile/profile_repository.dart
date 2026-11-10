import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:developer' as developer;

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
          
      developer.log('[ProfileRepository] Fetched profile: $response', name: 'ProfileRepository');
      return response;
    } catch (e) {
      developer.log('[ProfileRepository] Failed to fetch profile: $e', name: 'ProfileRepository');
      return null;
    }
  }
}