import 'package:flutter/material.dart';
import '../../theme/app_tokens.dart';

class ComebakAvatar extends StatelessWidget {
  final String? name;

  const ComebakAvatar({super.key, this.name});

  // [RULE 6.3.1] Avatar 56x56, primaryAccent background, initial w700 white.
  String _getInitial() {
    if (name == null || name!.trim().isEmpty) return '?';
    return name!.trim()[0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: AppSizes.avatar,
      height: AppSizes.avatar,
      decoration: const BoxDecoration(
        color: AppColors.primaryAccent,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        _getInitial(),
        style: AppTextStyles.titleLarge.copyWith(
          color: AppColors.onPrimary,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
