# Acceptance Criteria - comeback.in

Per-screen acceptance criteria. Reference SCREENS.md for IDs and edges.
Format: Visual -> Behavioural -> Interaction coverage -> Edge cases -> Non-goals.
All values below resolve to tokens per UI_SYSTEM.md section 9. No literals.

Numbering scheme: V=Visual, B=Behavioural, I=Interaction, E=Edge, N=Non-goal.
Each item is numbered for reference and counting. To update, cite the ID (e.g., "update B3").

---

## S-04 MainShell

Purpose: bottom island wrapper. Single Scaffold, tab body swaps.

### Visual AC
- V1: Bottom island is a floating pill with AppColors.surface fill and AppRadius.pill.
- V2: Island vertical margin from screen edge is AppSpacing.xxs (4px).
- V3: Release build shows 3 tabs - Home, Stats, Profile.
- V4: Debug build shows 4 tabs - Home, Stats, Profile, UI (UI last).
- V5: Active tab label color is AppColors.primary.
- V6: Inactive tab label color is AppColors.textPrimary at 60% opacity.
- V7: Body area background is AppColors.background.
- V8: Island shadow, if any, is <= 15% opacity.
- V9: Island respects bottom device inset.
- V10: Tab icons use AppSizes.tabIcon.

### Behavioural AC
- B1: Given app starts, then Home is the default tab.
- B2: Given user taps a tab, then body swaps instantly (no page transition).
- B3: Given user taps the already-active tab, then nothing happens.
- B4: Given release build, then UI tab is not rendered at all.
- B5: Given debug build, then UI tab renders last.
- B6: Given session expires mid-tab, then app replaces to S-02 SignIn.

### Interaction coverage
- I1: Tab tap target is >= 48x48.
- I2: Tab switch haptic is OFF (haptics reserved for game feedback per UI_SYSTEM section 5).
- I3: Swipe between tabs is DISABLED.
- I4: Android system back on non-Home tab goes to Home.
- I5: Android system back on Home tab exits app.
- I6: iOS swipe-back gesture is disabled at shell root.
- I7: IndexedStack preserves per-tab state (scroll, form drafts) across switches.
- I8: Keyboard open hides island; body shrinks; island does not push upward.
- I9: Each tab has a Semantics label; focus moves into new tab body on switch.
- I10: Portrait only, enforced in main.dart. No landscape re-layout.
- I11: Loading and error states render inside tab bodies; island stays fixed and interactive.

### Edge cases
- E1: Bottom inset 0 -> island floats AppSpacing.xs (8px) from screen bottom.
- E2: Bottom inset large (gesture nav) -> island sits above inset + AppSpacing.xxs (4px).
- E3: Landscape attempt -> ignored due to portrait lock.
- E4: Deep link while on non-Home tab -> shell switches to target tab, no duplicate shell.
- E5: Rapid tab taps (5+ in 1s) -> state consistent, no rebuild storms.

### Non-goals
- N1: No badges on tabs.
- N2: No long-press reorder.
- N3: No animated tab transitions.
- N4: No island collapse on scroll.
- N5: No tab-specific AppBar.
- N6: No mini-player or overlay widgets.
