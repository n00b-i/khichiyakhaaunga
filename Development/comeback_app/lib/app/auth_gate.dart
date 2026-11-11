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
  bool _isSessionInitialized = false;

  @override
  void initState() {
    super.initState();
    
    Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      final session = data.session;
      
      if (session != null) {
        _initializeSession(session.user.id);
      } else {
        debugPrint('[AuthGate] Session became null. User logged out.');
        _isSessionInitialized = false;
      }
    });
  }

  Future<void> _initializeSession(String userId) async {
    debugPrint('[AuthGate] _initializeSession called for user: $userId');
    
    if (_isSessionInitialized) return;
    _isSessionInitialized = true;

    await SessionManager().init(userId);
    debugPrint('[AuthGate] SessionManager init complete');
    
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
    return StreamBuilder<AuthState>(
      stream: Supabase.instance.client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: AppColors.background,
            body: Center(child: CircularProgressIndicator(color: AppColors.primary)),
          );
        }

        // [ISSUE-11] Handle auth stream errors (e.g., offline token refresh failure).
        if (snapshot.hasError) {
          return Scaffold(
            backgroundColor: AppColors.background,
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Connection Error. Please check your internet.',
                      style: AppTextStyles.body.copyWith(color: AppColors.textPrimary),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    ElevatedButton(
                      onPressed: () async {
                        await Supabase.instance.client.auth.refreshSession();
                        setState(() {});
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
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
