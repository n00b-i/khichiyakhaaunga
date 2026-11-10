import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/theme/app_theme.dart';
import '../core/session/session_manager.dart';
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
    _initialize();
  }

  Future<void> _initialize() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      // 1. Start Session
      await SessionManager().init(user.id);
      
      // 2. Cleanup abandoned matches
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
    return StreamBuilder<AuthState>(
      stream: Supabase.instance.client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: AppColors.background,
            body: Center(child: CircularProgressIndicator(color: AppColors.primary)),
          );
        }

        final session = snapshot.hasData ? snapshot.data!.session : null;
        
        if (session != null) {
          return const MainShell();
        }

        return const SignInScreen();
      },
    );
  }
}