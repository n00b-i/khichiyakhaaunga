import 'package:flutter/material.dart';
import '../../theme/app_tokens.dart';
import 'comebak_button.dart';

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.space24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: AppColors.textMuted.withValues(alpha: 0.2)),
            const SizedBox(height: AppSpacing.space16),
            Text(title, style: AppTextStyles.titleMedium, textAlign: TextAlign.center),
            const SizedBox(height: AppSpacing.space8),
            Text(subtitle, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textMuted), textAlign: TextAlign.center),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: AppSpacing.space24),
              ComebakButton(
                text: actionLabel!,
                variant: ComebakButtonVariant.ghost,
                onPressed: onAction,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
