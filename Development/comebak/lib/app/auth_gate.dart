import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Core & Session

// UI Lab Components (Source of Truth)
import '../features/debug/ui_lab/1_foundations/tokens/ui_lab_tokens.dart';
import '../features/debug/ui_lab/5_catalog/auth_variants/splash_v1_rules_v2.dart';
import '../features/debug/ui_lab/5_catalog/auth_variants/login_v1_rules.dart';
import '../features/debug/ui_lab/5_catalog/auth_variants/comebak_rule_engine.dart';

// Production Shell
import '../features/shell/main_shell.dart';

// ==============================================================================
// [APP] AuthGate
// ------------------------------------------------------------------------------
// PURPOSE: The root gatekeeper. Decides whether to show Splash, Login, or MainShell.
//
// FLOW:
// 1. App starts -> Shows SplashV1RulesV2 (Cinematic 4.2s animation).
// 2. While Splash animates, AuthGate listens to Supabase session stream.
// 3. On Splash complete:
//    - If session exists AND user is not blocked -> MainShell.
//    - If session exists BUT user is blocked -> Login (with error banner).
//    - If no session -> Login.
//
// STATES HANDLED:
// - Loading (Splash visible)
// - Authenticated (Session + Profile active)
// - Unauthenticated (No session)
// - Blocked (Session + Profile status != 'active')
// - Error (Network failure during session refresh)
// ==============================================================================
class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  bool _isSplashComplete = false;
  ComebakRule? _splashRule;

  Session? _currentSession;
  bool _isBlocked = false;
  bool _isLoadingProfile = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadSplashRule();
    _listenToAuthChanges();
  }

  /// Load a random rule for the Splash screen.
  Future<void> _loadSplashRule() async {
    final engine = ComebakRuleEngine();
    final rule = await engine.pickRule();
    if (mounted) setState(() => _splashRule = rule);
  }

  /// Listen to Supabase auth state changes.
  void _listenToAuthChanges() {
    Supabase.instance.client.auth.onAuthStateChange.listen((data) async {
      final session = data.session;
      if (session != null) {
        await _checkProfileStatus(session.user.id);
      } else {
        if (mounted) {
          setState(() {
            _currentSession = null;
            _isBlocked = false;
          });
        }
      }
    });
  }

  /// Fetch the user's profile to check if they are blocked.
  Future<void> _checkProfileStatus(String userId) async {
    setState(() => _isLoadingProfile = true);
    try {
      final profile = await Supabase.instance.client
          .from('profiles')
          .select('status')
          .eq('id', userId)
          .single();

      final isBlocked = profile['status'] != 'active';

      if (mounted) {
        setState(() {
          _currentSession = Supabase.instance.client.auth.currentSession;
          _isBlocked = isBlocked;
          _isLoadingProfile = false;
        });
      }
    } catch (e) {
      // Fail-open: if profile fetch fails, assume active but log.
      debugPrint('[AuthGate] Profile fetch failed: $e');
      if (mounted) {
        setState(() {
          _currentSession = Supabase.instance.client.auth.currentSession;
          _isBlocked = false;
          _isLoadingProfile = false;
        });
      }
    }
  }

  /// Called when Splash animation finishes.
  void _onSplashComplete() {
    setState(() => _isSplashComplete = true);
  }

  @override
  Widget build(BuildContext context) {
    // 1. Splash (or rule not yet loaded)
    if (!_isSplashComplete || _splashRule == null) {
      return SplashV1RulesV2(
        rule:
            _splashRule ??
            const ComebakRule(
              id: 'fallback',
              hook: 'ALWAYS REMEMBER',
              line: 'Giving up is not in the blood, sir!',
              category: 'resilience',
            ),
        onComplete: _onSplashComplete,
      );
    }

    // 2. Profile loading
    if (_isLoadingProfile) {
      return Scaffold(
        backgroundColor: ComebakColors.canvas,
        body: Center(
          child: CircularProgressIndicator(color: ComebakColors.neonGreen),
        ),
      );
    }

    // 3. Network error
    if (_errorMessage != null) {
      return Scaffold(
        backgroundColor: ComebakColors.canvas,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(ComebakLayout.spaceXl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _errorMessage!,
                  style: ComebakTypography.bodyMedium.copyWith(
                    color: ComebakColors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: ComebakLayout.spaceLg),
                ElevatedButton(
                  onPressed: () async {
                    await Supabase.instance.client.auth.refreshSession();
                    setState(() => _errorMessage = null);
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // 4. Authenticated & not blocked -> MainShell
    if (_currentSession != null && !_isBlocked) {
      return const MainShell();
    }

    // 5. Unauthenticated or blocked -> Login
    return LoginV1Rules(
      onGoogleSignIn: () {},
      isBlocked: _isBlocked, // New parameter
    );
  }
}
