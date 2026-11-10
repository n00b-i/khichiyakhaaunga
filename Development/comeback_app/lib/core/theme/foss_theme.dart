import 'package:fossui/fossui.dart';
import 'tokens/app_colors.dart';

// [ISSUE: fossui-adaptation] Central fossui theme.
// Seeds FossThemeData with our locked tokens. Unset roles inherit fossui defaults.
// [FORCE: COMMENT SYNTAX] All comments use //, never ///.
class FossAppTheme {
  FossAppTheme._();

  static FossThemeData get dark {
    return FossThemeData.dark.retheme(
      const FossThemeSpec(
        // [TOKEN: canvas] #121212 — our locked dark background.
        background: AppColors.background,
        // [TOKEN: text] #F5F5F5 — off-white, prevents glowing blur.
        foreground: AppColors.textPrimary,
        // [TOKEN: surface] #1E1E1E — cards, grid boxes.
        card: AppColors.surface,
        cardForeground: AppColors.textPrimary,
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
        // [TOKEN: spacing] 16 — base spacing unit from AppSpacing.md.
        spacing: 16,
      ),
    );
  }
}