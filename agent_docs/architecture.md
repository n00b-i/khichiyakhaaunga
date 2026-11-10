# Architecture — comebak.in

Read PROJECT_CONTEXT.md first; this file builds on it.

## 1. Tech Stack
- Frontend: Flutter (Dart), single package.
- Backend: Supabase (Auth, PostgreSQL, future Edge Functions).
- Platforms: Android APK and iOS. No web.

## 2. Directory Structure

comebak/
|-- agent_docs/           docs layer (human-owned)
|   |-- PROJECT_CONTEXT.md  anchor rulebook
|   |-- UI_SYSTEM.md        locked design contract
|   |-- SCREENS.md          locked navigation tree
|   |-- ACCEPTANCE_CRITERIA.md  index of per-screen AC
|   |-- ac/S-XX-*.md        614 numbered AC items
|   |-- architecture.md     this file
|   |-- state.md            current build status
|   |-- tree.md             file layout snapshot
|   |-- prompts.md          how to instruct the agent
|   `-- roadmap.md          MVP phases
|-- Development/
|   `-- comebak_app/
|       |-- lib/
|       |   |-- app/            composition root (MaterialApp)
|         |-- core/
|       |   |   |-- theme/
|       |   |   |   |-- app_theme.dart   single import point, exports tokens
|       |   |   |   `-- tokens/          app_colors, app_spacing, app_radius, app_sizes, app_text_styles, app_motion
|       |   |   `-- widgets/      cross-feature widgets
|       |   |-- features/
|       |   |   |-- auth/         splash, sign_in, magic_link_sent
|       |   |   |-- shell/        main_shell (bottom island)
|       |   |   |-- home/         home_screen
|       |   |   |-- stats/        stats_screen
|       |   |   |-- profile/      profile_screen
|       |   |   |-- games/
|       |   |   |   |-- shared/     game_result_screen, game_hud, game_scoring, game_timer
|       |   |   |   |-- add_burst/
|       |   |   |   |-- mad_burst/
|       |   |   |   |-- math_burst/
|       |   |   |   `-- memory_of_saitan/
|       |   |   |-- common/       coming_soon_screen
|       |   |   `-- debug/        ui_lab (kDebugMode only)
|       |   |-- ios/              iOS runner
|       |   |-- android/          Android runner
|       |   `-- pubspec.yaml
|       `-- src/                  future Supabase SQL + Edge Functions

Rule: a widget moves to core/widgets/ only if used by 3+ features.
Otherwise it stays inside its feature folder.

## 3. Agent Loop Design (adapted from karpathy/autoresearch)

The autoresearch repo is deliberately minimal: three files. One is fixed
(human-owned), one is the single edit surface (agent-owned), one is the
instruction file (human-owned, never edited by the agent). One measurable
metric determines keep/discard. Each experiment has a hard wall-clock budget.
Manual interrupt is the only stop control.

We adopt the same principles.

### 3.1 Control surface separation
- Contract / instructions (Human): PROJECT_CONTEXT.md, UI_SYSTEM.md, SCREENS.md, AC files.
- Edit surface (Agent): Everything under Development/comebak_app/lib/.
- Verification (Tool): flutter analyze, AC count checks, git diff.

The agent never modifies contract docs without explicit human approval.
The agent never modifies lib/ without an in-scope task referencing an AC ID.

### 3.2 Single edit surface per change
One commit, one concern. If a change touches the theme and a widget and a
screen, it becomes three commits with the intermediate states buildable.
Precedent: Steps 2a, 2b, 3, 4 were split to keep main always green.

### 3.3 Measurable gate
flutter analyze must report "No issues found!" before any commit lands.
Errors block commit. Infos and warnings block only if their file is in the
current change scope. Zero literals policy from UI_SYSTEM section 9 is
enforced by manual review and the UILab screen.

AC counts are verifiable by command. Index totals must match (currently 614 across 14 screens).

### 3.4 Fixed budget, hard limits
- Game sessions: exactly 60 seconds. Timer is the only stop.
- Commits: one concern each. No "while I'm here" additions.
- Agent turns: one step per message. No bundling.
- Deletions: require explicit human approval on a named file list.

Manual interrupt replaces soft stops. "Do not do X" is a contract rule,
not a preference — the agent re-reads the contract every turn.

### 3.5 Keep/discard, never in-place chaos
Commits are the keep/dcard mechanism. A bad commit reverts cleanly.
No uncommitted drift longer than one step.

## 4. Database Schema (locked)

profiles
- id (UUID, references auth.users)
- username (String)
- email (String)

scores
- user_id (UUID, references profiles.id)
- game_id (String) - one of: 'add_burst', 'mad_burst', 'math_burst', 'memory_of_saitan'
- score (Integer)
- time (Integer, seconds)
- accuracy (Float)

No `created_at` required by MVP; add only if analytics demands it.
No leaderboard table. No cross-user read access.

## 5. Security
- Supabase RLS: users read/update only their own profile and scores.
- No service-role keys in the Flutter app.
- Future Edge Functions handle any cross-user aggregation if ever added
  (out of MVP scope).

## 6. Non-negotiable game rule
Wrong answers never pause, lock, disable, or restrict the user.
Wrong tap = point deduction (-5, floor 0) + subtle visual feedback.
The game loop continues until the 60s timer ends. Time end is the ONLY
stop condition. This rule is repeated in PROJECT_CONTEXT.md section 5
and must be cited whenever a game-screen AC is implemented.


## 7. UI component ownership and composition

### 7.1 Three layers

1. **FossUI primitives:** reusable low-level controls and interaction patterns (for example dialogs, alert dialogs and buttons).
2. **Comeback theme/tokens:** the single source of truth in `lib/core/theme/app_theme.dart`. App-owned styling must resolve through these tokens.
3. **Feature composition:** screens compose primitives, provide content and implement feature behavior. Feature-specific widgets stay inside their feature unless the 3+ feature reuse rule is met.

Do not create an app-level wrapper that only renames or forwards a FossUI widget. Introduce a shared abstraction only for repeated application policy/behavior that the dependency does not provide, and obtain human approval as required by UI_SYSTEM.md.

### 7.2 Dialog composition rules

- Use `FossDialog` for standard informational/form/task dialogs.
- Use `FossAlertDialog` for focused confirmations.
- Put title/description in the header API, task UI in content, and actions in the dedicated actions API.
- Never put Cancel/Save/Confirm buttons inside content to simulate a footer.
- Use the existing `AppDialogWidth` tokens/definitions. Do not create screen-specific width constants.
- FossUI 0.1.2's action footer is a trailing-aligned horizontal row; validate narrow widths and long labels. Do not assume automatic wrapping.
- Keep dialog height content-driven and content scrollable where needed. Do not introduce fixed heights as a visual patch.
- Explicitly specify dismissal, loading, error, repeat-submit, focus and keyboard behavior.

### 7.3 Dependency source of truth

The resolved package version in the Flutter lockfile is authoritative for runtime behavior. A caret constraint in pubspec.yaml is not proof of the version currently resolved. When investigating a package:

1. Read the resolved version from pubspec.lock.
2. Inspect the matching package source/API.
3. Check whether the proposed property exists in that version.
4. Add a focused widget test or UI Lab case for any behavior relied upon.
5. Document limitations before adding application workarounds.

### 7.4 UI change verification

For UI/dialog changes, run from the Flutter package directory:

- `flutter pub get` only when dependency metadata changed.
- `flutter analyze`.
- Relevant widget tests.
- Manual checks on a narrow device and a typical device.
- Text scaling, keyboard-open, loading/error and dismissal scenarios.
- `git diff --check` and review the complete diff.

A successful analyzer run does not replace visual or interaction testing.
