# S-13 UILabScreen

Purpose: dev-only UI storyboard viewer. Accessible only in debug builds via the MainShell UI tab.

### Visual AC
- V1: Rendered only when kDebugMode is true.
- V2: Background AppColors.background.
- V3: Single scrollable column with sections in order: Colours, Typography, Spacing, Radius, Components, Motion, Forbidden.
- V4: Colour section: swatch grid; each swatch 56x56 box with AppRadius.card, hex label below in Body typography.
- V5: Typography section: three specimen rows for Display, HUD, Body with labels.
- V6: Spacing section: labelled bars for xxs, xs, sm, md, lg, xl using AppColors.primary fill on AppColors.surface.
- V7: Radius section: three boxes with radius card, sheet, pill.
- V8: Components section: live GameCard (default + pressed), PrimaryButton (default + pressed), HudDisplay example.
- V9: Motion section: three buttons to trigger correct +10 burst, wrong shake, and transition preview.
- V10: Forbidden section: bullet list of disallowed tokens (pure white, pure black, google_fonts, glows above 15%, gradients).

### Behavioural AC
- B1: Given debug build, when UI tab tapped, then this screen mounts.
- B2: Given release build, then this screen is not in the bundle and not reachable.
- B3: Given user taps a colour swatch, then hex copied to clipboard and light haptic fires.
- B4: Given user taps a motion button, then the documented animation plays.
- B5: Given theme drifts from UI_SYSTEM.md, then this screen reflects the drift (intentional).
- B6: Given user changes nothing, then no state persists across rebuilds.

### Interaction coverage
- I1: All swatches tappable, minimum 56x56.
- I2: Motion buttons tappable; light haptic on tap.
- I3: Screen reader reads hex labels per swatch.
- I4: Portrait only.
- I5: Landscape ignored.
- I6: Android back returns to MainShell Home.
- I7: iOS swipe-back disabled (tab body, not pushed route).
- I8: Copy-to-clipboard is silent (no snackbar).

### Edge cases
- E1: Very long hex labels -> truncate with ellipsis but full hex accessible via Semantics label.
- E2: UILab opened in release -> unreachable; no fallback route.
- E3: Screen below 360dp width -> swatches wrap to 2 columns.
- E4: Screen above 800dp width -> still 6-column max.
- E5: App backgrounded -> no state to preserve.

### Non-goals
- N1: No token editing in-app.
- N2: No theme switcher.
- N3: No persistence of last-viewed section.
- N4: No export or copy of the whole token list.
- N5: No Figma or design-tool integration.
- N6: No auth beyond MainShell access.
