# 🧠 Ask Yourself Documentation
## Concept
A dedicated space for self-reflection, gratitude, and daily journaling to promote mental well-being.

## UX Flow
1.  User taps "Ask Yourself" on Home Screen.
2.  Presented with a daily rotating prompt (e.g., "What made you smile today?").
3.  User writes an answer in a distraction-free editor.
4.  Entry is saved to a separate "Reflection" history.

## Technical Details
-   **Prompt Rotation**: Logic to select a new prompt daily from a local Pre-defined list or user custom list.
-   **Privacy**: Reflections are stored locally and marked with a privacy indicator.
-   **Storage**: Dedicated `reflection_notes` table in SQLite.

## Benefits
-   **Habit forming**: Daily notifications encourage consistency.
-   **Mental Clarity**: Structured prompts help overcome writer's block.
-   **Private**: Safe space for personal thoughts.
