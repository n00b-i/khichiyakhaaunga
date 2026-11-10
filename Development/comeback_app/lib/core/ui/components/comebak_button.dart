import 'package:flutter/material.dart';
import '../../dev/dev_haptics.dart';
import '../../theme/app_tokens.dart';

enum ComebakButtonVariant { primary, secondary, ghost, danger }

class ComebakButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final ComebakButtonVariant variant;
  final bool isLoading;

  const ComebakButton({
    super.key,
    required this.text,
    this.onPressed,
    this.variant = ComebakButtonVariant.primary,
    this.isLoading = false,
  });

  @override
  State<ComebakButton> createState() => _ComebakButtonState();
}

class _ComebakButtonState extends State<ComebakButton> {
  bool _isPressed = false;

  void _handleTapDown(TapDownDetails details) {
    if (widget.onPressed == null || widget.isLoading) return;
    setState(() => _isPressed = true);
    DevHaptics.selectionClick(source: 'ComebakButton');
  }

  void _handleTapUp(TapUpDetails details) {
    if (widget.onPressed == null || widget.isLoading) return;
    setState(() => _isPressed = false);
  }

  void _handleTapCancel() {
    if (widget.onPressed == null || widget.isLoading) return;
    setState(() => _isPressed = false);
  }

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color fgColor;
    BorderSide? borderSide;

    switch (widget.variant) {
      case ComebakButtonVariant.primary:
        bgColor = AppColors.primaryAccent;
        fgColor = AppColors.onPrimary;
        break;
      case ComebakButtonVariant.secondary:
        bgColor = Colors.transparent;
        fgColor = AppColors.textPrimary;
        borderSide = const BorderSide(color: AppColors.borderSubtle);
        break;
      case ComebakButtonVariant.ghost:
        bgColor = Colors.transparent;
        fgColor = AppColors.textSecondary;
        break;
      case ComebakButtonVariant.danger:
        bgColor = AppColors.danger;
        fgColor = AppColors.onPrimary;
        break;
    }

    final isDisabled = widget.onPressed == null || widget.isLoading;

    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      onTap: isDisabled ? null : widget.onPressed,
      child: AnimatedScale(
        scale: _isPressed ? 0.96 : 1.0,
        duration: AppMotion.durationFast,
        curve: AppMotion.curvePress,
        child: AnimatedOpacity(
          opacity: isDisabled ? 0.4 : 1.0,
          duration: AppMotion.durationFast,
          child: Container(
            height: 52,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(AppRadius.radiusMedium),
              border: borderSide != null ? Border.fromBorderSide(borderSide) : null,
            ),
            alignment: Alignment.center,
            child: widget.isLoading
                ? SizedBox(
                    width: AppSizes.iconSm,
                    height: AppSizes.iconSm,
                    child: CircularProgressIndicator(color: fgColor, strokeWidth: 2),
                  )
                : Text(
                    widget.text,
                    style: AppTextStyles.titleMedium.copyWith(color: fgColor),
                  ),
          ),
        ),
      ),
    );
  }
}
