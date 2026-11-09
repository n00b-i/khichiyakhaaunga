import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_theme.dart';

class ComingSoonScreen extends StatelessWidget {
  final String? gameName;

  const ComingSoonScreen({super.key, this.gameName});

  @override
  Widget build(BuildContext context) {
    final body = (gameName == null || gameName!.isEmpty)
        ? 'This game is being built. Check back soon.'
        : '$gameName is being built. Check back soon.';

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.construction_outlined,
                size: AppSizes.iconLg,
                color: AppColors.border,
              ),
              SizedBox(height: AppSpacing.lg),
              Text(
                'Coming soon',
                style: AppTextStyles.display,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: AppSpacing.md),
              Text(
                body,
                style: AppTextStyles.body.copyWith(
                  color: AppColors.textPrimary.withValues(alpha: 0.6),
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: AppSpacing.xl),
              TextButton(
                onPressed: () {
                  HapticFeedback.selectionClick();
                  Navigator.of(context).pop();
                },
                child: Text(
                  'Back',
                  style: AppTextStyles.body.copyWith(color: AppColors.primary),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
