# Acceptance Criteria - comeback.in (Index)

Per-screen acceptance criteria live in one file per screen under agent_docs/ac/.
This file is the index: legend, conventions, and per-screen counts.

## Conventions

- Numbering per screen: V=Visual, B=Behavioural, I=Interaction, E=Edge, N=Non-goal.
- To request a change, cite the screen and item ID (e.g., "S-05, update B3").
- Every AC references tokens from UI_SYSTEM.md section 9. No literals.
- Screen IDs and edges are defined in SCREENS.md. Do not renumber here.
- One file per screen. Do not combine screens in a single file.

## Adding a new screen

1. Add the screen to SCREENS.md first (node row + edges).
2. Create agent_docs/ac/S-XX-kebab-name.md with sections in this order:
   Purpose, Visual AC, Behavioural AC, Interaction coverage, Edge cases, Non-goals.
3. Add a row to the table below.
4. Commit the new file and this index in one commit.

## Files and counts

| Screen ID | Name                       | File                          | V  | B  | I  | E  | N  | Total |
|-----------|----------------------------|-------------------------------|----|----|----|----|----|-------|
| S-01      | SplashScreen               | ac/S-01-splash.md             | 6  | 6  | 8  | 6  | 6  | 32    |
| S-02      | SignInScreen               | ac/S-02-sign-in.md            | 11 | 8  | 12 | 12 | 10 | 53    |
| S-03      | MagicLinkSentScreen        | ac/S-03-magic-link-sent.md    | 10 | 6  | 8  | 10 | 7  | 41    |
| S-04      | MainShell                  | ac/S-04-main-shell.md         | 10 | 6  | 11 | 5  | 6  | 38    |
| S-05      | HomeScreen                 | ac/S-05-home.md               | 11 | 8  | 10 | 9  | 10 | 48    |
| S-06      | StatsScreen                | ac/S-06-stats.md              | 11 | 8  | 9  | 10 | 8  | 46    |
| S-07      | ProfileScreen              | ac/S-07-profile.md            | 10 | 7  | 10 | 10 | 10 | 47    |
| S-08      | AddBurstGameScreen         | ac/S-08-add-burst.md          | 10 | 12 | 10 | 10 | 8  | 50    |
| S-09      | MadBurstGameScreen         | ac/S-09-mad-burst.md          | 10 | 12 | 10 | 10 | 8  | 50    |
| S-10      | MathBurstGameScreen        | ac/S-10-math-burst.md         | 12 | 11 | 12 | 11 | 8  | 54    |
| S-11      | MemoryOfSaitanGameScreen   | ac/S-11-memory-of-saitan.md   | 10 | 10 | 10 | 10 | 8  | 48    |
| S-12      | GameResultScreen           | ac/S-12-game-result.md        | 11 | 7  | 9  | 8  | 8  | 43    |
| S-13      | UILabScreen (debug only)   | ac/S-13-ui-lab.md             | 10 | 6  | 8  | 5  | 6  | 35    |
| S-14      | ComingSoonScreen           | ac/S-14-coming-soon.md        | 7  | 5  | 6  | 5  | 6  | 29    |
| Total     | 14 screens                 |                               | 139 | 112 | 133 | 121 | 109 | 614 |

## Verification command

Run from repo root to verify counts match this index:

  for f in agent_docs/ac/*.md; do echo "$(basename $f): $(grep -cE '^- (V|B|I|E|N)[0-9]+:' "$f")"; done
