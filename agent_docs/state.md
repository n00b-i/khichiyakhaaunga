# State — comebak.in
> Updated: 2026-11-12
> Source of truth for active context. Max 15 lines. See GitHub issues for deep detail.

## Active Phase
Phase 4: Launch Readiness.

## Current Task
1. Verify #24 (Postgres trigger on INSERT for streak).
2. Verify #21 (empty name crash in ComebakAvatar).
3. Close #15 and #30 (code complete in e094959 but still open on board).
4. Privacy Policy + Store metadata (Screenshots, Data Safety).

## Recent Gotchas (The "Never Again" List)
1. Postgres privileges are additive. Rely on triggers.
2. Package names: Android = `in.comebak.comebak_app`. iOS = `in.comebak.comebakApp`.
3. Logs: `debugPrint`, NOT `developer.log`.
4. Schema drift: `SELECT column_name` before assuming.
5. SharedPreferences must be nullable in singletons.
6. Comment syntax: `//` only. Never `///`. Never end with `/`.
7. Connectivity: `ConnectivityService.instance.isOffline()` (interface + real ping).
8. Google Sign-In: Never wrap `authencate()` in a short timeout.
9. `GameTimerMixin`: MUST call `_ticker.stop()` at 0, else 60x/sec `onTimeUp`.
10. AppLifecycle: Pause on `inactive` and `hidden`, not just `paused`.
11. KGP warning is upstream (flutter/flutter#195467). Do NOT set `android.builtInKotlin=true`.
12. Crashlytics is disabled in debug by default; force-enable with `kDebugMode` guard for test.
