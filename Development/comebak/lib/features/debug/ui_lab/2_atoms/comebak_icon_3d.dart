import 'package:flutter/material.dart';
import '../1_foundations/tokens/ui_lab_tokens.dart';

// [ATOM] The pseudo-3D icon used in GameCards.
// [DRY RULE] Presentational only. Receives icons and color to be reused across all games.
class ComebakIcon3D extends StatelessWidget {
  final IconData primaryIcon;
  final IconData secondaryIcon;
  final Color color;

  const ComebakIcon3D({
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
          // [LAYER 1: SECONDARY BLOCK]
          // Floating behind to create isometric illusion.
          Transform.translate(
            offset: ComebakLayout.offsetIconSecondary,
            child: Transform.rotate(
              // [RULE 1] Angle pulled from Token.
              angle: ComebakLayout.iconRotationAngle,
              child: Container(
                width: ComebakLayout.iconBoxSecondary, 
                height: ComebakLayout.iconBoxSecondary,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      color.withValues(alpha: ComebakLayout.opacityGradientStart), 
                      color.withValues(alpha: ComebakLayout.opacityGradientEnd)
                    ],
                  ),
                  borderRadius: BorderRadius.circular(ComebakLayout.radiusSm),
                  border: Border.all(color: ComebakColors.border, width: ComebakLayout.borderThin),
                ),
                child: Icon(
                  secondaryIcon, 
                  color: ComebakColors.textSecondary, 
                  size: ComebakLayout.spaceMd 
                ),
              ),
            ),
          ),
          
          // [LAYER 2: PRIMARY BLOCK]
          Transform.translate(
            offset: ComebakLayout.offsetIconPrimary,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // [LAYER 2A: SHADOW]
                Transform.translate(
                  offset: ComebakLayout.offsetIconShadow,
                  child: Container(
                    width: ComebakLayout.iconBoxPrimary, 
                    height: ComebakLayout.iconBoxPrimary,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: ComebakLayout.opacityShadow), 
                      borderRadius: BorderRadius.circular(ComebakLayout.radiusMd),
                    ),
                  ),
                ),
                // [LAYER 2B: SURFACE]
                Container(
                  width: ComebakLayout.iconBoxPrimary,
                  height: ComebakLayout.iconBoxPrimary,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        color.withValues(alpha: ComebakLayout.opacityGradientStart), 
                        color.withValues(alpha: ComebakLayout.opacityGradientEnd)
                      ],
                    ),
                    borderRadius: BorderRadius.circular(ComebakLayout.radiusMd),
                    border: Border.all(color: ComebakColors.border, width: ComebakLayout.borderThick),
                    boxShadow: [
                      BoxShadow(
                        color: color.withValues(alpha: ComebakLayout.opacityIconBg), 
                        blurRadius: ComebakMotion.blurRadius,
                      )
                    ],
                  ),
                  child: Icon(
                    primaryIcon, 
                    color: ComebakColors.textPrimary, 
                    size: ComebakLayout.spaceXl 
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}