import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../1_foundations/tokens/ui_lab_tokens.dart';
import '../1_foundations/ui_lab_copy.dart';
import '../2_atoms/comebak_button.dart';
import 'comebak_bottom_sheet.dart';

// ==============================================================================
// [MOLECULE] ComebakLogoutSheet
// ------------------------------------------------------------------------------
// PURPOSE: Asks the user to confirm logging out.
// ARCHITECTURE: Uses the ComebakButton atom for consistent styling.
// ==============================================================================
class ComebakLogoutSheet extends StatelessWidget {
  const ComebakLogoutSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return ComebakBottomSheet(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(ComebakCopy.logoutTitle, style: ComebakTypography.titleLarge),
          const SizedBox(height: ComebakLayout.spaceSm),
          
          // [TEXT] Using RichText to highlight the brand name "Comebak" in Green.
          RichText(
            text: TextSpan(
              style: ComebakTypography.bodyMedium,
              children: [
                TextSpan(text: ComebakCopy.logoutSubtitlePart1),
                TextSpan(
                  text: ComebakCopy.logoutSubtitleHighlight,
                  style: ComebakTypography.bodyMedium.copyWith(
                    color: ComebakColors.neonGreen,
                    fontWeight: FontWeight.w700, // Optional: make it bold
                  ),
                ),
                TextSpan(text: ComebakCopy.logoutSubtitlePart2),
              ],
            ),
          ),
          
          const SizedBox(height: ComebakLayout.spaceXl),
          Row(
            children: [
              // [LOGOUT ON LEFT] White font
              Expanded(
                child: ComebakButton(
                  text: ComebakCopy.btnLogout,
                  variant: ComebakButtonVariant.primary,
                  onPressed: () => Navigator.pop(context, true),
                ),
              ),
              const SizedBox(width: ComebakLayout.spaceMd),
              // [CANCEL ON RIGHT] Red font
              Expanded(
                child: ComebakButton(
                  text: ComebakCopy.btnCancel,
                  variant: ComebakButtonVariant.danger,
                  onPressed: () => Navigator.pop(context, false),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ==============================================================================
// [MOLECULE] ComebakEditNameSheet
// ------------------------------------------------------------------------------
// PURPOSE: Allows the user to update their display name.
// ARCHITECTURE: Contains local state for the TextField, validation, and error text.
// ==============================================================================
class ComebakEditNameSheet extends StatefulWidget {
  final String? initialName;
  const ComebakEditNameSheet({super.key, this.initialName});

  @override
  State<ComebakEditNameSheet> createState() => _ComebakEditNameSheetState();
}

class _ComebakEditNameSheetState extends State<ComebakEditNameSheet> {
  late TextEditingController _controller;
  late bool _isValid;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialName);
    _validate(_controller.text);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _validate(String val) {
    final trimmed = val.trim();
    String? err;
    // [VALIDATION] Only letters, numbers, underscores.
    if (trimmed.isNotEmpty && !RegExp(r'^[A-Za-z0-9_]+$').hasMatch(trimmed)) {
      err = ComebakCopy.editNameError;
    }
    _errorText = err;
    _isValid = trimmed.isNotEmpty &&
        trimmed != (widget.initialName ?? '').trim() &&
        err == null;
  }

  @override
  Widget build(BuildContext context) {
    return ComebakBottomSheet(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(ComebakCopy.editNameTitle, style: ComebakTypography.titleLarge),
          const SizedBox(height: ComebakLayout.spaceLg),
          TextField(
            controller: _controller,
            autofocus: true,
            style: ComebakTypography.bodyMedium.copyWith(color: ComebakColors.textPrimary),
            inputFormatters: [LengthLimitingTextInputFormatter(20)],
            onChanged: (val) => setState(() => _validate(val)),
            decoration: InputDecoration(
              hintText: ComebakCopy.editNameHint,
              hintStyle: ComebakTypography.bodyMedium,
              filled: true,
              fillColor: ComebakColors.surfaceElevated,
              errorText: _errorText,
              errorMaxLines: 2,
              errorStyle: ComebakTypography.labelSmall.copyWith(color: ComebakColors.vibrantRed),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: ComebakLayout.spaceLg, 
                vertical: ComebakLayout.spaceMd
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(ComebakLayout.radiusMd),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: ComebakLayout.spaceXl),
          Row(
            children: [
              // [CANCEL ON LEFT] White font
              Expanded(
                child: ComebakButton(
                  text: ComebakCopy.btnCancel,
                  variant: ComebakButtonVariant.primary,
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              const SizedBox(width: ComebakLayout.spaceMd),
              // [SAVE ON RIGHT] Green font (Valid) or Muted Green (Invalid)
              Expanded(
                child: ComebakButton(
                  text: ComebakCopy.btnSave,
                  variant: _isValid ? ComebakButtonVariant.success : ComebakButtonVariant.successMuted,
                  onPressed: _isValid
                      ? () => Navigator.pop(context, _controller.text.trim())
                      : null,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}