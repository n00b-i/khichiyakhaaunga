import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/theme/app_theme.dart';
import '../features/auth/sign_in_screen.dart';
import '../features/shell/main_shell.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  @override
  void initState() {
    super.initState();
    _cleanupAbandonedMatches();
  }

  // Janitor Logic: If a user closed the app mid-game, mark it as abandoned
  Future<void> _cleanupAbandonedMatches() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      try {
        await Supabase.instance.client
            .from('matches')
            .update({'status': 'abandoned', 'ended_at': DateTime.now().toIso8601String()})
            .eq('user_id', user.id)
            .eq('status', 'in_progress');
      } catch (e) {
        debugPrint('Failed to clean up abandoned matches: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Listen to Supabase Auth state changes globally
    return StreamBuilder<AuthState>(
      stream: Supabase.instance.client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        // 1. While waiting for the initial session check, show a loading spinner
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: AppColors.background,
            body: Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          );
        }

        // 2. If session exists, go to Main App
        final session = snapshot.hasData ? snapshot.data!.session : null;
        
        if (session != null) {
          return const MainShell();
        }

        // 3. If no session, go to Sign In
        return const SignInScreen();
      },
    );
  }
}