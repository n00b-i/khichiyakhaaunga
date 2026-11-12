# Learnings: Building Comebak with a Browser AI

> Updated: 2026-11-12
> Rules and anti-patterns for using a browser-based LLM to write Flutter/Dart code.

## 1. The Golden Rule: Source of Truth
1. The AI MUST read the remote repository (https://github.com/n00b-i/khichiyakhaaunga) before proposing any code while ensuring that on local there is no difference, strictly!!!!. 
2. The AI MUST NOT ask the user to paste code if it can fetch it via GitHub URL.
3. If the AI cannot fetch the code, it MUST ask the user to run `cat <file>` or `sed -n 'X,Yp' <file>`.

## 2. Why Python/Sed Scripts Fail (The "Half-Broken" Problem)
1. **Whitespace Mismatch:** Python `.replace()` and `sed` require byte-for-byte exact matches. A single missing space causes a silent failure or a half-applied patch.
2. **Partial Writes:** If a script modifies 3 lines successfully but fails on the 4th, the file is left in a broken state. This requires `git checkout` and wasted time.
3. **The Fix:** NEVER use `sed` or Python scripts for structural changes (adding/removing blocks, changing methods). ALWAYS provide the complete, final file code so the user can paste it cleanly in Cursor.

## 3. Why Terminal Paste Fails (The "Clipboard Corruption" Problem)
1. **Buffer Drops:** Pasting large code blocks (100+ lines) into the macOS terminal using `cat > file` drops random characters (e.g., `AppColors` becomes `ppColors`, `AppTextStyles.body` becomes `AppTextStylesody`).
2. **The Fix:** Never provide `cat > file` commands for large Dart files. Provide the code in a markdown block and tell the user to use `cursor <file>` to open the file and paste it.

## 4. The "Analyze is Clean" Trap
1. `flutter analyze` only checks syntax and static types. It does NOT catch layout overflows, missing UI elements, or broken navigation flows.
2. **The Fix:** Every UI change MUST have a numbered on-device test checklist (e.g., "1. Tap bubble. 2. Verify green color. 3. Verify text floats up").

## 5. Upstream vs. App Bugs
1. Warnings from Flutter or Firebase plugins (like the KGP warning) are upstream issues.
2. **The Fix:** Track them in `state.md`. Do not waste time writing code to fix them unless there is an official update.

## 6. Comment Preservation
1. Comments are the historical memory of the project (e.g., `[ISSUE-22]`).
2. The AI MUST preserve every existing comment when providing a full file replacement. New changes MUST be documented with a new `[ISSUE-X]` comment explaining the impact.