import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../core/theme/app_theme.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  bool _isLoading = false;

  Future<void> _signInWithGoogle() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);
    
    try {
      const webClientId = '836171717498-un6j40aatbi1622u1h686ijejrhc5dvt.apps.googleusercontent.com';
      const iosClientId = '836171717498-e2gq4g3219o0en1un4slfmpt2kc786f4.apps.googleusercontent.com';
      const androidClientId = '836171717498-2939anjueefjtd7ohc5jjs28gbr4e2ib.apps.googleusercontent.com';

      await GoogleSignIn.instance.initialize(
        clientId: Platform.isIOS ? iosClientId : androidClientId,
        serverClientId: webClientId,
      );

      final GoogleSignInAccount googleUser = await GoogleSignIn.instance.authenticate();
      final String? idToken = googleUser.authentication.idToken;

      if (idToken == null) throw 'No ID Token found.';

      await Supabase.instance.client.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
      );
      
    } on GoogleSignInException catch (e) {
      // [ISSUE-11] Map specific v7 error codes to friendly messages.
      debugPrint('[Auth] GoogleSignInException: ${e.code.name} — ${e.description}');
      
      switch (e.code.name) {
        case 'canceled':
        case 'interrupted':
          break; // Silent reset. User cancelled.
        case 'clientConfigurationError':
        case 'providerConfigurationError':
          _showError('Unable to sign in. Please try again.'); // Hide technical SHA-1 errors
          break;
        default:
          _showError('No internet connection. Please connect and try again.');
          break;
      }
    } catch (e) {
      // [ISSUE-11] Catch-all for network drops during Supabase exchange.
      debugPrint('[Auth] Sign-In Error: $e');
      if (mounted) _showError('Something went wrong. Please check your internet.');
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
              const Text('comebak', style: AppTextStyles.display, textAlign: TextAlign.center),
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
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: AppColors.primary, strokeWidth: 2))
                      : const Text('Continue with Google', style: AppTextStyles.body),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}