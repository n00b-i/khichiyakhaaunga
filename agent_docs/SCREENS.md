# Screens - comeback.in

Single source of truth for every screen and its navigation.
Rule: no screen may exist in lib/ without an entry here. Update this file BEFORE coding a new screen.

Status markers:
- [BUILT]   built and matches contract
- [PARTIAL] built but incomplete
- [PENDING] spec'd, not built
- [DEBUG]   kDebugMode only, never in release

## Navigation Tree

App (main.dart)
|
+-- SplashScreen [PENDING]
|   +-- no session      -> SignInScreen
|   +-- valid session   -> MainShell
|
+-- SignInScreen [PENDING]
|   +-- submit email    -> MagicLinkSentScreen
|   +-- Google/Apple    -> OAuth -> MainShell
|
+-- MagicLinkSentScreen [PENDING]
|   +-- link tapped     -> MainShell
|   +-- back            -> SignInScreen
|
+-- MainShell [PARTIAL]
|   +-- Tab 1 Home [PARTIAL]
|   |   +-- Add Burst         -> AddBurstGameScreen | ComingSoonScreen
|   |   +-- Mad Burst         -> MadBurstGameScreen | ComingSoonScreen
|   |   +-- Math Burst        -> MathBurstGameScreen | ComingSoonScreen
|   |   +-- Memory of Saitan  -> MemoryOfSaitanGameScreen | ComingSoonScreen
|   +-- Tab 2 Stats [PENDING]
|   +-- Tab 3 Profile [PENDING] -> Logout -> SignInScreen
|   +-- Tab 4 UI Lab [DEBUG]    -> UILabScreen
|
+-- AddBurstGameScreen [PENDING]         -> GameResultScreen
+-- MadBurstGameScreen [PENDING]         -> GameResultScreen
+-- MathBurstGameScreen [PENDING]        -> GameResultScreen
+-- MemoryOfSaitanGameScreen [PENDING]   -> GameResultScreen
|
+-- GameResultScreen [PENDING]
|   +-- Play Again      -> restart same game
|   +-- Done            -> MainShell (Home)
|
+-- ComingSoonScreen [PARTIAL]  -> back -> previous

## Screen Nodes

| ID   | Screen                    | Target file                                         | Status    |
|------|---------------------------|-----------------------------------------------------|-----------|
| S-01 | SplashScreen              | features/auth/splash_screen.dart                    | PENDING   |
| S-02 | SignInScreen              | features/auth/sign_in_screen.dart                   | PENDING   |
| S-03 | MagicLinkSentScreen       | features/auth/magic_link_sent_screen.dart           | PENDING   |
| S-04 | MainShell                 | features/shell/main_shell.dart                      | PARTIAL   |
| S-05 | HomeScreen                | features/home/home_screen.dart                      | PARTIAL   |
| S-06 | StatsScreen               | features/stats/stats_screen.dart                    | PENDING   |
| S-07 | ProfileScreen             | features/profile/profile_screen.dart                | PENDING   |
| S-08 | AddBurstGameScreen        | features/games/add_burst/add_burst_screen.dart      | PENDING   |
| S-09 | MadBurstGameScreen        | features/games/mad_burst/mad_burst_screen.dart      | PENDING   |
| S-10 | MathBurstGameScreen       | features/games/math_burst/math_burst_screen.dart    | PENDING   |
| S-11 | MemoryOfSaitanGameScreen  | features/games/memory_of_saitan/memory_of_saitan_screen.dart | PENDING |
| S-12 | GameResultScreen          | features/games/common/game_result_screen.dart       | PENDING   |
| S-13 | UILabScreen               | features/debug/ui_lab/ui_lab_screen.dart            | PENDING   |
| S-14 | ComingSoonScreen          | features/common/coming_soon_screen.dart             | PARTIAL   |

## Navigation Edges

| From | Action           | To                  | Type    |
|------|------------------|---------------------|---------|
| S-01 | valid session    | S-04 MainShell      | replace |
| S-01 | no session       | S-02 SignIn         | replace |
| S-02 | submit email     | S-03 MagicSent      | push    |
| S-02 | Google / Apple   | OAuth               | system  |
| S-03 | link tapped      | S-04 MainShell      | replace |
| S-03 | back             | S-02 SignIn         | pop     |
| S-05 | tap game card    | S-08/09/10/11 or S-14 | push  |
| S-08 | timer ends       | S-12 GameResult     | replace |
| S-09 | timer ends       | S-12 GameResult     | replace |
| S-10 | timer ends       | S-12 GameResult     | replace |
| S-11 | timer ends       | S-12 GameResult     | replace |
| S-12 | Play Again       | restart same game   | replace |
| S-12 | Done             | S-04 MainShell Home | popUntil|
| S-07 | Logout           | S-02 SignIn         | replace |
| S-14 | back             | previous            | pop     |

## Rules

1. No orphan screens: every screen in lib/ must be reachable from S-01 or S-04.
2. No unlisted screens: every screen must appear here before code is written.
3. S-13 and Tab 4 must be wrapped in kDebugMode. Never rendered in release.
4. Auth always gates: unauthenticated users cannot reach S-04.
5. Game results are terminal: after 60s, replace to S-12. No pop back to game.
6. Update this file first, then write acceptance criteria, then code.
