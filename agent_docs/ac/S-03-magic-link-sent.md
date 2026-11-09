# S-03 MagicLinkSentScreen

Purpose: waiting state after magic-link email is dispatched. Handles deep-link callback.

### Visual AC
- V1: Background is AppColors.background.
- V2: Centered mail glyph at AppSizes.iconLg (48px), color AppColors.primary.
- V3: Headline "Check your email" in Display typography, color AppColors.textPrimary.
- V4: Subheadline "We sent a sign-in link to {email}" in Body typography, color AppColors.textPrimary at 60% opacity.
- V5: Hint line "Tap the link to sign in. You can close this app." in Body typography, AppColors.textPrimary at 60% opacity.
- V6: "Back to sign in" as TextButton, label color AppColors.primary, Body typography.
- V7: No bottom island and no AppBar.
- V8: All vertical and horizontal spacing uses AppSpacing tokens only.
- V9: No glow, no shadow, no gradient.
- V10: Safe area respected; content never clips under notch or home indicator.

### Behavioural AC
- B1: Given email send succeeded on S-02, then S-03 pushes with the submitted email in V4.
- B2: Given deep link tapped on the device, then Supabase exchanges the token and app replaces to S-04.
- B3: Given deep link is invalid or expired, then an inline banner appears "This link has expired. Request a new one." and Back to sign in is emphasised.
- B4: Given user taps Back to sign in, then pop to S-02 with the previous email preserved in the field.
- B5: Given user returns to foreground after tapping the link on another device, then session is checked and app routes to S-04 if valid.
- B6: Given app killed while on S-03, then next launch flows through S-01 normally.

### Interaction coverage
- I1: No text input on this screen.
- I2: Only one tap target: Back to sign in.
- I3: Android system back behaves the same as Back to sign in (pop to S-02).
- I4: iOS swipe-back enabled (previous route exists).
- I5: No haptic on entry, no haptic on deep-link.
- I6: Screen reader announces V3, V4, V5 in reading order.
- I7: Portrait only.
- I8: Deep-link handler registered in main.dart and detached when S-03 unmounts.

### Edge cases
- E1: Email with plus-sign or subaddress displays verbatim.
- E2: Very long email wraps at display width; no mid-word truncation.
- E3: Deep link arrives while S-02 visible -> route to S-04 directly, do not show S-03.
- E4: Deep link arrives while S-04 visible -> session refreshed silently, no navigation.
- E5: Deep link arrives while a game is in progress -> ignore, keep user on the game.
- E6: Deep link with malformed token -> expired banner, no crash.
- E7: Multiple deep links in quick succession -> only first processed.
- E8: Network offline on exchange -> banner "Check your connection and tap the link again".
- E9: Timezone or clock change while on S-03 -> no effect.
- E10: User backgrounds the app on S-03 and returns -> state preserved, no auto-send.

### Non-goals
- N1: No resend link button.
- N2: No countdown timer.
- N3: No email editing on this screen.
- N4: No check-spam-folder copy variations.
- N5: No auto-detection of incoming email.
- N6: No copy-to-clipboard for the email.
- N7: No mail-app promo.
