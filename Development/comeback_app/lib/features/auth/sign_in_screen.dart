import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class SignInScreen extends StatelessWidget {
  const SignInScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // STUB: This will be fully implemented in S-02 (Magic Link + OAuth)
    return const Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Text('Sign In Screen (Stub)', style: AppTextStyles.display),
      ),
    );
  }
}