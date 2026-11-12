import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';

class PrimaryButton extends StatefulWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isLoading;

  const PrimaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
  });

  @override
  State<PrimaryButton> createState() => _PrimaryButtonState();
}

class _PrimaryButtonState extends State<PrimaryButton> {
  // Tracks the tap state to handle the 0.9 opacity press requirement
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // UI_SYSTEM.md §4: PrimaryButton must have a 0.9 opacity pressed state
      onTapDown: (_) => setState(() => _pressed = true),
      onTapCancel: () => setState(() => _pressed = false),
      onTapUp: (_) => setState(() => _pressed = false),
      onTap: widget.isLoading
          ? null
          : () {
              // UI_SYSTEM.md §5: Haptics are reserved for core interactions (like buttons)
              HapticFeedback.selectionClick();
              widget.onPressed();
            },
      child: AnimatedOpacity(
        opacity: _pressed ? 0.9 : 1.0,
        // Use the standard AppMotion duration (80ms) for button feedback
        duration: const Duration(milliseconds: AppMotion.wrongMs),
        child: Container(
          height: 52,
          width: double.infinity,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(AppRadius.pill),
          ),
          // Handle loading state (e.g., during auth or score submission)
          child: widget.isLoading
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    color: AppColors.background,
                    strokeWidth: 2,
                  ),
                )
              : Text(
                  widget.text,
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.background,
                    fontWeight: FontWeight.w700,
                  ),
                ),
        ),
      ),
    );
  }
}