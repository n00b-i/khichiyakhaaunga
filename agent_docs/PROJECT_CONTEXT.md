# Project Context — comeback.in

This file is the anchor. Every agent session reads this first.
It mirrors the locked initialization contract. Do not modify without explicit human approval.

## 1. Project Identity
- Name: comeback.in
- Philosophy: Self-improvement, cognitive training, zero friction.
  No social pressure, no leaderboards, no ranks for the MVP.
- Design ethos: "Absolute Clean". Premium dark mode, generous negative space,
  micro-interactions over visual clutter. UI/UX > Logic.
- Platforms: Android APK and iOS. No web/HTML.

## 2. Tech Stack
- Frontend: Flutter (Dart).
- Backend: Supabase (Auth, PostgreSQL).
- Repo: github.com/n00b-i/khichiyakhaaunga
- Local root: /Users/user1/main/comebak/
- Flutter source: /Development/comeback_app
- Docs: /agent_docs
- Future backend: /src

## 3. Agent Operational Rules
- One thing at a time. Do not write code until explicitly told "Code it".
- No manual file creation: use `cat <<EOF' > /absolute/path/file` commands.
- Surgical updates via `python3 -c` or `sed`.
- Always use absolute paths in terminal commands.
- Never output `#` comments inside bash blocks (zsh will error).
- iOS: native system fonts only. Do NOT use `google_fonts`.
- If iOS breaks: `flutter create . --platforms ios`.
- Solo dev: work ONLY on main. Never create feature branches.
  `git pull` before starting. Commit and push frequently.

## 4. Locked Contracts (read these before coding)
- UI_SYSTEM.md — colors, typography, components, motion, token discipline,
  Saitan near-black exception.
- SCREENS.md — navigation tree, 14 screens, edges. No screen exists without an entry.
- ACCEPTANCE_CRITERIA.md + ac/*.md — 614 numbered items (V/B/I/E/N).
  To request a change, cite the screen and item ID (e.g., "S-05, update B3").

## 5. Game Rules — NON-NEGOTIABLE
- All games: exactly 60 seconds.
- Scoring: +10 correct, -5 wrong, score floor at 0.
- **Wrong answers NEVER pause, lock, disable, or restrict the user.**
   loop continues. Wrong tap = point deduction + visual feedback only.
- **Time end is the ONLY stop condition.**
- No native keyboard in Math Burst. Custom in-app numpad only.
- Bubble games: correct pair freezes existing bubbles; only tapped bubble removed.
- Score cannot drop below 0.
- Wrong pair triggers subtle red shake (AppMotion.wrongMs = 80ms).

## 6. Design Tokens (summary — full contract in UI_SYSTEM.md)
- Canvas: #121212. Surface: #1E1E1E. Border: #2C2C2C. Text: #F5F5F5.
- Primary: #00B386 (Groww Green).
- 7 vibrants only: Red #FF5252, Orange #FF9800, Yellow #FFD600,
  Green #00E676, Blue #00E5FF, Purple #B388FF, Pink #FF4081.
- No pure white (#FFFFFF). No pure black (#000000).
- Glows/shadows under 15% opacity only.
- Native system font. Display 48/w900. HUD 32/w700 tabular. Body 16/w400.

## 7. Deprecated — do not build
- Number Hunt, Rebus, Product Clash, pure HTML/CSS, 1v1 multiplayer.

## 8. Current State
- See state.md for build status.
- See tree.md for file layout.
- See architecture.mr edit-surface rules and agent loop design.
