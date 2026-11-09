# UI System — comeback.in

Locked contract. No pure white (#FFFFFF) or pure black (#000000).  
No colours outside this file. No glows/shadows above 15% opacity.

## 1. Colour Tokens

### Base
- Canvas: `#121212` (true dark grey; eye-safe background)
- Surface: `#1E1E1E` (cards, grid boxes, bottom sheets)
- Border: `#2C2C2C` (subtle structure, dividers)
- Text primary: `#F5F5F5` (off-white; prevents glowing blur)

### Brand
- Primary accent: `#00B386` (Groww Green — primary buttons, active states, score)

### Eye-Safe Vibrants (strict limit — 7 only)
| Name   | Hex       |
|--------|-----------|
| Red    | `#FF5252` |
| Orange | `#FF9800` |
| Yellow | `#FFD600` |
| Green  | `#00E676` |
| Blue   | `#00E5FF` |
| Purple | `#B388FF` |
| Pink   | `#FF4081` |

**Rule:** vibrants are reserved for game-specific feedback, charts, and the 7 game identities. Do not create gradients or mix them outside these exact hex values.

## 2. Typography
e system font only (San Francisco on iOS, Roboto on Android).  
**Do not use `google_fonts`** — Apple signing and package conflict.

| Role       | Size | Weight | Features               |
|------------|------|--------|------------------------|
| Display    | 48   | 900    | —                      |
| HUD        | 32   | 700    | Tabular numerals (`fontFeatures: [FontFeature.tabularFigures()]`) |
| Body       | 16   | 400    | —                      |

All text uses the `#F5F5F5` token. No secondary text colour is introduced for the MVP.

## 3. Spacing & Shape

- Negative space is generous; do not compress cards or game canvas.
- Use a 4-px baseline (4 / 8 / 12 / 16 / 24 / 32) for padding and gaps.
- Corner radius: `12` for `GameCard`, `16` for modals/sheets, `999` for pill buttons.
- Shadows: max 15% opacity, always soft and dark — never glowing white.

## 4. Component Contracts

These are the **only** shared shell components. Do not create new custom shell components without approval.

### `GameCantainer: surface `#1E1E1E`, border `#2C2C2C`, radius `12`.
- Leading icon area: 48×48, can use one vibrant token per game.
- Title: body 16 w400, text `#F5F5F5`.
- Optional meta line: body 16 w400, text `#F5F5F5` at 60% opacity (implement as `Color(0x99F5F5F5)` — still within the text token family).
- Trailing chevron: border colour `#2C2C2C`.

### `PrimaryButton`
- Background: `#00B386`.
- Text: `#121212` (canvas) for contrast — do **not** use pure white.
- Height: 52, radius: 999.
- Pressed state: same background, 0.9 opacity.
- No shadow.

### `HudDisplay`
- Uses HUD typography (32 w700 tabular).
- Text colour: `#F5F5F5`.
- Optional accent value (e.g., +10) uses `#00E676` (Green vibrant) for correct, `#FF5252` (Red vibrant) for wrong.
- No background fill; sits on canvas or surface.

## 5. Motion & Feedback

- Haptics: use `vibration` package for correct/incorrect taps.
- Correct pair: floating `+10` in `#00E676`, burst scale 1.0 → 1.15 → 1.0, 180 ms.
- Wrong pair: subtle red shake (`#FF5252`), cycles, amplitude 4 px.
- Transitions: 180–220 ms, ease-out. No bounce or elastic curves.
- Freeze rule (bubble games): when a correct pair is tapped, all existing bubbles freeze exactly where they are; only the tapped bubble is removed.

## 6. Screen Shell Rules

- Home, Stats, Profile, and all game screens use `#121212` canvas.
- No AppBar with pure white background; use canvas or surface.
- No global ranking UI in MVP. Personal bests only.
- Dynamic greeting uses Display or HUD; tagline `#Time to go high and higher#` uses body text.

## 7. Forbidden

- Pure white (`#FFFFFF`), pure black (`#000000`).
- `google_fonts` package.
- Any colour not listed above.
- Gradients, glows, or shadows >15% opacity.
- New shared components without explicit approval.
- Native keyboard in Math Burst — custom in-app numpad only.

## 8. Game Canvas Exception — Memory of Saitan

Memory of Saitan uses a pitch-black play grid. This is the **only** permitted deviation from the no-pure-black rule.

- Grid canvas: `#0A0A0A` (near-black). **Never** `#000000`.
- Everything else on the screen still obeys §§1–7: chrome, HUD, Light Toggle button, text, borders.
- Only the grid cells may use `#0A0A0A`. No other screen may adopt this value.
- If `#0A0A0A` is ever needed elsewhere, it must be added here first with an explicit reason.
