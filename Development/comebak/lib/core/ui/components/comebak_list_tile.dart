import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/app_tokens.dart';

class ComebakListTile extends StatelessWidget {
  final Widget leading;
  final String title;
  final Widget? trailing;
  final VoidCallback? onTap;

  const ComebakListTile({
    super.key,
    required this.leading,
    required this.title,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // [RULE 3.6.1] Haptic selectionClick on onTapDown
    return GestureDetector(
      onTapDown: onTap != null ? (_) => HapticFeedback.selectionClick() : null,
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.space16),
        child: Row(
          children: [
            leading,
            const SizedBox(width: AppSpacing.space16),
            Expanded(child: Text(title, style: AppTextStyles.body)),
            ?trailing,
          ],
        ),
      ),
    );
  }
}
