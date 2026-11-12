import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import '../1_foundations/tokens/ui_lab_tokens.dart';
import '../1_foundations/ui_lab_haptics.dart';

// ==============================================================================
// [MOLECULE] ComebakGameCard
// ------------------------------------------------------------------------------
// PURPOSE: The primary navigation card for selecting a game.
// DRY PRINCIPLE: Handles all states (Normal, Locked, Pressed) for ANY game.
// It does not know WHICH game it is; it receives the data via props.
// ==============================================================================
class ComebakGameCard extends StatefulWidget {
  // [PROPS] The text and icons passed in from the Organism (Home Grid).
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
  // [STATE] Tracks if the user's finger is currently pressing down on the card.
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    // [STATE LOGIC] Determine colors based on whether the game is locked.
    final cardColor = widget.isLocked ? ComebakColors.surfaceElevated : ComebakColors.surface;
    final borderColor = widget.isLocked 
        ? ComebakColors.border 
        : widget.accentColor.withValues(alpha: ComebakLayout.opacityBorderAccent);

    return GestureDetector(
      // [INTERACTION] Prevent press animations if the game is locked.
      onTapDown: (_) {
        if (!widget.isLocked) setState(() => _isPressed = true);
      },
      onTapUp: (_) {
        if (!widget.isLocked) setState(() => _isPressed = false);
      },
      onTapCancel: () {
        if (!widget.isLocked) setState(() => _isPressed = false);
      },
      onTap: () {
        // [HAPTICS] Trigger a light vibration on tap.
        ComebakHaptics.tap();
        widget.onTap();
      },
      child: AnimatedScale(
        // [MOTION] Scale down slightly when pressed for tactile feedback.
        scale: _isPressed ? ComebakLayout.opacityPressScale : 1.0,
        duration: ComebakMotion.press,
        child: AnimatedOpacity(
          // [STATE] Dim the card if it's locked.
          opacity: widget.isLocked ? ComebakLayout.opacityLocked : 1.0,
          duration: ComebakMotion.fade,
          child: Container(
            width: double.infinity, 
            // [DESIGN] The gradient border trick. Outer container with padding.
            padding: const EdgeInsets.all(ComebakLayout.borderGradient), 
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(ComebakLayout.radiusXl),
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [borderColor, ComebakColors.canvas],
              ),
            ),
            child: Container(
              // [DESIGN] The inner card surface.
              padding: const EdgeInsets.all(ComebakLayout.spaceLg),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(ComebakLayout.radiusInner),
              ),
              child: Row(
                children: [
                  // [ICON CONTAINER] Fixed size ensures text aligns perfectly across all cards.
                  SizedBox(
                    width: ComebakLayout.cardIconContainer, 
                    height: ComebakLayout.cardIconContainer, 
                    child: Center(
                      // [STATE] Show a lock icon if locked, otherwise show the 3D Atom.
                      child: widget.isLocked 
                          ? const Icon(LucideIcons.lock, size: ComebakLayout.spaceXl, color: ComebakColors.textSecondary)
                          : widget.iconWidget,
                    ),
                  ), 
                  const SizedBox(width: ComebakLayout.spaceLg),
                  
                  // [TEXT SECTION] Expanded fills the remaining space.
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.title, 
                          style: ComebakTypography.titleLarge.copyWith(
                            color: widget.isLocked ? ComebakColors.textSecondary : ComebakColors.textPrimary,
                          )
                        ),
                        const SizedBox(height: ComebakLayout.spaceXs),
                        Text(widget.subtitle, style: ComebakTypography.bodyMedium),
                      ],
                    ),
                  ),
                  
                  // [TRAILING ICON] The chevron hints at navigation.
                  const Icon(LucideIcons.chevron_right, color: ComebakColors.textSecondary),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}