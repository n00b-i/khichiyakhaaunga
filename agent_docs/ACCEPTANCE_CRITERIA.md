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

---

## S-05 HomeScreen

Purpose: post-login entry inside MainShell Home tab. Greeting, tagline, 4 game cards.

### Visual AC
- V1: Background is AppColors.background.
- V2: Greeting uses Display typography (48/w900), color AppColors.textPrimary.
- V3: Greeting format: "Good morning, {Name}" / "Good afternoon, {Name}" / "Good evening, {Name}".
- V4: Tagline text is exactly "#Time to go high and higher#", Body typography (16/w400), color AppColors.textPrimary at 60% opacity.
- V5: Exactly 4 GameCard widgets render: Add Burst, Mad Burst, Math Burst, Memory of Saitan.
- V6: Each GameCard matches UI_SYSTEM.md section 4 contract exactly.
- V7: Vertical spacing between greeting, tagline, and cards uses AppSpacing tokens only.
- V8: Top safe area respected; content starts below notch/status bar.
- V9: No glow or shadow on greeting text. No shadow on cards.
- V10: Bottom island (from S-04) is visible below content.
- V11: Every game card icon area uses one AppColors vibrant token per game, no mixing within a single card.

### Behavioural AC
- B1: Given logged-in user with username, when mounted, then greeting renders within 300 ms.
- B2: Given logged-in user with no username, when mounted, then greeting omits name: "Good morning".
- B3: Given user taps Add Burst, then push to S-08 or S-14 (if game pending).
- B4: Given user taps Mad Burst, then push to S-09 or S-14.
- B5: Given user taps Math Burst, then push to S-10 or S-14.
- B6: Given user taps Memory of Saitan, then push to S-11 or S-14.
- B7: Given session expires while Home is active, then replace to S-02 SignIn.
- B8: Given clock crosses morning/afternoon/evening boundary while app is backgrounded, when app resumes, then greeting recomputes.

### Interaction coverage
- I1: Game card tap target is the full card (entire card is tappable, not just icon/text).
- I2: Game card press state shows 0.9 opacity on the card surface.
- I3: Tapping a game card triggers light haptic (HapticFeedback.selectionClick) before navigation.
- I4: Rapid double-tap on a game card triggers navigation once only (debounced 300 ms).
- I5: Pull-to-refresh is DISABLED; no RefreshIndicator wraps the list.
- I6: Scroll is enabled when content exceeds viewport; scroll position preserved across tab switches (IndexedStack in S-04).
- I7: Screen reader announces each GameCard as a button with its title and description.
- I8: Greeting has Semantics label with the full resolved text.
- I9: Portrait only; no landscape layout.
- I10: Tap target for Back from a returned game flows through MainShell, not HomeScreen.

### Edge cases
- E1: Username null -> greeting shows time-only form.
- E2: Username empty string -> treated as null.
- E3: Username 20+ chars -> truncate with ellipsis at Display 48; do not wrap.
- E4: Profile fetch slow -> render skeleton placeholder in greeting area; do not block cards.
- E5: Profile fetch fails -> render "Good morning" with no name; do not surface error toast.
- E6: Device hour 0-11 -> morning; 12-16 -> afternoon; 17-23 -> evening (local device timezone).
- E7: Timezone changed while app open -> greeting recomputes on next resume, not live.
- E8: Deep link to Home while Home already active -> no-op, no duplicate push.
- E9: Returning from a game result screen -> Home scroll position preserved, no reload spinner.

### Non-goals
- N1: No pull-to-refresh.
- N2: No daily challenge banner.
- N3: No streak counter.
- N4: No search field.
- N5: No game filter or sort.
- N6: No social feed.
- N7: No leaderboard or rank display.
- N8: No onboarding overlay or tutorial.
- N9: No settings icon in Home header.
- N10: No avatar or profile shortcut in Home header.

---

## S-06 StatsScreen

Purpose: personal metrics inside MainShell Stats tab. No global rankings.

### Visual AC
- V1: Background is AppColors.background.
- V2: Metric tiles use AppColors.surface fill, AppColors.border border, AppRadius.card radius.
- V3: Numeric displays use HUD typography (32/w700 tabular), color AppColors.textPrimary.
- V4: Labels use Body typography (16/w400), color AppColors.textPrimary at 60% opacity.
- V5: Exactly three metric groups render: Total games played, Total time spent, Personal bests per game.
- V6: Personal bests render as 4 rows (one per game: Add Burst, Mad Burst, Math Burst, Memory of Saitan).
- V7: Each PB row shows game title and best score value; no other data.
- V8: Empty values render as "0" for counts and "—" for missing PBs (never blank cells, never spinner-in-cell).
- V9: Vertical and horizontal spacing use AppSpacing tokens only.
- V10: No leaderboard, no rank badge, no cross-er comparison element anywhere on the screen.
- V11: Bottom island (from S-04) visible below content.

### Behavioural AC
- B1: Given 0 games played, then empty state renders with zeros/dashes after load completes.
- B2: Given N games played, then totals resolve within 500 ms of mount.
- B3: Given user taps a PB row, then nothing happens (no drill-down in MVP).
- B4: Given network slow (>500 ms), then skeleton tiles render first.
- B5: Given data arrives, then skeleton swaps to content with a fade at AppMotion.transitionMinMs, no layout jump.
- B6: Given fetch fails, then tiles show "—" and a retry affordance appears.
- B7: Given user taps retry, then fetch refires and skeleton returns.
- B8: Given session expires mid-fetch, then replace to S-02 SignIn.

### Interaction coverage
- I1: Scroll is enabled when content exceeds viewport.
- I2: PB rows are passive display, no tap targets.
- I3: Screen reader announces each metric tile as one semantic node (label + value combined).
- I4: Numeric values are read turally (e.g., "3 games", not "3" alone).
- I5: Portrait only; no landscape layout.
- I6: Loading uses skeleton tiles, never a centred spinner.
- I7: Error retry uses PrimaryButton per UI_SYSTEM.md section 4.
- I8: No haptic on screen entry or on data swap.
- I9: State preserved across tab switches via IndexedStack (S-04 I7).

### Edge cases
- E1: New user, no scores -> all zeros/dashes.
- E2: Partial data (some games have PBs, some do not) -> present games show value, missing show "—".
- E3: Totals >= 10,000 -> thousands separator (e.g., "10,000").
- E4: Time format rules: 0s -> "0s"; <60s -> "{n}s"; <60min -> "{m}m {s}s"; >=60min -> "{h}h {m}m".
- E5: PB score >= 10,000 -> thousands separator.
- E6: Fetch returns PB rows for unknown games -> ignore extras, render only the 4 known games.
- E7: Fetch returns duplicate rows per game -> dedupe by game, keep max score.
- E8: Deep link to Stats while Stats already active -> no-op, no duplicate push.
- E9: Session expires mid-fetch -> route to S-02.
- E10: Deve clock/date changes -> no effect on this screen (metrics are cumulative).

### Non-goals
- N1: No global leaderboard.
- N2: No rank badges.
- N3: No cross-user comparison.
- N4: No per-session drill-down.
- N5: No charts or graphs.
- N6: No time-of-day or streak analysis.
- N7: No export or share.
- N8: No pull-to-refresh gesture (metrics refresh on tab mount).
