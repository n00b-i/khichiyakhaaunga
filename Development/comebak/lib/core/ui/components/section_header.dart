import 'package:flutter/material.dart';
import '../../theme/app_tokens.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  const SectionHeader(this.title, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        top: AppSpacing.space32,
        bottom: AppSpacing.space12,
      ),
      child: Text(
        title.toUpperCase(),
        style: AppTextStyles.labelSmall,
      ),
    );
  }
}
