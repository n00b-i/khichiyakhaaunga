# S-07 ProfileScreen

Purpose: identity display and logout inside MainShell Profile tab.

### Visual AC
- V1: Background is AppColors.background.
- V2: Avatar is a circle of AppSizes.avatar (64), filled AppColors.surface, showing first initial of username in HUD typography, color AppColors.primary.
- V3: Username uses Display typography (48/w900), color AppColors.textPrimary.
- V4: Email uses Body typography (16/w400), color AppColors.textPrimary at 60% opacity.
- V5: Logout uses PrimaryButton per UI_SYSTEM.md section 4 (AppColors.primary fill, AppColors.background text, AppRadius.pill, height 52).
- V6: No opaque AppBar; content sits directly on canvas.
- V7: Vertical and horizontal spacing use AppSpacing tokens only.
- V8: Bottom island (from S-04) visible below content.
- V9: Avatar has no border, no glow, no shadow.
- V10: No settings icon, no edit pencil, no secondary action row.

### Behavioural AC
- B1: Given logged-in user, when mounted, then username and email resolve within 300 ms.
- B2: Given user taps Logout, then a confirmation dialog appears.
- B3: Given user confirms in dialog, then Supabase signOut is called, session cleared, replace to S-02 SignIn.
- B4: Given user cancels in dialog, then dialog dismisses, no state change, no network call.
- B5: Given signOut fails (network), then dialog stays open with an inline error and a retry option.
- B6: Given session already expired on mount, then replace to S-02 without flashing profile data.
- B7: Given profile data still loading, then skeleton placeholders render in avatar, name, and email slots.

### Interaction coverage
- I1: Logout button tap target is full PrimaryButton (52 height, pill).
- I2: Logout triggers HapticFeedback.selectionClick on tap, before dialog.
- I3: Confirmation dialog has two actions: Cancel (text button) and Logout (PrimaryButton).
- I4: Dialog dismisses on backdrop tap and on system back (treated as Cancel).
- I5: Rapid double-tap on Logout opens only one dialog (debounced).
- I6: Screen reader announces avatar as decorative (excluded from semantics) and reads name/email as separate nodes.
- I7: Email is selectable (long-press to copy); username is not.
- I8: Portrait only; no landscape layout.
- I9: Loading skeleton is not focusable; focus starts on Logout once loaded.
- I10: State preserved across tab switches via IndexedStack (S-04 I7).

### Edge cases
- E1: Username null -> avatar shows "?" and username line shows "—".
- E2: Username empty string -> treated as null.
- E3: Username 20+ chars -> truncate with ellipsis; avatar still shows first character.
- E4: Email null (should not happen post-auth) -> email line shows "—".
- E5: Email very long -> truncate with ellipsis, single line.
- E6: First char is emoji -> render emoji in avatar; do not crash.
- E7: First char is non-Latin script -> uppercase only if applicable; otherwise render as-is.
- E8: Network offline when Logout tapped -> local session cleared anyway; route to S-02 evf remote signOut fails (retry silently on next auth).
- E9: Deep link to Profile while Profile already active -> no-op.
- E10: App resumed from background with expired session -> replace to S-02 without dialog.

### Non-goals
- N1: No avatar image upload.
- N2: No username editing.
- N3: No email change flow.
- N4: No password change (magic link only).
- N5: No account deletion.
- N6: No settings screen.
- N7: No theme switcher.
- N8: No notification preferences.
- N9: No account type or plan display.
- N10: No delete-account affordance in MVP.
