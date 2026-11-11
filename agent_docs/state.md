# State — comebak.in
> Updated: 2026-11-11
> Source of truth for active context. Max 15 lines. Never list completed features. See GitHub issues for deep architecture.

## Active Phase
Phase 3 MVP Polish -> Launch Readiness.

## Current Task
Issue #11: Graceful Error Handling for Sign-In and Stats Screens.

## Recent Gotchas (The "Never Again" List)
1. Postgres privileges are additive. Rely on triggers.
2. Package names: Android = `in.comebak.comebak_app`. iOS = `in.comebak.comebakApp`.
3. Logs: Use `debugPrint`, NOT `developer.log`.
4. Schema drift: Always run `SELECT column_name` before assuming.
5. SharedPreferences: Must be nullable in singletons.
6. Comment syntax: `//` only. Never `///`. Never end with `/`.
7. GameTimerMixin: Implemented for all games except `memory_of_saitan` (see #15).
