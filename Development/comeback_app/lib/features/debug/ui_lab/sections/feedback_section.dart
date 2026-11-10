import 'package:flutter/material.dart';
import 'package:fossui/fossui.dart';
import '../../../../core/theme/app_theme.dart';
import '../widgets/lab_titles.dart';

// [COMPONENT] Feedback components: alerts, toasts, spinners, skeletons, badges.
class FeedbackSection extends StatelessWidget {
  const FeedbackSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // [COMPONENT] FossAlert — persistent inline callout.
        // [TOKEN MAPPING] variant -> role color tint; radius -> radii.md.
        const LabSubTitle('FossAlert'),
        const FossAlert(
          title: Text('Neutral'),
          description: Text('Plain bordered callout.'),
          variant: FossAlertVariant.neutral,
        ),
        const SizedBox(height: AppSpacing.sm),
        const FossAlert(
          title: Text('Success'),
          description: Text('Your score was saved.'),
          variant: FossAlertVariant.success,
        ),
        const SizedBox(height: AppSpacing.sm),
        const FossAlert(
          title: Text('Warning'),
          description: Text('You are offline. Showing cached data.'),
          variant: FossAlertVariant.warning,
        ),
        const SizedBox(height: AppSpacing.sm),
        const FossAlert(
          title: Text('Error'),
          description: Text('Could not connect.'),
          variant: FossAlertVariant.error,
        ),

        // [COMPONENT] showFossToast — transient overlay. Requires FossToaster at root (mounted in app.dart).
        const LabSubTitle('Toast (showFossToast)'),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            FossButton(
              variant: FossButtonVariant.outline,
              onPressed: () => showFossToast(
                context,
                const FossToast(
                  title: Text('Saved'),
                  description: Text('Changes saved.'),
                  variant: FossToastVariant.success,
                ),
              ),
              child: const Text('Success toast'),
            ),
            FossButton(
              variant: FossButtonVariant.outline,
              onPressed: () => showFossToast(
                context,
                const FossToast(
                  title: Text('Offline'),
                  description: Text('No internet.'),
                  variant: FossToastVariant.warning,
                ),
              ),
              child: const Text('Warning toast'),
            ),
            FossButton(
              variant: FossButtonVariant.outline,
              onPressed: () => showFossToast(
                context,
                const FossToast(
                  title: Text('Failed'),
                  description: Text('Could not complete.'),
                  variant: FossToastVariant.error,
                ),
              ),
              child: const Text('Error toast'),
            ),
          ],
        ),

        // [COMPONENT] FossSpinner — replaces CircularProgressIndicator.
        const LabSubTitle('FossSpinner'),
        const Row(
          children: [
            FossSpinner(size: 16),
            SizedBox(width: AppSpacing.sm),
            FossSpinner(size: 24),
            SizedBox(width: AppSpacing.sm),
            FossSpinner(size: 32),
          ],
        ),

        // [COMPONENT] FossSkeleton — loading shimmer for Stats screen.
        const LabSubTitle('FossSkeleton'),
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FossSkeleton(width: double.infinity, height: 16),
            SizedBox(height: AppSpacing.xs),
            FossSkeleton(width: 200, height: 16),
            SizedBox(height: AppSpacing.xs),
            FossSkeleton.circle(size: 40),
          ],
        ),

        // [COMPONENT] FossBadge — compact status pill.
        const LabSubTitle('FossBadge'),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: const [
            FossBadge(label: Text('Primary')),
            FossBadge(label: Text('Secondary'), variant: FossBadgeVariant.secondary),
            FossBadge(label: Text('Outline'), variant: FossBadgeVariant.outline),
            FossBadge(label: Text('Destructive'), variant: FossBadgeVariant.destructive),
            FossBadge(label: Text('Info'), variant: FossBadgeVariant.info),
            FossBadge(label: Text('Success'), variant: FossBadgeVariant.success),
            FossBadge(label: Text('Warning'), variant: FossBadgeVariant.warning),
            FossBadge(label: Text('Error'), variant: FossBadgeVariant.error),
          ],
        ),
      ],
    );
  }
}