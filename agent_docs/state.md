# State — comeback.in
> Updated: 2026-11-10 17:00 IST
> Source of truth for active context. Max 15 lines. Never list completed features. The code is the truth of what works.

## Active Phase
Phase 2: DB Integration → Merged. 
Next: Phase 3 MVP Polish (Profile Edit, PB Badges).

## Current Task
Issue #14: New PB Badge on GameResultScreen.

## What's Blocked
None.

## Recent Gotchas (The "Never Again" List)
1. Postgres privileges are additive. `REVOKE UPDATE (column)` does not override table-level `GRANT UPDATE`. Rely on triggers for column-level security.
1. Package names: Android = `in.comebak.comebak_app` (underscore). iOS = `in.comebak.comebakApp` (camelCase). Never assume they match.
2. Logs: Use `debugPrint`, NOT `developer.log`. `developer.log` does not show in `flutter logs`.
3. Schema drift: Always run `SELECT column_name FROM information_schema.columns` before assuming a column exists. `events` was missing `session_id`.
4. SharedPreferences: Must be `SharedPreferences?` (nullable) in singletons to avoid `LateInitializationError`.
5. **FK constraint dropped**: `matches_session_id_fkey` was removed on 2026-11-10 for offline sync testing. MUST restore after offline session queuing is built. Tracked in GitHub issue.
6. **Comment syntax**: Use `//` for comments. NEVER `///`. Never end a comment line with `/`.
