import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/profile/profile_repository.dart';
import '../../core/session/session_manager.dart';
import '../auth/sign_in_screen.dart';

class ProfileScreen extends StatefulWidget {
  final bool isDevMode;
  final ValueChanged<bool> onToggleDevMode;

  const ProfileScreen({
    super.key,
    required this.isDevMode,
    required this.onToggleDevMode,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late ProfileRepository _profileRepo;
  Future<Map<String, dynamic>?>? _profileFuture;

  @override
  void initState() {
    super.initState();
    // [UI-1] Fetch profile on mount
    _profileRepo = ProfileRepository(Supabase.instance.client);
    _profileFuture = _profileRepo.getProfile();
  }

  String _getInitial(String? username, String? email) {
    final name = username ?? email ?? '?';
    if (name.trim().isEmpty) return '?';
    return name.trim().substring(0, 1).toUpperCase();
  }

  String _getDisplayName(String? username, String? email) {
    if (username != null && username.trim().isNotEmpty) return username.trim();
    if (email != null && email.trim().isNotEmpty) return email.split('@').first;
    return '—';
  }

  void _showLogoutDialog(BuildContext context) {
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
                onPressed: () async {
                  Navigator.of(context).pop();
                  
                  // [DB-2] Log logout event and sync pending events before signing out
                  await SessionManager().logout();
                  
                  // [DB-3] Sign out of Supabase
                  await Supabase.instance.client.auth.signOut();
                  
                  if (context.mounted) {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const SignInScreen()),
                      (route) => false,
                    );
                  }
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
        child: FutureBuilder<Map<String, dynamic>?>(
          future: _profileFuture,
          builder: (context, snapshot) {
            // Get real email from Supabase Auth
            final email = Supabase.instance.client.auth.currentUser?.email;
            
            // Get username from public.profiles table
            final username = snapshot.data?['username'] as String?;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: AppSpacing.xl),
                  
                  // Avatar
                  Container(
                    width: AppSizes.avatar,
                    height: AppSizes.avatar,
                    decoration: const BoxDecoration(
                      color: AppColors.surface,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      _getInitial(username, email),
                      style: AppTextStyles.hud.copyWith(
                        color: AppColors.primary,
                        fontSize: 32,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  
                  // Username / Display Name
                  Text(
                    _getDisplayName(username, email),
                    style: AppTextStyles.display,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  
                  // Email
                  SelectableText(
                    email ?? '—',
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.textPrimary.withValues(alpha: 0.6),
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                  ),
                  
                  const SizedBox(height: AppSpacing.xl * 2),
                  
                  // DEV MODE TOGGLE
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(AppRadius.card),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: SwitchListTile(
                      title: Text('Developer Mode', style: AppTextStyles.body),
                      subtitle: Text(
                        'Toggle UILab tab visibility',
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.textPrimary.withValues(alpha: 0.6),
                          fontSize: 12,
                        ),
                      ),
                      value: widget.isDevMode,
                      activeThumbColor: AppColors.primary,
                      onChanged: widget.onToggleDevMode,
                    ),
                  ),

                  const SizedBox(height: AppSpacing.xl),
                  
                  PrimaryButton(
                    text: 'Logout',
                    onPressed: () => _showLogoutDialog(context),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}