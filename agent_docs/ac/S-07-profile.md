# S-07 ProfileScreen

Purpose: identity display, profile identity management and logout inside MainShell Profile tab.

## Visual AC

- V1: Background is AppColors.background.
- V2: Avatar is a circle of AppSizes.avatar (64), filled AppColors.surface, showing the first grapheme/initial of the current username in HUD typography, color AppColors.primary.
- V3: Username uses Display typography (48/w900), color AppColors.textPrimary.
- V4: Email uses Body typography (16/w400), color AppColors.textPrimary at 60% opacity.
- V5: Username editing has a clearly discoverable affordance that fits the existing Profile visual hierarchy; do not add unrelated settings or action rows.
- V6: Logout uses PrimaryButton per UI_SYSTEM.md section 4 (AppColors.primary fill, AppColors.background text, AppRadius.pill, height 52).
- V7: No opaque AppBar; content sits directly on canvas.
- V8: Vertical and horizontal spacing use AppSpacing tokens only.
- V9: Bottom island (from S-04) visible below content.
- V10: Avatar has no border, no glow, no shadow.

## Behavioural AC

- B1: Given a logged-in user, when mounted, then username and email resolve within 300 ms.
- B2: Given user invokes username editing, then an edit flow is presented without navigating away from Profile.
- B3: Given a valid username is submitted, then the profile update follows the existing repository/service contract and the displayed username/avatar refresh from the persisted result.
- B4: Given an invalid username, then the user receives actionable validation feedback and no invalid value is persisted.
- B5: Given username update is in progress, duplicate submissions are prevented and progress is communicated.
- B6: Given username update succeeds, the edit flow closes and the updated username is visible.
- B7: Given username update fails, the edit flow remains recoverable, an understandable error is shown, and the user's entered value is not silently discarded.
- B8: Given user taps Logout, then a confirmation dialog appears.
- B9: Given user confirms in dialog, then Supabase signOut is called, session cleared, replace to S-02 SignIn.
- B10: Given user cancels in dialog, then dialog dismisses, no state change, no network call.
- B11: Given signOut fails (network), then behavior follows the existing auth/session policy and communicates the failure without falsely reporting success.
- B12: Given session already expired on mount, then replace to S-02 without flashing profile data.
- B13: Given profile data still loading, then skeleton placeholders render in avatar, name, and email slots.

## Interaction coverage

- I1: Logout button tap target is full PrimaryButton (52 height, pill).
- I2: Logout triggers HapticFeedback.selectionClick on tap, before dialog.
- I3: Confirmation dialog has two actions: Cancel (secondary/text treatment) and Logout (destructive treatment).
- I4: Backdrop and system-back dismissal behavior is explicit, consistent with the consequence of the action, and tested; dismissal is treated as Cancel.
- I5: Rapid double-tap on Logout opens only one dialog (debounced).
- I6: Screen reader announces avatar as decorative (excluded from semantics) and reads name/email as separate nodes.
- I7: Email is selectable (long-press to copy); username is not directly editable inline unless the edit affordance is activated.
- I8: Portrait only; no landscape layout.
- I9: Loading skeleton is not focusable; focus order moves logically through Profile actions once loaded.
- I10: State preserved across tab switches via IndexedStack (S-04 I7).
- I11: Username editing supports keyboard visibility, system back, explicit cancel, text scaling and screen-reader labeling.
- I12: Username editing does not allow repeated saves while a save is in progress.

## Edge cases

- E1: Username null -> avatar shows "?" and username line shows "—".
- E2: Username empty string -> treated according to the existing validation contract; never persist an empty username.
- E3: Username at or beyond the supported maximum length -> validation/formatting follows the existing product contract without clipping the Profile layout.
- E4: Email null (should not happen post-auth) -> email line shows "—".
- E5: Email very long -> truncate with ellipsis, single line.
- E6: First character is emoji -> render safely without splitting a grapheme.
- E7: First character is non-Latin script -> uppercase only if applicable; otherwise render as-is.
- E8: Network offline when Logout tapped -> follow the app's established local-session and remote-sign-out policy; do not claim remote sign-out succeeded if it did not.
- E9: Deep link to Profile while Profile already active -> no-op.
- E10: App resumed from background with expired session -> replace to S-02 without dialog.

## Non-goals

- N1: No avatar image upload.
- N2: Username editing is **in scope for MVP**; it is not a non-goal.
- N3: No email change flow.
- N4: No password change (magic link only).
- N5: No account deletion.
- N6: No settings screen.
- N7: No theme switcher.
- N8: No notification preferences.
- N9: No account type or plan display.
- N10: No delete-account affordance in MVP.

## Implementation note

The exact username constraints (allowed characters, minimum/maximum length, cooldown/rate limit and server-side validation) must match the current implementation and backend contract. Do not invent or change those rules as part of a dialog visual redesign. If the implementation and this AC differ, surface the discrepancy for product confirmation rather than silently changing behavior.
