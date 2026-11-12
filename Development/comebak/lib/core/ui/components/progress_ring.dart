import 'package:flutter/material.dart';
import '../../theme/app_tokens.dart';

class ProgressRing extends StatelessWidget {
  final double value; // 0.0 to 1.0
  final Color? color;

  const ProgressRing({
    super.key,
    required this.value,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 48,
      height: 48,
      child: CircularProgressIndicator(
        value: value,
        strokeWidth: 6,
        strokeCap: StrokeCap.round,
        backgroundColor: AppColors.borderSubtle,
        valueColor: AlwaysStoppedAnimation<Color>(color ?? AppColors.primaryAccent),
      ),
    );
  }
}
