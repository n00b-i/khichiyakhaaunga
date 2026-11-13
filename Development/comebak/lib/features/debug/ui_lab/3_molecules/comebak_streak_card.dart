import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import '../1_foundations/tokens/ui_lab_tokens.dart';
import '../2_atoms/comebak_flame_3d.dart';
import '../2_atoms/comebak_xp_icon.dart';

// ==============================================================================
// [MOLECULE] ComebakStreakCard
// ------------------------------------------------------------------------------
// PURPOSE: Renders the streak status, title, subtitle, and XP data.
// FIXES APPLIED:
// - Added a right-aligned chevron icon in the header to indicate clickability.
// ==============================================================================
class ComebakStreakCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final String? totalXpText;
  final Color? totalXpColor; // Controls the color of the XP text
  final Color? totalXpIconColor; // Controls the color of the 3D XP icon
  final String? deltaXpText;
  final Color? deltaXpColor;

  const ComebakStreakCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    this.totalXpText,
    this.totalXpColor,
    this.totalXpIconColor,
    this.deltaXpText,
    this.deltaXpColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(ComebakLayout.spaceLg),
      decoration: BoxDecoration(
        color: ComebakColors.surface,
        borderRadius: BorderRadius.circular(ComebakLayout.radiusLg),
        border: Border.all(
          color: ComebakColors.border,
          width: ComebakLayout.borderThin,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // [ICON] 3D Flame vs Flat Lucide
              SizedBox(
                width: ComebakLayout.iconBoxPrimary,
                height: ComebakLayout.iconBoxPrimary,
                child: Center(
                  child: icon == LucideIcons.flame
                      ? const ComebakFlame3D(size: ComebakLayout.spaceXl)
                      : Icon(
                          icon,
                          color: iconColor,
                          size: ComebakLayout.spaceXl,
                        ),
                ),
              ),
              const SizedBox(width: ComebakLayout.spaceLg),
              // [TEXT] Title & Subtitle
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: ComebakTypography.titleMedium.copyWith(
                        color: ComebakColors.textPrimary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: ComebakLayout.spaceXs),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: ComebakTypography.bodyMedium.copyWith(
                        color: ComebakColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              // [AFFORDANCE] Right Chevron
              // Indicates the card is tappable and navigates to Stats.
              const SizedBox(width: ComebakLayout.spaceSm),
              const Icon(
                LucideIcons.chevron_right,
                color: ComebakColors.textSecondary,
                size: ComebakLayout.spaceXl,
              ),
            ],
          ),

          // [XP ROW] Only shows if totalXpText is provided
          if (totalXpText != null) ...[
            const SizedBox(height: ComebakLayout.spaceLg),
            Container(height: 1, color: ComebakColors.border),
            const SizedBox(height: ComebakLayout.spaceMd),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    // [XP ICON] Custom 3D XP Icon
                    ComebakXpIcon(
                      icon: Icons.bolt,
                      color: totalXpIconColor ?? ComebakColors.neonGreen,
                      size: ComebakLayout.spaceLg,
                    ),
                    const SizedBox(width: ComebakLayout.spaceSm),
                    // [XP TEXT]
                    Text(
                      totalXpText!,
                      style: ComebakTypography.titleMedium.copyWith(
                        color: totalXpColor ?? ComebakColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                if (deltaXpText != null)
                  Text(
                    deltaXpText!,
                    style: ComebakTypography.labelSmall.copyWith(
                      color: deltaXpColor ?? ComebakColors.textSecondary,
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
