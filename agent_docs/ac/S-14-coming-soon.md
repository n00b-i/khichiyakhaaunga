# S-14 ComingSoonScreen

Purpose: interim placeholder for game cards whose game screen is not yet built.

### Visual AC
- V1: Background is AppColors.background.
- V2: Centered icon at 48px (AppSizes.iconLg), color AppColors.border.
- V3: Headline "Coming soon" in Display typography, AppColors.textPrimary.
- V4: Body line "{GameName} is being built. Check back soon." in Body typography, AppColors.textPrimary at 60% opacity.
- V5: TextButton "Back" below, label AppColors.primary.
- V6: No bottom island.
- V7: All spacing uses AppSpacing tokens.

### Behavioural AC
- B1: Given a game card tapped while that game is pending, then S-14 pushes with the game name.
- B2: Given user taps Back, then pop to previous (HomeTab).
- B3: Given iOS swipe-back, then pop to previous.
- B4: Given no game name provided, then headline remains "Coming soon" and body is generic.
- B5: Given session expires while on S-14, then replace to S-02.

### Interaction coverage
- I1: Back button tap target >= 48x48.
- I2: Android system back pops to previous.
- I3: iOS swipe-back enabled (previous route exists).
- I4: Haptic light on Back tap.
- I5: Screen reader announces headline and body.
- I6: Portrait only.

### Edge cases
- E1: Back when S-14 is first route (should not happen) -> fallback to MainShell.
- E2: Game name very long -> wraps gracefully.
- E3: Game name empty string -> treated as generic.
- E4: Deep link to S-14 -> ignore; route to MainShell Home instead.
- E5: Session expires while open -> S-02.

### Non-goals
- N1: No waitlist signup.
- N2: No notify-me toggle.
- N3: No share.
- N4: No ETA date.
- N5: No animation beyond a fade-in.
- N6: No progress bar.
