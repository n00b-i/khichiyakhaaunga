import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class FloatingNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTabSelected;

  const FloatingNavBar({
    super.key,
    required this.currentIndex,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    // S-04 V1/V2: Floating pill UI centered at the bottom.
    return Center(
      child: Container(
        height: AppSizes.islandHeight,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.pill),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // S-04 V3/V4: 3 tabs for release (no debug UI tab here).
            _NavItem(
              icon: Icons.home_outlined,
              activeIcon: Icons.home,
              label: 'Home',
              isActive: currentIndex == 0,
              onTap: () => onTabSelected(0),
            ),
            _NavItem(
              icon: Icons.bar_chart_outlined,
              activeIcon: Icons.bar_chart,
              label: 'Stats',
              isActive: currentIndex == 1,
              onTap: () => onTabSelected(1),
            ),
            _NavItem(
              icon: Icons.person_outline,
              activeIcon: Icons.person,
              label: 'Profile',
              isActive: currentIndex == 2,
              onTap: () => onTabSelected(2),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // S-04 V5/V6: Active uses Groww Green, Inactive uses 60% opacity text.
    final color = isActive
        ? AppColors.primary
        : AppColors.textPrimary.withValues(alpha: 0.6);

    return GestureDetector(
      onTap: onTap,
      // Ensures the entire 48x48 tap target is clickable (S-04 I1).
      behavior: HitTestBehavior.opaque,
      child: Semantics(
        button: true,
        label: label,
        selected: isActive,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.xs,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isActive ? activeIcon : icon,
                color: color,
                size: AppSizes.tabIcon,
              ),
              const SizedBox(height: AppSpacing.xxs),
              Text(
                label,
                style: AppTextStyles.body.copyWith(
                  color: color,
                  fontSize: 12, // Slightly smaller to fit the pill
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
