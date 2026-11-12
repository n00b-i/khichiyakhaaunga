# Parking Lot — Deferred Ideas

> Ideas captured but deliberately deferred. Do not implement until explicitly unparked.
> Unpark by moving the entry to `roadmap.md` + opening a GitHub issue.

---

## Swipe Direction Game (working title: "Swipe Burst")

- **Captured:** 2026-11-12
- **Core loop:** Show a direction (up / down / left / right). User swipes that direction. 60-second session. Score = number of correct swipes.
- **Theme (tentative):** Neon Yellow (`#FFD600`).
- **Open design questions:**
  - Wrong-swipe penalty: lose time? reset streak? no penalty?
  - Streak multiplier: consecutive correct swipes scale score?
  - Direction-change speed curve: constant, or accelerate at 0s/30s/45s?
  - Direction display: text label, arrow icon, or both?
  - Haptics on correct vs wrong (`ComebakHaptics.success()` / `.error()`)?
  - Layout: single arrow centered, or 4-way ring with active highlight?
- **Dependencies:** none. Prototype can live in `ui_lab/5_catalog/` after Flow screens.
- **Status:** PARKED — post-UI-Lab / post-MVP.