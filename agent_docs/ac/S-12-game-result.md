# S-12 GameResultScreen

Purpose: post-game summary. Score, accuracy, duration, personal best, and next actions.

### Visual AC
- V1: Background is AppColors.background.
- V2: Top: game name in Body typography, AppColors.textPrimary at 60% opacity.
- V3: Score value at HUD typography (32/w700 tabular), color AppColors.primary, centered.
- V4: Score label "SCORE" in Body typography, AppColors.textPrimary at 60% opacity.
- V5: Two secondary metrics side by side: Accuracy (%) and Duration (mm:ss), Body typography, AppColors.textPrimary.
- V6: PB indicator: if new PB, "New personal best" chip in AppColors.primary; else "Best: N" at 60% opacity.
- V7: PrimaryButton "Play Again" full width at bottom.
- V8: TextButton "Done" below Play Again, label AppColors.textPrimary at 60% opacity.
- V9: No bottom island during result.
- V10: All spacing uses AppSpacing tokens.
- V11: No glow, no shadow, no gradient.

### Behavioural AC
- B1: Given game ends, then S-12 replaces the game screen; back cannot return to game.
- B2: Given game has known game_id, then submit score to Supabase after mount (fire-and-forget).
- B3: Given submission succeeds, then local PB cache updates and PB indicator shows correctly.
- B4: Given submission fails, then result still shows; retry silently on next S-12 or S-04 mount.
- B5: Given user taps Play Again, then replace to the same game screen with a fresh session.
- B6: Given user taps Done, then popUntil S-04 MainShell HomeTab.
- B7: Given new PB, then V6 shows "New personal best".

### Interaction coverage
- I1: Play Again tap target is full-width PrimaryButton.
- I2: Done tap target >= 48x48.
- I3: Haptic: none on mount; light selection on Play Again; none on Done.
- I4: Android system back behaves the same as Done (popUntil MainShell).
- I5: iOS swipe-back disabled (game and result are terminal).
- I6: Screen reader announces score, accuracy, duration, PB state.
- I7: Portrait only.
- I8: Landscape ignored.
- I9: Metrics fade in over AppMotion.correctMs on mount.

### Edge cases
- E1: Score 0 -> displayed normally, no judgemental copy.
- E2: New user (no previous scores) -> PB indicator says "First score" instead of "New personal best".
- E3: Accuracy 0% or 100% -> integer percent, no decimals.
- E4: Duration exactly 60s -> "1:00".
- E5: Supabase submission delayed >2s -> result shows immediately; submission completes in background.
- E6: Rapid double-tap Play Again -> single navigation (debounce 300ms).
- E7: Rapid double-tap Done -> single navigation (debounce 300ms).
- E8: Deep link arrives while on S-12 -> ignored; user stays on result.

### Non-goals
- N1: No leaderboard.
- N2: No share sheet.
- N3: No replay recording.
- N4: No rate-this-game prompt.
- N5: No ad or upsell.
- N6: No per-answer review.
- N7: No comparison to global average.
- N8: No animated count-up of the score.
