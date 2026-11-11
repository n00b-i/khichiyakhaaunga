# State — comebak.in
> Updated: 2026-11-12
> Source of truth for active context. Max 15 lines. Never list completed features. See GitHub issues for deep architecture.

## Active Phase
Phase 4: Launch Readiness.

## Current Task
Crashlytics integration & Store Metadata.

## Recent Gotchas (The "Never Again" List)
1. Postgres privileges are additive. Rely on triggers.
2. Package names: Android = `in.comebak.comebak_app`. iOS = `in.comebak.comebakApp`.
3. Logs: Use `debugPrint`, NOT `developer.log`.
4. Schema drift: Always run `SELECT column_name` before assuming.
5. SharedPreferences: Must be nullable in singletons.
6. Comment syntax: `//` only. Never `///`. Never end with `/`.
7. Connectivy: Use `ConnectivityService.instance.isOffline()` (interface + real internet ping).
8. Interactive Flows: Never wrap `GoogleSignIn.authenticate()` in a short timeout.
9. Timers: GameTimerMixin MUST call `_ticker.stop()` when time reaches 0, otherwise `onTimeUp()` fires 60x/sec.
10. AppLifecycle: Pause timers on `inactive` and `hidden`, not just `paused`.
