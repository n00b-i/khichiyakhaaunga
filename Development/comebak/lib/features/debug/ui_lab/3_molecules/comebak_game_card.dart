import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import '../1_foundations/tokens/ui_lab_tokens.dart';
import '../1_foundations/ui_lab_haptics.dart';

class ComebakGameCard extends StatefulWidget {
  final String title;
  final String subtitle;
  final Widget iconWidget;
  final Color accentColor;
  final bool isLocked;
  final VoidCallback onTap;

  const ComebakGameCard({
    super.key,
    required this.title, 
    required this.subtitle, 
    required this.iconWidget,
    required this.accentColor,
    required this.onTap,
    this.isLocked = false,
  });

  @override
  State<ComebakGameCard> createState() => _ComebakGameCardState();
}

class _ComebakGameCardState extends State<ComebakGameCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final cardColor = widget.isLocked ? ComebakColors.surfaceElevated : ComebakColors.surface;
    final borderColor = widget.isLocked ? ComebakColors.border : widget.accentColor.withValues(alpha: ComebakLayout.opacityBorderAccent);

    return GestureDetector(
      onTapDown: (_) { if (!widget.isLocked) setState(() => _isPressed = true); },
      onTapUp: (_) { if (!widget.isLocked) setState(() => _isPressed = false); },
      onTapCancel: () { if (!widget.isLocked) setState(() => _isPressed = false); },
      onTap: () {
        ComebakHaptics.tap();
        widget.onTap();
      },
      child: AnimatedScale(
        scale: _isPressed ? ComebakLayout.opacityPressScale : 1.0,
        duration: ComebakMotion.press,
        child: AnimatedOpacity(
          opacity: widget.isLocked ? ComebakLayout.opacityLocked : 1.0,
          duration: ComebakMotion.fade,
          child: Container(
            // [LAYOUT] Fixed height for grid alignment
            height: ComebakLayout.gameCardHeight,
            padding: const EdgeInsets.all(ComebakLayout.borderGradient), 
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(ComebakLayout.radiusXl),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [borderColor, ComebakColors.canvas],
              ),
            ),
            child: Container(
              padding: const EdgeInsets.all(ComebakLayout.spaceLg),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(ComebakLayout.radiusInner),
              ),
              // [LAYOUT FIX] Vertical Column instead of horizontal Row
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Icon Area
                  Expanded(
                    child: Center(
                      child: widget.isLocked 
                          ? const Icon(LucideIcons.lock, size: ComebakLayout.avatarSize, color: ComebakColors.textSecondary)
                          : widget.iconWidget,
                    ),
                  ),
                  const SizedBox(height: ComebakLayout.spaceSm),
                  
                  // Text Area
                  Text(
                    widget.title, 
                    style: ComebakTypography.titleLarge.copyWith(
                      color: widget.isLocked ? ComebakColors.textSecondary : ComebakColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: ComebakLayout.spaceXs),
                  Text(
                    widget.subtitle, 
                    style: ComebakTypography.bodyMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}