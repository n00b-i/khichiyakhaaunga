import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import '../1_foundations/tokens/ui_lab_tokens.dart';
import '../1_foundations/ui_lab_copy.dart';
// [IMPORT FIX] Pulling from the layers directory where the 3D logo lives
import '../5_catalog/auth_variants/layers/comebak_clay_logo.dart';

// ==============================================================================
// [ORGANISM] ComebakHeader
// ------------------------------------------------------------------------------
// PURPOSE: The top header section combining the 3D Logo and Typography.
// ==============================================================================
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
            // [LOGO SWAP] Replaced the old flat logo with the 3D Clay Logo
            const SizedBox(
              width: ComebakLayout.spaceXxl,
              height: ComebakLayout.spaceXxl,
              child: FittedBox(
                fit: BoxFit.contain,
                child: ComebakClayLogo(pose: 4, time: 0, enableSparks: false),
              ),
            ),
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
