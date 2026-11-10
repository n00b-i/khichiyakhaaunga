# Decision Log — comeback.in
> Append-only. Never delete. Each entry: Date | Tag | Decision | Why | Impact | Alternative rejected.
> Tags: [ARCH] [DB] [UX] [SEC] [OPS]

---

2026-11-10 [ARCH] Use Repository pattern for all database access.
Why: Keeps UI clean, centralizes RLS error handling, enables unit testing.
Impact: All screens go through GameRepository / SessionRepository / StatsRepository / ProfileRepository.
Rejected: Direct `Supabase.instance.client.from(...)` calls in screens.

---

2026-11-10 [DB] SessionManager is a singleton.
Why: Prevents duplicate session rows on hot reload; one session per app launch.
Impact: `SessionManager().init()` runs once; `_isSessionInitialized` guard in AuthGate.
Rejected: Instance-per-screen.

---

2026-11-10 [DB] Events split into "critical" (instant push) vs "non-critical" (queued, batched on next launch).
Why: Supabase free tier = 50K requests/day. Instant-pushing every tap would blow through itImpact: `game_started`, `game_completed`, `logout` push instantly. `app_opened` and future high-volume events queue.
Rejected: Push everything instantly.

---

2026-11-10 [UX] Separate OAuth clients per platform.
Why: Google requires separate client IDs for iOS and Android, each with its own package + SHA-1.
Impact: Android client uses `in.comebak.comebak_app` + SHA-1. iOS client uses `in.comebak.comebakApp`. Web client is `serverClientId`.
Rejected: Single client ID (not possible).
