import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:ui' as ui;
import 'dart:async';
import '../design_system/design_system.dart';
import '../bloc/note_bloc.dart';
import '../bloc/note_event.dart';
import '../bloc/note_state.dart';
import '../../domain/entities/note.dart';

/// Enhanced Note Editor with Links and Pins
/// Advanced note editing interface with smart features
/// Based on note_editor_with_links_and_pins template
class EnhancedNoteEditorScreen extends StatefulWidget {
  final Note? note;
  final String? template;
  final String? initialContent;

  const EnhancedNoteEditorScreen({
    super.key,
    this.note,
    this.template,
    this.initialContent,
  });

  @override
  State<EnhancedNoteEditorScreen> createState() =>
      _EnhancedNoteEditorScreenState();
}

class _EnhancedNoteEditorScreenState extends State<EnhancedNoteEditorScreen>
    with TickerProviderStateMixin {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  final FocusNode _titleFocusNode = FocusNode();
  final FocusNode _contentFocusNode = FocusNode();

  late AnimationController _summaryController;
  late AnimationController _fabController;
  late AnimationController _toolbarController;

  bool _isPinned = false;
  bool _showSummary = false;
  bool _isModified = false;
  bool _isListening = false;
  bool _showRichToolbar = false;

  // Rich text formatting state
  bool _isBold = false;
  bool _isItalic = false;
  bool _isUnderline = false;

  String _generatedSummary = '';
  List<String> _detectedLinks = [];
  List<String> _keyPoints = [];

  // Voice input
  late stt.SpeechToText _speechToText;
  String _voiceText = '';
  bool _isVoiceAvailable = false;
  String _currentLocale = 'en_US';

  @override
  void initState() {
    super.initState();

    _summaryController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _fabController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _toolbarController = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );

    _initializeNote();
    _setupListeners();
    _initializeVoiceInput();

    // Auto-focus content if new note
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.note == null) {
        _titleFocusNode.requestFocus();
      }
    });
  }

  @override
  void dispose() {
    _summaryController.dispose();
    _fabController.dispose();
    _toolbarController.dispose();
    _titleController.dispose();
    _contentController.dispose();
    _titleFocusNode.dispose();
    _contentFocusNode.dispose();
    super.dispose();
  }

  void _initializeNote() {
    if (widget.note != null) {
      _titleController.text = widget.note!.title;
      _contentController.text = widget.note!.content;
      _isPinned = widget.note!.isPinned;
    } else if (widget.initialContent != null) {
      _contentController.text = widget.initialContent!;
    }

    if (_contentController.text.isNotEmpty) {
      _analyzeContent();
    }
  }

  void _setupListeners() {
    _titleController.addListener(() {
      if (!_isModified) {
        setState(() {
          _isModified = true;
        });
      }
    });

    _contentController.addListener(() {
      if (!_isModified) {
        setState(() {
          _isModified = true;
        });
      }

      // Re-analyze content after changes
      _debounceAnalysis();
    });
  }

  Timer? _debounceTimer;
  void _debounceAnalysis() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      if (mounted) {
        _analyzeContent();
      }
    });
  }

  void _analyzeContent() {
    final content = _contentController.text;

    if (content.isEmpty) {
      setState(() {
        _detectedLinks = [];
        _keyPoints = [];
        _generatedSummary = '';
        _showSummary = false;
      });
      return;
    }

    // Detect links
    final urlRegex = RegExp(r'https?://[^\s]+');
    final matches = urlRegex.allMatches(content);
    final links = matches.map((m) => m.group(0)!).toList();

    // Generate key points (simplified extraction)
    final lines = content.split('\n');
    final points = <String>[];

    for (final line in lines) {
      final trimmed = line.trim();
      if (trimmed.startsWith('- ') ||
          trimmed.startsWith('• ') ||
          trimmed.startsWith('* ') ||
          trimmed.contains(':')) {
        if (trimmed.length > 10 && trimmed.length < 100) {
          points.add(trimmed);
        }
      }
    }

    // Generate summary
    final summary = _generateSummary(content);

    setState(() {
      _detectedLinks = links;
      _keyPoints = points.take(3).toList();
      _generatedSummary = summary;
      _showSummary =
          summary.isNotEmpty || links.isNotEmpty || points.isNotEmpty;
    });

    if (_showSummary && !_summaryController.isCompleted) {
      _summaryController.forward();
    }
  }

  void _initializeVoiceInput() async {
    _speechToText = stt.SpeechToText();

    try {
      // Check microphone permission
      final hasPermission = await Permission.microphone.request();
      if (hasPermission != PermissionStatus.granted) {
        setState(() {
          _isVoiceAvailable = false;
        });
        return;
      }

      // Initialize speech recognition
      final available = await _speechToText.initialize(
        onStatus: (status) {
          if (mounted) {
            setState(() {
              _isListening = status == 'listening';
            });
          }
        },
        onError: (error) {
          if (mounted) {
            setState(() {
              _isListening = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Voice recognition error: ${error.errorMsg}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
      );

      if (mounted) {
        setState(() {
          _isVoiceAvailable = available;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isVoiceAvailable = false;
        });
      }
    }
  }

  void _startVoiceInput() async {
    if (!_isVoiceAvailable || _isListening) return;

    try {
      final available = await _speechToText.initialize();
      if (!available) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Speech recognition not available'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      setState(() {
        _isListening = true;
        _voiceText = '';
      });

      await _speechToText.listen(
        onResult: (result) {
          setState(() {
            _voiceText = result.recognizedWords;
          });

          if (result.finalResult) {
            final currentText = _contentController.text;
            final cursorPosition = _contentController.selection.baseOffset;

            String newText;
            if (cursorPosition >= 0) {
              newText =
                  currentText.substring(0, cursorPosition) +
                  _voiceText +
                  currentText.substring(cursorPosition);
            } else {
              newText = currentText + ' ' + _voiceText;
            }

            _contentController.text = newText;
            _contentController.selection = TextSelection.collapsed(
              offset: cursorPosition + _voiceText.length,
            );

            setState(() {
              _isModified = true;
              _isListening = false;
            });

            _debounceAnalysis();
          }
        },
        localeId: _currentLocale,
        listenFor: const Duration(seconds: 30),
        pauseFor: const Duration(seconds: 3),
        partialResults: true,
        cancelOnError: true,
      );
    } catch (e) {
      setState(() {
        _isListening = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Voice input failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
    setState(() {
      _showRichToolbar = !_showRichToolbar;
    });

    if (_showRichToolbar) {
      _toolbarController.forward();
    } else {
      _toolbarController.reverse();
    }
  }

  void _applyRichFormatting(String type) {
    final selection = _contentController.selection;
    if (!selection.isValid) return;

    final text = _contentController.text;
    final selectedText = text.substring(selection.start, selection.end);

    String formattedText;
    switch (type) {
      case 'bold':
        formattedText = '**$selectedText**';
        setState(() {
          _isBold = !_isBold;
        });
        break;
      case 'italic':
        formattedText = '*$selectedText*';
        setState(() {
          _isItalic = !_isItalic;
        });
        break;
      case 'underline':
        formattedText = '_${selectedText}_';
        setState(() {
          _isUnderline = !_isUnderline;
        });
        break;
      case 'list':
        formattedText = '• $selectedText';
        break;
      case 'checkbox':
        formattedText = '☐ $selectedText';
        break;
      default:
        formattedText = selectedText;
    }

    final newText = text.replaceRange(
      selection.start,
      selection.end,
      formattedText,
    );
    _contentController.text = newText;
    _contentController.selection = TextSelection.collapsed(
      offset: selection.start + formattedText.length,
    );

    setState(() {
      _isModified = true;
    });
  }

  String _generateSummary(String content) {
    if (content.length < 100) return '';

    // Simple extractive summary - take first meaningful sentence
    final sentences = content.split(RegExp(r'[.!?]+'));
    if (sentences.isNotEmpty) {
      final firstSentence = sentences.first.trim();
      if (firstSentence.length > 20) {
        return firstSentence + '.';
      }
    }

    return 'This note contains ${content.split(' ').length} words and covers key topics from your content.';
  }

  void _togglePin() {
    setState(() {
      _isPinned = !_isPinned;
    });

    HapticFeedback.lightImpact();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_isPinned ? 'Note pinned' : 'Note unpinned'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _saveNote() {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();

    if (title.isEmpty && content.isEmpty) {
      Navigator.pop(context);
      return;
    }

    if (widget.note != null) {
      // Update existing note
      final updatedNote = widget.note!.copyWith(
        title: title.isEmpty ? 'Untitled' : title,
        content: content,
        isPinned: _isPinned,
        updatedAt: DateTime.now(),
      );

      context.read<NotesBloc>().add(UpdateNoteEvent(updatedNote));
    } else {
      // Create new note
      context.read<NotesBloc>().add(
        CreateNoteEvent(
          title: title.isEmpty ? 'Untitled' : title,
          content: content,
          isPinned: _isPinned,
        ),
      );
    }

    setState(() {
      _isModified = false;
    });

    Navigator.pop(context);
  }

  void _showMoreOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildOptionsSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocListener<NotesBloc, NoteState>(
      listener: (context, state) {
        if (state is NoteCreated || state is NoteUpdated) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                state is NoteCreated
                    ? 'Note created successfully'
                    : 'Note updated successfully',
              ),
              backgroundColor: AppColors.primary,
            ),
          );
        } else if (state is NoteError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.getBackgroundColor(
          Theme.of(context).brightness,
        ),
        body: CustomScrollView(
          slivers: [
            _buildAppBar(isDark),
            SliverToBoxAdapter(
              child: Container(
                constraints: BoxConstraints(maxWidth: 640.w),
                margin: EdgeInsets.symmetric(horizontal: 16.w),
                child: Column(
                  children: [
                    if (_showSummary) _buildSummarySection(),
                    _buildNoteEditor(),
                    SizedBox(height: 100.h),
                  ],
                ),
              ),
            ),
          ],
        ),
        floatingActionButton: _buildFloatingActionButton(),
      ),
    );
  }

  Widget _buildAppBar(bool isDark) {
    return SliverAppBar(
      floating: true,
      snap: true,
      backgroundColor: AppColors.getBackgroundColor(
        Theme.of(context).brightness,
      ).withOpacity(0.8),
      elevation: 0,
      scrolledUnderElevation: 0,
      flexibleSpace: ClipRect(
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            color: AppColors.getBackgroundColor(
              Theme.of(context).brightness,
            ).withOpacity(0.8),
          ),
        ),
      ),
      leading: IconButton(
        onPressed: () {
          if (_isModified) {
            _showSaveDialog();
          } else {
            Navigator.pop(context);
          }
        },
        icon: Icon(
          Icons.arrow_back_ios_new,
          color: AppColors.getTextColor(Theme.of(context).brightness),
          size: 24.sp,
        ),
      ),
      title: Text(
        widget.note?.title ?? 'New Note',
        style: TextStyle(
          fontSize: 18.sp,
          fontWeight: FontWeight.w600,
          color: AppColors.getTextColor(Theme.of(context).brightness),
        ),
      ),
      actions: [
        GestureDetector(
          onTap: _togglePin,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 40.w,
            height: 40.w,
            decoration: BoxDecoration(
              color: _isPinned
                  ? AppColors.primary.withOpacity(0.1)
                  : Colors.transparent,
              shape: BoxShape.circle,
            ),
            child: Icon(
              _isPinned ? Icons.push_pin : Icons.push_pin_outlined,
              color: _isPinned
                  ? AppColors.primary
                  : AppColors.getTextColor(Theme.of(context).brightness),
              size: 24.sp,
            ),
          ),
        ),

        IconButton(
          onPressed: _showMoreOptions,
          icon: Icon(
            Icons.more_horiz,
            color: AppColors.getTextColor(Theme.of(context).brightness),
            size: 24.sp,
          ),
        ),

        SizedBox(width: 8.w),
      ],
    );
  }

  Widget _buildSummarySection() {
    return SlideTransition(
      position: Tween<Offset>(begin: const Offset(0, -1), end: Offset.zero)
          .animate(
            CurvedAnimation(
              parent: _summaryController,
              curve: Curves.easeOutCubic,
            ),
          ),
      child: Container(
        margin: EdgeInsets.only(bottom: 24.h, top: 8.h),
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: AppColors.primary.withOpacity(0.1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.auto_awesome, color: AppColors.primary, size: 18.sp),
                SizedBox(width: 8.w),
                Text(
                  'NOTE SUMMARY',
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),

            if (_generatedSummary.isNotEmpty) ...[
              SizedBox(height: 12.h),
              Text(
                _generatedSummary,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: AppColors.getTextColor(Theme.of(context).brightness),
                  height: 1.4,
                ),
              ),
            ],

            if (_keyPoints.isNotEmpty) ...[
              SizedBox(height: 12.h),
              Text(
                'Key Points:',
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.getSecondaryTextColor(
                    Theme.of(context).brightness,
                  ),
                ),
              ),
              SizedBox(height: 4.h),
              ...(_keyPoints.map(
                (point) => Padding(
                  padding: EdgeInsets.only(bottom: 2.h),
                  child: Text(
                    point,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: AppColors.getSecondaryTextColor(
                        Theme.of(context).brightness,
                      ),
                    ),
                  ),
                ),
              )),
            ],

            if (_detectedLinks.isNotEmpty) ...[
              SizedBox(height: 12.h),
              Text(
                'Detected Links:',
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.getSecondaryTextColor(
                    Theme.of(context).brightness,
                  ),
                ),
              ),
              SizedBox(height: 4.h),
              ...(_detectedLinks
                  .map(
                    (link) => Padding(
                      padding: EdgeInsets.only(bottom: 4.h),
                      child: GestureDetector(
                        onTap: () {
                          // TODO: Open link
                        },
                        child: Text(
                          link,
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: AppColors.primary,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ),
                  )
                  .toList()),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildNoteEditor() {
    return Column(
      children: [
        // Title field
        TextField(
          controller: _titleController,
          focusNode: _titleFocusNode,
          style: TextStyle(
            fontSize: 24.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.getTextColor(Theme.of(context).brightness),
            height: 1.2,
          ),
          decoration: InputDecoration(
            hintText: 'Note title',
            hintStyle: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.getSecondaryTextColor(
                Theme.of(context).brightness,
              ),
            ),
            border: InputBorder.none,
            contentPadding: EdgeInsets.zero,
          ),
          textInputAction: TextInputAction.next,
          onSubmitted: (_) => _contentFocusNode.requestFocus(),
        ),

        SizedBox(height: 16.h),

        // Rich Text Toolbar
        if (_showRichToolbar) _buildRichTextToolbar(),

        // Content field with enhanced features
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.r),
            border: _contentFocusNode.hasFocus
                ? Border.all(
                    color: AppColors.primary.withOpacity(0.3),
                    width: 1,
                  )
                : null,
          ),
          child: TextField(
            controller: _contentController,
            focusNode: _contentFocusNode,
            maxLines: null,
            minLines: 10,
            style: TextStyle(
              fontSize: 16.sp,
              color: AppColors.getTextColor(Theme.of(context).brightness),
              height: 1.6,
            ),
            decoration: InputDecoration(
              hintText:
                  'Start writing... Tap the toolbar icon for rich text formatting',
              hintStyle: TextStyle(
                fontSize: 16.sp,
                color: AppColors.getSecondaryTextColor(
                  Theme.of(context).brightness,
                ),
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(16.w),
            ),
            onChanged: (text) {
              // Content changed - trigger analysis
              _debounceAnalysis();
            },
          ),
        ),

        SizedBox(height: 16.h),

        // Quick Actions Row
        _buildQuickActionsRow(),
      ],
    );
  }

  Widget _buildRichTextToolbar() {
    return SlideTransition(
      position: Tween<Offset>(begin: const Offset(0, -1), end: Offset.zero)
          .animate(
            CurvedAnimation(parent: _toolbarController, curve: Curves.easeOut),
          ),
      child: Container(
        margin: EdgeInsets.only(bottom: 16.h),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: AppColors.getSurfaceColor(Theme.of(context).brightness),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: AppColors.getSecondaryTextColor(
              Theme.of(context).brightness,
            ).withOpacity(0.2),
          ),
        ),
        child: Row(
          children: [
            _buildToolbarButton(Icons.format_bold, 'bold', _isBold),
            SizedBox(width: 8.w),
            _buildToolbarButton(Icons.format_italic, 'italic', _isItalic),
            SizedBox(width: 8.w),
            _buildToolbarButton(
              Icons.format_underlined,
              'underline',
              _isUnderline,
            ),
            SizedBox(width: 16.w),
            _buildToolbarButton(Icons.format_list_bulleted, 'list', false),
            SizedBox(width: 8.w),
            _buildToolbarButton(
              Icons.check_box_outline_blank,
              'checkbox',
              false,
            ),
            const Spacer(),
            Text(
              'Rich Text',
              style: TextStyle(
                fontSize: 12.sp,
                color: AppColors.getSecondaryTextColor(
                  Theme.of(context).brightness,
                ),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToolbarButton(IconData icon, String type, bool isActive) {
    return GestureDetector(
      onTap: () => _applyRichFormatting(type),
      child: Container(
        padding: EdgeInsets.all(8.w),
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.primary.withOpacity(0.2)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(6.r),
        ),
        child: Icon(
          icon,
          size: 18.sp,
          color: isActive
              ? AppColors.primary
              : AppColors.getTextColor(Theme.of(context).brightness),
        ),
      ),
    );
  }

  Widget _buildQuickActionsRow() {
    return Row(
      children: [
        _buildQuickAction(Icons.link, 'Add Link', _showAddLinkDialog),
        SizedBox(width: 12.w),
        _buildQuickAction(Icons.image, 'Add Image', _showAddImageDialog),
        SizedBox(width: 12.w),
        _buildQuickAction(Icons.alarm, 'Set Reminder', _showReminderDialog),
        const Spacer(),
        Text(
          '${_contentController.text.split(' ').length} words',
          style: TextStyle(
            fontSize: 12.sp,
            color: AppColors.getSecondaryTextColor(
              Theme.of(context).brightness,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickAction(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: AppColors.getSurfaceColor(Theme.of(context).brightness),
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: AppColors.getSecondaryTextColor(
              Theme.of(context).brightness,
            ).withOpacity(0.2),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16.sp,
              color: AppColors.getSecondaryTextColor(
                Theme.of(context).brightness,
              ),
            ),
            SizedBox(width: 4.w),
            Text(
              label,
              style: TextStyle(
                fontSize: 12.sp,
                color: AppColors.getSecondaryTextColor(
                  Theme.of(context).brightness,
                ),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton(
      onPressed: _saveNote,
      backgroundColor: AppColors.primary,
      elevation: 8,
      child: Icon(Icons.check, color: Colors.white, size: 24.sp),
    );
  }

  Widget _buildOptionsSheet() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.getSurfaceColor(Theme.of(context).brightness),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.r),
          topRight: Radius.circular(20.r),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            margin: EdgeInsets.only(top: 12.h),
            height: 4.h,
            width: 40.w,
            decoration: BoxDecoration(
              color: AppColors.getSecondaryTextColor(
                Theme.of(context).brightness,
              ),
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),

          ListTile(
            leading: Icon(
              Icons.share,
              color: AppColors.getTextColor(Theme.of(context).brightness),
            ),
            title: Text(
              'Share',
              style: TextStyle(
                color: AppColors.getTextColor(Theme.of(context).brightness),
              ),
            ),
            onTap: () {
              Navigator.pop(context);
              // TODO: Implement share functionality
            },
          ),

          ListTile(
            leading: Icon(
              Icons.copy,
              color: AppColors.getTextColor(Theme.of(context).brightness),
            ),
            title: Text(
              'Copy to Clipboard',
              style: TextStyle(
                color: AppColors.getTextColor(Theme.of(context).brightness),
              ),
            ),
            onTap: () {
              Navigator.pop(context);
              Clipboard.setData(ClipboardData(text: _contentController.text));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Copied to clipboard')),
              );
            },
          ),

          if (widget.note != null)
            ListTile(
              leading: Icon(Icons.delete, color: AppColors.error),
              title: Text(
                'Delete Note',
                style: TextStyle(color: AppColors.error),
              ),
              onTap: () {
                Navigator.pop(context);
                _showDeleteDialog();
              },
            ),

          SizedBox(height: MediaQuery.of(context).viewPadding.bottom),
        ],
      ),
    );
  }

  void _showSaveDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Save changes?'),
        content: const Text(
          'You have unsaved changes. Do you want to save them?',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Discard'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _saveNote();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete note?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              if (widget.note != null) {
                context.read<NotesBloc>().add(DeleteNoteEvent(widget.note!.id));
              }
              Navigator.pop(context);
            },
            child: Text('Delete', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  void _showAddLinkDialog() {
    final TextEditingController urlController = TextEditingController();
    final TextEditingController titleController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.getSurfaceColor(
          Theme.of(context).brightness,
        ),
        title: Text(
          'Add Link',
          style: TextStyle(
            color: AppColors.getTextColor(Theme.of(context).brightness),
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: urlController,
              decoration: InputDecoration(
                labelText: 'URL',
                hintText: 'https://example.com',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
              keyboardType: TextInputType.url,
            ),
            SizedBox(height: 16.h),
            TextField(
              controller: titleController,
              decoration: InputDecoration(
                labelText: 'Title (optional)',
                hintText: 'Link description',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final url = urlController.text.trim();
              if (url.isNotEmpty) {
                final title = titleController.text.trim();
                final linkText = title.isNotEmpty ? '[$title]($url)' : url;

                final currentText = _contentController.text;
                final cursorPosition = _contentController.selection.baseOffset;

                String newText;
                if (cursorPosition >= 0) {
                  newText =
                      currentText.substring(0, cursorPosition) +
                      linkText +
                      currentText.substring(cursorPosition);
                } else {
                  newText = currentText + '\n' + linkText;
                }

                _contentController.text = newText;
                _contentController.selection = TextSelection.collapsed(
                  offset: cursorPosition + linkText.length,
                );

                setState(() {
                  _isModified = true;
                });

                _debounceAnalysis();
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showAddImageDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: AppColors.getSurfaceColor(Theme.of(context).brightness),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20.r),
            topRight: Radius.circular(20.r),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40.w,
              height: 4.h,
              margin: EdgeInsets.symmetric(vertical: 16.h),
              decoration: BoxDecoration(
                color: Colors.grey.shade600,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            ListTile(
              leading: Icon(
                Icons.camera_alt,
                color: AppColors.getTextColor(Theme.of(context).brightness),
              ),
              title: Text(
                'Take Photo',
                style: TextStyle(
                  color: AppColors.getTextColor(Theme.of(context).brightness),
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: Icon(
                Icons.photo_library,
                color: AppColors.getTextColor(Theme.of(context).brightness),
              ),
              title: Text(
                'Choose from Gallery',
                style: TextStyle(
                  color: AppColors.getTextColor(Theme.of(context).brightness),
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }

  void _pickImage(ImageSource source) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: source);

      if (image != null) {
        final imageText = '![Image](${image.path})';
        final currentText = _contentController.text;
        final cursorPosition = _contentController.selection.baseOffset;

        String newText;
        if (cursorPosition >= 0) {
          newText =
              currentText.substring(0, cursorPosition) +
              imageText +
              currentText.substring(cursorPosition);
        } else {
          newText = currentText + '\n' + imageText;
        }

        _contentController.text = newText;
        _contentController.selection = TextSelection.collapsed(
          offset: cursorPosition + imageText.length,
        );

        setState(() {
          _isModified = true;
        });

        _debounceAnalysis();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to pick image: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showReminderDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: 300.h,
        decoration: BoxDecoration(
          color: AppColors.getSurfaceColor(Theme.of(context).brightness),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20.r),
            topRight: Radius.circular(20.r),
          ),
        ),
        child: Column(
          children: [
            Container(
              width: 40.w,
              height: 4.h,
              margin: EdgeInsets.symmetric(vertical: 16.h),
              decoration: BoxDecoration(
                color: Colors.grey.shade600,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Set Reminder',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.getTextColor(
                        Theme.of(context).brightness,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                        fontSize: 16.sp,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20.h),
            Expanded(
              child: ListView(
                children: [
                  _buildReminderOption(
                    'In 1 hour',
                    DateTime.now().add(const Duration(hours: 1)),
                  ),
                  _buildReminderOption('This evening (6 PM)', _getTodayAt(18)),
                  _buildReminderOption(
                    'Tomorrow morning (9 AM)',
                    _getTomorrowAt(9),
                  ),
                  _buildReminderOption(
                    'Next week',
                    DateTime.now().add(const Duration(days: 7)),
                  ),
                  ListTile(
                    leading: Icon(Icons.access_time, color: AppColors.primary),
                    title: Text(
                      'Custom time...',
                      style: TextStyle(
                        color: AppColors.getTextColor(
                          Theme.of(context).brightness,
                        ),
                      ),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      _showCustomReminderPicker();
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReminderOption(String title, DateTime dateTime) {
    return ListTile(
      leading: Icon(Icons.alarm, color: AppColors.primary),
      title: Text(
        title,
        style: TextStyle(
          color: AppColors.getTextColor(Theme.of(context).brightness),
        ),
      ),
      onTap: () {
        Navigator.pop(context);
        _setReminder(dateTime);
      },
    );
  }

  DateTime _getTodayAt(int hour) {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day, hour, 0);
  }

  DateTime _getTomorrowAt(int hour) {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return DateTime(tomorrow.year, tomorrow.month, tomorrow.day, hour, 0);
  }

  void _showCustomReminderPicker() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (date != null) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (time != null) {
        final dateTime = DateTime(
          date.year,
          date.month,
          date.day,
          time.hour,
          time.minute,
        );
        _setReminder(dateTime);
      }
    }
  }

  void _setReminder(DateTime dateTime) {
    // TODO: Implement actual reminder setting with notifications
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Reminder set for ${dateTime.toString().substring(0, 16)}',
        ),
        backgroundColor: AppColors.primary,
      ),
    );

    // Add reminder text to note
    final reminderText =
        '\n📅 Reminder: ${dateTime.toString().substring(0, 16)}\n';
    final currentText = _contentController.text;
    _contentController.text = currentText + reminderText;

    setState(() {
      _isModified = true;
    });

    _debounceAnalysis();
  }
}
