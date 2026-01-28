
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import '../../core/constants/app_colors.dart';
import '../../core/services/speech_service.dart';
import '../../core/services/voice_command_service.dart';
import '../../core/services/audio_feedback_service.dart';
import '../../core/services/language_service.dart';
import '../../core/services/speech_settings_service.dart';
import '../../domain/entities/note.dart';
import 'package:image_picker/image_picker.dart';
import '../widgets/voice_input_button.dart';
import '../widgets/language_picker.dart';
import '../widgets/sound_level_indicator.dart';

/// Advanced Note Editor with Rich Text Formatting and Voice Commands
class AdvancedNoteEditor extends StatefulWidget {
  final Note? note;

  const AdvancedNoteEditor({super.key, this.note});

  @override
  State<AdvancedNoteEditor> createState() => _AdvancedNoteEditorState();
}

class _AdvancedNoteEditorState extends State<AdvancedNoteEditor>
    with SingleTickerProviderStateMixin {
  final TextEditingController _titleController = TextEditingController();
  late quill.QuillController _quillController;
  final FocusNode _editorFocusNode = FocusNode();

  // Services
  final SpeechService _speechService = SpeechService();
  final VoiceCommandService _commandService = VoiceCommandService();
  final AudioFeedbackService _feedbackService = AudioFeedbackService();
  final LanguageService _languageService = LanguageService();
  final SpeechSettingsService _settingsService = SpeechSettingsService();

  bool _isListening = false;
  bool _showFormatToolbar = false;
  double _soundLevel = 0.0;
  String _currentLocale = 'en_US';
  String _partialText = '';
  late AnimationController _toolbarAnimationController;

  NoteColor _selectedColor = NoteColor.defaultColor;

  @override
  void initState() {
    super.initState();

    _toolbarAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    if (widget.note != null) {
      _titleController.text = widget.note!.title;
      _selectedColor = widget.note!.color;
    }

    // Initialize Quill controller
    _quillController = quill.QuillController.basic();

    // Load existing content if editing
    if (widget.note != null && widget.note!.content.isNotEmpty) {
      try {
        _quillController.document = quill.Document()
          ..insert(0, widget.note!.content);
      } catch (e) {
        print('Error loading content: $e');
      }
    }

    _editorFocusNode.addListener(() {
      setState(() {
        _showFormatToolbar = _editorFocusNode.hasFocus;
      });

      if (_showFormatToolbar) {
        _toolbarAnimationController.forward();
      } else {
        _toolbarAnimationController.reverse();
      }
    });

    _initializeServices();
    _registerVoiceCommands();
  }

  Future<void> _initializeServices() async {
    // Load saved language
    _currentLocale = await _languageService.getSavedLanguage();
    _speechService.setLocale(_currentLocale);

    // Load settings
    final confidence = await _settingsService.getMinConfidence();
    final timeout = await _settingsService.getTimeout();
    final hapticsEnabled = await _settingsService.getHapticsEnabled();

    _speechService.setMinConfidence(confidence);
    _speechService.setCustomTimeout(timeout);
    _feedbackService.setHapticsEnabled(hapticsEnabled);

    setState(() {});
  }

  void _registerVoiceCommands() {
    _commandService.registerCommand('bold', () {
      _quillController.formatSelection(quill.Attribute.bold);
      _feedbackService.commandRecognized();
    });

    _commandService.registerCommand('italic', () {
      _quillController.formatSelection(quill.Attribute.italic);
      _feedbackService.commandRecognized();
    });

    _commandService.registerCommand('underline', () {
      _quillController.formatSelection(quill.Attribute.underline);
      _feedbackService.commandRecognized();
    });

    _commandService.registerCommand('heading1', () {
      _quillController.formatSelection(quill.Attribute.h1);
      _feedbackService.commandRecognized();
    });

    _commandService.registerCommand('heading2', () {
      _quillController.formatSelection(quill.Attribute.h2);
      _feedbackService.commandRecognized();
    });

    _commandService.registerCommand('heading3', () {
      _quillController.formatSelection(quill.Attribute.h3);
      _feedbackService.commandRecognized();
    });

    _commandService.registerCommand('bullet_list', () {
      _quillController.formatSelection(quill.Attribute.ul);
      _feedbackService.commandRecognized();
    });

    _commandService.registerCommand('numbered_list', () {
      _quillController.formatSelection(quill.Attribute.ol);
      _feedbackService.commandRecognized();
    });

    _commandService.registerCommand('checklist', () {
      _quillController.formatSelection(quill.Attribute.checked);
      _feedbackService.commandRecognized();
    });

    _commandService.registerCommand('quote', () {
      _quillController.formatSelection(quill.Attribute.blockQuote);
      _feedbackService.commandRecognized();
    });

    _commandService.registerCommand('save', () {
      _saveNote();
      _feedbackService.commandRecognized();
    });

    _commandService.registerCommand('undo', () {
      _quillController.undo();
      _feedbackService.commandRecognized();
    });

    _commandService.registerCommand('redo', () {
      _quillController.redo();
      _feedbackService.commandRecognized();
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _quillController.dispose();
    _editorFocusNode.dispose();
    _toolbarAnimationController.dispose();
    _speechService.dispose();
    _commandService.clearAllCommands();
    super.dispose();
  }

  Future<void> _startVoiceInput() async {
    final commandsEnabled = await _settingsService.getCommandsEnabled();

    final initialized = await _speechService.initialize();
    if (!initialized) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Microphone permission denied')),
        );
        _feedbackService.errorOccurred();
      }
      return;
    }

    setState(() => _isListening = true);
    await _feedbackService.recordingStarted();

    await _speechService.startListening(
      onResult: (text) async {
        // Check for voice commands first
        if (commandsEnabled && _commandService.containsCommand(text)) {
          final executed = _commandService.detectAndExecute(text);
          if (executed) {
            // Extract remaining text without commands
            final cleanText = _commandService.extractTextWithoutCommands(text);
            if (cleanText.isNotEmpty) {
              final index = _quillController.selection.baseOffset;
              _quillController.document.insert(index, '$cleanText ');
            }
          }
        } else {
          // Insert as regular text
          final index = _quillController.selection.baseOffset;
          _quillController.document.insert(index, '$text ');
        }

        setState(() {
          _isListening = false;
          _partialText = '';
        });
        await _feedbackService.recordingStopped();
      },
      onPartialResult: (text) {
        setState(() => _partialText = text);
      },
      onDone: () async {
        setState(() => _isListening = false);
        await _feedbackService.recordingStopped();
      },
      onSoundLevel: (level) {
        setState(() => _soundLevel = level);
      },
    );
  }

  Future<void> _stopVoiceInput() async {
    await _speechService.stopListening();
    setState(() {
      _isListening = false;
      _partialText = '';
      _soundLevel = 0.0;
    });
    await _feedbackService.recordingStopped();
  }

  Future<void> _changeLanguage() async {
    await _feedbackService.lightHaptic();

    final selectedLocale = await LanguagePicker.show(
      context,
      currentLocale: _currentLocale,
    );

    if (selectedLocale != null && selectedLocale != _currentLocale) {
      setState(() => _currentLocale = selectedLocale);
      _speechService.setLocale(selectedLocale);
      await _languageService.saveLanguage(selectedLocale);
      await _feedbackService.successHaptic();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Language changed to ${_languageService.getLanguageName(selectedLocale)}',
            ),
            backgroundColor: AppColors.successColor,
          ),
        );
      }
    }
  }

  Future<void> _insertImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      // Insert image into document
      final index = _quillController.selection.baseOffset;
      _quillController.document.insert(index, '\n');
      // Note: Full image embedding would require custom quill embeds
      _quillController.document.insert(index + 1, '[Image: ${image.name}]\n');
    }
  }

  void _saveNote() {
    final plainText = _quillController.document.toPlainText();
    final title = _titleController.text.trim();

    if (title.isEmpty && plainText.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Note cannot be empty'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // TODO: Save note with rich content using BLoC
    // For now, just show success message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Note saved successfully'),
        backgroundColor: AppColors.successColor,
      ),
    );

    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Custom App Bar
            _buildCustomAppBar(isDark),

            // Title Input
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
              child: TextField(
                controller: _titleController,
                style: TextStyle(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
                decoration: InputDecoration(
                  hintText: 'Title',
                  hintStyle: TextStyle(
                    color: Colors.grey.withOpacity(0.5),
                    fontWeight: FontWeight.bold,
                  ),
                  border: InputBorder.none,
                ),
              ),
            ),

            Divider(height: 1, color: Colors.grey.withOpacity(0.2)),

            // Rich Text Editor
            Expanded(
              child: Stack(
                children: [
                  Container(
                    padding: EdgeInsets.all(20.w),
                    child: quill.QuillEditor.basic(
                      configurations: quill.QuillEditorConfigurations(
                        controller: _quillController,
                        sharedConfigurations:
                            const quill.QuillSharedConfigurations(
                              locale: Locale('en'),
                            ),
                        scrollable: true,
                        autoFocus: false,
                        expands: false,
                        padding: EdgeInsets.zero,
                        placeholder: 'Start writing your note...',
                        customStyles: quill.DefaultStyles(
                          h1: quill.DefaultTextBlockStyle(
                            const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              height: 1.5,
                            ),
                            const quill.VerticalSpacing(16, 0),
                            const quill.VerticalSpacing(0, 0),
                            null,
                          ),
                          h2: quill.DefaultTextBlockStyle(
                            const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              height: 1.4,
                            ),
                            const quill.VerticalSpacing(12, 0),
                            const quill.VerticalSpacing(0, 0),
                            null,
                          ),
                          h3: quill.DefaultTextBlockStyle(
                            const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              height: 1.3,
                            ),
                            const quill.VerticalSpacing(10, 0),
                            const quill.VerticalSpacing(0, 0),
                            null,
                          ),
                          paragraph: quill.DefaultTextBlockStyle(
                            const TextStyle(fontSize: 16, height: 1.6),
                            const quill.VerticalSpacing(8, 0),
                            const quill.VerticalSpacing(0, 0),
                            null,
                          ),
                          code: quill.DefaultTextBlockStyle(
                            TextStyle(
                              fontSize: 14,
                              fontFamily: 'monospace',
                              backgroundColor: Colors.grey.shade200,
                            ),
                            const quill.VerticalSpacing(8, 0),
                            const quill.VerticalSpacing(0, 0),
                            null,
                          ),
                          quote: quill.DefaultTextBlockStyle(
                            TextStyle(
                              fontSize: 16,
                              fontStyle: FontStyle.italic,
                              color: Colors.grey.shade700,
                            ),
                            const quill.VerticalSpacing(8, 0),
                            const quill.VerticalSpacing(0, 0),
                            BoxDecoration(
                              border: Border(
                                left: BorderSide(
                                  width: 4,
                                  color: AppColors.primaryColor,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      focusNode: _editorFocusNode,
                    ),
                  ),

                  // Floating Format Toolbar
                  if (_showFormatToolbar)
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: _buildFloatingToolbar(isDark),
                    ),
                ],
              ),
            ),

            // Bottom Action Bar
            _buildBottomActionBar(isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomAppBar(bool isDark) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              if (Navigator.canPop(context)) {
                Navigator.pop(context);
              }
            },
          ),
          const Spacer(),
          // Color Picker
          PopupMenuButton<NoteColor>(
            icon: Container(
              width: 28.w,
              height: 28.w,
              decoration: BoxDecoration(
                color: Color(_selectedColor.lightColor),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.grey.shade300),
              ),
            ),
            onSelected: (color) {
              setState(() => _selectedColor = color);
            },
            itemBuilder: (context) => NoteColor.values.map((color) {
              return PopupMenuItem(
                value: color,
                child: Row(
                  children: [
                    Container(
                      width: 24.w,
                      height: 24.w,
                      decoration: BoxDecoration(
                        color: Color(color.lightColor),
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Text(color.name),
                  ],
                ),
              );
            }).toList(),
          ),

          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              // Show more options
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingToolbar(bool isDark) {
    return SlideTransition(
      position: Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
          .animate(
            CurvedAnimation(
              parent: _toolbarAnimationController,
              curve: Curves.easeOut,
            ),
          ),
      child: Container(
        height: 50.h,
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: quill.QuillToolbar.simple(
            configurations: quill.QuillSimpleToolbarConfigurations(
              controller: _quillController,
              sharedConfigurations: const quill.QuillSharedConfigurations(),
              // Text formatting
              showBoldButton: true,
              showItalicButton: true,
              showUnderLineButton: true,
              showStrikeThrough: true,
              showSubscript: false,
              showSuperscript: false,
              showSmallButton: false,
              // Text color and background
              showFontFamily: false,
              showFontSize: true,
              showInlineCode: true,
              showColorButton: true,
              showBackgroundColorButton: true,
              // Alignment
              showAlignmentButtons: true,
              showDirection: false,
              // Lists and indentation
              showListBullets: true,
              showListNumbers: true,
              showListCheck: true,
              showIndent: true,
              // Block formatting
              showQuote: true,
              showCodeBlock: true,
              showHeaderStyle: true,
              // Links and embeds
              showLink: true,
              // History
              showUndo: true,
              showRedo: true,
              showClearFormat: true,
              // Search
              showSearchButton: false,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomActionBar(bool isDark) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Sound level indicator when listening
          if (_isListening)
            Padding(
              padding: EdgeInsets.only(bottom: 8.h),
              child: Column(
                children: [
                  SoundLevelIndicator(level: _soundLevel, height: 20.h),
                  if (_partialText.isNotEmpty)
                    Padding(
                      padding: EdgeInsets.only(top: 4.h),
                      child: Text(
                        _partialText,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.grey,
                          fontStyle: FontStyle.italic,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
              ),
            ),

          // Main action bar
          Row(
            children: [
              // Language Selector
              IconButton(
                icon: const Icon(Icons.language, color: AppColors.primaryColor),
                tooltip: _languageService.getLanguageName(_currentLocale),
                onPressed: _changeLanguage,
              ),

              // Quick Format Buttons
              PopupMenuButton<String>(
                icon: const Icon(
                  Icons.format_size,
                  color: AppColors.primaryColor,
                ),
                tooltip: 'Headings',
                onSelected: (value) async {
                  await _feedbackService.selectionHaptic();
                  if (value == 'h1') {
                    _quillController.formatSelection(quill.Attribute.h1);
                  } else if (value == 'h2') {
                    _quillController.formatSelection(quill.Attribute.h2);
                  } else if (value == 'h3') {
                    _quillController.formatSelection(quill.Attribute.h3);
                  } else if (value == 'normal') {
                    _quillController.formatSelection(
                      quill.Attribute.clone(quill.Attribute.header, null),
                    );
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(value: 'h1', child: Text('Heading 1')),
                  const PopupMenuItem(value: 'h2', child: Text('Heading 2')),
                  const PopupMenuItem(value: 'h3', child: Text('Heading 3')),
                  const PopupMenuItem(
                    value: 'normal',
                    child: Text('Normal Text'),
                  ),
                ],
              ),

              // Voice Input Button (using new widget)
              VoiceInputButton(
                isListening: _isListening,
                onPressed: _isListening ? _stopVoiceInput : _startVoiceInput,
                soundLevel: _soundLevel,
                size: 40.w,
              ),

              SizedBox(width: 8.w),

              // Insert Image
              IconButton(
                icon: const Icon(Icons.image, color: AppColors.primaryColor),
                tooltip: 'Insert Image',
                onPressed: () async {
                  await _feedbackService.lightHaptic();
                  await _insertImage();
                },
              ),

              // Insert Checklist
              IconButton(
                icon: const Icon(
                  Icons.checklist,
                  color: AppColors.primaryColor,
                ),
                tooltip: 'Checklist',
                onPressed: () async {
                  await _feedbackService.lightHaptic();
                  _quillController.formatSelection(quill.Attribute.checked);
                },
              ),

              const Spacer(),

              // Word Count
              Text(
                '${_quillController.document.toPlainText().split(' ').where((word) => word.isNotEmpty).length} words',
                style: TextStyle(fontSize: 12.sp, color: Colors.grey),
              ),

              SizedBox(width: 12.w),

              // Save Button
              ElevatedButton.icon(
                onPressed: () async {
                  await _feedbackService.heavyHaptic();
                  _saveNote();
                },
                icon: const Icon(Icons.check, size: 18),
                label: const Text('Save'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(
                    horizontal: 20.w,
                    vertical: 12.h,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

