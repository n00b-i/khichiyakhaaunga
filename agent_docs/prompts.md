# AI Prompting Rules for comeback.in

When asking AI to write code for this project, always use this structure:

**[CONTEXT]**
We are building a Flutter game module for comeback.in. The design philosophy is "UI > Text" and "Zero Friction".

**[TASK]**
Build the `[GAME NAME]` module in Flutter. It must use `CustomPaint` and `GestureDetector` for smooth 60fps animations.

**[RULES]**
*   Use pure Flutter for all visuals (no external images).
*   Add haptics (`HapticFeedback.lightImpact()`).
*   Never pause the game loop unless the user finishes or the timer ends.
*   Match the app's dark navy and neon color palette.

**[FEEDBACK]**
(Provide specific UI feedback here if iterating).
