# UI Lab Learnings: 3D Claymorphism & Grid Layouts

This document records the architectural and technical decisions made while building the 3D Game Icons and the 2-column Grid, ensuring we don't repeat mistakes in the production app.

## 1. CustomPainter Geometry & Scaling
*   **The 140x140 Bounding Box:** All isometric cubes are designed on a 140x140 logical grid. When rendering in Flutter, the scale factor must be `size.width / 140.0` to prevent stretching or clipping.
*   **Soft Edges (Clay Effect):** Standard polygons (`Path`) have sharp 90-degree vertices. To achieve a soft, clay-like bevel, we draw the path twice: first with `PaintingStyle.stroke` using a thick `strokeWidth` and `StrokeJoin.round`, then with `PaintingStyle.fill`.
*   **Geometry Exception:** Unlike UI layout tokens (padding/margins), isometric math (e.g., `Offset(0, -40)`, `w / 2`) is kept directly inside the `CustomPainter` to maintain the precision of the geometric shape without polluting the global `UiLabLayout` tokens.

## 2. True 3D Emboss Text
*   **The 3-Layer Technique:** To make the math symbols (`+`, `×`, `Σ`) look molded out of the cube rather than pasted on top, we use a 3-layered `TextPainter`.
    1.  **Bottom Layer:** Deep shadow color, offset down (`dy: 4`).
    2.  **Middle Layer:** Mid-tone accent color, offset halfway (`dy: 2`).
    3.  **Top Layer:** Pure white with a subtle drop shadow (`dy: 2, blur: 2`) to simulate a cast shadow on the surface.

## 3. Ambient Occlusion & Lighting
*   **Colored Drop Shadows:** Never use pure black for 3D drop shadows. Use the game's darkest base color with a low opacity (`alpha: 0.3` to `0.4`) and a large blur (`blurRadius: 15.0`). This grounds the icon in the card.
*   **Specular Gloss:** A semi-transparent white polygon on the top-left face is required to simulate the light hitting a glossy, physical object.

## 4. 2-Column Grid Layout
*   **Fixed Card Height:** To prevent jagged rows when text wraps, the `ComebakGameCard` must have a fixed height (e.g., `180.0`).
*   **Expanded Rows:** For a perfect 2-column layout, use a `Row` with two `Expanded` widgets and a `SizedBox` gap between them.
*   **Icon Container:** The 3D icons are scaled to `80.0`. They sit inside an `Expanded` widget in the top half of the card, ensuring perfect vertical centering regardless of the 3D bounding box.

## 5. File & Token Management
*   **Avoid Duplicate Colors:** When applying `sed` commands for tokens, always verify the file state afterward. If a conflict arises (like the BODMAS duplicates), completely overwrite the token file with the final clean version instead of trying to patch it.
*   **No `const` on dynamic widgets:** When passing `size: ComebakLayout.gameIconSize` to a widget, do not use the `const` keyword on the parent widget, as it causes compile errors.