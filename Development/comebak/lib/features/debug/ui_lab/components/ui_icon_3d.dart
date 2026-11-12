import 'package:flutter/material.dart';
import '../../../../core/theme/tokens/ui_lab_colors.dart';
import '../tokens/ui_lab_tokens.dart';

class UiLabIcon3D extends StatelessWidget {
  final IconData primaryIcon;
  final IconData secondaryIcon;
  final Color color;

  const UiLabIcon3D({
    super.key,
    required this.primaryIcon,
    required this.secondaryIcon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Secondary Block
          Transform.translate(
            offset: UiLabOffsets.iconSecondary,
            child: Transform.rotate(
              angle: UiLabOffsets.iconSecondaryRotation,
              child: Container(
                // Fixed: iconSecondarySize -> iconSecondaryBox
                width: UiLabSizes.iconSecondaryBox, 
                height: UiLabSizes.iconSecondaryBox,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      color.withValues(alpha: UiLabOpacities.gradientStart), 
                      color.withValues(alpha: UiLabOpacities.gradientEnd)
                    ],
                  ),
                  borderRadius: BorderRadius.circular(UiLabSizes.iconSecondaryRadius),
                  border: Border.all(color: UiLabColors.border, width: UiLabSizes.borderThin),
                ),
                child: Icon(secondaryIcon, color: UiLabColors.textSecondary, size: UiLabSizes.iconSecondary),
              ),
            ),
          ),
          // Primary Block
          Transform.translate(
            offset: UiLabOffsets.iconPrimary,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Transform.translate(
                  offset: UiLabOffsets.iconShadow,
                  child: Container(
                    // Fixed: iconPrimarySize -> iconPrimaryBox
                    width: UiLabSizes.iconPrimaryBox, 
                    height: UiLabSizes.iconPrimaryBox,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: UiLabOpacities.shadow), 
                      borderRadius: BorderRadius.circular(UiLabSizes.iconPrimaryRadius),
                    ),
                  ),
                ),
                Container(
                  // Fixed: iconPrimarySize -> iconPrimaryBox
                  width: UiLabSizes.iconPrimaryBox,
                  height: UiLabSizes.iconPrimaryBox,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        color.withValues(alpha: UiLabOpacities.gradientStart), 
                        color.withValues(alpha: UiLabOpacities.gradientEnd)
                      ],
                    ),
                    borderRadius: BorderRadius.circular(UiLabSizes.iconPrimaryRadius),
                    border: Border.all(color: UiLabColors.border, width: UiLabSizes.borderThick),
                    boxShadow: [
                      BoxShadow(color: color.withValues(alpha: UiLabOpacities.iconBg), blurRadius: UiLabOffsets.iconGlowBlur)
                    ],
                  ),
                  child: Icon(primaryIcon, color: Colors.white, size: UiLabSizes.iconPrimary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}