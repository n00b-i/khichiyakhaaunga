# AI Prompting Rules for comebak.in

When asking the Agent to write or refactor code, use this exact structure.

[CONTEXT]
We are building a Flutter module for comebak.in. Read PROJECT_CONTEXT.md,
UI_SYSTEM.md, and SCREENS.md before writing any code. We use the modular
feature-first architecture defined in architecture.md.

[TASK]
Build or rewrite [SCREEN/GAME NAME] (S-XX). Cite the specific Acceptance
Criteria IDs being implemented (e.g., S-05 V1, B3, I2).

[RULES]
- Zero hardcoded values. Use tokens from lib/core/theme/.
- No pure black (#000000) or white (#FFFFFF). Glows <15% opacity.
- Game rule: Wrong answers deduct points but NEVER pause, lock, or
  restrict the user. The 60s timer is the only stop condition.
- Native system fonts only. No google_fonts.
- Use withValues(alpha:) not withOpacity.
- One thing at a time: do not bundle unrelated changes in one commit.
- Follow the Karpathy loop: contract docs are human-owned, lib/ is agent-owned.

[FEEDBACK]
(Provide specific UI feedback or bug reports here if iterating).


## UI / dependency investigation requirements

Before changing UI code:

- Read the applicable screen AC and `UI_SYSTEM.md`.
- Inspect the current implementation and existing shared tokens/components before proposing new abstractions.
- Identify the exact resolved package version in `pubspec.lock`; inspect that version's source/API before using a property or assuming behavior.
- Distinguish verified package behavior from assumptions. Do not claim a widget wraps, scrolls, stacks, or handles keyboard insets unless verified.
- Keep feature behavior in the feature. Reuse app tokens. Do not introduce new shared shell components without approval.
- For dialogs, follow UI_SYSTEM.md §10: correct FossUI primitive, dedicated header/content/actions regions, no footer actions inside content, tokenized width, content-driven height, and explicit dismissal/loading/error behavior.

## Git safety and local work

- Never create or switch branches unless the user explicitly asks.
- Never run `git reset`, `git clean`, `git stash`, force-push, or destructive checkout as a convenience.
- Before editing, inspect `git status --short` and the relevant diff. Treat every pre-existing modification and untracked file as user-owned.
- Do not overwrite a modified file without first reading and preserving the user's changes.
- Do not commit or push unless explicitly authorized.
- Keep documentation edits separate from unrelated Dart/business-logic changes.

## Completion report

At the end, report exact files changed, commands/tests run, results, known limitations and anything the user must verify on-device. Never claim a test passed unless it was actually run.
