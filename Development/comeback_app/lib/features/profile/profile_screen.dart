import 'package:flutter/material.dart';
import 'package:fossui/fossui.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/app_dialog_style.dart';
import '../../core/profile/profile_repository.dart';
import '../../core/session/session_manager.dart';

// [ISSUE-13] Profile screen with username edit and 24h cooldown.
// [ARCHITECTURE] Uses FossDialog (centered) for edit and FossAlertDialog (centered) for logout.
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

  // [ISSUE-13] Edit username flow with 24h cooldown.
  void _handleEditUsername(String? currentUsername, String? lastUpdatedStr) async {
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
        if (!mounted) return;
        showFossToast(
          context,
          FossToast(
            title: Text('You can change your name again in $hoursLeft hours.'),
            variant: FossToastVariant.warning,
          ),
        );
        return;
      }
    }

    final TextEditingController controller = TextEditingController(text: currentUsername);
    
    // [FIX: OVERFLOW BUG] Keep actions inside the constrained content area.
    // FossDialog's footer is a fixed Row and does not wrap on narrow screens.
    // Wrap keeps Cancel and Save responsive without placing Flexible in actions.
    final String? newName = await showFossDialog<String>(
      context: context,
      presentation: FossDialogPresentation.centered,
      barrierDismissible: false,
      builder: (context) => FossDialog(
        style: const FossDialogStyle(maxWidth: AppDialogWidth.compact),
        title: const Text('Edit name'),
        description: const Text('Choose a new display name.'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            FossTextField(
              controller: controller,
              label: 'New name',
              hintText: 'deevanshu_guru',
            ),
            const SizedBox(height: AppSpacing.md),
            Wrap(
              alignment: WrapAlignment.end,
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                FossButton(
                  variant: FossButtonVariant.ghost,
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                FossButton(
                  onPressed: () =>
                      Navigator.pop(context, controller.text.trim()),
                  child: const Text('Save'),
                ),
              ],
            ),
          ],
        ),
        actions: const [],
      ),
    );

    if (newName != null && newName.isNotEmpty && newName != currentUsername) {
      final success = await _profileRepo.updateUsername(newName);

      if (success) {
        final nowStr = DateTime.now().toUtc().toIso8601String();
        await _prefs?.setString('username_last_updated', nowStr);

        setState(() {
          _profileFuture = _profileRepo.getProfile();
        });

        if (!mounted) return;
        showFossToast(
          context,
          const FossToast(
            title: Text('Name updated'),
            variant: FossToastVariant.success,
          ),
        );
      } else {
        if (!mounted) return;
        showFossToast(
          context,
          const FossToast(
            title: Text('Could not update name. Try again.'),
            variant: FossToastVariant.error,
          ),
        );
      }
    }
  }

  // [LOGOUT] Confirmation dialog using FossAlertDialog (centered).
  void _showLogoutDialog(BuildContext context) async {
    final confirmed = await showFossAlertDialog<bool>(
      context: context,
      presentation: FossDialogPresentation.centered,
      builder: (context) => FossAlertDialog(
        style: const FossAlertDialogStyle(maxWidth: AppDialogWidth.compact),
        title: const Text('Log out?'),
        description: const Text('Are you sure you want to log out?'),
        actions: [
          FossButton(
            variant: FossButtonVariant.ghost,
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FossButton(
            variant: FossButtonVariant.destructive,
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await SessionManager().logout();
        await Supabase.instance.client.auth.signOut();
      } catch (e) {
        debugPrint('[ProfileScreen] Logout error: $e');
        await Supabase.instance.client.auth.signOut();
      }
    }
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
                  FossAvatar(
                    fallback: Text(_getInitial(username, email)),
                    size: FossAvatarSize.xl2,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  GestureDetector(
                    onTap: () => _handleEditUsername(username, lastUpdated),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Flexible(
                          child: FossText(
                            _getDisplayName(username, email),
                            size: FossTextSize.xl2,
                            weight: FossTextWeight.bold,
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
                  FossText(
                    email ?? '—',
                    size: FossTextSize.base,
                    color: FossTextColor.mutedForeground,
                  ),
                  const SizedBox(height: AppSpacing.xl * 2),
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
                        title: FossText('Developer Mode', size: FossTextSize.base),
                        subtitle: FossText(
                          'Toggle UILab tab visibility',
                          size: FossTextSize.xs,
                          color: FossTextColor.mutedForeground,
                        ),
                        value: widget.isDevMode,
                        activeThumbColor: AppColors.primary,
                        onChanged: widget.onToggleDevMode,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  SizedBox(
                    width: double.infinity,
                    child: FossButton(
                      variant: FossButtonVariant.destructive,
                      onPressed: () => _showLogoutDialog(context),
                      child: const Text('Logout'),
                    ),
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