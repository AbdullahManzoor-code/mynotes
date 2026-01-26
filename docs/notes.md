# 📝 Notes (Text, Audio, Video) Documentation
## Core Feature Breakdown
The multimedia note editor is the heart of MyNotes, designed for rich expression.

## Features
### 1. Rich Text Editor
-   Formatting: Bold, Italic, Lists, Links.
-   Auto-save: Saves changes automatically to preventing data loss.

### 2. Audio Recording
-   **Usage**: Tap record, speak, tap stop.
-   **Storage**: Saved as compressed `.m4a` files locally.
-   **Playback**: Integrated mini-player with visualizer.

### 3. Video Handling
-   **Usage**: Record new or pick existing video.
-   **Compression**: Auto-compressed to 720p/MP4 to save space.
-   **Playback**: In-app player with basic controls.

### 4. Image Handling
-   **Usage**: Pick from gallery or camera.
-   **Optimization**: Compressed to max 1080p width to maintain performance.

## Architecture
-   **Media Storage**: Files stored in app's local document directory.
-   **Database**: Paths and metadata stored in SQLite.
-   **State**: `NoteBloc` manages the editor state and media attachments.
