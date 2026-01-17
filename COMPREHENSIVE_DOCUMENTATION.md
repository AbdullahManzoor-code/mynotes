# MyNotes - Flutter Multimedia Notes App

A production-ready, feature-rich multimedia notes app built with Flutter, BLoC architecture, and clean code principles.

## 🎯 Features

### Core Features
- ✅ **Rich Text Notes** - Create and edit detailed text notes
- ✅ **Multimedia Support** - Attach images, audio recordings, and videos
- ✅ **Todo Lists** - Add checklists within notes with completion tracking
- ✅ **Alarms & Reminders** - Set reminders and repeating alarms for notes
- ✅ **Smart Organization** - Pin, archive, tag, and color-code notes
- ✅ **PDF Export** - Export notes with embedded media as professional PDFs
- ✅ **Search & Filter** - Full-text search and tag-based filtering
- ✅ **Responsive UI** - Adapts beautifully to mobile, tablet, and desktop

### Media Features
- 📸 **Image Support** - Camera or gallery uploads with automatic compression
- 🎙️ **Audio Recording** - Record voice notes directly in the app
- 🎥 **Video Recording** - Short video clips (up to 60 seconds) with compression
- 🗜️ **Automatic Compression** - Smart compression to save storage space

### Notification System
- 🔔 **Local Notifications** - Real-time notifications for reminders
- ⏰ **Alarm Support** - Daily, weekly, and monthly recurring alarms
- 📲 **Full-screen Alerts** - Prominent alerts for urgent reminders

## 🏗️ Architecture

### Clean Architecture Layers

```
lib/
├── core/                 # Core/shared layer
│   ├── constants/       # App-wide constants
│   ├── themes/          # Theme and styling
│   ├── utils/           # Utility functions
│   ├── media/           # Media compression
│   ├── pdf/             # PDF generation
│   └── notifications/   # Notification service
│
├── data/                # Data layer
│   ├── models/          # Data models (JSON serialization)
│   ├── datasources/     # Local database access
│   └── repositories/    # Repository implementations
│
├── domain/              # Domain layer
│   ├── entities/        # Core business entities
│   │   ├── note.dart
│   │   ├── media_item.dart
│   │   ├── todo_item.dart
│   │   └── alarm.dart
│   ├── repositories/    # Repository interfaces
│   └── usecases/        # Use cases (optional)
│
└── presentation/        # Presentation layer
    ├── bloc/            # BLoC state management
    ├── pages/           # Full screen pages
    └── widgets/         # Reusable UI components
```

### State Management (BLoC Pattern)

The app uses **BLoC (Business Logic Component)** for clean state management:

```dart
// Events represent user actions
class CreateNoteEvent extends NoteEvent { ... }
class AddMediaToNoteEvent extends MediaEvent { ... }
class SetAlarmEvent extends AlarmEvent { ... }

// States represent UI states
class NoteLoading extends NoteState { ... }
class NoteCreated extends NoteState { ... }
class NoteError extends NoteState { ... }

// BLoCs handle events and emit states
class NotesBloc extends Bloc<NoteEvent, NoteState> {
  Future<void> _onCreateNote(CreateNoteEvent event, Emitter emit) async {
    // Handle event
    emit(NoteCreated(note));
  }
}
```

**Why BLoC?**
- ✅ Clean separation of business logic from UI
- ✅ Testable state management
- ✅ Reactive programming with streams
- ✅ Reusable across widgets
- ✅ Easy to debug and maintain

## 📦 Key Technologies

### State Management & Architecture
- **flutter_bloc** - BLoC pattern implementation
- **equatable** - Equality comparison for entities

### Database & Storage
- **sqflite** - Local SQLite database
- **path_provider** - Access app directories

### Media Handling
- **image_picker** - Pick images from gallery/camera
- **flutter_image_compress** - Compress images to medium quality
- **video_compress** - Compress videos to 720p
- **video_player** - Play videos
- **record** - Record audio
- **audioplayers** - Play audio files

### Notifications
- **flutter_local_notifications** - Local push notifications
- **timezone** - Timezone-aware scheduling

### PDF Generation
- **pdf** - Generate PDF documents
- **printing** - Print and PDF preview

### Utilities
- **intl** - Date/time formatting
- **uuid** - Generate unique IDs
- **permission_handler** - Request device permissions
- **file_picker** - File selection
- **share_plus** - Share functionality

## 🎨 Theme & Styling

### Centralized Theme System

All theming is centralized to avoid duplication:

```dart
// Single source of truth for colors
class AppColors {
  static const Color primaryLight = Color(0xFF6750A4);
  static const Color imageColor = Color(0xFF4CAF50);
  static const Color audioColor = Color(0xFFFF9800);
  // ... more colors
}

// Material 3 compatible themes
class AppTheme {
  static ThemeData get lightTheme { ... }
  static ThemeData get darkTheme { ... }
}

// Use in app
theme: AppTheme.lightTheme,
darkTheme: AppTheme.darkTheme,
```

### Responsive Design

The app adapts to all screen sizes using responsive utilities:

```dart
// Breakpoints
- Mobile: < 600dp
- Tablet: 600dp - 900dp
- Desktop: >= 1200dp

// Responsive helpers
if (ResponsiveUtils.isMobile(context)) { ... }
final columns = ResponsiveUtils.getGridColumns(context); // 2-4 columns
final padding = ResponsiveUtils.getResponsivePadding(context);
```

## 🗜️ Media Compression

### Why Compression?

**Without compression:**
- Single photo: 3-5 MB
- One hour of video: 500+ MB
- App grows quickly, affects performance

**With medium-quality compression:**
- Photos: 60-70% size reduction (1-1.5 MB)
- Videos: 70-80% reduction (100-150 MB for 1 hour)
- Maintains visual quality
- Smooth scrolling and performance

### Image Compression

```dart
// Automatic compression on selection
final compressedPath = await ImageCompressor.compressImage(
  sourcePath: selectedImage,
  outputPath: appCacheDir,
  maxWidth: 1080,           // Full HD width
  quality: 65,              // 65% quality (sweet spot)
);

// Handles:
// - PNG (transparency) vs JPEG (photos)
// - EXIF metadata removal
// - Thumbnail generation for previews
// - Batch processing
```

**Compression Rules:**
- Max width: 1080px (Full HD)
- Quality: 65% (best quality/size ratio)
- Format: JPEG for photos, PNG for transparency
- No upscaling (preserves original if smaller)
- Removes EXIF metadata

### Video Compression

```dart
// Compress video to 720p
final result = await VideoCompressor.compressVideo(
  sourcePath: selectedVideo,
  quality: VideoQuality.MediumQuality,
  onProgress: (progress) => updateUI(progress),
);

// Returns: path, thumbnail, duration, file size
```

**Compression Specs:**
- Resolution: 720p (1280x720)
- Bitrate: Medium (adaptive)
- Frame rate: 30 fps
- Codec: H.264 (widely compatible)
- Audio: AAC, clear and understandable
- Format: MP4
- Max duration: 60 seconds

### Why NOT Store Raw Bytes?

❌ **Bad Approach:**
```dart
// DON'T DO THIS
class Note {
  Uint8List imageBytes;  // 3MB per image!
  Uint8List videoBytes;  // 100MB+ per video!
}
```

**Problems:**
- Massive database size
- Entire file loaded into memory
- Slow database queries
- OOM crashes on large files

✅ **Good Approach:**
```dart
// DO THIS
class MediaItem {
  String filePath;          // Store path only
  int fileSize;             // Metadata only
  String? thumbnailPath;    // Compressed thumbnail
  Duration? duration;       // Metadata
}
```

**Benefits:**
- Efficient storage (paths are tiny)
- Files loaded on-demand
- Quick database queries
- Memory-efficient
- Can access files independently

## 📱 Responsive UI Examples

### Home Page - Grid View
```
Mobile (1 column)          Tablet (3 columns)         Desktop (4 columns)
┌──────────────┐          ┌─────┐ ┌─────┐ ┌─────┐   ┌─────┐ ┌─────┐ ┌─────┐ ┌─────┐
│              │          │     │ │     │ │     │   │     │ │     │ │     │ │     │
│   Note 1     │          │  1  │ │  2  │ │  3  │   │  1  │ │  2  │ │  3  │ │  4  │
│              │          │     │ │     │ │     │   │     │ │     │ │     │ │     │
├──────────────┤          └─────┘ └─────┘ └─────┘   └─────┘ └─────┘ └─────┘ └─────┘
│              │
│   Note 2     │
│              │
└──────────────┘
```

### Bottom Sheet Adaptability
- **Mobile**: Full-screen modal
- **Tablet**: Half-screen modal with padding
- **Desktop**: Floating centered dialog

## 🔔 Notification System

### How It Works

1. **User sets alarm** → Event triggers
2. **BLoC processes** → Stores in database
3. **Alarm time reached** → System notification
4. **User taps notification** → Navigate to note

### Notification Channels

```dart
// Regular notes channel
- Icon: Note icon
- Priority: High
- Sound: Enabled

// Alarm channel
- Icon: Alarm icon
- Priority: Urgent (max)
- Sound: Enabled
- Vibration: Enabled
- Full-screen intent: Yes (Android 12+)
```

## 📄 PDF Export

### Features

✅ **Embedded Images** - Full resolution images in PDF
✅ **Media References** - Audio/video shown as icons with metadata
✅ **Formatted Layout** - Professional multi-page PDFs
✅ **Metadata** - Creation date, tags, completion status
✅ **Batch Export** - Multiple notes to single PDF

### Example

```dart
// Export single note
final pdfPath = await PdfExportService.exportNoteToPdf(note);
// Result: /Documents/pdf/My Note_20240117_143022.pdf

// Export multiple notes
final pdfPath = await PdfExportService.exportMultipleNotesToPdf(notes);
// Result: /Documents/pdf/notes_export_20240117_143022.pdf
```

## 🚀 Getting Started

### Prerequisites
- Flutter SDK 3.8.1+
- Dart 3.8.1+
- Android SDK (for Android)
- Xcode (for iOS)

### Installation

```bash
# Clone repository
git clone https://github.com/yourusername/mynotes.git
cd mynotes

# Get dependencies
flutter pub get

# Run app
flutter run

# Build for release
flutter build apk
flutter build ipa
```

### Run Tests

```bash
# Run all tests
flutter test

# Run specific test
flutter test test/widget_test.dart

# With coverage
flutter test --coverage
```

## 📚 Project Structure Best Practices

### Naming Conventions
- **Events**: `*Event` (e.g., `CreateNoteEvent`)
- **States**: `*State` or `*Loaded` (e.g., `NoteLoaded`)
- **BLoCs**: `*Bloc` (e.g., `NotesBloc`)
- **Pages**: `*Page` (e.g., `HomePage`)
- **Widgets**: `*Widget` (e.g., `NoteCardWidget`)
- **Services**: `*Service` (e.g., `NotificationService`)

### File Organization
```
domain/
  ├── entities/        (models, pure Dart)
  ├── repositories/    (interfaces)
  └── usecases/        (business logic)

data/
  ├── models/          (JSON serialization)
  ├── datasources/     (local/remote data)
  └── repositories/    (implements domain interfaces)

presentation/
  ├── bloc/            (state management)
  ├── pages/           (full screens)
  └── widgets/         (components)
```

## 🔐 Permissions

Required permissions and how to handle them:

```yaml
# Android (AndroidManifest.xml)
- READ_EXTERNAL_STORAGE
- WRITE_EXTERNAL_STORAGE
- CAMERA
- RECORD_AUDIO
- ACCESS_FINE_LOCATION (for timezone)

# iOS (Info.plist)
- NSCameraUsageDescription
- NSMicrophoneUsageDescription
- NSPhotoLibraryUsageDescription
```

## 💾 Data Storage Strategy

### Local Database (SQLite)
- Notes metadata (title, content, timestamps)
- Todo items
- Alarm configurations
- Tags and color settings

### File System
- Images: `/app-docs/media/images/`
- Audio: `/app-docs/media/audio/`
- Videos: `/app-docs/media/videos/`
- Thumbnails: `/app-docs/media/thumbnails/`
- PDFs: `/app-docs/pdfs/`

### Memory
- Cache recent notes (up to 100)
- Stream controllers for real-time updates
- Media players for in-memory playback

## 🎓 Learning Resources

### BLoC Pattern
- See `lib/presentation/bloc/note_bloc.dart` for complete example
- Events represent actions
- States represent screen states
- Repository pattern for data access

### Responsive Design
- `lib/core/utils/responsive_utils.dart` - Helper functions
- Media queries for device detection
- Flexible layouts with LayoutBuilder

### Media Handling
- `lib/core/media/image_compressor.dart` - Image compression
- `lib/core/media/video_compressor.dart` - Video compression
- Async file processing with Futures

### PDF Generation
- `lib/core/pdf/pdf_export_service.dart` - PDF creation
- Embedding images in PDFs
- Multi-page layout

## 🐛 Troubleshooting

### Common Issues

**Storage permission denied**
```dart
// Use permission_handler
import 'package:permission_handler/permission_handler.dart';

final status = await Permission.storage.request();
if (status.isDenied) {
  // Handle denied
}
```

**Large files crash app**
- Implement lazy loading
- Use thumbnail previews
- Stream large files instead of loading entirely

**Database locked error**
- Close database connections properly
- Use single database instance (singleton)
- Avoid concurrent writes

## 📝 Future Enhancements

- 🤖 AI-powered note summarization
- 🔍 OCR text extraction from images
- 🎤 Speech-to-text transcription
- 🔗 Note linking and relationships
- ☁️ Cloud sync and backup
- 🌐 Web version
- 🎨 Advanced text formatting (rich text editor)
- 📊 Analytics dashboard

## 📄 License

This project is licensed under the MIT License - see LICENSE file for details.

## 👨‍💻 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 📧 Support

For support, email support@mynotes.app or open an issue on GitHub.

---

**Built with ❤️ using Flutter**
