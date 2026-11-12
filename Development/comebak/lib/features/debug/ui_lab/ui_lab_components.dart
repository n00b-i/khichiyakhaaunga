import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/tokens/ui_lab_colors.dart';

// ==========================================
// 1. STREAK CARD COMPONENT
// ==========================================
// [ARCHITECTURE] This is a pure "dumb" UI component. It holds no state 
// and knows nothing about the business logic. It just renders whatever 
// strings and icons are passed into it.
class UiLabStreakCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  
  // [UX] If xpText is null, the left section stretches full width automatically.
  final String? xpText;
  final String? xpDelta;
  final Color? xpDeltaColor;

  const UiLabStreakCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    this.xpText,
    this.xpDelta,
    this.xpDeltaColor,
  });

  @override
  Widget build(BuildContext context) {
    final bool hasXp = xpText != null;

    return Container(
      width: double.infinity, 
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: UiLabColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: UiLabColors.border),
      ),
      child: Row(
        children: [
          // [DESIGN] Icon in a soft circular background to indicate state type.
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 16),
          
          // [LAYOUT] Expanded forces this column to take all remaining space.
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.urbanist(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
                const SizedBox(height: 2),
                Text(subtitle, style: GoogleFonts.urbanist(fontSize: 13, fontWeight: FontWeight.w600, color: UiLabColors.textSecondary)),
              ],
            ),
          ),
          
          // [LAYOUT] Right section only renders if hasXp is true.
          if (hasXp) ...[
            Container(
              height: 40,
              width: 1,
              color: UiLabColors.border,
              margin: const EdgeInsets.symmetric(horizontal: 16),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(xpText!, style: GoogleFonts.urbanist(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
                const SizedBox(height: 2),
                Text(xpDelta ?? '', style: GoogleFonts.urbanist(fontSize: 12, fontWeight: FontWeight.w600, color: xpDeltaColor ?? UiLabColors.neonGreen)),
              ],
            ),
          ]
        ],
      ),
    );
  }
}

// ==========================================
// 2. GAME CARD COMPONENT (1 Column Layout)
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
  // [INTERACTION] Local state to track if the user is currently pressing the card.
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final cardColor = widget.isLocked ? UiLabColors.surfaceElevated : UiLabColors.surface;
    final textColor = widget.isLocked ? UiLabColors.textSecondary : Colors.white;
    final borderColor = widget.isLocked ? UiLabColors.border : widget.accentColor.withValues(alpha: 0.4);

    return GestureDetector(
      // [UX] Micro-interactions: Scale down slightly when pressed for tactile feel.
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: () {},
      child: AnimatedScale(
        scale: _isPressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: AnimatedOpacity(
          // [UX] Locked cards are dimmed to 50% opacity.
          opacity: widget.isLocked ? 0.5 : 1.0,
          duration: const Duration(milliseconds: 200),
          child: Container(
            width: double.infinity, 
            padding: const EdgeInsets.all(1.5), 
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [borderColor, UiLabColors.canvas],
              ),
            ),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(18.5),
              ),
              // [LAYOUT] Row instead of Column, since it's a 1-column full-width list.
              child: Row(
                children: [
                  SizedBox(
                    width: 60, 
                    height: 60, 
                    child: Center(
                      child: widget.isLocked 
                          ? const Icon(LucideIcons.lock, size: 28, color: UiLabColors.textSecondary)
                          : widget.iconWidget,
                    ),
                  ), 
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.title, style: GoogleFonts.urbanist(fontSize: 18, fontWeight: FontWeight.w700, color: textColor)),
                        const SizedBox(height: 4),
                        Text(widget.subtitle, style: GoogleFonts.urbanist(fontSize: 13, fontWeight: FontWeight.w600, color: UiLabColors.textSecondary)),
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

// ==========================================
// 3. PSEUDO-3D ICON ASSET
// ==========================================
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
          // [DESIGN] Secondary block (floating behind).
          Transform.translate(
            offset: const Offset(16, 12),
            child: Transform.rotate(
              angle: 0.2,
              child: Container(
                width: 24, 
                height: 24,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [color.withValues(alpha: 0.6), color.withValues(alpha: 0.3)],
                  ),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.white12, width: 1),
                ),
                child: Icon(secondaryIcon, color: Colors.white70, size: 12),
              ),
            ),
          ),
          // [DESIGN] Primary block (front).
          Transform.translate(
            offset: const Offset(-6, -6),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Shadow
                Transform.translate(
                  offset: const Offset(3, 4),
                  child: Container(
                    width: 42, 
                    height: 42,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.2), 
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                // Main block
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [color.withValues(alpha: 0.7), color.withValues(alpha: 0.4)],
                    ),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.white24, width: 1.2),
                    boxShadow: [
                      BoxShadow(color: color.withValues(alpha: 0.15), blurRadius: 10, spreadRadius: 0)
                    ],
                  ),
                  child: Icon(primaryIcon, color: Colors.white, size: 24),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}