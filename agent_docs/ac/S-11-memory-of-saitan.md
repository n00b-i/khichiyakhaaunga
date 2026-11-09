# S-11 MemoryOfSaitanGameScreen

Purpose: 60-second flashlight-reveal memory game on a near-black grid.

### Visual AC
- V1: Grid canvas uses the near-black value (#0A0A0A) per UI_SYSTEM section 8 (Saitan exception). Never pure black.
- V2: Grid cells fill the same near-black value, 1px borders in AppColors.surface.
- V3: Numbers rendered in HUD typography, color AppColors.textPrimary, centered per cell.
- V4: HUD top area fill AppColors.background (not the near-black value); timer and score HUD typography tabular.
- V5: Flashlight cursor: radial gradient from transparent center to opaque near-black edges, reveal radius about 120px.
- V6: Light Toggle button: AppColors.surface fill, AppColors.border border, AppRadius.pill, label "Light" Body typography AppColors.textPrimary, top-right below HUD.
- V7: Revealed numbers (within cone) at full opacity; unrevealed at 0 opacity.
- V8: No bottom island during play.
- V9: No glow, no shadow, no gradient beyond the flashlight cone.
- V10: All spacing uses AppSpacing tokens.

### Behavioural AC
- B1: Game starts at 60s countdown.
- B2: Level 1 grid is 2x2 with 4 numbered cells.
- B3: Correct sequence is ascending numeric order.
- B4: On level complete -> +10, next level loads immediately.
- B5: Progression order: 2x2 -> 3x3 (one cell empty) -> 3x3 (full) -> 4x4 (full); 4x4 reshuffles and repeats.
- B6: Wrong tap -> -5, shake on wrong cell, no advance.
- B7: Timer reaches 0 -> S-12 with {score, accuracy, duration}.
- B8: Light Toggle switches between flashlight mode (default) and full-light mode (all numbers visible, no cursor effect); does not affect score or timer.
- B9: Score floor at 0.
- B10: Session expires mid-game -> S-02, S-12 not shown.

### Interaction coverage
- I1: Swipe over grid moves the flashlight cursor; tap alone reveals a transient flash at tap point (100ms).
- I2: Tap on a revealed number selects it and checks against correct order.
- I3: Light Toggle tap target >= 48x48.
- I4: Haptic light on correct, medium on wrong.
- I5: Android system back disabled during play.
- I6: iOS swipe-back disabled during play.
- I7: Screen reader exposes only currently revealed numbers; unrevealed are silent.
- I8: Screen reader can activate the Light Toggle.
- I9: Portrait only.
- I10: Landscape ignored.

### Edge cases
- E1: 4x4 sequence is ascending 1..16.
- E2: Two taps within 100ms treated as separate (debounce 50ms only).
- E3: Screen below 360dp width -> cells scale to fit, numbers auto-shrink.
- E4: Screen above 800dp -> grid capped at 500dp width, centered.
- E5: Battery saver throttles swipes -> cursor follows last sampled position.
- E6: Multi-finger drag -> single-finger cursor only, second finger ignored.
- E7: App backgrounded -> timer pauses, cursor state preserved.
- E8: Session expires -> S-02 mid-game.
- E9: Light Toggle toggled 5x in 1s -> state toggles each time, no crash.
- E10: Timer reaches 0 as user lifts finger -> S-12 with current score.

### Non-goals
- N1: No dark-mode toggle beyond the Light button.
- N2: No difficulty selector.
- N3: No hints.
- N4: No pause menu.
- N5: No sound effects.
- N6: No score multiplier or combo.
- N7: No level-skip.
- N8: No replay of the last level.
