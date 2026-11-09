# Project Tree Structure

comebak/
|-- agent_docs/
|   |-- PROJECT_CONTEXT.md      # Anchor rulebook
|   |-- UI_SYSTEM.md            # Design tokens & component contract
|   |-- SCREENS.md              # Navigation tree
|   |-- ACCEPTANCE_CRITERIA.md  # Index of per-screen AC
|   |-- architecture.md         # Tech stack & agent loop rules
|   |-- state.md                # Current build status
|   |-- tree.md                 # This file
|   |-- prompts.md              # Instructions for agent
|   |-- roadmap.md              # MVP phases
|   `-- ac/                     # 14 per-screen acceptance criteria files
|       |-- S-01-splash.md
|       |-- S-02-sign-in.md
|       |-- ...
|       `-- S-14-coming-soon.md
|-- Development/
|   `-- comeback_app/
|       |-- lib/
|       |   |-- app/
|       |   |   `-- app.dart            # MaterialApp composition root
|       |   |-- core/
|       |   |   |-- theme/
|       |   |   |   |-- app_theme.dart  # Single import point
|       |   |   |   `-- tokens/         # app_colors, spacing, etc.
|       |   |   `-- widgets/
|       |   |       `-- game_card.dart  # Shared GameCard
|       |   |-- features/
|       |   |   |-- common/
|       |   |   |   `-- coming_soon_screen.dart
|       |   |   `-- home/
|       |   |       `-- home_screen.dart
|       |   `-- main.dart               # Thin entry point
|       |-- ios/                        # iOS Runner (tracked)
|       |-- android/                    # Android Runner (tracked)
|       `-- pubspec.yaml
|-- src/                                # Future Supabase SQL & Edge Functions
|-- .gitignore
|-- CONTRIBUTING.md
`-- README.md
