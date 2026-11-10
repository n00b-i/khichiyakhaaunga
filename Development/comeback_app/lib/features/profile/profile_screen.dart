import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/profile/profile_repository.dart';
import '../../core/session/session_manager.dart';

/// **ProfileScreen**
/// 
/// **Responsibility:**
/// - Displays the user's email (from Supabase Auth) and username (from public.profiles).
/// - Allows the user to toggle Developer Mode (only visible in Debug builds).
/// - Handles the logout flow gracefully, ensuring session events are flushed.
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
    // [1] Fetch the user's profile row from Supabase on screen mount.
    _profileRepo = ProfileRepository(Supabase.instance.client);
    _profileFuture = _profileRepo.getProfile();
  }

  // [2] Extracts the first letter for the Avatar fallback.
  String _getInitial(String? username, String? email) {
    final name = username ?? email ?? '?';
    if (name.trim().isEmpty) return '?';
    return name.trim().substring(0, 1).toUpperCase();
  }

  // [3] If the user hasn't set a username yet, fallback to the first part of their email.
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
                  // [4] Close the dialog immediately.
                  Navigator.of(context).pop();
                  
                  debugPrint('[ProfileScreen] Logout tapped');
                  
                  try {
                    // [4.1] Log the logout event and flush pending events to Supabase.
                    await SessionManager().logout();
                    debugPrint('[ProfileScreen] SessionManager logout done. Signing out of Supabase.');
                    
                    // [4.2] Sign out of Supabase. 
                    // AuthGate will automatically detect this and route to SignInScreen.
                    await Supabase.instance.client.auth.signOut();
                    
                  } catch (e) {
                    // [4.3] Offline Fallback: If the network fails, we still force local sign-out.
                    debugPrint('[ProfileScreen] Logout network error: $e');
                    await Supabase.instance.client.auth.signOut();
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
            // [5] Email comes directly from Supabase Auth.
            final email = Supabase.instance.client.auth.currentUser?.email;
            
            // [6] Username comes from the profiles table.
            final username = snapshot.data?['username'] as String?;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: AppSpacing.xl),
                  
                  // [7] Avatar
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
                  
                  // [8] Display Name
                  Text(
                    _getDisplayName(username, email),
                    style: AppTextStyles.display,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  
                  // [9] Email
                  SelectableText(
                    email ?? '—',
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.textPrimary.withValues(alpha: 0.6),
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                  ),
                  
                  const SizedBox(height: AppSpacing.xl * 2),
                  
                  // [10] Developer Mode Toggle
                  // [10.1] Wrapped in Material to fix the ListTile ink splash assertion error.
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(AppRadius.card),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(AppRadius.card),
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
                  ),

                  const SizedBox(height: AppSpacing.xl),
                  
                  // [11] Logout Button
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