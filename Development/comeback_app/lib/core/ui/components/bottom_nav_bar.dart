import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/app_tokens.dart';

class NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  NavItem({required this.icon, required this.activeIcon, required this.label});
}

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final List<NavItem> items;
  final ValueChanged<int> onTabSelected;

  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.items,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return Padding(
      padding: EdgeInsets.only(
        left: AppSpacing.space24,
        right: AppSpacing.space24,
        bottom: bottomInset > 0 ? bottomInset : AppSpacing.space16,
      ),
      child: Container(
        height: 64,
        decoration: BoxDecoration(
          color: AppColors.surfaceElevated,
          borderRadius: BorderRadius.circular(AppRadius.radiusLarge),
          border: Border.all(color: AppColors.borderSubtle),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(items.length, (index) {
            final isActive = currentIndex == index;
            final item = items[index];
            return GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                onTabSelected(index);
              },
              behavior: HitTestBehavior.opaque,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isActive ? item.activeIcon : item.icon,
                    color: isActive ? AppColors.primaryAccent : AppColors.textMuted,
                    size: 24,
                  ),
                  const SizedBox(height: AppSpacing.space4),
                  Text(
                    item.label,
                    style: AppTextStyles.labelSmall.copyWith(
                      color: isActive ? AppColors.primaryAccent : AppColors.textMuted,
                      letterSpacing: 0,
                    ),
                  ),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }
}
