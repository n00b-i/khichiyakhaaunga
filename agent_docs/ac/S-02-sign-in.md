# S-02 SignInScreen

Purpose: unauthenticated entry. Magic link email plus Google and Apple social sign-in.

### Visual AC
- V1: Background is AppColors.background.
- V2: App wordmark at top: "comebak", Display typography, color AppColors.textPrimary.
- V3: Email field: AppColors.surface fill, AppColors.border border, AppRadius.card, Body typography, AppColors.textPrimary text, 16px placeholder at 60% opacity.
- V4: Email field placeholder text: "you@example.com".
- V5: "Send magic link" PrimaryButton below the field (AppColors.primary fill, AppColors.background label, AppRadius.pill, height 52).
- V6: Divider row between magic-link and social: thin line AppColors.border + centered "or" label, Body 16/w400, AppColors.textPrimary at 60% opacity.
- V7: "Continue with Google" button: PrimaryButton-styled outline variant (transparent fill, AppColors.border border, AppColors.textPrimary label).
- V8: "Continue with Apple" button: same outline style, iOS only. Hidden on Android.
- V9: No bottom island, no AppBar.
- V10: Spacing between elements uses AppSpacing tokens only.
- V11: No glow, no shadow, no gradients anywhere on the screen.

### Behavioural AC
- B1: Given user enters a valid email and taps "Send magic link", then Supabase sends the link and app pushes to S-03 MagicLinkSent.
- B2: Given user enters an invalid email and taps "Send magic link", then inline validation error appears under the field; no network call.
- B3: Given user enters an empty email and taps "Send magic link", then inline error "Email is required"; no network call.
- B4: Given send succeeds, then no toast is shown (S-03 owns the message).
- B5: Given send fails (network), then inline error under the button with a retry option; no navigation.
- B6: Given user taps Google, then OAuth flow opens; success routes to S-04, cancel returns to S-02 unchanged.
- B7: Given user taps Apple on iOS, then Sign in with Apple flow opens; success to S-04, cancel to S-02 unchanged.
- B8: Given user is already authenticated and lands on S-02, then replace to S-04 (auth gate).

### Interaction coverage
- I1: Email field uses TextInputType.emailAddress and autocorrect off.
- I2: Email field autofocus on first mount (no, do not autofocus; keyboard should not pop on entry). Autofocus OFF.
- I3: Keyboard "Go" key submits "Send magic link".
- I4: "Send magic link" button disabled until email is non-empty.
- I5: Send button tap target is full PrimaryButton (52 height, pill).
- I6: Loading state after submit: button shows AppColors.background label with a 16px CircularProgressIndicator in AppColors.background; button tap disabled during load.
- I7: OAuth buttons open the system sheet; no custom webview.
- I8: Screen reader announces email field, send button, and each OAuth button with its label.
- I9: Portrait only.
- I10: Android system back exits the app (no previous route).
- I11: Tab order: email field, send button, Google, Apple (iOS).
- I12: Light haptic (selectionClick) when OAuth buttons tapped, none for email send.

### Edge cases
- E1: Email with leading/trailing whitespace -> trimmed before validation and submit.
- E2: Uppercase email -> accepted; no forced lowercase in the field (server canonicalises).
- E3: Email with no TLD -> client validation rejects.
- E4: Email 254+ chars -> validation rejects.
- E5: Network offline -> send error inline "Check your connection and try again".
- E6: Supabase rate-limits the request (429) -> inline error "Too many attempts, try again shortly".
- E7: Google/Apple cancel -> no state change, no error toast.
- E8: Google/Apple error (network or provider) -> inline error under the social row.
- E9: Deep link arrives while on S-02 and user is unauthenticated -> deep link ignored, remains on S-02.
- E10: iOS version below Apple Sign-in minimum (iOS 13) -> hide Apple button.
- E11: Screen rotated (attempted landscape) -> ignored via portrait lock.
- E12: Very small screen (<640 logical px height) -> scrollable; all buttons remain reachable.

### Non-goals
- N1: No password login.
- N2: No sign-up toggle (magic link covers both).
- N3: No "remember me" checkbox.
- N4: No guest mode.
- N5: No "skip sign in".
- N6: No phone number or OTP path.
- N7: No legal/TOS checkboxes in MVP.
- N8: No country picker.
- N9: No language picker.
- N10: No visibility toggle (no password).
