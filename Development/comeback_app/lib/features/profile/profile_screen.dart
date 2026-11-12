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
    final profile = await _profileRepo.getProfile();
    // [ISSUE-21-REFINE] Sync prefs to DB. DB is source of truth when fetch succeeds.
    if (profile != null) {
      final dbTs = profile['name_last_updated'] as String?;
      if (dbTs == null) {
        await _prefs?.remove('name_last_updated');
      } else {
        await _prefs?.setString('name_last_updated', dbTs);
      }
    }
    return profile;
  }

  String _getDisplayName(String? name) {
    if (name != null && name.trim().isNotEmpty) return name.trim();
    return '—';
  }

  void _handleEditName(String? currentName, String? lastUpdatedStr) async {
    DateTime? lastUpdated;
    // [ISSUE-21-REFINE] Removed _prefs fallback here. DB (via FutureBuilder) is the single source of truth.
    if (lastUpdatedStr != null) {
      lastUpdated = DateTime.tryParse(lastUpdatedStr)?.toLocal();
    }

    if (lastUpdated != null) {
      final remaining = const Duration(hours: 24) - DateTime.now().difference(lastUpdated);
      if (remaining > Duration.zero) {
        if (!mounted) return;
        showComebakSnackBar(context, 'Name can be changed once every 24 hours.', isError: true);
        return;
      }
    }

    final newName = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _EditNameBottomSheet(initialName: currentName),
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

  void _showLogoutBottomSheet(BuildContext context) async {
    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const _LogoutBottomSheet(),
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
                    onPressed: () => _showLogoutBottomSheet(context),
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

// [DRY] Shared base bottom sheet component for consistent styling and keyboard avoidance.
class _ComebakBaseBottomSheet extends StatelessWidget {
  final Widget child;
  const _ComebakBaseBottomSheet({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.radiusLarge)),
        border: Border(top: BorderSide(color: AppColors.borderSubtle)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom, // Pushes sheet up when keyboard opens
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // [UI] Standard Drag Handle
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.textMuted.withOpacity(0.5),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.space24, 
                AppSpacing.space8, 
                AppSpacing.space24, 
                AppSpacing.space24
              ),
              child: child,
            ),
          ],
        ),
      ),
    );
  }
}

// [UI] Logout Confirmation Bottom Sheet
class _LogoutBottomSheet extends StatelessWidget {
  const _LogoutBottomSheet();

  @override
  Widget build(BuildContext context) {
    return _ComebakBaseBottomSheet(
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
    );
  }
}

// [UI] Edit Name Bottom Sheet with inline validation
class _EditNameBottomSheet extends StatefulWidget {
  final String? initialName;

  const _EditNameBottomSheet({this.initialName});

  @override
  State<_EditNameBottomSheet> createState() => _EditNameBottomSheetState();
}

class _EditNameBottomSheetState extends State<_EditNameBottomSheet> {
  late TextEditingController _controller;
  late bool _isValid;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialName);
    _validate(_controller.text);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _validate(String val) {
    final trimmed = val.trim();
    String? err;
    if (trimmed.isNotEmpty && !RegExp(r'^[A-Za-z0-9_]+$').hasMatch(trimmed)) {
      // [UI] User-friendly error text
      err = 'Use only letters, numbers, and underscores.';
    }
    _errorText = err;
    _isValid = trimmed.isNotEmpty &&
        trimmed != (widget.initialName ?? '').trim() &&
        err == null;
  }

  @override
  Widget build(BuildContext context) {
    return _ComebakBaseBottomSheet(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Edit Name', style: AppTextStyles.titleMedium),
          const SizedBox(height: AppSpacing.space16),
          TextField(
            controller: _controller,
            autofocus: true,
            style: AppTextStyles.body,
            inputFormatters: [LengthLimitingTextInputFormatter(20)],
            onChanged: (val) {
              setState(() {
                _validate(val);
              });
            },
            decoration: InputDecoration(
              hintText: 'Your name',
              hintStyle: AppTextStyles.body.copyWith(color: AppColors.textMuted),
              filled: true,
              fillColor: AppColors.surfaceOverlay,
              errorText: _errorText,
              errorMaxLines: 2,
              errorStyle: AppTextStyles.body.copyWith(color: AppColors.danger),
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
                  onPressed: _isValid
                      ? () => Navigator.pop(context, _controller.text.trim())
                      : null,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}