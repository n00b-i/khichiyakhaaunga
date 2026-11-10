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
    setState(() => _isLoading = true);
    try {
      // ─────────────────────────────────────────────────────────────────────
      // FIX: Pass BOTH clientId and serverClientId for Android.
      // The v7 plugin needs the Android client ID to verify the SHA-1.
      // ─────────────────────────────────────────────────────────────────────
      
      const webClientId = '836171717498-un6j40aatbi1622u1h686ijejrhc5dvt.apps.googleusercontent.com';
      const iosClientId = '836171717498-e2gq4g3219o0en1un4slfmpt2kc786f4.apps.googleusercontent.com';
      const androidClientId = '836171717498-2939anjueefjtd7ohc5jjs28gbr4e2ib.apps.googleusercontent.com';

      await GoogleSignIn.instance.initialize(
        // On Android, we MUST pass the Android client ID here.
        // On iOS, we pass the iOS client ID.
        clientId: Platform.isIOS ? iosClientId : androidClientId,
        
        // The serverClientId is ALWAYS the Web client ID.
        serverClientId: webClientId,
      );

      final GoogleSignInAccount googleUser = await GoogleSignIn.instance.authenticate();
      final String? idToken = googleUser.authentication.idToken;

      if (idToken == null) {
        throw 'No ID Token found.';
      }

      await Supabase.instance.client.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
      );
      
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Google Sign-In Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
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

              // Google Button
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
                          width: 20, height: 20,
                          child: CircularProgressIndicator(color: AppColors.primary, strokeWidth: 2),
                        )
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