import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/app_tokens.dart';

class GameCard extends StatefulWidget {
  final String title;
  final String description;
  final IconData icon;
  final Color accentColor;
  final VoidCallback onTap;

  const GameCard({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    required this.accentColor,
    required this.onTap,
  });

  @override
  State<GameCard> createState() => _GameCardState();
}

class _GameCardState extends State<GameCard> {
  bool _isPressed = false;

  void _handleTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
    HapticFeedback.selectionClick();
  }

  void _handleTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
  }

  void _handleTapCancel() {
    setState(() => _isPressed = false);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _isPressed ? 0.98 : 1.0,
        duration: AppMotion.durationFast,
        curve: AppMotion.curvePress,
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.space16),
          decoration: BoxDecoration(
            color: AppColors.surfaceElevated,
            borderRadius: BorderRadius.circular(AppRadius.radiusMedium),
            border: Border.all(
              color: _isPressed ? AppColors.borderSubtle : Colors.transparent,
            ),
          ),
          child: Row(
            children: [
              // Left 4px accent bar
              Container(
                width: 4,
                height: 40,
                decoration: BoxDecoration(
                  color: widget.accentColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: AppSpacing.space16),
              // Icon
              Icon(widget.icon, color: widget.accentColor, size: 32),
              const SizedBox(width: AppSpacing.space16),
              // Text
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(widget.title, style: AppTextStyles.titleMedium),
                    const SizedBox(height: AppSpacing.space4),
                    Text(widget.description, style: AppTextStyles.bodyMedium),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
