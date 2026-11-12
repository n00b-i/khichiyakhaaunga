import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import '../1_foundations/tokens/ui_lab_tokens.dart';
import '../2_atoms/comebak_flame_3d.dart';
import '../2_atoms/comebak_xp_icon.dart';

// ==============================================================================
// [MOLECULE] ComebakStreakCard
// ------------------------------------------------------------------------------
// PURPOSE: Displays the user's streak status, total XP, and daily XP delta.
// ARCHITECTURE: Highly state-driven. It adapts its icon, colors, and XP section
// based on the props passed in (Active, At Risk, Broken, Milestones).
// DRY PRINCIPLE: It knows nothing about the backend. It is a pure UI component.
// ==============================================================================
class ComebakStreakCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  
  final String? totalXpText;
  final String? deltaXpText;
  final Color? deltaXpColor;

  const ComebakStreakCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    this.totalXpText,
    this.deltaXpText,
    this.deltaXpColor,
  });

  @override
  Widget build(BuildContext context) {
    final bool hasXp = totalXpText != null;
    final bool isFlame = icon == LucideIcons.flame;

    return Container(
      width: double.infinity, 
      padding: const EdgeInsets.all(ComebakLayout.spaceLg),
      decoration: BoxDecoration(
        color: ComebakColors.surface,
        borderRadius: BorderRadius.circular(ComebakLayout.radiusLg),
        border: Border.all(color: ComebakColors.border, width: ComebakLayout.borderThin),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center, 
            children: [
              SizedBox(
                width: ComebakLayout.cardIconContainer,
                height: ComebakLayout.cardIconContainer,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.all(ComebakLayout.spaceSm),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: ComebakColors.surfaceElevated, 
                    ),
                    child: isFlame 
                        ? const ComebakFlame3D(size: ComebakLayout.spaceXl)
                        : Icon(icon, color: iconColor, size: ComebakLayout.spaceXl),
                  ),
                ),
              ),
              const SizedBox(width: ComebakLayout.spaceLg),
              
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: ComebakTypography.titleMedium),
                    const SizedBox(height: ComebakLayout.spaceXs),
                    Text(subtitle, style: ComebakTypography.bodyMedium),
                  ],
                ),
              ),
              
              const Icon(LucideIcons.chevron_right, color: ComebakColors.textSecondary),
            ],
          ),
          
          if (hasXp) ...[
            const SizedBox(height: ComebakLayout.spaceLg),
            const Divider(
              height: ComebakLayout.borderThin, 
              color: ComebakColors.border, 
              thickness: ComebakLayout.borderThin
            ),
            const SizedBox(height: ComebakLayout.spaceLg),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    // [DESIGN FIX] Using Icons.bolt (Solid/Filled) instead of Lucide outline.
                    const ComebakXpIcon(
                      icon: Icons.bolt, 
                      color: ComebakColors.neonGreen,
                      size: ComebakLayout.spaceLg,
                    ),
                    const SizedBox(width: ComebakLayout.spaceSm),
                    Text(totalXpText!, style: ComebakTypography.titleMedium),
                  ],
                ),
                Text(
                  deltaXpText ?? '', 
                  style: ComebakTypography.labelSmall.copyWith(
                    color: deltaXpColor ?? ComebakColors.neonGreen,
                  ),
                ),
              ],
            ),
          ]
        ],
      ),
    );
  }
}