# S-09 MadBurstGameScreen

Purpose: 60-second bubble game. Tap two bubbles whose values multiply to the target.

### Visual AC
- V1: Background is AppColors.background.
- V2: Play area borderless; bubbles float directly on canvas.
- V3: HUD top: timer left, score right, HUD typography tabular, AppColors.textPrimary.
- V4: Target chip center-top: "Target: N", Body typography, AppColors.surface fill, AppColors.border border, AppRadius.pill.
- V5: Bubbles: perfect circles, diameter 72-96, AppColors.surface fill, AppColors.border 1px, numeral inside HUD 28/w700 tabular, AppColors.textPrimary.
- V6: Selected bubble shows AppColors.primary 2px stroke only.
- V7: Correct feedback: floating "+10" in AppColors.primary with 180ms upward fade.
- V8: Wrong feedback: both tapped bubbles shake 80ms and flash border to AppColors.vibrantRed.
- V9: No glow, no shadow, no gradient.
- V10: Bottom island hidden during play.

### Behavioural AC
- B1: Game starts with timer at 60 and counts down 1s steps to 0.
- B2: Initial spawn: 6 bubbles with unique values, none of which alone equals the target.
- B3: User taps one bubble then another; pair evaluation fires on the second tap.
- B4: Correct pair (product equals target) -> +10, both tapped bubbles removed, remaining bubbles freeze 180ms, then resume; new target and new bubbles spawn.
- B5: Wrong pair -> -5 (floor 0), red shake, no removal, no pause.
- B6: On spawn, new bubble values chosen so no visible pair already multiplies to the new target.
- B7: Timer reaches 0 -> game stops, replace to S-12 with {score, accuracy, duration}.
- B8: Score floor at 0.
- B9: Tapping the same bubble twice deselects it.
- B10: Tapping a third bubble while two are selected discards the selection; the new bubble becomes first selection.
- B11: Wrong pairs do not lock subsequent taps.
- B12: If no visible pair multiplies to the current target after spawn, re-roll target until a pair exists.

### Interaction coverage
- I1: Bubble tap target is the full circle.
- I2: Haptic on correct (lightImpact) and wrong (mediumImpact).
- I3: Bubbles collide and bounce off edges; never overlap.
- I4: Drag-and-drop unsupported; tap-to-select only.
- I5: Multi-touch beyond 2 fingers ignored.
- I6: Android system back disabled during play.
- I7: iOS swipe-back disabled during play.
- I8: Screen reader announces each bubble by number and selection state.
- I9: Portrait only.
- I10: Landscape attempt ignored.

### Edge cases
- E1: Screen width below 360dp -> bubble diameter scales to minimum 64.
- E2: Two bubbles spawn near-identical positions -> offset so no overlap.
- E3: Bubble count >12 -> no spawn until removal.
- E4: User idle 60s -> score 0, route to S-12.
- E5: Rapid double-tap on same bubble -> single tap (debounce 150ms).
- E6: App backgrounded mid-game -> timer pauses, resumes on foreground.
- E7: Orientation change blocked.
- E8: Score 999+ -> HUD scales.
- E9: Tap during freeze window -> ignored.
- E10: Session expires mid-game -> S-02, S-12 not shown.

### Non-goals
- N1: No pause menu.
- N2: No hints.
- N3: No undo.
- N4: No leaderboard or rank during play.
- N5: No sound effects.
- N6: No adjustable timer.
- N7: No difficulty selector.
- N8: No multiplayer.
