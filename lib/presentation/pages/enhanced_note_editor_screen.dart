// lib/presentation/pages/enhanced_note_editor_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:mynotes/injection_container.dart';
import 'package:mynotes/core/services/media_processing_service.dart';
import 'package:mynotes/core/services/ocr_service.dart';
import 'package:mynotes/core/utils/context_scanner.dart';
import 'package:share_plus/share_plus.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:mynotes/presentation/design_system/design_system.dart';
import 'package:mynotes/core/services/speech_service.dart';
import 'package:mynotes/core/services/voice_command_service.dart';
import 'package:mynotes/core/services/link_parser_service.dart';
import 'package:mynotes/data/datasources/local_database.dart';
import 'package:mynotes/data/repositories/note_repository_impl.dart';
import 'package:mynotes/core/services/audio_feedback_service.dart';
import 'package:mynotes/presentation/bloc/note/note_bloc.dart';
import 'package:mynotes/presentation/bloc/note_editor/note_editor_bloc.dart';
import 'package:mynotes/presentation/bloc/note_editor/note_editor_event.dart';
import 'package:mynotes/presentation/bloc/note_editor/note_editor_state.dart';
import 'package:mynotes/presentation/bloc/note/note_event.dart';
import 'package:mynotes/domain/entities/note.dart';
import 'package:mynotes/domain/entities/media_item.dart';
import 'package:mynotes/presentation/widgets/drawing_canvas_widget.dart';
import 'package:mynotes/presentation/widgets/audio_recorder_widget.dart';
import 'package:mynotes/presentation/widgets/document_scanner_widget.dart';
import 'package:mynotes/presentation/widgets/add_reminder_bottom_sheet.dart';
import 'package:mynotes/presentation/widgets/note_template_selector.dart';
import 'package:mynotes/presentation/widgets/video_player_widget.dart';
import '../widgets/universal_media_sheet.dart';
import 'package:mynotes/presentation/widgets/create_todo_bottom_sheet.dart';
import 'package:mynotes/presentation/widgets/media_player_widget.dart';
import 'package:mynotes/presentation/pages/media_viewer_screen.dart';
import 'package:mynotes/presentation/widgets/note_suggestion_bar.dart';

class EnhancedNoteEditorScreen extends StatelessWidget {
  final Note? note;
  final String? initialContent;
  final dynamic template;

  const EnhancedNoteEditorScreen({
    super.key,
    this.note,
    this.initialContent,
    this.template,
  });

  void _loadContentIntoQuill(quill.QuillController controller, String content) {
    if (content.isEmpty) return;
    try {
      if (content.startsWith('[') || content.startsWith('{')) {
        controller.document = quill.Document.fromJson(jsonDecode(content));
      } else {
        controller.document = quill.Document()..insert(0, content);
      }
    } catch (e) {
      controller.document = quill.Document()..insert(0, content);
    }
  }

  void _insertExtractedText(quill.QuillController controller, String text) {
    if (text.isEmpty) return;
    final index = controller.selection.baseOffset;
    controller.document.insert(index, '\n$text\n');
  }

  void _handleError(BuildContext context, String code) {
    String message;
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

  void _saveNote(
    BuildContext context,
    NoteEditorState state,
    TextEditingController titleController,
    quill.QuillController quillController,
  ) {
    final params = state.params;
    final noteParams = params.copyWith(
      title: titleController.text,
      content: jsonEncode(quillController.document.toDelta().toJson()),
    );

    if (noteParams.title.isEmpty && quillController.document.isEmpty()) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Note is empty')));
      return;
    }

    if (note != null) {
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

  @override
  Widget build(BuildContext context) {
    return _NoteEditorLifecycleWrapper(
      note: note,
      template: template,
      initialContent: initialContent,
      builder:
          (
            context,
            editorBloc,
            quillController,
            titleController,
            titleFocusNode,
            contentFocusNode,
            scrollController,
            quillScrollController,
          ) {
            return BlocProvider.value(
              value: editorBloc,
              child: BlocListener<NoteEditorBloc, NoteEditorState>(
                listener: (context, state) {
                  if (state is NoteEditorLoaded) {
                    if (state.errorCode != null) {
                      _handleError(context, state.errorCode!);
                    }
                    if (state.extractedText != null &&
                        state.extractedText!.isNotEmpty) {
                      _insertExtractedText(
                        quillController,
                        state.extractedText!,
                      );
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

                    if (titleController.text.isEmpty &&
                        params.title.isNotEmpty) {
                      titleController.text = params.title;
                    }
                    if (quillController.document.isEmpty() &&
                        params.content.isNotEmpty) {
                      _loadContentIntoQuill(quillController, params.content);
                    }

                    return Stack(
                      children: [
                        Scaffold(
                          backgroundColor: params.color.toColor(
                            Theme.of(context).brightness == Brightness.dark,
                          ),
                          appBar: _buildAppBar(
                            context,
                            state,
                            editorBloc,
                            quillController,
                            titleController,
                          ),
                          body: Column(
                            children: [
                              if (state.summary != null)
                                _buildSummaryCard(context, state.summary!),
                              NoteSuggestionBar(
                                suggestions: state.suggestions,
                                onAccept: (suggestion) {
                                  editorBloc.add(
                                    SuggestionActionAccepted(suggestion),
                                  );
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Created ${suggestion.type == SuggestionType.todo ? 'Todo' : 'Reminder'}: ${suggestion.title}',
                                      ),
                                      behavior: SnackBarBehavior.floating,
                                      backgroundColor: const Color(0xFF10B981),
                                    ),
                                  );
                                },
                                onDismiss: () {},
                              ),
                              _buildTitleField(
                                context,
                                titleController,
                                titleFocusNode,
                              ),
                              Expanded(
                                child: _buildQuillEditor(
                                  context,
                                  state,
                                  quillController,
                                  quillScrollController,
                                  contentFocusNode,
                                ),
                              ),
                              _buildAttachmentLists(context, state, editorBloc),
                              if (contentFocusNode.hasFocus)
                                _buildFormattingToolbar(
                                  context,
                                  quillController,
                                ),
                            ],
                          ),
                          bottomNavigationBar: _buildBottomActionButtons(
                            context,
                            state,
                            editorBloc,
                          ),
                          floatingActionButton: _buildFAB(
                            context,
                            state,
                            titleController,
                            quillController,
                          ),
                        ),
                        if (state is NoteEditorLoaded && state.isExtracting)
                          Container(
                            color: Colors.black54,
                            child: Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const CircularProgressIndicator(
                                    color: Colors.orange,
                                  ),
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
          },
    );
  }

  Future<void> _pickImage(
    BuildContext context,
    NoteEditorBloc editorBloc,
    quill.QuillController quillController,
  ) async {
    try {
      final picker = ImagePicker();
      final image = await picker.pickImage(source: ImageSource.gallery);

      if (image != null) {
        editorBloc.add(MediaAdded(image.path, MediaType.image));

        final index = quillController.selection.baseOffset;
        quillController.document.insert(index, '\n');
        quillController.document.insert(
          index + 1,
          quill.BlockEmbed.image(image.path),
        );
      }
    } catch (e) {
      editorBloc.add(
        ErrorOccurred('Failed to pick image: $e', code: 'MEDIA_ADD_FAILED'),
      );
    }
  }

  Widget _buildBacklinksPanel(BuildContext context, NoteEditorState state) {
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
            (linkedNote) => InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => EnhancedNoteEditorScreen(note: linkedNote),
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
                            linkedNote.title.isNotEmpty
                                ? linkedNote.title
                                : 'Untitled Note',
                            style: AppTypography.body1(
                              context,
                              AppColors.textPrimary(context),
                            ).copyWith(fontWeight: FontWeight.w600),
                          ),
                          if (linkedNote.content.isNotEmpty)
                            Text(
                              linkedNote.content.length > 50
                                  ? '${linkedNote.content.substring(0, 50)}...'
                                  : linkedNote.content,
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

  void _showTagPicker(BuildContext context, NoteEditorBloc editorBloc) {
    showModalBottomSheet(
      context: context,
      builder: (sheetContext) => BlocProvider.value(
        value: editorBloc,
        child: BlocBuilder<NoteEditorBloc, NoteEditorState>(
          builder: (blocContext, state) {
            return Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Manage Tags',
                    style: AppTypography.heading3(
                      blocContext,
                      AppColors.textPrimary(blocContext),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    children: state.params.tags
                        .map(
                          (tag) => Chip(
                            label: Text(tag),
                            onDeleted: () => editorBloc.add(TagRemoved(tag)),
                          ),
                        )
                        .toList(),
                  ),
                  TextField(
                    decoration: const InputDecoration(hintText: 'Add tag...'),
                    onSubmitted: (value) {
                      if (value.isNotEmpty) {
                        editorBloc.add(TagAdded(value));
                      }
                      Navigator.pop(blocContext);
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

  void _showMoreOptions(BuildContext context, NoteEditorBloc editorBloc) {
    // Capture `note` from the StatelessWidget's field before entering the sheet
    final currentNote = note;

    showModalBottomSheet(
      context: context,
      builder: (sheetContext) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.share),
            title: const Text('Share Note'),
            onTap: () async {
              Navigator.pop(sheetContext);
              final state = editorBloc.state;
              if (state is NoteEditorLoaded) {
                final text = "${state.params.title}\n\n${state.params.content}";
                await Share.share(
                  text,
                  subject: state.params.title.isNotEmpty
                      ? state.params.title
                      : 'MyNotes Attachment',
                );
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.check_box_outlined, color: Colors.green),
            title: const Text('Convert to Task'),
            subtitle: const Text('Promote this note to a todo item'),
            onTap: () {
              Navigator.pop(sheetContext);
              editorBloc.add(const PromoteToTodoRequested());
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Note promoted to task!'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete, color: Colors.red),
            title: const Text(
              'Delete Note',
              style: TextStyle(color: Colors.red),
            ),
            onTap: () {
              if (currentNote != null) {
                context.read<NotesBloc>().add(DeleteNoteEvent(currentNote.id));
              }
              Navigator.pop(sheetContext);
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  // ─── Helper Widget Builders ───────────────────────────────────────────

  PreferredSizeWidget _buildAppBar(
    BuildContext context,
    NoteEditorState state,
    NoteEditorBloc editorBloc,
    quill.QuillController quillController,
    TextEditingController titleController,
  ) {
    return AppBar(
      title: const Text('Edit Note'),
      actions: [
        IconButton(
          icon: const Icon(Icons.label_outline),
          tooltip: 'Tags',
          onPressed: () => _showTagPicker(context, editorBloc),
        ),
        IconButton(
          icon: const Icon(Icons.more_vert),
          tooltip: 'More',
          onPressed: () => _showMoreOptions(context, editorBloc),
        ),
      ],
    );
  }

  Widget _buildSummaryCard(BuildContext context, String summary) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.amber.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.amber.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'AI Summary',
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: Colors.amber.shade800,
            ),
          ),
          const SizedBox(height: 4),
          Text(summary, style: TextStyle(fontSize: 14.sp)),
        ],
      ),
    );
  }

  Widget _buildTitleField(
    BuildContext context,
    TextEditingController titleController,
    FocusNode titleFocusNode,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: TextField(
        controller: titleController,
        focusNode: titleFocusNode,
        style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.bold),
        decoration: const InputDecoration(
          hintText: 'Title',
          border: InputBorder.none,
        ),
        maxLines: 1,
      ),
    );
  }

  Widget _buildQuillEditor(
    BuildContext context,
    NoteEditorState state,
    quill.QuillController quillController,
    ScrollController quillScrollController,
    FocusNode contentFocusNode,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: quill.QuillEditor(
        controller: quillController,
        scrollController: quillScrollController,
        focusNode: contentFocusNode,
      ),
    );
  }

  Widget _buildFormattingToolbar(
    BuildContext context,
    quill.QuillController quillController,
  ) {
    return const SizedBox.shrink();
  }

  Widget _buildBottomActionButtons(
    BuildContext context,
    NoteEditorState state,
    NoteEditorBloc editorBloc,
  ) {
    return const SizedBox.shrink();
  }

  Widget _buildFAB(
    BuildContext context,
    NoteEditorState state,
    TextEditingController titleController,
    quill.QuillController quillController,
  ) {
    return FloatingActionButton(
      onPressed: () =>
          _saveNote(context, state, titleController, quillController),
      child: const Icon(Icons.save),
    );
  }

  // ─── Media Sheet ──────────────────────────────────────────────────────

  void _showUnifiedMediaSheet(
    BuildContext context,
    NoteEditorBloc editorBloc,
    quill.QuillController quillController,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) => UniversalMediaSheet(
        onOptionSelected: (option) {
          switch (option) {
            case MediaOption.photoVideo:
              _pickImage(context, editorBloc, quillController);
              break;
            case MediaOption.camera:
              _takePhoto(context, editorBloc, quillController);
              break;
            case MediaOption.audio:
              _openAudioRecorder(context, editorBloc);
              break;
            case MediaOption.scan:
              _openDocumentScanner(context, editorBloc, quillController);
              break;
            case MediaOption.sketch:
              _openDrawingCanvas(context, editorBloc, quillController);
              break;
            case MediaOption.link:
              _showAddLinkDialog(context, quillController);
              break;
          }
        },
      ),
    );
  }

  Future<void> _takePhoto(
    BuildContext context,
    NoteEditorBloc editorBloc,
    quill.QuillController quillController,
  ) async {
    try {
      final picker = ImagePicker();
      final image = await picker.pickImage(source: ImageSource.camera);

      if (image != null) {
        editorBloc.add(MediaAdded(image.path, MediaType.image));

        final index = quillController.selection.baseOffset;
        quillController.document.insert(index, '\n');
        quillController.document.insert(
          index + 1,
          quill.BlockEmbed.image(image.path),
        );
      }
    } catch (e) {
      editorBloc.add(
        ErrorOccurred('Failed to take photo: $e', code: 'MEDIA_ADD_FAILED'),
      );
    }
  }

  void _showAddLinkDialog(
    BuildContext context,
    quill.QuillController quillController,
  ) {
    final TextEditingController urlController = TextEditingController();
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Add Link'),
        content: TextField(
          controller: urlController,
          decoration: const InputDecoration(hintText: 'https://example.com'),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final url = urlController.text.trim();
              if (url.isNotEmpty) {
                final index = quillController.selection.baseOffset;
                quillController.document.insert(index, url);
              }
              Navigator.pop(dialogContext);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _openDrawingCanvas(
    BuildContext context,
    NoteEditorBloc editorBloc,
    quill.QuillController quillController,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (routeContext) => Scaffold(
          appBar: AppBar(title: const Text('Drawing')),
          body: DrawingCanvasWidget(
            onDrawingComplete: (image) =>
                _onDrawingComplete(context, editorBloc, quillController, image),
          ),
        ),
      ),
    );
  }

  void _openAudioRecorder(BuildContext context, NoteEditorBloc editorBloc) {
    showModalBottomSheet(
      context: context,
      builder: (sheetContext) => AudioRecorderWidget(
        onRecordingComplete: (path, duration) =>
            _onAudioComplete(context, editorBloc, path, duration),
      ),
    );
  }

  void _openDocumentScanner(
    BuildContext context,
    NoteEditorBloc editorBloc,
    quill.QuillController quillController,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (routeContext) => Scaffold(
          body: DocumentScannerWidget(
            onScanComplete: (doc) => _onScanComplete(context, editorBloc, doc),
            onCancel: () => Navigator.pop(routeContext),
          ),
        ),
      ),
    );
  }

  void _openReminderPicker(BuildContext context, NoteEditorBloc editorBloc) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => AddReminderBottomSheet(
        onReminderCreated: (alarm) => editorBloc.add(AlarmAdded(alarm)),
      ),
    );
  }

  void _openTemplateSelector(BuildContext context, NoteEditorBloc editorBloc) {
    showModalBottomSheet(
      context: context,
      builder: (sheetContext) => Container(
        padding: const EdgeInsets.all(16),
        child: TemplateSelector(
          onTemplateSelected: (template) {
            editorBloc.add(TemplateApplied(template));
            Navigator.pop(sheetContext);
          },
        ),
      ),
    );
  }

  void _openTodoPicker(BuildContext context, NoteEditorBloc editorBloc) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => CreateTodoBottomSheet(
        onTodoCreated: (todo) => editorBloc.add(TodoAdded(todo)),
      ),
    );
  }

  Future<void> _onDrawingComplete(
    BuildContext context,
    NoteEditorBloc editorBloc,
    quill.QuillController quillController,
    ui.Image image,
  ) async {
    try {
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return;

      final bytes = byteData.buffer.asUint8List();
      final tempDir = Directory.systemTemp;
      final file = File(
        '${tempDir.path}/drawing_${DateTime.now().millisecondsSinceEpoch}.png',
      );
      await file.writeAsBytes(bytes);

      editorBloc.add(MediaAdded(file.path, MediaType.image));

      final index = quillController.selection.baseOffset;
      quillController.document.insert(index, '\n');
      quillController.document.insert(
        index + 1,
        quill.BlockEmbed.image(file.path),
      );

      if (context.mounted) Navigator.pop(context);
    } catch (e) {
      editorBloc.add(
        ErrorOccurred('Failed to save drawing: $e', code: 'MEDIA_ADD_FAILED'),
      );
    }
  }

  Future<void> _pickVideo(NoteEditorBloc editorBloc) async {
    try {
      final picker = ImagePicker();
      final video = await picker.pickVideo(source: ImageSource.camera);

      if (video != null) {
        editorBloc.add(
          MediaAdded(video.path, MediaType.video, name: video.name),
        );
      }
    } catch (e) {
      editorBloc.add(
        ErrorOccurred('Failed to pick video: $e', code: 'MEDIA_ADD_FAILED'),
      );
    }
  }

  void _onAudioComplete(
    BuildContext context,
    NoteEditorBloc editorBloc,
    String path,
    Duration duration,
  ) {
    editorBloc.add(
      MediaAdded(
        path,
        MediaType.audio,
        name: 'Audio Recording',
        duration: duration.inMilliseconds,
      ),
    );
    Navigator.pop(context);
  }

  void _onScanComplete(
    BuildContext context,
    NoteEditorBloc editorBloc,
    ScannedDocument doc,
  ) {
    editorBloc.add(
      MediaAdded(doc.filePath, MediaType.image, name: doc.fileName),
    );
    Navigator.pop(context);
  }

  Future<void> _pickDocument(
    BuildContext context,
    NoteEditorBloc editorBloc,
  ) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'ppt', 'pptx', 'txt'],
      );

      if (result != null) {
        for (final file in result.files) {
          if (file.path != null) {
            editorBloc.add(
              MediaAdded(file.path!, MediaType.document, name: file.name),
            );
            if (context.mounted) {
              _showExtractionPrompt(context, editorBloc, file.path!, file.name);
            }
          }
        }
      }
    } catch (e) {
      editorBloc.add(
        ErrorOccurred('Failed to pick document: $e', code: 'MEDIA_ADD_FAILED'),
      );
    }
  }

  void _showExtractionPrompt(
    BuildContext context,
    NoteEditorBloc editorBloc,
    String path,
    String name,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Extract Text?'),
        content: Text(
          'Do you want to extract text from "$name" and insert it into your note?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              editorBloc.add(TextExtractionRequested(path));
            },
            child: const Text('Extract'),
          ),
        ],
      ),
    );
  }

  // ─── Attachment Lists (single definition) ─────────────────────────────

  Widget _buildAttachmentLists(
    BuildContext context,
    NoteEditorState state,
    NoteEditorBloc editorBloc,
  ) {
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
                            onPressed: () => editorBloc.add(
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
                                editorBloc.add(MediaRemoved(globalIndex));
                              }
                            },
                          ),
                        ],
                      ),
                      onTap: () => _openMediaViewer(
                        context,
                        editorBloc,
                        state,
                        index,
                        MediaType.document,
                      ),
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
                  editorBloc.add(MediaRemoved(globalIndex));
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
                  editorBloc.add(MediaRemoved(globalIndex));
                }
              },
              onVideoTap: (index) => _openMediaViewer(
                context,
                editorBloc,
                state,
                index,
                MediaType.video,
              ),
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
                  editorBloc.add(MediaRemoved(globalIndex));
                }
              },
              onDocumentTap: (index) => _openMediaViewer(
                context,
                editorBloc,
                state,
                index,
                MediaType.image,
              ),
            ),
          ),
        _buildImageGallery(context, editorBloc, state),
      ],
    );
  }

  Widget _buildImageGallery(
    BuildContext context,
    NoteEditorBloc editorBloc,
    NoteEditorState state,
  ) {
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
            onTap: () => _openMediaViewer(
              context,
              editorBloc,
              state,
              index,
              MediaType.image,
            ),
          );
        },
      ),
    );
  }

  void _openMediaViewer(
    BuildContext context,
    NoteEditorBloc editorBloc,
    NoteEditorState state,
    int index,
    MediaType type,
  ) {
    final filteredMedia = state.params.media
        .where((m) => m.type == type)
        .toList();
    if (index >= filteredMedia.length) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (routeContext) => MediaViewerScreen(
          mediaItems: filteredMedia,
          initialIndex: index,
          onDelete: (media) {
            final globalIndex = state.params.media.indexWhere(
              (m) => m.id == media.id,
            );
            if (globalIndex != -1) {
              editorBloc.add(MediaRemoved(globalIndex));
            }
          },
          onUpdate: (oldMedia, newMedia) {
            editorBloc.add(MediaUpdated(oldMedia, newMedia));
          },
        ),
      ),
    );
  }
}

// ─── Lifecycle Wrapper (StatefulWidget for controllers) ──────────────────

class _NoteEditorLifecycleWrapper extends StatefulWidget {
  final Note? note;
  final String? initialContent;
  final dynamic template;
  final Widget Function(
    BuildContext,
    NoteEditorBloc,
    quill.QuillController,
    TextEditingController,
    FocusNode,
    FocusNode,
    ScrollController,
    ScrollController,
  )
  builder;

  const _NoteEditorLifecycleWrapper({
    this.note,
    this.initialContent,
    this.template,
    required this.builder,
  });

  @override
  State<_NoteEditorLifecycleWrapper> createState() =>
      _NoteEditorLifecycleWrapperState();
}

class _NoteEditorLifecycleWrapperState
    extends State<_NoteEditorLifecycleWrapper> {
  late NoteEditorBloc _editorBloc;
  late quill.QuillController _quillController;
  final TextEditingController _titleController = TextEditingController();
  final FocusNode _titleFocusNode = FocusNode();
  final FocusNode _contentFocusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();
  final ScrollController _quillScrollController = ScrollController();

  final SpeechService _speechService = SpeechService();
  final VoiceCommandService _commandService = VoiceCommandService();
  final AudioFeedbackService _feedbackService = AudioFeedbackService();

  bool _isUndoingOrRedoing = false;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _editorBloc =
        NoteEditorBloc(
          speechService: _speechService,
          commandService: _commandService,
          feedbackService: _feedbackService,
          ocrService: OCRService(),
          mediaProcessingService: getIt<MediaProcessingService>(),
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
    _quillController.addListener(() {
      if (!_isUndoingOrRedoing) {
        _debounceTimer?.cancel();
        _debounceTimer = Timer(const Duration(milliseconds: 500), () {
          final content = jsonEncode(
            _quillController.document.toDelta().toJson(),
          );
          _editorBloc.add(ContentChanged(content));

          final plainText = _quillController.document.toPlainText();
          _editorBloc.add(ContextScannerTriggered(plainText));
        });
      }
    });

    _titleController.addListener(() {
      _editorBloc.add(TitleChanged(_titleController.text));
    });
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _titleController.dispose();
    _quillController.dispose();
    _titleFocusNode.dispose();
    _contentFocusNode.dispose();
    _scrollController.dispose();
    _quillScrollController.dispose();
    _editorBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(
      context,
      _editorBloc,
      _quillController,
      _titleController,
      _titleFocusNode,
      _contentFocusNode,
      _scrollController,
      _quillScrollController,
    );
  }
}
