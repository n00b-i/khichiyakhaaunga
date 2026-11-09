# Current Project State

## Overall Status
- Foundation, docs, and design system are locked.
- App shell (Theme + GameCard + Home) is built and building cleanly.
- Zero `flutter analyze` issues.

## What is Built
- **Docs:** UI_SYSTEM.md, SCREENS.md, ACCEPTANCE_CRITERIA.md (14 files, 614 items), PROJECT_CONTEXT.md, architecture.md.
- **Theme:** Split tokens in `lib/core/theme/tokens/` (colors, spacing, radius, sizes, text styles, motion). Single import point in `app_theme.dart`.
- **Core UI:** `GameCard` fully rewritten to contract (no shadow, radius 12, border, 48x48 icon, press state, haptics).
- **Screens:** `HomeScreen` (greeting, tagline, 4 GameCards), `ComingSoonScreen`, `ComebakApp` (composition root).
- **Platform:** iOS folder generated, `.gitignore` correct. Android ready.

## Active Task (Next up)
- Build `MainShell` (S-04) — bottom island with Home / Stats / Profile (+ debug UI tab).

## Blockers / Notes
- No blocking issues.
-arget is Android APK **and** iOS (not Android-only).
- Never use `google_fonts`. Native system fonts only.
- Game rule: wrong answers subtract points but NEVER pause, lock, or restrict the user. The 60s timer is the only stop.
- No glowing orbs. Glows/shadows must be under 15% opacity. Absolute Clean ethos.
