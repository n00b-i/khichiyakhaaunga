import 'package:flutter/material.dart';
import '../1_foundations/tokens/ui_lab_tokens.dart';

// ==============================================================================
// [MOLECULE] ComebakBottomSheet
// ------------------------------------------------------------------------------
// PURPOSE: The base wrapper for all bottom sheets in the app.
// ARCHITECTURE: Handles the top rounded corners, the drag handle, the background
// color, and critically, the keyboard padding (viewInsets).
// ==============================================================================
class ComebakBottomSheet extends StatelessWidget {
  final Widget child;

  const ComebakBottomSheet({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: ComebakColors.surface,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(ComebakLayout.radiusXl),
        ),
        border: Border(
          top: BorderSide(color: ComebakColors.border, width: ComebakLayout.borderThin),
        ),
      ),
      // [KEYBOARD FIX] Pushes the sheet up when the keyboard opens
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // [UI] Standard Drag Handle
            Container(
              margin: const EdgeInsets.only(
                top: ComebakLayout.spaceMd, 
                bottom: ComebakLayout.spaceSm
              ),
              width: ComebakLayout.spaceXxl,
              height: ComebakLayout.spaceXs,
              decoration: BoxDecoration(
                color: ComebakColors.border,
                borderRadius: BorderRadius.circular(ComebakLayout.radiusSm),
              ),
            ),
            // [CONTENT] Injects the specific sheet content here
            Padding(
              padding: const EdgeInsets.fromLTRB(
                ComebakLayout.spaceXl, 
                ComebakLayout.spaceSm, 
                ComebakLayout.spaceXl, 
                ComebakLayout.spaceXl
              ),
              child: child,
            ),
          ],
        ),
      ),
    );
  }
}