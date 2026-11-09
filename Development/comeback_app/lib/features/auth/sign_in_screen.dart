import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/primary_button.dart';
import 'magic_link_sent_screen.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _emailController = TextEditingController();
  bool _isLoading = false;

  Future<void> _submitEmail() async {
    final email = _emailController.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid email.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await Supabase.instance.client.auth.signInWithOtp(
        email: email,
        emailRedirectTo: 'comebak.in://login-callback',
      );
      
      if (mounted) {
        setState(() => _isLoading = false);
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => MagicLinkSentScreen(email: email),
          ),
        );
      }
    } on AuthException catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message)),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Network error. Please try again.')),
        );
      }
    }
  }

    Future<void> _signInWithGoogle() async {
    setState(() => _isLoading = true);
    try {
      const webClientId = '836171717498-un6j40aatbi1622u1h686ijejrhc5dvt.apps.googleusercontent.com';
      const iosClientId = '836171717498-e2gq4g3219o0en1un4slfmpt2kc786f4.apps.googleusercontent.com';

      // 1. Initialize the GoogleSignIn singleton (Required in v7)
      await GoogleSignIn.instance.initialize(
        clientId: Platform.isIOS ? iosClientId : null,
        serverClientId: webClientId,
      );

      // 2. Authenticate (Replaces signIn() in v7)
      final GoogleSignInAccount googleUser = await GoogleSignIn.instance.authenticate();

      // 3. Get the ID token (synchronously)
      final String? idToken = googleUser.authentication.idToken;

      if (idToken == null) {
        throw 'No ID Token found.';
      }

      // 4. Sign in to Supabase
      // Note: We omit accessToken since it's no longer returned by default
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
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: AppSpacing.xl * 2),
                const Text('comebak', style: AppTextStyles.display),
                const SizedBox(height: AppSpacing.xl * 2),

                // Email Field
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppRadius.card),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: TextField(
                    controller: _emailController,
                    style: AppTextStyles.body,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.go,
                    onSubmitted: (_) => _submitEmail(),
                    decoration: InputDecoration(
                      hintText: 'you@example.com',
                      hintStyle: AppTextStyles.body.copyWith(
                        color: AppColors.textPrimary.withValues(alpha: 0.6),
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.md,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),

                // Send Magic Link Button
                PrimaryButton(
                  text: 'Send magic link',
                  isLoading: _isLoading,
                  onPressed: _submitEmail,
                ),
                
                const SizedBox(height: AppSpacing.xl),
                Row(
                  children: [
                    const Expanded(child: Divider(color: AppColors.border)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                      child: Text(
                        'or',
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.textPrimary.withValues(alpha: 0.6),
                        ),
                      ),
                    ),
                    const Expanded(child: Divider(color: AppColors.border)),
                  ],
                ),
                const SizedBox(height: AppSpacing.xl),

                // Google Button
                GestureDetector(
                  onTap: _isLoading ? null : _signInWithGoogle,
                  child: Container(
                    height: 52,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                      border: Border.all(color: AppColors.border),
                    ),
                    alignment: Alignment.center,
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: AppColors.primary,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text('Continue with Google', style: AppTextStyles.body),
                  ),
                ),
                
                // Apple Sign in (iOS only)
                if (Platform.isIOS) ...[
                  const SizedBox(height: AppSpacing.sm),
                  GestureDetector(
                    onTap: () {
                      // Apple Sign-In requires Apple Developer setup
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Apple Sign-In coming soon.')),
                      );
                    },
                    child: Container(
                      height: 52,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(AppRadius.pill),
                        border: Border.all(color: AppColors.border),
                      ),
                      alignment: Alignment.center,
                      child: const Text('Continue with Apple', style: AppTextStyles.body),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}