import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:flutter_quill_extensions/flutter_quill_extensions.dart';
import 'package:mynotes/core/services/ocr_service.dart';
import 'package:share_plus/share_plus.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:mynotes/presentation/design_system/design_system.dart';
import 'package:mynotes/core/services/speech_service.dart';
import 'graph_view_page.dart';
import 'package:mynotes/core/services/voice_command_service.dart';
// OPTIONAL FEATURE: Knowledge Graph & Linking (may be removed)
import 'package:mynotes/core/services/link_parser_service.dart';
import 'package:mynotes/data/datasources/local_database.dart';
import 'package:mynotes/data/repositories/note_repository_impl.dart';
import 'package:mynotes/core/services/audio_feedback_service.dart';
import 'package:mynotes/presentation/bloc/note_bloc.dart';
import 'package:mynotes/presentation/bloc/note_editor_bloc.dart';
import 'package:mynotes/presentation/bloc/note_editor_event.dart';
import 'package:mynotes/presentation/bloc/note_editor_state.dart';
import 'package:mynotes/presentation/bloc/note_event.dart';
import 'package:mynotes/domain/entities/note.dart';
import 'package:mynotes/domain/entities/media_item.dart';
import 'package:mynotes/presentation/widgets/drawing_canvas_widget.dart';
import 'package:mynotes/presentation/widgets/audio_recorder_widget.dart';
import 'package:mynotes/presentation/widgets/document_scanner_widget.dart';
import 'package:mynotes/presentation/widgets/add_reminder_bottom_sheet.dart';
import 'package:mynotes/presentation/widgets/note_template_selector.dart';
import 'package:mynotes/presentation/widgets/video_player_widget.dart';
import '../widgets/developer_test_links_sheet.dart';
import '../widgets/universal_media_sheet.dart';
import 'package:mynotes/presentation/widgets/create_todo_bottom_sheet.dart';
import 'package:mynotes/presentation/widgets/media_player_widget.dart';
import 'package:mynotes/presentation/pages/media_viewer_screen.dart';

class EnhancedNoteEditorScreen extends StatefulWidget {
  final Note? note;
  final String? initialContent;
  final dynamic template;

  const EnhancedNoteEditorScreen({
    super.key,
    this.note,
    this.initialContent,
    this.template,
  });

  @override
  State<EnhancedNoteEditorScreen> createState() =>
      _EnhancedNoteEditorScreenState();
}

class _EnhancedNoteEditorScreenState extends State<EnhancedNoteEditorScreen>
    with TickerProviderStateMixin {
  final TextEditingController _titleController = TextEditingController();
  late quill.QuillController _quillController;
  final FocusNode _titleFocusNode = FocusNode();
  final FocusNode _contentFocusNode = FocusNode();

  final SpeechService _speechService = SpeechService();
  final VoiceCommandService _commandService = VoiceCommandService();
  final AudioFeedbackService _feedbackService = AudioFeedbackService();

  late AnimationController _summaryController;
  late AnimationController _fabController;
  late AnimationController _toolbarController;
  final ScrollController _scrollController = ScrollController();
  final ScrollController _quillScrollController = ScrollController();

  late NoteEditorBloc _editorBloc;
  bool _isUndoingOrRedoing = false;

  @override
  void initState() {
    super.initState();
    _summaryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fabController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _toolbarController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _fabController.forward();

    _editorBloc =
        NoteEditorBloc(
          speechService: _speechService,
          commandService: _commandService,
          feedbackService: _feedbackService,
          ocrService: OCRService(),
          // OPTIONAL FEATURE: Knowledge Graph & Linking (may be removed)
          noteRepository: NoteRepositoryImpl(database: NotesDatabase()),
          linkParserService: LinkParserService(),
        )..add(
          NoteEditorInitialized(
            note: widget.note,
            template: widget.template,
            initialContent: widget.initialContent,
          ),
        );

    _quillController = quill.QuillController.basic();
    _setupUIListeners();
  }

  void _setupUIListeners() {
    _contentFocusNode.addListener(() {
      if (_contentFocusNode.hasFocus) {
        _toolbarController.forward();
      } else {
        _toolbarController.reverse();
      }
    });

    _quillController.addListener(() {
      if (!_isUndoingOrRedoing) {
        final content = jsonEncode(
          _quillController.document.toDelta().toJson(),
        );
        _editorBloc.add(ContentChanged(content));
      }
    });

    _titleController.addListener(() {
      _editorBloc.add(TitleChanged(_titleController.text));
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _quillController.dispose();
    _titleFocusNode.dispose();
    _contentFocusNode.dispose();
    _summaryController.dispose();
    _fabController.dispose();
    _toolbarController.dispose();
    _scrollController.dispose();
    _quillScrollController.dispose();
    _editorBloc.close();
    super.dispose();
  }

  void _loadContentIntoQuill(String content) {
    if (content.isEmpty) return;
    _isUndoingOrRedoing = true;
    try {
      if (content.startsWith('[') || content.startsWith('{')) {
        _quillController.document = quill.Document.fromJson(
          jsonDecode(content),
        );
      } else {
        _quillController.document = quill.Document()..insert(0, content);
      }
    } catch (e) {
      _quillController.document = quill.Document()..insert(0, content);
    }
    _isUndoingOrRedoing = false;
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _editorBloc,
      child: BlocListener<NoteEditorBloc, NoteEditorState>(
        listener: (context, state) {
          if (state is NoteEditorLoaded) {
            if (state.errorCode != null) {
              _handleError(state.errorCode!);
            }
            if (state.summary != null && state.summary!.isNotEmpty) {
              _summaryController.forward();
            }
            if (state.extractedText != null &&
                state.extractedText!.isNotEmpty) {
              _insertExtractedText(state.extractedText!);
            }
          }
        },
        child: BlocBuilder<NoteEditorBloc, NoteEditorState>(
          builder: (context, state) {
            if (state is NoteEditorInitial) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            final params = state.params;

            if (_titleController.text.isEmpty && params.title.isNotEmpty) {
              _titleController.text = params.title;
            }
            if (_quillController.document.isEmpty() &&
                params.content.isNotEmpty) {
              _loadContentIntoQuill(params.content);
            }

            return Stack(
              children: [
                Scaffold(
                  backgroundColor: params.color.toColor(
                    Theme.of(context).brightness == Brightness.dark,
                  ),
                  appBar: _buildAppBar(context, state),
                  body: Column(
                    children: [
                      if (state.summary != null)
                        _buildSummaryCard(context, state.summary!),
                      _buildTitleField(context),
                      Expanded(child: _buildQuillEditor(context, state)),
                      _buildAttachmentLists(context, state),
                      if (_contentFocusNode.hasFocus)
                        _buildFormattingToolbar(context),
                    ],
                  ),
                  bottomNavigationBar: _buildBottomActionButtons(
                    context,
                    state,
                  ),
                  floatingActionButton: _buildFAB(context, state),
                ),
                if (state is NoteEditorLoaded && state.isExtracting)
                  Container(
                    color: Colors.black54,
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const CircularProgressIndicator(color: Colors.orange),
                          const SizedBox(height: 16),
                          Text(
                            'Extracting text...',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16.sp,
                              decoration: TextDecoration.none,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _insertExtractedText(String text) {
    if (text.isEmpty) return;
    final index = _quillController.selection.baseOffset;
    _quillController.document.insert(index, '\n$text\n');
  }

  void _handleError(String code) {
    String message = 'An error occurred';
    switch (code) {
      case 'SPEECH_PERMISSION_DENIED':
        message = 'Microphone permission denied';
        break;
      case 'SPEECH_INIT_FAILED':
        message = 'Speech service failed to start';
        break;
      case 'SAVE_FAILED':
        message = 'Failed to save note';
        break;
      case 'EMPTY_NOTE':
        message = 'Note cannot be empty';
        break;
      case 'SUMMARY_FAILED':
        message = 'AI Summary failed';
        break;
      case 'EXTRACTION_FAILED':
        message = 'Could not extract text from file';
        break;
      case 'EXTRACTION_ERROR':
        message = 'Error during text extraction';
        break;
      case 'MEDIA_ADD_FAILED':
        message = 'Failed to attach media';
        break;
      case 'MEDIA_REMOVE_FAILED':
        message = 'Failed to remove media';
        break;
      case 'MEDIA_UPDATE_FAILED':
        message = 'Failed to update media';
        break;
      case 'GENERAL_ERROR':
      default:
        message = 'An unexpected error occurred';
        break;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.errorColor),
    );
  }

  AppBar _buildAppBar(BuildContext context, NoteEditorState state) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.hub),
          tooltip: 'Knowledge Graph',
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const GraphViewPage()),
          ),
        ),
        IconButton(
          icon: Icon(
            state.params.isPinned ? Icons.push_pin : Icons.push_pin_outlined,
          ),
          onPressed: () => _editorBloc.add(const PinToggled()),
        ),
        IconButton(
          icon: const Icon(Icons.undo),
          onPressed: () => _quillController.undo(),
        ),
        IconButton(
          icon: const Icon(Icons.redo),
          onPressed: () => _quillController.redo(),
        ),
        IconButton(
          icon: const Icon(Icons.check),
          onPressed: () => _saveNote(state),
        ),
      ],
    );
  }

  Widget _buildTitleField(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: TextField(
        controller: _titleController,
        focusNode: _titleFocusNode,
        style: AppTypography.heading2(context, AppColors.textPrimary(context)),
        decoration: const InputDecoration(
          hintText: 'Title',
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildSummaryCard(BuildContext context, String summary) {
    return SizeTransition(
      sizeFactor: _summaryController,
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.auto_awesome, size: 16, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(
                  'AI Summary',
                  style: AppTypography.heading3(context, AppColors.primary),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close, size: 16),
                  onPressed: () => _summaryController.reverse(),
                ),
              ],
            ),
            Text(
              summary,
              style: AppTypography.bodyMedium(
                context,
                AppColors.textPrimary(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuillEditor(BuildContext context, NoteEditorState state) {
    return quill.QuillEditor.basic(
      configurations: quill.QuillEditorConfigurations(
        controller: _quillController,
        // readOnly: false,
        placeholder: 'Start typing...',
        padding: EdgeInsets.zero,
        autoFocus: false,
        expands: false, // Set to false when wrapped in SingleChildScrollView
        // scrollController: _quillScrollController, // Not needed when parent is SingleChildScrollView
        embedBuilders: FlutterQuillEmbeds.editorBuilders(),
      ),
      focusNode: _contentFocusNode,
    );
  }

  Widget _buildFormattingToolbar(BuildContext context) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, 1),
        end: Offset.zero,
      ).animate(_toolbarController),
      child: Container(
        color: AppColors.surface(context),
        child: quill.QuillToolbar.simple(
          configurations: quill.QuillSimpleToolbarConfigurations(
            controller: _quillController,
            showAlignmentButtons: false,
            showBoldButton: true,
            showItalicButton: true,
            showUnderLineButton: true,
            showListNumbers: true,
            showListBullets: true,
            showQuote: true,
            embedButtons: FlutterQuillEmbeds.toolbarButtons(),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomActionButtons(
    BuildContext context,
    NoteEditorState state,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          IconButton(
            icon: const Icon(Icons.attach_file_outlined),
            onPressed: _showUnifiedMediaSheet,
            tooltip: 'Attach Media',
          ),
          IconButton(
            icon: const Icon(Icons.mic_none_outlined),
            onPressed: () => _editorBloc.add(const VoiceInputToggled()),
            tooltip: 'Voice Input',
          ),
          IconButton(
            icon: const Icon(Icons.local_offer_outlined),
            onPressed: _showTagPicker,
            tooltip: 'Tags',
          ),
          IconButton(
            icon: const Icon(Icons.auto_awesome_outlined),
            onPressed: () => _editorBloc.add(const GenerateSummaryRequested()),
            tooltip: 'AI Summary',
          ),
          IconButton(
            icon: const Icon(Icons.more_horiz),
            onPressed: _showMoreOptions,
            tooltip: 'More',
          ),
        ],
      ),
    );
  }

  Widget _buildFAB(BuildContext context, NoteEditorState state) {
    return FloatingActionButton(
      heroTag: 'enhanced_note_editor_fab', // Fix for hero conflict
      onPressed: () => _saveNote(state),
      backgroundColor: AppColors.primary,
      child: state.isSaving
          ? const CircularProgressIndicator(color: Colors.white)
          : const Icon(Icons.save),
    );
  }

  void _saveNote(NoteEditorState state) {
    final params = state.params;
    final noteParams = params.copyWith(
      title: _titleController.text,
      content: jsonEncode(_quillController.document.toDelta().toJson()),
    );

    if (noteParams.title.isEmpty && _quillController.document.isEmpty()) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Note is empty')));
      return;
    }

    if (widget.note != null) {
      context.read<NotesBloc>().add(UpdateNoteEvent(noteParams));
    } else {
      context.read<NotesBloc>().add(CreateNoteEvent(params: noteParams));
    }

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Note saved'),
        backgroundColor: AppColors.successColor,
      ),
    );
  }

  Future<void> _pickImage() async {
    try {
      final picker = ImagePicker();
      final image = await picker.pickImage(source: ImageSource.gallery);

      if (image != null) {
        _editorBloc.add(MediaAdded(image.path, MediaType.image));

        final index = _quillController.selection.baseOffset;
        _quillController.document.insert(index, '\n');
        _quillController.document.insert(
          index + 1,
          quill.BlockEmbed.image(image.path),
        );
      }
    } catch (e) {
      _editorBloc.add(
        ErrorOccurred('Failed to pick image: $e', code: 'MEDIA_ADD_FAILED'),
      );
    }
  }

  // OPTIONAL FEATURE: Knowledge Graph & Linking (may be removed)
  Widget _buildBacklinksPanel(NoteEditorState state) {
    return Container(
      margin: const EdgeInsets.only(top: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.grey400),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.link, size: 20, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                'Linked References',
                style: AppTypography.heading3(
                  context,
                  AppColors.textPrimary(context),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...state.linkedNotes.map(
            (note) => InkWell(
              onTap: () {
                // Navigation to linked note could be implemented here
                // For now, maybe just show a snackbar or push a new editor?
                // Ideally: Navigator.push(context, MaterialPageRoute(builder: (_) => EnhancedNoteEditorScreen(note: note)))
                // But we need to make sure we don't stack indefinitely.
                // Let's just push for now.
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => EnhancedNoteEditorScreen(note: note),
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            note.title.isNotEmpty
                                ? note.title
                                : 'Untitled Note',
                            style: AppTypography.body1(
                              context,
                              AppColors.textPrimary(context),
                            ).copyWith(fontWeight: FontWeight.w600),
                          ),
                          if (note.content.isNotEmpty)
                            Text(
                              note.content.length > 50
                                  ? '${note.content.substring(0, 50)}...'
                                  : note.content,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTypography.caption(
                                context,
                                AppColors.textSecondary(context),
                              ),
                            ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.chevron_right,
                      size: 16,
                      color: AppColors.grey500,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showTagPicker() {
    showModalBottomSheet(
      context: context,
      builder: (context) => BlocProvider.value(
        value: _editorBloc,
        child: BlocBuilder<NoteEditorBloc, NoteEditorState>(
          builder: (context, state) {
            return Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Manage Tags',
                    style: AppTypography.heading3(
                      context,
                      AppColors.textPrimary(context),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    children: state.params.tags
                        .map(
                          (tag) => Chip(
                            label: Text(tag),
                            onDeleted: () => _editorBloc.add(TagRemoved(tag)),
                          ),
                        )
                        .toList(),
                  ),
                  TextField(
                    decoration: const InputDecoration(hintText: 'Add tag...'),
                    onSubmitted: (value) {
                      if (value.isNotEmpty) _editorBloc.add(TagAdded(value));
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  void _showMoreOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.share),
            title: const Text('Share Note'),
            onTap: () async {
              final content = _quillController.document.toPlainText();
              final state = _editorBloc.state;
              final media = state.params.media;
              final title = state.params.title;
              final tags = state.params.tags;

              String shareText = '';
              if (title.isNotEmpty) shareText += '$title\n\n';
              shareText += content;
              if (tags.isNotEmpty) {
                shareText += '\n\nTags: ${tags.join(", ")}';
              }

              Navigator.pop(context);

              if (media.isEmpty) {
                await Share.share(
                  shareText,
                  subject: title.isNotEmpty ? title : null,
                );
              } else {
                final files = media.map((m) => XFile(m.filePath)).toList();
                await Share.shareXFiles(
                  files,
                  text: shareText,
                  subject: title.isNotEmpty ? title : null,
                );
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete, color: Colors.red),
            title: const Text(
              'Delete Note',
              style: TextStyle(color: Colors.red),
            ),
            onTap: () {
              if (widget.note != null) {
                context.read<NotesBloc>().add(DeleteNoteEvent(widget.note!.id));
              }
              Navigator.pop(context);
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  void _showUnifiedMediaSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => UniversalMediaSheet(
        onOptionSelected: (option) {
          switch (option) {
            case MediaOption.photoVideo:
              _pickImage();
              break;
            case MediaOption.camera:
              _takePhoto(); // Need to implement or update _pickImage
              break;
            case MediaOption.audio:
              _openAudioRecorder();
              break;
            case MediaOption.scan:
              _openDocumentScanner();
              break;
            case MediaOption.sketch:
              _openDrawingCanvas();
              break;
            case MediaOption.link:
              _showAddLinkDialog();
              break;
          }
        },
      ),
    );
  }

  Future<void> _takePhoto() async {
    try {
      final picker = ImagePicker();
      final image = await picker.pickImage(source: ImageSource.camera);

      if (image != null) {
        _editorBloc.add(MediaAdded(image.path, MediaType.image));

        final index = _quillController.selection.baseOffset;
        _quillController.document.insert(index, '\n');
        _quillController.document.insert(
          index + 1,
          quill.BlockEmbed.image(image.path),
        );
      }
    } catch (e) {
      _editorBloc.add(
        ErrorOccurred('Failed to take photo: $e', code: 'MEDIA_ADD_FAILED'),
      );
    }
  }

  void _showAddLinkDialog() {
    final TextEditingController urlController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Link'),
        content: TextField(
          controller: urlController,
          decoration: const InputDecoration(hintText: 'https://example.com'),
          autofocus: true,
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
                // For now, insert as text. Ideally, create a Link object.
                final index = _quillController.selection.baseOffset;
                _quillController.document.insert(index, url);
              }
              Navigator.pop(context);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _openDrawingCanvas() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(title: const Text('Drawing')),
          body: DrawingCanvasWidget(
            onDrawingComplete: (image) => _onDrawingComplete(image),
          ),
        ),
      ),
    );
  }

  void _openAudioRecorder() {
    showModalBottomSheet(
      context: context,
      builder: (context) => AudioRecorderWidget(
        onRecordingComplete: (path, duration) =>
            _onAudioComplete(path, duration),
      ),
    );
  }

  void _openDocumentScanner() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          body: DocumentScannerWidget(
            onScanComplete: (doc) => _onScanComplete(doc),
            onCancel: () => Navigator.pop(context),
          ),
        ),
      ),
    );
  }

  void _openReminderPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => AddReminderBottomSheet(
        onReminderCreated: (alarm) => _editorBloc.add(AlarmAdded(alarm)),
      ),
    );
  }

  void _openTemplateSelector() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: TemplateSelector(
          onTemplateSelected: (template) {
            _editorBloc.add(TemplateApplied(template));
            Navigator.pop(context);
          },
        ),
      ),
    );
  }

  void _openTodoPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => CreateTodoBottomSheet(
        onTodoCreated: (todo) => _editorBloc.add(TodoAdded(todo)),
      ),
    );
  }

  Future<void> _onDrawingComplete(ui.Image image) async {
    try {
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return;

      final bytes = byteData.buffer.asUint8List();
      final tempDir = Directory.systemTemp;
      final file = File(
        '${tempDir.path}/drawing_${DateTime.now().millisecondsSinceEpoch}.png',
      );
      await file.writeAsBytes(bytes);

      _editorBloc.add(MediaAdded(file.path, MediaType.image));

      // Also insert into Quill
      final index = _quillController.selection.baseOffset;
      _quillController.document.insert(index, '\n');
      _quillController.document.insert(
        index + 1,
        quill.BlockEmbed.image(file.path),
      );

      if (mounted) Navigator.pop(context);
    } catch (e) {
      _editorBloc.add(
        ErrorOccurred('Failed to save drawing: $e', code: 'MEDIA_ADD_FAILED'),
      );
    }
  }

  Future<void> _pickVideo() async {
    try {
      final picker = ImagePicker();
      final video = await picker.pickVideo(source: ImageSource.camera);

      if (video != null) {
        _editorBloc.add(
          MediaAdded(video.path, MediaType.video, name: video.name),
        );
      }
    } catch (e) {
      _editorBloc.add(
        ErrorOccurred('Failed to pick video: $e', code: 'MEDIA_ADD_FAILED'),
      );
    }
  }

  void _onAudioComplete(String path, Duration duration) {
    _editorBloc.add(
      MediaAdded(
        path,
        MediaType.audio,
        name: 'Audio Recording',
        duration: duration.inMilliseconds,
      ),
    );
    if (mounted) Navigator.pop(context);
  }

  void _onScanComplete(ScannedDocument doc) {
    _editorBloc.add(
      MediaAdded(doc.filePath, MediaType.image, name: doc.fileName),
    );
    Navigator.pop(context);
  }

  Future<void> _pickDocument() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'ppt', 'pptx', 'txt'],
      );

      if (result != null) {
        for (final file in result.files) {
          if (file.path != null) {
            _editorBloc.add(
              MediaAdded(file.path!, MediaType.document, name: file.name),
            );
            // Auto-prompt for OCR/Extraction if it's a PDF or Image
            _showExtractionPrompt(file.path!, file.name);
          }
        }
      }
    } catch (e) {
      _editorBloc.add(
        ErrorOccurred('Failed to pick document: $e', code: 'MEDIA_ADD_FAILED'),
      );
    }
  }

  void _showExtractionPrompt(String path, String name) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Extract Text?'),
        content: Text(
          'Do you want to extract text from "$name" and insert it into your note?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _editorBloc.add(TextExtractionRequested(path));
            },
            child: const Text('Extract'),
          ),
        ],
      ),
    );
  }

  Widget _buildAttachmentLists(BuildContext context, NoteEditorState state) {
    final audioAttachments = state.params.media
        .where((m) => m.type == MediaType.audio)
        .map(
          (m) => AudioMetadata(
            filePath: m.filePath,
            fileName: m.name,
            fileSize: 0,
            duration: Duration(milliseconds: m.durationMs),
            createdAt: m.createdAt,
          ),
        )
        .toList();

    final videoAttachments = state.params.media
        .where((m) => m.type == MediaType.video)
        .map(
          (m) => VideoMetadata(
            filePath: m.filePath,
            fileName: m.name,
            fileSize: 0,
            duration: Duration(milliseconds: m.durationMs),
            thumbnailPath: m.thumbnailPath,
            createdAt: m.createdAt,
          ),
        )
        .toList();

    final scannedDocs = state.params.media
        .where((m) => m.name.startsWith('Scan') || m.filePath.contains('scan'))
        .map(
          (m) => ScannedDocument(
            filePath: m.filePath,
            fileName: m.name,
            pageImagePaths: [m.filePath],
            createdAt: m.createdAt,
            pageCount: 1,
          ),
        )
        .toList();

    final fileAttachments = state.params.media
        .where((m) => m.type == MediaType.document)
        .toList();

    return Column(
      children: [
        if (fileAttachments.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Attached Files',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 8),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: fileAttachments.length,
                  itemBuilder: (context, index) {
                    final file = fileAttachments[index];
                    return ListTile(
                      leading: const Icon(
                        Icons.description,
                        color: Colors.orange,
                      ),
                      title: Text(file.name),
                      subtitle: Text(
                        '${(file.size / 1024).toStringAsFixed(1)} KB',
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.spellcheck),
                            tooltip: 'Extract Text',
                            onPressed: () => _editorBloc.add(
                              TextExtractionRequested(file.filePath),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline),
                            onPressed: () {
                              final globalIndex = state.params.media.indexOf(
                                file,
                              );
                              if (globalIndex != -1) {
                                _editorBloc.add(MediaRemoved(globalIndex));
                              }
                            },
                          ),
                        ],
                      ),
                      onTap: () =>
                          _openMediaViewer(state, index, MediaType.document),
                    );
                  },
                ),
              ],
            ),
          ),
        if (audioAttachments.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: AudioAttachmentsList(
              audios: audioAttachments,
              onAudioDelete: (index) {
                final audio = audioAttachments[index];
                final globalIndex = state.params.media.indexWhere(
                  (m) => m.filePath == audio.filePath,
                );
                if (globalIndex != -1) {
                  _editorBloc.add(MediaRemoved(globalIndex));
                }
              },
            ),
          ),
        if (videoAttachments.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: VideoAttachmentsList(
              videos: videoAttachments,
              onVideoDelete: (index) {
                final video = videoAttachments[index];
                final globalIndex = state.params.media.indexWhere(
                  (m) => m.filePath == video.filePath,
                );
                if (globalIndex != -1) {
                  _editorBloc.add(MediaRemoved(globalIndex));
                }
              },
              onVideoTap: (index) =>
                  _openMediaViewer(state, index, MediaType.video),
            ),
          ),
        if (scannedDocs.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: DocumentAttachmentsList(
              documents: scannedDocs,
              onDocumentDelete: (index) {
                final doc = scannedDocs[index];
                final globalIndex = state.params.media.indexWhere(
                  (m) => m.filePath == doc.filePath,
                );
                if (globalIndex != -1) {
                  _editorBloc.add(MediaRemoved(globalIndex));
                }
              },
              onDocumentTap: (index) =>
                  _openMediaViewer(state, index, MediaType.image),
            ),
          ),
        _buildImageGallery(state),
      ],
    );
  }

  Widget _buildImageGallery(NoteEditorState state) {
    final images = state.params.media
        .where((m) => m.type == MediaType.image)
        .toList();
    if (images.isEmpty) return const SizedBox.shrink();

    return Container(
      height: 120,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: images.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          return ImageThumbnailWidget(
            imagePath: images[index].filePath,
            onTap: () => _openMediaViewer(state, index, MediaType.image),
          );
        },
      ),
    );
  }

  void _openMediaViewer(NoteEditorState state, int index, MediaType type) {
    final filteredMedia = state.params.media
        .where((m) => m.type == type)
        .toList();
    if (index >= filteredMedia.length) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MediaViewerScreen(
          mediaItems: filteredMedia,
          initialIndex: index,
          onDelete: (media) {
            final globalIndex = state.params.media.indexWhere(
              (m) => m.id == media.id,
            );
            if (globalIndex != -1) _editorBloc.add(MediaRemoved(globalIndex));
          },
          onUpdate: (oldMedia, newMedia) {
            _editorBloc.add(MediaUpdated(oldMedia, newMedia));
          },
        ),
      ),
    );
  }
}
