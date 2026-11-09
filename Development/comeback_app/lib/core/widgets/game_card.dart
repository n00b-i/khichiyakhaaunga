import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';

class GameCard extends StatefulWidget {
  final String title;
  final String? description;
  final IconData icon;
  final Color accentColor;
  final VoidCallback onTap;
  final int debounceMs;

  const GameCard({
    super.key,
    required this.title,
    this.description,
    required this.icon,
    required this.accentColor,
    required this.onTap,
    this.debounceMs = 300,
  });

  @override
  State<GameCard> createState() => _GameCardState();
}

class _GameCardState extends State<GameCard> {
  DateTime? _lastTap;
  bool _pressed = false;

  void _handleTap() {
    final now = DateTime.now();
    if (_lastTap != null &&
        now.difference(_lastTap!).inMilliseconds < widget.debounceMs) {
      return;
    }
    _lastTap = now;
    HapticFeedback.selectionClick();
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: widget.description == null
          ? widget.title
          : '${widget.title}. ${widget.description}',
      child: GestureDetector(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapCancel: () => setState(() => _pressed = false),
        onTapUp: (_) => setState(() => _pressed = false),
        onTap: _handleTap,
        child: Opacity(
          opacity: _pressed ? 0.9 : 1.0,
          child: Container(
            padding: EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadius.card),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: AppSizes.iconLg,
                  height: AppSizes.iconLg,
                  child: Center(
                    child: Icon(
                      widget.icon,
                      color: widget.accentColor,
                      size: AppSizes.iconMd,
                    ),
                  ),
                ),
                SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        widget.title,
                        style: AppTextStyles.body,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (widget.description != null) ...[
                        SizedBox(height: AppSpacing.xxs),
                        Text(
                          widget.description!,
                          style: AppTextStyles.body.copyWith(
                            color: AppColors.textPrimary
                                .withValues(alpha: 0.6),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                SizedBox(width: AppSpacing.xs),
                Icon(
                  Icons.chevron_right,
                  color: AppColors.border,
                  size: AppSizes.iconSm,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
