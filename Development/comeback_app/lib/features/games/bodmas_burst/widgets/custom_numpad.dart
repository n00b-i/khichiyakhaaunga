import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_theme.dart';

class CustomNumpad extends StatelessWidget {
  final Function(int) onDigitTap;
  final VoidCallback onBackspace;
  final VoidCallback onClear;

  const CustomNumpad({
    super.key,
    required this.onDigitTap,
    required this.onBackspace,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(top: BorderSide(color: AppColors.border, width: 1)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildRow([1, 2, 3]),
          _buildRow([4, 5, 6]),
          _buildRow([7, 8, 9]),
          Row(
            children: [
              _buildKey(
                label: 'CLR',
                onTap: onClear,
                isAction: true,
              ),
              _buildKey(
                label: '0',
                onTap: () => onDigitTap(0),
              ),
              _buildKey(
                icon: Icons.backspace_outlined,
                onTap: onBackspace,
                isAction: true,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRow(List<int> digits) {
    return Row(
      children: digits.map((d) => _buildKey(label: d.toString(), onTap: () => onDigitTap(d))).toList(),
    );
  }

  Widget _buildKey({
    String? label,
    IconData? icon,
    required VoidCallback onTap,
    bool isAction = false,
  }) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xs),
        child: Material(
          color: isAction ? AppColors.surface : AppColors.background,
          borderRadius: BorderRadius.circular(AppRadius.card),
          child: InkWell(
            borderRadius: BorderRadius.circular(AppRadius.card),
            onTap: () {
              HapticFeedback.selectionClick();
              onTap();
            },
            child: Container(
              height: 64,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.border),
                borderRadius: BorderRadius.circular(AppRadius.card),
              ),
              child: icon != null
                  ? Icon(icon, color: AppColors.textPrimary, size: 24)
                  : Text(
                      label!,
                      style: AppTextStyles.hud.copyWith(
                        color: isAction ? AppColors.vibrantRed : AppColors.textPrimary,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
