# S-05 HomeScreen

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


