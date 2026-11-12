import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/ui/components/comebak_avatar.dart';
import '../../core/ui/components/comebak_button.dart';
import '../../core/ui/components/comebak_chip.dart';
import '../../core/ui/components/comebak_list_tile.dart';
import '../../core/ui/components/section_header.dart';
import '../../core/ui/utils/comebak_snackbar.dart';
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
  SharedPreferences? _prefs;

  @override
  void initState() {
    super.initState();
    _profileRepo = ProfileRepository(Supabase.instance.client);
    _profileFuture = _loadProfileAndPrefs();
  }

  Future<Map<String, dynamic>?> _loadProfileAndPrefs() async {
    _prefs = await SharedPreferences.getInstance();
    return await _profileRepo.getProfile();
  }

  String _getDisplayName(String? name) {
    if (name != null && name.trim().isNotEmpty) return name.trim();
    return '—';
  }

  void _handleEditName(String? currentName, String? lastUpdatedStr) async {
    DateTime? lastUpdated;
    if (lastUpdatedStr != null) {
      lastUpdated = DateTime.tryParse(lastUpdatedStr)?.toLocal();
    } else if (_prefs != null) {
      final cachedStr = _prefs!.getString('name_last_updated');
      if (cachedStr != null) {
        lastUpdated = DateTime.tryParse(cachedStr)?.toLocal();
      }
    }

    if (lastUpdated != null) {
      final remaining = const Duration(hours: 24) - DateTime.now().difference(lastUpdated);
      if (remaining > Duration.zero) {
        // [ISSUE-21-REFINE] Static cooldown message. No time digits to avoid <1h edge cases and local/UTC drift.
        if (!mounted) return;
        showComebakSnackBar(context, 'Name can be changed once every 24 hours.', isError: true);
        return;
      }
    }

    final newName = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (context) => _EditNameDialog(initialName: currentName),
    );

    if (!mounted) return;
    if (newName == null || newName.isEmpty) return;
    if (newName == currentName) return;

    final success = await _profileRepo.updateUsername(newName);

    if (!mounted) return;

    if (success) {
      final nowStr = DateTime.now().toUtc().toIso8601String();
      await _prefs?.setString('name_last_updated', nowStr);
      if (!mounted) return;
      setState(() {
        _profileFuture = _loadProfileAndPrefs();
      });
      showComebakSnackBar(context, 'Name updated');
    } else {
      showComebakSnackBar(context, 'Could not update name. Try again.', isError: true);
    }
  }

  void _showLogoutDialog(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: AppColors.surfaceElevated,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.radiusLarge),
          side: const BorderSide(color: AppColors.borderSubtle),
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 340),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.space24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Log out?', style: AppTextStyles.titleMedium),
                const SizedBox(height: AppSpacing.space8),
                Text('Are you sure you want to log out?', style: AppTextStyles.bodyMedium),
                const SizedBox(height: AppSpacing.space24),
                Row(
                  children: [
                    Expanded(
                      child: ComebakButton(
                        text: 'Cancel',
                        variant: ComebakButtonVariant.ghost,
                        onPressed: () => Navigator.pop(context, false),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.space16),
                    Expanded(
                      child: ComebakButton(
                        text: 'Logout',
                        variant: ComebakButtonVariant.danger,
                        onPressed: () => Navigator.pop(context, true),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );

    if (confirmed == true) {
      try {
        await SessionManager().logout();
      } catch (e) {
        debugPrint('[ProfileScreen] SessionManager logout error: $e');
      } finally {
        try {
          await Supabase.instance.client.auth.signOut();
        } catch (e) {
          debugPrint('[ProfileScreen] Supabase signOut error: $e');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: SafeArea(
        child: FutureBuilder<Map<String, dynamic>?>(
          future: _profileFuture,
          builder: (context, snapshot) {
            final email = Supabase.instance.client.auth.currentUser?.email;
            final name = snapshot.data?['name'] as String?;
            final lastUpdated = snapshot.data?['name_last_updated'] as String?;
            final currentStreak = snapshot.data?['current_streak'] as int? ?? 0;
            final lastPlayedStr = snapshot.data?['last_played_at'] as String?;

            String streakText = '';
            bool isStreakActive = false;

            if (currentStreak > 1) {
              streakText = '🔥 $currentStreak Days Streak';
              isStreakActive = true;
            }
            else if (currentStreak == 1) {
              streakText = '🔥 Keep it up!';
              isStreakActive = true;
            }
             else if (lastPlayedStr != null) {
              final date = DateTime.tryParse(lastPlayedStr);
              if (date != null) {
                streakText = 'Last played on ${date.day}/${date.month}/${date.year}';
              }
            } else {
              streakText = 'Time to Comebak';
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.space24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: AppSpacing.space32),

                  Row(
                    children: [
                      ComebakAvatar(name: name),
                      const SizedBox(width: AppSpacing.space16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(_getDisplayName(name), style: AppTextStyles.titleLarge),
                            const SizedBox(height: AppSpacing.space4),
                            Text(
                              email ?? '—',
                              style: AppTextStyles.bodyMedium,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: AppSpacing.space8),
                            ComebakChip(text: streakText, isActive: isStreakActive),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SectionHeader('Account'),
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.surfaceElevated,
                      borderRadius: BorderRadius.circular(AppRadius.radiusMedium),
                      border: Border.all(color: AppColors.borderSubtle),
                    ),
                    child: Column(
                      children: [
                        ComebakListTile(
                          leading: const Icon(LucideIcons.pencil, size: 24, color: AppColors.textMuted),
                          title: 'Edit Name',
                          trailing: const Icon(LucideIcons.chevron_right, size: 20, color: AppColors.textMuted),
                          onTap: () => _handleEditName(name, lastUpdated),
                        ),
                        // [ISSUE-28] Developer Mode is only visible in debug builds.
                        if (kDebugMode) ...[
                          const Divider(height: 1, color: AppColors.borderSubtle),
                          ComebakListTile(
                            leading: const Icon(LucideIcons.settings, size: 24, color: AppColors.textMuted),
                            title: 'Developer Mode',
                            trailing: Switch(
                              value: widget.isDevMode,
                              onChanged: widget.onToggleDevMode,
                              activeThumbColor: AppColors.primaryAccent,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSpacing.space48),

                  ComebakButton(
                    text: 'Logout',
                    variant: ComebakButtonVariant.danger,
                    onPressed: () => _showLogoutDialog(context),
                  ),
                  const SizedBox(height: AppSpacing.space32),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

// [FIX] Extracted Edit Name Dialog to manage its own TextEditingController lifecycle.
class _EditNameDialog extends StatefulWidget {
  final String? initialName;

  const _EditNameDialog({this.initialName});

  @override
  State<_EditNameDialog> createState() => _EditNameDialogState();
}

class _EditNameDialogState extends State<_EditNameDialog> {
  late TextEditingController _controller;
  late bool _isValid;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialName);
    // [ISSUE-21] Save disabled unless input is non-empty AND differs from initial name.
    _isValid = _controller.text.trim().isNotEmpty &&
        _controller.text.trim() != (widget.initialName ?? '').trim();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.surfaceElevated,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.radiusLarge),
        side: const BorderSide(color: AppColors.borderSubtle),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 340),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.space24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Edit Name', style: AppTextStyles.titleMedium),
              const SizedBox(height: AppSpacing.space16),
              TextField(
                controller: _controller,
                style: AppTextStyles.body,
                // [ISSUE-21-REFINE] 20 char cap, matching DB constraint profiles_name_length_check.
                inputFormatters: [LengthLimitingTextInputFormatter(20)],
                onChanged: (val) {
                  setState(() {
                    // [ISSUE-21] Mirror initState gate on every keystroke.
                    _isValid = val.trim().isNotEmpty &&
                        val.trim() != (widget.initialName ?? '').trim();
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Your name',
                  hintStyle: AppTextStyles.body.copyWith(color: AppColors.textMuted),
                  filled: true,
                  fillColor: AppColors.surfaceOverlay,
                  contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.space16, vertical: AppSpacing.space12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.radiusSmall),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.space24),
              Row(
                children: [
                  Expanded(
                    child: ComebakButton(
                      text: 'Cancel',
                      variant: ComebakButtonVariant.ghost,
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.space16),
                  Expanded(
                    child: ComebakButton(
                      text: 'Save',
                      variant: ComebakButtonVariant.primary,
                      // [FIX] Button is disabled if input is empty or unchanged. [ISSUE-21]
                      onPressed: _isValid
                          ? () => Navigator.pop(context, _controller.text.trim())
                          : null,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}