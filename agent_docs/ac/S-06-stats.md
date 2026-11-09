# S-06 StatsScreen

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


