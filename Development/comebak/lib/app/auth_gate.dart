import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Core & Session
import '../core/session/session_manager.dart';
import '../core/network/connectivity_service.dart';

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
// This is the root gatekeeper. It manages the entire authentication flow.
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
  bool _isSigningIn = false;

  static const String _msgOffline =
      'No internet connection. Please connect and try again.';
  static const String _msgTimeout =
      'Connection timed out. Check your internet and try again.';
  static const String _msgConfigError = 'Unable to sign in. Please try again.';
  static const String _msgGenericError =
      'Something went wrong. Please check your internet.';
  static const Duration _signInTimeout = Duration(seconds: 8);

  @override
  void initState() {
    super.initState();
    _loadSplashRule();
    _listenToAuthChanges();
  }

  Future<void> _loadSplashRule() async {
    final engine = ComebakRuleEngine();
    final rule = await engine.pickRule();
    if (mounted) setState(() => _splashRule = rule);
  }

  void _listenToAuthChanges() {
    Supabase.instance.client.auth.onAuthStateChange.listen((data) async {
      final session = data.session;
      if (session != null) {
        await _initializeSession(session.user.id);
      } else {
        if (mounted) {
          setState(() {
            _currentSession = null;
            _isBlocked = false;
            _isSigningIn = false;
          });
        }
      }
    });
  }

  Future<void> _initializeSession(String userId) async {
    await SessionManager().init(userId);

    try {
      await Supabase.instance.client
          .from('matches')
          .update({
            'status': 'abandoned',
            'ended_at': DateTime.now().toIso8601String(),
          })
          .eq('user_id', userId)
          .eq('status', 'in_progress');
    } catch (e) {
      debugPrint('[AuthGate] Failed to clean up abandoned matches: $e');
    }

    await _checkProfileStatus(userId);
  }

  Future<void> _signInWithGoogle() async {
    if (_isSigningIn) return;

    if (await ConnectivityService.instance.isOffline()) {
      _showError(_msgOffline);
      return;
    }

    setState(() {
      _isSigningIn = true;
    });

    try {
      const webClientId =
          '836171717498-un6j40aatbi1622u1h686ijejrhc5dvt.apps.googleusercontent.com';
      const iosClientId =
          '836171717498-e2gq4g3219o0en1un4slfmpt2kc786f4.apps.googleusercontent.com';
      const androidClientId =
          '836171717498-2939anjueefjtd7ohc5jjs28gbr4e2ib.apps.googleusercontent.com';

      await GoogleSignIn.instance.initialize(
        clientId: Platform.isIOS ? iosClientId : androidClientId,
        serverClientId: webClientId,
      );

      final GoogleSignInAccount googleUser = await GoogleSignIn.instance
          .authenticate();
      final String? idToken = googleUser.authentication.idToken;
      if (idToken == null) throw 'No ID Token found.';

      await Supabase.instance.client.auth
          .signInWithIdToken(provider: OAuthProvider.google, idToken: idToken)
          .timeout(_signInTimeout);
    } on TimeoutException {
      _showError(_msgTimeout);
    } on AuthException {
      _showError(_msgOffline);
    } on GoogleSignInException catch (e) {
      switch (e.code.name) {
        case 'canceled':
        case 'interrupted':
          break;
        case 'clientConfigurationError':
        case 'providerConfigurationError':
          _showError(_msgConfigError);
          break;
        default:
          _showError(_msgOffline);
          break;
      }
    } catch (e) {
      _showError(_msgGenericError);
    } finally {
      if (mounted) setState(() => _isSigningIn = false);
    }
  }

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
          _isSigningIn = false;
        });
      }
    } catch (e) {
      debugPrint('[AuthGate] Profile fetch failed: $e');
      if (mounted) {
        setState(() {
          _currentSession = Supabase.instance.client.auth.currentSession;
          _isBlocked = false;
          _isLoadingProfile = false;
          _isSigningIn = false;
        });
      }
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: ComebakColors.surface,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _onSplashComplete() {
    setState(() => _isSplashComplete = true);
  }

  @override
  Widget build(BuildContext context) {
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

    if (_isLoadingProfile) {
      return Scaffold(
        backgroundColor: ComebakColors.canvas,
        body: Center(
          child: CircularProgressIndicator(color: ComebakColors.neonGreen),
        ),
      );
    }

    if (_currentSession != null && !_isBlocked) {
      return const MainShell();
    }

    return LoginV1Rules(
      onGoogleSignIn: _signInWithGoogle,
      isBlocked: _isBlocked,
      isLoading: _isSigningIn,
    );
  }
}
