import 'package:flutter/material.dart';
import 'package:fossui/fossui.dart';
import '../widgets/lab_titles.dart';

// [COMPONENT] Overlays: Dialog (dismissible) and AlertDialog (requires explicit action).
// [NOTE] No AppColors/AppSpacing used in this file because fossui dialogs read from FossThemeData.
class OverlaysSection extends StatelessWidget {
  const OverlaysSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // [COMPONENT] FossDialog — dismissible dialog. Replaces Material AlertDialog for form dialogs.
        const LabSubTitle('FossDialog (showFossDialog)'),
        FossButton(
          variant: FossButtonVariant.outline,
          onPressed: () {
            showFossDialog<void>(
              context: context,
              builder: (context) => FossDialog(
                title: const Text('Edit name'),
                description: const Text('Change your display name.'),
                content: const FossTextField(
                  label: 'New name',
                  hintText: 'deevanshu_guru',
                ),
                actions: [
                  FossButton(
                    variant: FossButtonVariant.ghost,
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  FossButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Save'),
                  ),
                ],
              ),
            );
          },
          child: const Text('Open dialog'),
        ),

        // [COMPONENT] FossAlertDialog — blocking confirmation. Replaces Material AlertDialog for logout.
        const LabSubTitle('FossAlertDialog (showFossAlertDialog)'),
        FossButton(
          variant: FossButtonVariant.destructive,
          onPressed: () async {
            final confirmed = await showFossAlertDialog<bool>(
              context: context,
              builder: (context) => FossAlertDialog(
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
            // [FIX] Guard against use_build_context_synchronously after await.
            if (!context.mounted) return;
            if (confirmed == true) {
              showFossToast(
                context,
                const FossToast(
                  title: Text('Logged out'),
                  variant: FossToastVariant.success,
                ),
              );
            }
          },
          child: const Text('Confirm logout'),
        ),
      ],
    );
  }
}