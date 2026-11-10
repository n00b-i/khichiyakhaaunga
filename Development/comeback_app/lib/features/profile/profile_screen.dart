import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/profile/profile_repository.dart';
import '../../core/session/session_manager.dart';

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
  
  // Local cache for offline cooldown enforcement
  SharedPreferences? _prefs;

  @override
  void initState() {
    super.initState();
    _profileRepo = ProfileRepository(Supabase.instance.client);
    _profileFuture = _profileRepo.getProfile();
    _initPrefs();
  }

  Future<void> _initPrefs() async {
    _prefs = await SharedPreferences.getInstance();
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

  // [UI-1] Edit Username Flow
  void _handleEditUsername(String? currentUsername, String? lastUpdatedStr) async {
    // 1. Check Cooldown (Prioritize DB timestamp, fallback to local cache)
    DateTime? lastUpdated;
    if (lastUpdatedStr != null) {
      lastUpdated = DateTime.parse(lastUpdatedStr).toLocal();
    } else if (_prefs != null) {
      final cachedStr = _prefs!.getString('username_last_updated');
      if (cachedStr != null) lastUpdated = DateTime.parse(cachedStr).toLocal();
    }

    if (lastUpdated != null) {
      final hoursSinceUpdate = DateTime.now().difference(lastUpdated).inHours;
      if (hoursSinceUpdate < 24) {
        final hoursLeft = 24 - hoursSinceUpdate;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('You can change your name again in $hoursLeft hours.')),
        );
        return; // Abort
      }
    }

    // 2. Show Edit Dialog
    final TextEditingController controller = TextEditingController(text: currentUsername);
    final String? newName = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.sheet),
          side: const BorderSide(color: AppColors.border),
        ),
        title: const Text('Edit Name', style: AppTextStyles.hud),
        content: TextField(
          controller: controller,
          maxLength: 20,
          style: AppTextStyles.body,
          decoration: InputDecoration(
            hintText: 'Enter new name',
            hintStyle: AppTextStyles.body.copyWith(color: AppColors.textPrimary.withValues(alpha: 0.3)),
            counterText: "", // Hides the 0/20 counter
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel', style: AppTextStyles.body.copyWith(color: AppColors.textPrimary.withValues(alpha: 0.6))),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(controller.text.trim()),
            child: Text('Save', style: AppTextStyles.body.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    // 3. Save to DB and Local Cache
    if (newName != null && newName.isNotEmpty && newName != currentUsername) {
      final success = await _profileRepo.updateUsername(newName);
      
      if (success) {
        final nowStr = DateTime.now().toUtc().toIso8601String();
        await _prefs?.setString('username_last_updated', nowStr);
        
        setState(() {
          _profileFuture = _profileRepo.getProfile(); // Refresh UI
        });
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to update name. Try again.')),
          );
        }
      }
    }
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
            style: AppTextStyles.body.copyWith(color: AppColors.textPrimary.withValues(alpha: 0.6)),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel', style: AppTextStyles.body.copyWith(color: AppColors.textPrimary.withValues(alpha: 0.6))),
            ),
            SizedBox(
              width: 120,
              child: PrimaryButton(
                text: 'Logout',
                onPressed: () async {
                  Navigator.of(context).pop();
                  try {
                    await SessionManager().logout();
                    await Supabase.instance.client.auth.signOut();
                  } catch (e) {
                    debugPrint('[ProfileScreen] Logout error: $e');
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
            final email = Supabase.instance.client.auth.currentUser?.email;
            final username = snapshot.data?['username'] as String?;
            final lastUpdated = snapshot.data?['username_last_updated'] as String?;

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
                      style: AppTextStyles.hud.copyWith(color: AppColors.primary, fontSize: 32),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  
                  // Username with Edit Icon [AC-1]
                  GestureDetector(
                    onTap: () => _handleEditUsername(username, lastUpdated),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Flexible(
                          child: Text(
                            _getDisplayName(username, email),
                            style: AppTextStyles.display,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Icon(
                          Icons.edit,
                          size: 20,
                          color: AppColors.textPrimary.withValues(alpha: 0.6),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  
                  // Email
                  SelectableText(
                    email ?? '—',
                    style: AppTextStyles.body.copyWith(color: AppColors.textPrimary.withValues(alpha: 0.6)),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                  ),
                  
                  const SizedBox(height: AppSpacing.xl * 2),
                  
                  // Developer Mode Toggle
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
                          style: AppTextStyles.body.copyWith(color: AppColors.textPrimary.withValues(alpha: 0.6), fontSize: 12),
                        ),
                        value: widget.isDevMode,
                        activeThumbColor: AppColors.primary,
                        onChanged: widget.onToggleDevMode,
                      ),
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