# S-10 MathBurstGameScreen

Purpose: 60-second fast-fire arithmetic with a custom in-app numpad. Native keyboard MUST NEVER appear.

### Visual AC
- V1: Background is AppColors.background.
- V2: HUD top: timer left, score right, HUD typography tabular, AppColors.textPrimary.
- V3: Center equation: "{a} + {b} = _" in Display typography 48/w900, AppColors.textPrimary; underscore slot in AppColors.primary.
- V4: Answer slot displays entered digits in Display typography, AppColors.primary.
- V5: Custom numpad at bottom: 3x4 grid (1..9, blank, 0, backspace), each key min 72x72, AppColors.surface fill, AppColors.border, AppRadius.card, Body typography.
- V6: Backspace key uses a clear backspace glyph, same styling.
- V7: Numpad pinned to bottom safe area; no bottom island during play.
- V8: No native soft keyboard ever shown on this screen.
- V9: Correct feedback: floating "+10" in AppColors.primary.
- V10: Wrong feedback: equation and answer row shake 80ms, border flashes AppColors.vibrantRed.
- V11: No glow, no shadow, no gradient.
- V12: All spacing uses AppSpacing tokens.

### Behavioural AC
- B1: Game starts at 60s countdown.
- B2: Equations generated from integers 1-99; operations cycle + and - only (no multiplication, no division).
- B3: User taps digits to fill answer; no explicit submit button.
- B4: When digit count equals the correct answer length, auto-validate.
- B5: Digits equal correct answer -> +10, next equation within 100ms, answer clears.
- B6: Digits differ -> -5, red shake, answer clears, same equation persists.
- B7: Backspace removes last digit; does not trigger validation.
- B8: Max 3 digits; generator never produces answers with more than 3 digits.
- B9: Timer reaches 0 -> S-12 with {score, accuracy, duration}.
- B10: Score floor at 0.
- B11: Session expires mid-game -> S-02, S-12 not shown.

### Interaction coverage
- I1: Each numpad key tap target >= 72x72.
- I2: Haptic light on correct, medium on wrong.
- I3: No TextField or TextFormField used anywhere on this screen; native keyboard cannot appear.
- I4: Backspace short-press removes one digit; long-press clears all digits.
- I5: Android system back disabled during play.
- I6: iOS swipe-back disabled during play.
- I7: Screen reader announces current equation, entered digits, score.
- I8: Screen reader reachable keys in grid order 1..9, backspace, 0.
- I9: Portrait only.
- I10: Landscape ignored.
- I11: Single-finger input only; second finger ignored.
- I12: Rapid repeated digit taps are queued; each adds one digit until max length.

### Edge cases
- E1: Equation complexity never changes timer pacing; timer counts wall clock.
- E2: Answer length 3 reached with wrong digits -> auto-validate fires immediately.
- E3: Backspace at 0 digits -> no-op.
- E4: Numpad tap during 100ms validation animation -> queued, not dropped.
- E5: Battery saver or throttled frames -> timer uses wall clock, not frame count.
- E6: App backgrounded -> timer pauses.
- E7: Device rotated -> ignored (portrait lock).
- E8: Screen below 360dp width -> equation typography auto-shrinks to fit.
- E9: Screen above 800dp width -> numpad stays fixed height, content gaps grow via AppSpacing.
- E10: Session expires -> S-02, S-12 not shown.
- E11: Timer 0 mid-equation -> stops immediately, S-12 with current score.

### Non-goals
- N1: No keyboard shortcuts.
- N2: No undo beyond backspace.
- N3: No difficulty selector.
- N4: No hints.
- N5: No pause menu.
- N6: No sound effects.
- N7: No per-equation timer.
- N8: No multiplication or division in MVP.
