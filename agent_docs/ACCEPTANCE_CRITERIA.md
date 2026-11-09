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

| Screen ID | Name                | File                          | V  | B | I  | E  | N  | Total |
|-----------|---------------------|-------------------------------|----|---|----|----|----|-------|
| S-04      | MainShell           | ac/S-04-main-shell.md         | 10 | 6 | 11 | 5  | 6  | 38    |
| S-05      | HomeScreen          | ac/S-05-home.md               | 11 | 8 | 10 | 9  | 10 | 48    |
| S-06      | StatsScreen         | ac/S-06-stats.md              | 11 | 8 | 9  | 10 | 8  | 46    |
| S-07      | ProfileScreen       | ac/S-07-profile.md            | 10 | 7 | 10 | 10 | 10 | 47    |

Total items defined: 179.

## Pending screens (files not yet created)

| Screen ID | Name                       | Status  |
|-----------|----------------------------|---------|
| S-01      | SplashScreen               | pending |
| S-02      | SignInScreen               | pending |
| S-03      | MagicLinkSentScreen        | pending |
| S-08      | AddBurstGameScreen         | pending |
| S-09      | MadBurstGameScreen         | pending |
| S-10      | MathBurstGameScreen        | pending |
| S-11      | MemoryOfSaitanGameScreen   | pending |
| S-12      | GameResultScreen           | pending |
| S-13      | UILabScreen (debug only)   | pending |
| S-14      | ComingSoonScreen           | pending |

## Verification command

Run from repo root to verify counts match this index:

  for f in agent_docs/ac/*.md; do echo "$(basename $f): $(grep -cE '^- (V|B|I|E|N)[0-9]+:' "$f")"; done
