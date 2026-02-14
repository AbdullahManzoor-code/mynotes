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

## Predefined Question Categories
To guide users through their self-reflection journey, the app provides several categories of prompts:

### 🌟 Gratitude
-   What are three small things that brought you joy today?
-   Who is someone you're thankful for, and why?
-   What is a comfort in your life that you often take for granted?

### 📈 Growth & Learning
-   What was the biggest lesson you learned this week?
-   In what way did you step outside your comfort zone today?
-   If you could redo one part of today, what would you do differently?

### 🧘 Mindfulness & Emotions
-   How would you describe your current energy level?
-   What is a thought that has been repeating in your mind today?
-   What does "peace" look like to you right now?

### 🚀 Productivity & Purpose
-   What was your most meaningful accomplishment today?
-   What is one thing you can do tomorrow to make it successful?
-   How did your actions today align with your long-term values?

## Customization
Users can:
1.  **Add Custom Prompts**: Create their own questions and assign them to existing or new categories.
2.  **Frequency Settings**: Choose how often prompts from certain categories appear.
3.  **Shuffle**: Manually request a new prompt if the current one doesn't resonate.

## Benefits
-   **Habit forming**: Daily notifications encourage consistency.
-   **Mental Clarity**: Structured prompts help overcome writer's block.
-   **Private**: Safe space for personal thoughts.
