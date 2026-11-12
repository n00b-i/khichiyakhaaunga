import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import '../1_foundations/tokens/ui_lab_tokens.dart';
import '../1_foundations/ui_lab_copy.dart';
import '../2_atoms/comebak_logo.dart';

// [ORGANISM] The Top Header section.
// Combines the Logo Atom and Typography. Includes the Profile Icon.
class ComebakHeader extends StatelessWidget {
  final VoidCallback onProfileTap;

  const ComebakHeader({super.key, required this.onProfileTap});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            const ComebakLogo(),
            const SizedBox(width: ComebakLayout.spaceSm),
            Text(ComebakCopy.brand, style: ComebakTypography.brand),
          ],
        ),
        GestureDetector(
          onTap: onProfileTap,
          child: const Icon(
            LucideIcons.user, 
            color: ComebakColors.textPrimary, 
            size: ComebakLayout.spaceXl,
          ),
        ),
      ],
    );
  }
}