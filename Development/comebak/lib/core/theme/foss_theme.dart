import 'package:fossui/fossui.dart';
import 'tokens/app_colors.dart';
import 'tokens/app_spacing.dart';

// [ISSUE: fossui-adaptation] Central fossui theme.
// Seeds FossThemeData with our locked tokens. Unset roles inherit fossui defaults.
// [FORCE: COMMENT SYNTAX] All comments use //, never ///.
class FossAppTheme {
  FossAppTheme._();

  static FossThemeData get dark {
    return FossThemeData.dark.retheme(
      // [FIX: NON-CONST] Removed 'const' because withValues() is a method.
      FossThemeSpec(
        // [TOKEN: canvas] #121212 — our locked dark background.
        background: AppColors.background,
        // [TOKEN: text] #F5F5F5 — off-white, prevents glowing blur.
        foreground: AppColors.textPrimary,
        // [TOKEN: surface] #1E1E1E — cards, grid boxes.
        card: AppColors.surface,
        cardForeground: AppColors.textPrimary,
        
        // [FIX] Dialog and overlay surface roles use the app palette.
        popover: AppColors.surface,
        popoverForeground: AppColors.textPrimary,
        
        // [FIX] Dialog description and filled footer treatment.
        muted: AppColors.background,
        mutedForeground: AppColors.textPrimary.withValues(alpha: 0.68),
        
        // [FIX] Close affordance pressed state.
        accent: AppColors.border,
        accentForeground: AppColors.textPrimary,

        // [TOKEN: primary] #00B386 — Groww Green.
        primary: AppColors.primary,
        // [TOKEN: on-primary] #121212 — dark text on green button.
        primaryForeground: AppColors.background,
        // [TOKEN: border] #2C2C2C — subtle structure.
        border: AppColors.border,
        // [TOKEN: input] #2C2C2C — form field border.
        input: AppColors.border,
        // [TOKEN: ring] #00B386 — focus indicator.
        ring: AppColors.primary,
        // [TOKEN: destructive] #FF5252 — wrong answers, errors.
        destructive: AppColors.vibrantRed,
        // [TOKEN: success] #00E676 — correct answers, PBs.
        success: AppColors.vibrantGreen,
        // [TOKEN: warning] #FF9800 — offline banners, caution.
        warning: AppColors.vibrantOrange,
        // [TOKEN: radius] 12 — card corner radius from AppRadius.card.
        radius: 12,
        
        // [FIX] FossUI spacing is a pixel unit; its standard scale is 4 px.
        spacing: AppSpacing.xxs,
      ),
    );
  }
}