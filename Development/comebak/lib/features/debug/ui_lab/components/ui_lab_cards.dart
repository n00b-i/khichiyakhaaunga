import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import '../../../../core/theme/tokens/ui_lab_colors.dart';
import '../tokens/ui_lab_tokens.dart';

// ==========================================
// STREAK CARD (Aligned & Tokenized)
// ==========================================
class UiLabStreakCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  
  // [NAMING] Renamed for clarity.
  final String? totalXpText; // e.g. "1,250 XP"
  final String? deltaXpText; // e.g. "+150 XP Today"
  final Color? deltaXpColor;

  const UiLabStreakCard({
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

    return Container(
      width: double.infinity, 
      padding: const EdgeInsets.all(UiLabSpacing.lg),
      decoration: BoxDecoration(
        color: UiLabColors.surface,
        borderRadius: BorderRadius.circular(UiLabRadii.card),
        border: Border.all(color: UiLabColors.border, width: UiLabSizes.borderThin),
      ),
      child: Column(
        children: [
          // --- TOP ROW ---
          Row(
            // [ALIGNMENT FIX] Center aligns the icon with the text block
            crossAxisAlignment: CrossAxisAlignment.center, 
            children: [
              // [ALIGNMENT FIX] Fixed 60x60 box to perfectly match GameCard
              SizedBox(
                width: UiLabSizes.cardIconContainer,
                height: UiLabSizes.cardIconContainer,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.all(UiLabSizes.iconCirclePadding),
                    decoration: BoxDecoration(
                      color: iconColor.withValues(alpha: UiLabOpacities.iconBg),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, color: iconColor, size: UiLabSizes.iconPrimary),
                  ),
                ),
              ),
              const SizedBox(width: UiLabSpacing.lg),
              
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: UiLabTypography.titleMedium),
                    const SizedBox(height: UiLabSpacing.xs),
                    Text(subtitle, style: UiLabTypography.bodyMedium),
                  ],
                ),
              ),
              
              const Icon(LucideIcons.chevron_right, color: UiLabColors.textSecondary),
            ],
          ),
          
          // --- BOTTOM ROW (XP) ---
          if (hasXp) ...[
            const SizedBox(height: UiLabSpacing.lg),
            Divider(height: UiLabSizes.dividerWidth, color: UiLabColors.border, thickness: UiLabSizes.borderThin),
            const SizedBox(height: UiLabSpacing.lg),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(LucideIcons.zap, color: UiLabColors.neonOrange, size: UiLabSizes.iconSecondary),
                    const SizedBox(width: UiLabSpacing.sm),
                    Text(totalXpText!, style: UiLabTypography.titleMedium),
                  ],
                ),
                Text(
                  deltaXpText ?? '', 
                  style: UiLabTypography.labelSmall.copyWith(color: deltaXpColor ?? UiLabColors.neonGreen),
                ),
              ],
            ),
          ]
        ],
      ),
    );
  }
}

// ==========================================
// GAME CARD (Aligned & Tokenized)
// ==========================================
class UiLabGameCard extends StatefulWidget {
  final String title;
  final String subtitle;
  final Widget iconWidget;
  final Color accentColor;
  final bool isLocked;

  const UiLabGameCard({
    super.key,
    required this.title, 
    required this.subtitle, 
    required this.iconWidget,
    required this.accentColor,
    this.isLocked = false,
  });

  @override
  State<UiLabGameCard> createState() => _UiLabGameCardState();
}

class _UiLabGameCardState extends State<UiLabGameCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final cardColor = widget.isLocked ? UiLabColors.surfaceElevated : UiLabColors.surface;
    final borderColor = widget.isLocked ? UiLabColors.border : widget.accentColor.withValues(alpha: UiLabOpacities.borderAccent);

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? UiLabOpacities.pressScale : 1.0,
        duration: UiLabDurations.press,
        child: AnimatedOpacity(
          opacity: widget.isLocked ? UiLabOpacities.locked : 1.0,
          duration: UiLabDurations.fade,
          child: Container(
            width: double.infinity, 
            padding: const EdgeInsets.all(UiLabSizes.cardGradientBorder), 
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(UiLabRadii.gameCard),
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [borderColor, UiLabColors.canvas],
              ),
            ),
            child: Container(
              padding: const EdgeInsets.all(UiLabSpacing.lg),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(UiLabRadii.gameCardInner),
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: UiLabSizes.cardIconContainer, 
                    height: UiLabSizes.cardIconContainer, 
                    child: Center(
                      child: widget.isLocked 
                          ? const Icon(LucideIcons.lock, size: UiLabSizes.lockIcon, color: UiLabColors.textSecondary)
                          : widget.iconWidget,
                    ),
                  ), 
                  const SizedBox(width: UiLabSpacing.lg),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.title, 
                          style: UiLabTypography.titleLarge.copyWith(
                            color: widget.isLocked ? UiLabColors.textSecondary : Colors.white,
                          )
                        ),
                        const SizedBox(height: UiLabSpacing.xs),
                        Text(widget.subtitle, style: UiLabTypography.bodyMedium),
                      ],
                    ),
                  ),
                  const Icon(LucideIcons.chevron_right, color: UiLabColors.textSecondary),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}