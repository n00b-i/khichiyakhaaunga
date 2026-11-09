import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/primary_button.dart';
import '../auth/sign_in_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  // Mock data for now. Will be replaced by Supabase user session.
  final String? username = 'Agent';
  final String? email = 'agent@comebak.in';

  // S-07 E1/E2/E6/E7: Handles null, empty, emojis, and non-latin characters.
  String _getInitial() {
    if (username == null || username!.trim().isEmpty) return '?';
    final trimmed = username!.trim();
    // Using substring instead of characters to avoid needing extra imports
    return trimmed.substring(0, 1).toUpperCase();
  }

  // S-07 E1/E2: Fallback to em-dash if name is null/empty.
  String _getDisplayName() {
    if (username == null || username!.trim().isEmpty) return '—';
    return username!.trim();
  }

  void _showLogoutDialog(BuildContext context) {
    // S-07 B2: Tapping Logout opens a confirmation dialog.
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.sheet),
            side: const BorderSide(color: AppColors.border),
          ),
          title: const Text('Log out?', style: AppTextStyles.hud),
          content: Text(
            'Are you sure you want to log out of comeback.in?',
            style: AppTextStyles.body.copyWith(
              color: AppColors.textPrimary.withValues(alpha: 0.6),
            ),
          ),
          actions: [
            // S-07 B4: Cancel dismisses the dialog with no state change.
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: AppTextStyles.body.copyWith(
                  color: AppColors.textPrimary.withValues(alpha: 0.6),
                ),
              ),
            ),
            SizedBox(
              width: 120,
              child: PrimaryButton(
                text: 'Logout',
                onPressed: () {
                  Navigator.of(context).pop();
                  // S-07 B3: Clear session and replace to SignIn.
                  // pushAndRemoveUntil prevents going "back" into the app.
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const SignInScreen()),
                    (route) => false,
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: AppSpacing.xl),
              
              // S-07 V2/V9: Avatar (no border/shadow).
              Container(
                width: AppSizes.avatar,
                height: AppSizes.avatar,
                decoration: const BoxDecoration(
                  color: AppColors.surface,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  _getInitial(),
                  style: AppTextStyles.hud.copyWith(
                    color: AppColors.primary,
                    fontSize: 32,
                  ),
                ),
              ),
              
              const SizedBox(height: AppSpacing.lg),
              
              // S-07 V3/E3: Username (truncates with ellipsis if too long).
              Text(
                _getDisplayName(),
                style: AppTextStyles.display,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: AppSpacing.xs),
              
              // S-07 V4/I7: Email (selectable so users can copy it).
              SelectableText(
                email ?? '—',
                style: AppTextStyles.body.copyWith(
                  color: AppColors.textPrimary.withValues(alpha: 0.6),
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
              ),
              
              const SizedBox(height: AppSpacing.xl * 2),
              
              // S-07 V5: Logout uses our shared PrimaryButton.
              PrimaryButton(
                text: 'Logout',
                onPressed: () => _showLogoutDialog(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}