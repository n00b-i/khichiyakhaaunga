import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/theme/app_theme.dart';
import '../core/session/session_manager.dart';
import '../features/auth/sign_in_screen.dart';
import '../features/shell/main_shell.dart';

/// **AuthGate**
/// 
/// **Responsibility:**
/// - Acts as the root router based on Supabase Auth state.
/// - Detects when a user logs in or out and routes accordingly.
/// - Initializes the `SessionManager` exactly once per app launch.
/// - Cleans up any 'in_progress' matches left behind by a previous crash.
class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  // [1] Guard variable to prevent multiple initializations if the stream emits rapidly.
  bool _isSessionInitialized = false;

  @override
  void initState() {
    super.initState();
    
    // [2] Listen to the auth stream. 
    // We do this instead of checking currentUser directly in initState because 
    // Supabase might still be loading the token from local storage when initState fires.
    Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      final session = data.session;
      
      if (session != null) {
        // [2.1] Valid session found. Initialize the app session.
        _initializeSession(session.user.id);
      } else {
        // [2.2] Session became null (user logged out).
        debugPrint('[AuthGate] Session became null. User logged out.');
        _isSessionInitialized = false; // Reset for the next user
      }
    });
  }

  /// [3] Initializes the SessionManager and cleans up the database.
  Future<void> _initializeSession(String userId) async {
    debugPrint('[AuthGate] _initializeSession called for user: $userId');
    
    // [3.1] Only initialize once per launch.
    if (_isSessionInitialized) return;
    _isSessionInitialized = true;

    // [3.2] Start the SessionManager (creates session row, syncs offline events, fetches telemetry)
    await SessionManager().init(userId);
    debugPrint('[AuthGate] SessionManager init complete');
    
    // [3.3] Cleanup abandoned matches.
    // If the app crashed or was killed mid-game, the match is stuck as 'in_progress'.
    // We mark any lingering 'in_progress' matches as 'abandoned' so they don't pollute stats.
    try {
      await Supabase.instance.client
          .from('matches')
          .update({
            'status': 'abandoned', 
            'ended_at': DateTime.now().toIso8601String()
          })
          .eq('user_id', userId)
          .eq('status', 'in_progress');
      debugPrint('[AuthGate] Abandoned matches cleanup complete.');
    } catch (e) {
      debugPrint('[AuthGate] Failed to clean up abandoned matches: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    // [4] StreamBuilder listens to auth changes and rebuilds the UI.
    return StreamBuilder<AuthState>(
      stream: Supabase.instance.client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        // [4.1] Loading state while Supabase checks local tokens.
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: AppColors.background,
            body: Center(child: CircularProgressIndicator(color: AppColors.primary)),
          );
        }

        // [4.2] Route based on authentication status.
        final session = snapshot.hasData ? snapshot.data!.session : null;
        
        if (session != null) {
          return const MainShell();
        }

        return const SignInScreen();
      },
    );
  }
}