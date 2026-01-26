# ✅ Todo Tasks Documentation
## Purpose
To provide a simple, satisfying way to track progress on checklists within notes.

## User Flow
1.  User taps "+ Add Todo" inside a note.
2.  Types task text and presses Enter.
3.  Task appears with a checkbox.
4.  User taps checkbox to complete (strikethrough + animation).
5.  User can drag to reorder or swipe to delete.

## Entities
-   **TodoItem**:
    -   `id`: Unique identifier.
    -   `noteId`: Link to parent note.
    -   `text`: Content of the task.
    -   `isCompleted`: Boolean status.
    -   `dueDate`: Optional deadline.

## Benefits
-   **Visual reward**: Animations make completing tasks satisfying.
-   **Focus**: Keep related tasks together within the context of a note.
-   **Clarity**: Progress bars show completion status at a glance.
