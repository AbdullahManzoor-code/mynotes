# 🔧 Quick Integration Guide

## How to Use the New Advanced Features

This guide shows you exactly how to integrate all the newly created features into your existing app.

---

## 📝 1. Note Templates

### **In `note_editor_page.dart` or creation flow:**

```dart
// Add this method to show template selector
Future<void> _selectTemplate() async {
  final template = await showModalBottomSheet<NoteTemplate>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => SizedBox(
      height: MediaQuery.of(context).size.height * 0.7,
      child: const TemplateSelectorSheet(),
    ),
  );
  
  if (template != null) {
    // Use template content
    _contentController.text = template.content;
  }
}

// Add button in app bar or FAB
IconButton(
  icon: Icon(Icons.note_add),
  tooltip: 'Use Template',
  onPressed: _selectTemplate,
)
```

**Status:** ✅ Already integrated in `notes_list_screen.dart`

---

## 🎨 2. Markdown Preview

### **In `note_editor_page.dart`:**

```dart
import '../widgets/markdown_preview_widget.dart';

// Add state variable
bool _isPreviewMode = false;

// In build method:
_isPreviewMode
  ? MarkdownPreviewWidget(
      content: _contentController.text,
      isDark: Theme.of(context).brightness == Brightness.dark,
    )
  : TextField(
      controller: _contentController,
      // ... your existing editor
    ),

// Add toggle button
IconButton(
  icon: Icon(_isPreviewMode ? Icons.edit : Icons.visibility),
  onPressed: () => setState(() => _isPreviewMode = !_isPreviewMode),
)
```

---

## 📤 3. Export & Share

### **Add to Note Card's PopupMenu:**

```dart
import '../../core/services/export_service.dart';

PopupMenuButton<String>(
  onSelected: (value) async {
    switch (value) {
      case 'export_text':
        await ExportService.shareNote(note, format: 'text');
        break;
      case 'export_markdown':
        await ExportService.shareNote(note, format: 'markdown');
        break;
      case 'export_html':
        await ExportService.shareNote(note, format: 'html');
        break;
      case 'copy':
        await ExportService.copyToClipboard(note);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Copied to clipboard')),
        );
        break;
    }
  },
  itemBuilder: (context) => [
    PopupMenuItem(value: 'export_text', child: Text('📄 Export as Text')),
    PopupMenuItem(value: 'export_markdown', child: Text('📝 Export as Markdown')),
    PopupMenuItem(value: 'export_html', child: Text('🌐 Export as HTML')),
    PopupMenuDivider(),
    PopupMenuItem(value: 'copy', child: Text('📋 Copy to Clipboard')),
  ],
)
```

---

## 🔍 4. Global Search

### **Add Search Button to App Bar:**

```dart
import 'global_search_screen.dart';

// In app bar actions:
IconButton(
  icon: Icon(Icons.search),
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const GlobalSearchScreen()),
    );
  },
)
```

**Status:** ✅ Already integrated in `notes_list_screen.dart`

---

## 😊 5. Mood Tracking

### **In `reflection_home_screen.dart`:**

```dart
import '../widgets/mood_selector_widget.dart';
import '../../domain/entities/mood.dart';

class _ReflectionHomeScreenState extends State<ReflectionHomeScreen> {
  MoodType? _selectedMood;
  
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Add mood selector
        MoodSelectorWidget(
          selectedMood: _selectedMood,
          onMoodSelected: (mood) {
            setState(() => _selectedMood = mood);
            // Save mood entry
            _saveMoodEntry(mood);
          },
        ),
        
        // Rest of your reflection UI
      ],
    );
  }
  
  void _saveMoodEntry(MoodType mood) {
    final entry = MoodEntry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      mood: mood,
      timestamp: DateTime.now(),
      note: _reflectionController.text,
    );
    
    // Save to your local storage or database
    // You can add this to ReflectionBloc if needed
  }
}
```

---

## ⏱️ 6. Enhanced Pomodoro Timer

### **Option A: In `todo_focus_screen.dart`:**

```dart
import '../widgets/pomodoro_timer_widget.dart';

// Add FAB or dedicated timer section
FloatingActionButton.extended(
  icon: Icon(Icons.timer),
  label: Text('Focus Mode'),
  onPressed: _showPomodoroTimer,
)

void _showPomodoroTimer() {
  showDialog(
    context: context,
    builder: (context) => Dialog(
      child: PomodoroTimerWidget(
        taskName: widget.note.title,
        onTimerComplete: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Session complete! 🎉')),
          );
        },
      ),
    ),
  );
}
```

### **Option B: Dedicated Timer Page:**

```dart
// Navigate to full-screen timer
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (_) => Scaffold(
      appBar: AppBar(title: Text('Focus Timer')),
      body: Center(
        child: PomodoroTimerWidget(
          taskName: selectedTodo?.title,
          onTimerComplete: () {
            // Mark todo as complete or update stats
          },
        ),
      ),
    ),
  ),
);
```

---

## 🎨 7. Theme Customization

### **In `settings_screen.dart`:**

```dart
import '../../core/services/theme_customization_service.dart';

class _SettingsScreenState extends State<SettingsScreen> {
  final _themeService = ThemeCustomizationService();
  AppThemeType _selectedTheme = AppThemeType.system;
  AppFont _selectedFont = AppFont.system;
  
  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }
  
  Future<void> _loadPreferences() async {
    final theme = await _themeService.getThemeType();
    final font = await _themeService.getFont();
    setState(() {
      _selectedTheme = theme;
      _selectedFont = font;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        // Theme Selector
        ListTile(
          title: Text('App Theme'),
          subtitle: Text(_selectedTheme.displayName),
          leading: Text(_selectedTheme.icon, style: TextStyle(fontSize: 24)),
          onTap: _showThemeSelector,
        ),
        
        // Font Selector
        ListTile(
          title: Text('Font'),
          subtitle: Text(_selectedFont.displayName),
          leading: Icon(Icons.font_download),
          onTap: _showFontSelector,
        ),
      ],
    );
  }
  
  void _showThemeSelector() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Select Theme'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: AppThemeType.values.map((theme) {
              return RadioListTile<AppThemeType>(
                title: Row(
                  children: [
                    Text(theme.icon, style: TextStyle(fontSize: 20)),
                    SizedBox(width: 12),
                    Text(theme.displayName),
                  ],
                ),
                value: theme,
                groupValue: _selectedTheme,
                onChanged: (value) async {
                  if (value != null) {
                    await _themeService.setThemeType(value);
                    setState(() => _selectedTheme = value);
                    Navigator.pop(context);
                    
                    // Restart app to apply theme
                    // You'll need to implement theme provider in main.dart
                  }
                },
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
  
  void _showFontSelector() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Select Font'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: AppFont.values.map((font) {
              return RadioListTile<AppFont>(
                title: Text(
                  font.displayName,
                  style: TextStyle(fontFamily: font.fontFamily),
                ),
                value: font,
                groupValue: _selectedFont,
                onChanged: (value) async {
                  if (value != null) {
                    await _themeService.setFont(value);
                    setState(() => _selectedFont = value);
                    Navigator.pop(context);
                    
                    // Restart app to apply font
                  }
                },
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
```

---

## ✅ 8. Subtasks & Todo Categories

### **Extend Note Entity (Optional):**

If you want to use dedicated todo items instead of notes, you can create a new entity or use the existing structure with tags.

### **For now, use tags:**

```dart
// Create todo with category
context.read<NotesBloc>().add(
  CreateNoteEvent(
    title: 'Buy groceries',
    content: '',
    tags: ['todo', 'shopping'], // Category as tag
  ),
);

// Filter by category
final shoppingTodos = notes
  .where((n) => n.tags.contains('todo') && n.tags.contains('shopping'))
  .toList();
```

---

## 🎯 9. Main.dart Theme Integration

### **Update `main.dart` to support dynamic themes:**

```dart
import 'package:flutter/material.dart';
import 'core/services/theme_customization_service.dart';

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _themeService = ThemeCustomizationService();
  AppThemeType _currentTheme = AppThemeType.system;
  AppFont _currentFont = AppFont.system;
  
  @override
  void initState() {
    super.initState();
    _loadTheme();
  }
  
  Future<void> _loadTheme() async {
    final theme = await _themeService.getThemeType();
    final font = await _themeService.getFont();
    setState(() {
      _currentTheme = theme;
      _currentFont = font;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MyNotes',
      theme: _themeService.getThemeData(_currentTheme, _currentFont),
      darkTheme: _themeService.getThemeData(AppThemeType.dark, _currentFont),
      themeMode: _currentTheme == AppThemeType.system
          ? ThemeMode.system
          : (_currentTheme == AppThemeType.dark ? ThemeMode.dark : ThemeMode.light),
      home: const SplashScreen(),
    );
  }
}
```

---

## 📊 10. Quick Feature Checklist

After integration, you'll have:

- [x] **10 Note Templates** - Quick start for different note types
- [x] **Markdown Preview** - Professional document rendering
- [x] **Export/Share** - 3 formats (TXT, MD, HTML)
- [x] **Global Search** - Fast cross-module search
- [x] **Mood Tracking** - 10 mood types with metadata
- [x] **Pomodoro Timer** - Customizable focus sessions
- [x] **7 Custom Themes** - Beautiful color schemes
- [x] **6 Font Options** - Typography customization
- [x] **Todo Categories** - 8 category types
- [x] **Priority Levels** - 4 priority levels

---

## 🚀 Next Steps

1. **Test Each Feature:**
   - Create notes with templates
   - Export and share notes
   - Use global search
   - Track moods
   - Try Pomodoro timer
   - Switch themes

2. **Add Analytics (Future):**
   - Track template usage
   - Mood trends over time
   - Productivity metrics
   - Note creation patterns

3. **Cloud Sync (Future):**
   - Integrate with Google Drive
   - Auto-backup settings
   - Cross-device sync

4. **AI Features (Future):**
   - Auto-tagging
   - Smart suggestions
   - Sentiment analysis
   - Writing insights

---

## 💡 Tips

- **Templates:** Users love pre-made structures - promote this feature prominently
- **Export:** Add bulk export option for backing up all notes
- **Themes:** Consider adding theme preview before applying
- **Pomodoro:** Add statistics tracking (total sessions, productivity score)
- **Mood:** Build monthly mood calendar heatmap

---

## 🎉 You're All Set!

All the code is ready - just integrate these snippets into your existing UI and enjoy the advanced features!

For questions or issues, refer to `FEATURES_IMPLEMENTED.md` for detailed documentation.
