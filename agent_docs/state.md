# State — comebak.in
> Updated: 2026-11-12
> Source of truth for active context. Max 15 lines. Deep detail lives in GitHub issues.

## Active Phase
UI Lab — Flow Screen Completion (post-Home, pre-Launch).

## Current Task
1. Close #45 (Home Screen Assembly & QA) after on-device QA — code is complete, issue is still open.
2. Start #47 (Auth & Splash Screens) in UI Lab.
3. Verify #43 and #44 are complete; close them if code is merged.

## Queue
#47 Auth & Splash → #48 Gameplay HUD → #49 Game Over → #50 Stats → #51 Profile.

## Parked
Swipe-direction game — see `agent_docs/PARKING_LOT.md`.

## Critical Gotchas
See `LEARNINGS_3D_UI.md` + issue comments. Highest risk: Postgres privileges are additive (use triggers); package names `in.comebak.comebak_app` / `in.comebak.comebakApp`; `debugPrint` only; nullable SharedPreferences; `//` comments only; `GameTimerMixin._ticker.stop()` at 0; pause on `inactive` + `hidden`; do NOT set `android.builtInKotlin=true`.