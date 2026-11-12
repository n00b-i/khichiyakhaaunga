import 'dart:async';
import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../core/theme/app_theme.dart';
import '../../core/network/connectivity_service.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  bool _isLoading = false;

  // [ISSUE-11] Centralized Error Messages
  static const String _msgOffline = 'No internet connection.\nPlease connect and try again.';
  static const String _msgTimeout = 'Connection timed out.\nCheck your internet and try again.';
  static const String _msgConfigError = 'Unable to sign in.\nPlease try again.';
  static const String _msgGenericError = 'Something went wrong.\nPlease check your internet.';

  // [ISSUE-11] Timeout duration for both Google Auth and Supabase token exchange
  static const Duration _signInTimeout = Duration(seconds: 8);

    Future<void> _signInWithGoogle() async {
    if (_isLoading) return;

    // Pre-flight: Now catches captive portals via the new service
    if (await ConnectivityService.instance.isOffline()) {
      _showError(_msgOffline);
      return;
    }

    setState(() => _isLoading = true);

    try {
      const webClientId = '836171717498-un6j40aatbi1622u1h686ijejrhc5dvt.apps.googleusercontent.com';
      const iosClientId = '836171717498-e2gq4g3219o0en1un4slfmpt2kc786f4.apps.googleusercontent.com';
      const androidClientId = '836171717498-2939anjueefjtd7ohc5jjs28gbr4e2ib.apps.googleusercontent.com';

      await GoogleSignIn.instance.initialize(
        clientId: Platform.isIOS ? iosClientId : androidClientId,
        serverClientId: webClientId,
      );

      // Interactive step: No artificial timeout here. Let the user take their time.
      final GoogleSignInAccount googleUser = await GoogleSignIn.instance.authenticate();

      final String? idToken = googleUser.authentication.idToken;
      if (idToken == null) throw 'No ID Token found.';

      // Network step: Apply timeout only to the backend token exchange.
      await Supabase.instance.client.auth
          .signInWithIdToken(
            provider: OAuthProvider.google,
            idToken: idToken,
          )
          .timeout(_signInTimeout);
          
    } on TimeoutException {
      debugPrint('[Auth] Supabase token exchange timed out');
      _showError(_msgTimeout);
    } on AuthException catch (e) {
      debugPrint('[Auth] AuthException: $e');
      _showError(_msgOffline);
    } on GoogleSignInException catch (e) {
      debugPrint('[Auth] GoogleSignInException: ${e.code.name} — ${e.description}');
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
      debugPrint('[Auth] Sign-In Error: $e');
      _showError(_msgGenericError);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: AppTextStyles.body),
        backgroundColor: AppColors.surface,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'comebak',
                style: AppTextStyles.display,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xl * 3),
              GestureDetector(
                onTap: _isLoading ? null : _signInWithGoogle,
                child: Container(
                  height: 52,
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                    border: Border.all(color: AppColors.border),
                  ),
                  alignment: Alignment.center,
                  child: _isLoading
                      ? const SizedBox(
                          width: AppSizes.iconSm,
                          height: AppSizes.iconSm,
                          child: CircularProgressIndicator(
                            color: AppColors.primary,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Continue with Google',
                          style: AppTextStyles.body,
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}