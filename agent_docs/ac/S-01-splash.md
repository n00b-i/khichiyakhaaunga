# S-01 SplashScreen

Purpose: session gate while Supabase restores the persisted session. First screen on cold launch.

### Visual AC
- V1: Background is AppColors.background.
- V2: Centered app mark: either Groww Green dot (AppColors.primary, 24px) or a 24px CircularProgressIndicator in AppColors.primary. Pick one, not both.
- V3: No text, no logo image, no app name on this screen.
- V4: No bottom island, no AppBar.
- V5: No shadow, no glow.
- V6: Respects safe area; centered content ignores insets.

### Behavioural AC
- B1: Given app cold start, then SplashScreen is the initial route.
- B2: Given Supabase restores a valid session, then replace to S-04 MainShell within 500 ms of restore completion.
- B3: Given Supabase returns no session, then replace to S-02 SignIn.
- B4: Given restore takes longer than 500 ms, then splash remains visible; no timeout, no fallback.
- B5: Given restore throws an error, then replace to S-02 SignIn (fail-safe to auth, not crash).
- B6: Given the widget unmounts before restore completes, then ignore the result (guard with `mounted` check).

### Interaction coverage
- I1: No tap targets on this screen.
- I2: Android system back exits the app (no previous route to pop).
- I3: iOS swipe-back disabled (no previous route).
- I4: Screen reader announces the app name once ("comebak").
- I5: Portrait only.
- I6: No haptics.
- I7: Loading indicator is decorative (excluded from semantics).
- I8: Splash never re-appears on hot restart in debug (only on cold start).

### Edge cases
- E1: Network offline during restore -> cached session still restores if present; else route to SignIn.
- E2: Session exists but expired -> refresh attempt; success to MainShell, failure to SignIn.
- E3: Restore resolves in <50 ms -> no visible flash of splash beyond one frame.
- E4: Deep link arrives on cold start -> resolve session first, then route to linked screen (MainShell tab or SignIn).
- E5: App launched in release build -> same behaviour; no debug overlays.
- E6: App killed by OS during splash -> next launch re-runs splash normally.

### Non-goals
- N1: No animated logo.
- N2: No version number display.
- N3: No "Checking session..." text.
- N4: No onboarding carousel.
- N5: No splash duration control (it is not a timer, it is a gate).
- N6: No manual skip.
