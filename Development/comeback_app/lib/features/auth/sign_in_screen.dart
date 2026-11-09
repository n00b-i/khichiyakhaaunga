import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
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
      // Catches Supabase specific errors (e.g., Rate Limit)
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

  Future<void> _signInWithProvider(OAuthProvider provider) async {
    try {
      await Supabase.instance.client.auth.signInWithOAuth(
        provider,
        redirectTo: 'comebak.in://login-callback',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('OAuth Error: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 1. GestureDetector dismisses keyboard when tapping outside
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

                // Social Buttons
                GestureDetector(
                  onTap: () => _signInWithProvider(OAuthProvider.google),
                  child: Container(
                    height: 52,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                      border: Border.all(color: AppColors.border),
                    ),
                    alignment: Alignment.center,
                    child: const Text('Continue with Google', style: AppTextStyles.body),
                  ),
                ),
                
                // 2. Only show Apple Sign in on iOS
                if (Platform.isIOS) ...[
                  const SizedBox(height: AppSpacing.sm),
                  GestureDetector(
                    onTap: () => _signInWithProvider(OAuthProvider.apple),
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