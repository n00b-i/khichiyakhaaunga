# AI Prompting Rules for comeback.in

When asking the Agent to write or refactor code, use this exact structure.

[CONTEXT]
We are building a Flutter module for comeback.in. Read PROJECT_CONTEXT.md,
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
