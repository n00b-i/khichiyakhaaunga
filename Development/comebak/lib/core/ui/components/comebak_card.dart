import 'package:flutter/material.dart';
import '../../theme/app_tokens.dart';

class ComebakCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;

  const ComebakCard({super.key, required this.child, this.padding});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? const EdgeInsets.all(AppSpacing.space16),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(AppRadius.radiusMedium),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: child,
    );
  }
}
