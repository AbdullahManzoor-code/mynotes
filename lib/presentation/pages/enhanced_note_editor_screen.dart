// lib/presentation/pages/enhanced_note_editor_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:flutter_quill/quill_delta.dart'; // Add this import
import 'package:flutter_quill_extensions/flutter_quill_extensions.dart';
import 'package:mynotes/injection_container.dart';
import 'package:mynotes/core/services/media_processing_service.dart';
import 'package:mynotes/core/services/ocr_service.dart';
import 'package:mynotes/core/utils/context_scanner.dart';
import 'package:mynotes/presentation/pages/graph_view_page.dart'
    show GraphViewPage;
import 'package:share_plus/share_plus.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:mynotes/presentation/design_system/design_system.dart'
    hide TextButton;
import 'package:mynotes/core/routes/app_routes.dart';
import 'package:mynotes/core/services/speech_service.dart';
import 'package:mynotes/core/services/voice_command_service.dart';
import 'package:mynotes/core/services/link_parser_service.dart';
import 'package:mynotes/core/database/core_database.dart';
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
import '../widgets/universal_media_sheet.dart';
import 'package:mynotes/presentation/pages/media_viewer_screen.dart';
import 'package:mynotes/presentation/pages/video_trimming_screen.dart';
import 'package:mynotes/presentation/widgets/note_suggestion_bar.dart';
import 'package:mynotes/presentation/widgets/note_tags_input.dart';

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
    AppLogger.i('EnhancedNoteEditorScreen: _loadContentIntoQuill called');
    if (content.isEmpty) return;
    try {
      if (content.startsWith('[') || content.startsWith('{')) {
        controller.document = quill.Document.fromJson(jsonDecode(content));
      } else {
        controller.document = quill.Document()..insert(0, content);
      }
    } catch (e) {
      AppLogger.e('EnhancedNoteEditorScreen: Error loading quill content', e);
      controller.document = quill.Document()..insert(0, content);
    }
  }

  void _insertExtractedText(quill.QuillController controller, String text) {
    AppLogger.i('EnhancedNoteEditorScreen: _insertExtractedText called');
    if (text.isEmpty) return;
    final index = controller.selection.baseOffset;
    controller.document.insert(index, '\n$text\n');
  }

  void _handleError(BuildContext context, String code) {
    AppLogger.e(
      'EnhancedNoteEditorScreen: _handleError called with code: $code',
    );
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
    AppLogger.i('EnhancedNoteEditorScreen: _saveNote triggered');
    final params = state.params;
    final noteParams = params.copyWith(
      title: titleController.text,
      content: jsonEncode(quillController.document.toDelta().toJson()),
    );

    if (noteParams.title.isEmpty && quillController.document.isEmpty()) {
      AppLogger.w('EnhancedNoteEditorScreen: Attempted to save empty note');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Note is empty')));
      return;
    }

    if (note != null) {
      AppLogger.i(
        'EnhancedNoteEditorScreen: Updating existing note: ${note!.id}',
      );
      context.read<NotesBloc>().add(UpdateNoteEvent(noteParams));
    } else {
      AppLogger.i('EnhancedNoteEditorScreen: Creating new note');
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
                                _buildSummaryCard(summary: state.summary!),
                              NoteSuggestionBar(
                                suggestions: state.suggestions,
                                onAccept: (suggestion) {
                                  AppLogger.i(
                                    'EnhancedNoteEditorScreen: Suggestion accepted: ${suggestion.title}',
                                  );
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
                                onDismiss: () {
                                  AppLogger.i(
                                    'EnhancedNoteEditorScreen: Suggestion dismissed',
                                  );
                                },
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
                            quillController,
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
                                  SizedBox(height: 16.h),
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
    AppLogger.i('EnhancedNoteEditorScreen: _pickImage triggered');
    try {
      final picker = ImagePicker();
      final image = await picker.pickImage(source: ImageSource.gallery);

      if (image != null) {
        AppLogger.i('EnhancedNoteEditorScreen: Image picked: ${image.path}');
        editorBloc.add(MediaAdded(image.path, MediaType.image));

        final index = quillController.selection.baseOffset;
        quillController.document.insert(index, '\n');
        quillController.document.insert(
          index + 1,
          quill.BlockEmbed.image(image.path),
        );
      } else {
        AppLogger.i('EnhancedNoteEditorScreen: Image picking cancelled');
      }
    } catch (e) {
      AppLogger.e('EnhancedNoteEditorScreen: Error picking image', e);
      editorBloc.add(
        ErrorOccurred('Failed to pick image: $e', code: 'MEDIA_ADD_FAILED'),
      );
    }
  }

  void _showTagPicker(BuildContext context, NoteEditorBloc editorBloc) {
    AppLogger.i('EnhancedNoteEditorScreen: _showTagPicker triggered');
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
        ),
        child: BlocProvider.value(
          value: editorBloc,
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(16.w),
              child: NoteTagsInput(
                initialTags: editorBloc.state.params.tags,
                maxTags: 10,
                onTagsChanged: (updatedTags) {
                  AppLogger.i(
                    'EnhancedNoteEditorScreen: Tags changed: $updatedTags',
                  );
                  // Update all tags in the editor
                  final currentTags = Set<String>.from(
                    editorBloc.state.params.tags,
                  );

                  // Remove tags that are no longer in the list
                  for (final tag in currentTags) {
                    if (!updatedTags.contains(tag)) {
                      AppLogger.i(
                        'EnhancedNoteEditorScreen: Removing tag: $tag',
                      );
                      editorBloc.add(TagRemoved(tag));
                    }
                  }

                  // Add new tags
                  for (final tag in updatedTags) {
                    if (!currentTags.contains(tag)) {
                      AppLogger.i('EnhancedNoteEditorScreen: Adding tag: $tag');
                      editorBloc.add(TagAdded(tag));
                    }
                  }

                  Navigator.pop(sheetContext);
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showMoreOptions(BuildContext context, NoteEditorBloc editorBloc) {
    AppLogger.i('EnhancedNoteEditorScreen: _showMoreOptions triggered');
    // Capture `note` from the StatelessWidget's field before entering the sheet
    final currentNote = note;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => GlassContainer(
        borderRadius: 24.r,
        blur: 20,
        color: AppColors.surface(context).withOpacity(0.9),
        padding: EdgeInsets.symmetric(vertical: 20.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40.w,
              height: 4.h,
              // margin: EdgeInsets.bottom(20.h),
              decoration: BoxDecoration(
                color: AppColors.textSecondary(context).withOpacity(0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            _buildPremiumMenuOption(
              icon: Icons.summarize_outlined,
              title: 'AI Smart Summary',
              subtitle: 'Generate a concise overview of this note',
              color: AppColors.primary,
              onTap: () {
                AppLogger.i(
                  'EnhancedNoteEditorScreen: AI Summary option tapped',
                );
                Navigator.pop(sheetContext);
                editorBloc.add(const GenerateSummaryRequested());
              },
            ),
            _buildPremiumMenuOption(
              icon: Icons.document_scanner_outlined,
              title: 'Extract Text (OCR)',
              subtitle: 'Scan images and documents for text',
              color: Colors.orange.shade400,
              onTap: () {
                AppLogger.i('EnhancedNoteEditorScreen: OCR option tapped');
                Navigator.pop(sheetContext);
                _showOCRSourcePicker(context, editorBloc);
              },
            ),
            _buildPremiumMenuOption(
              icon: Icons.check_box_outlined,
              title: 'Convert to Task',
              subtitle: 'Promote this note to a todo item',
              color: Colors.green.shade400,
              onTap: () {
                AppLogger.i('EnhancedNoteEditorScreen: Convert to task tapped');
                Navigator.pop(sheetContext);
                editorBloc.add(const PromoteToTodoRequested());
              },
            ),
            _buildPremiumMenuOption(
              icon: Icons.auto_stories_outlined,
              title: 'Apply Template',
              subtitle: 'Restructure note with a template',
              color: Colors.purple.shade400,
              onTap: () {
                AppLogger.i('EnhancedNoteEditorScreen: Apply template tapped');
                Navigator.pop(sheetContext);
                _showTemplateSelector(context, editorBloc);
              },
            ),
            _buildPremiumMenuOption(
              icon: Icons.share_outlined,
              title: 'Share & Export',
              subtitle: 'Send as text, PDF or Markdown',
              color: Colors.blue.shade400,
              onTap: () {
                AppLogger.i('EnhancedNoteEditorScreen: Share option tapped');
                Navigator.pop(sheetContext);
                _handleShare(sheetContext, editorBloc);
              },
            ),
            const Divider(height: 32),
            _buildPremiumMenuOption(
              icon: Icons.delete_outline,
              title: 'Delete Note',
              subtitle: 'Move to trash',
              color: Colors.red.shade400,
              onTap: () {
                AppLogger.i('EnhancedNoteEditorScreen: Delete option tapped');
                if (currentNote != null) {
                  AppLogger.i(
                    'EnhancedNoteEditorScreen: Dispatching DeleteNoteEvent for ${currentNote.id}',
                  );
                  context.read<NotesBloc>().add(
                    DeleteNoteEvent(currentNote.id),
                  );
                }
                Navigator.pop(sheetContext);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPremiumMenuOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: EdgeInsets.all(8.w),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Icon(icon, color: color, size: 20.sp),
      ),
      title: Text(title, style: AppTypography.labelLarge()),
      subtitle: Text(subtitle, style: AppTypography.caption()),
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
    );
  }

  void _showTemplateSelector(BuildContext context, NoteEditorBloc editorBloc) {
    AppLogger.i('EnhancedNoteEditorScreen: _showTemplateSelector triggered');
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => GlassContainer(
        borderRadius: 24.r,
        blur: 20,
        color: AppColors.surface(context).withOpacity(0.9),
        padding: EdgeInsets.symmetric(vertical: 20.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: AppColors.textSecondary(context).withOpacity(0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: 16.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Text(
                'Select Template',
                style: AppTypography.heading2(context),
              ),
            ),
            SizedBox(height: 16.h),
            Flexible(
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12.w,
                  mainAxisSpacing: 12.h,
                  childAspectRatio: 1.0,
                ),
                itemCount: NoteTemplates.builtIn.length,
                itemBuilder: (context, index) {
                  final template = NoteTemplates.builtIn[index];
                  return InkWell(
                    onTap: () {
                      AppLogger.i(
                        'EnhancedNoteEditorScreen: Template selected: ${template.name}',
                      );
                      editorBloc.add(TemplateApplied(template));
                      Navigator.pop(sheetContext);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Applied template: ${template.name}'),
                          backgroundColor: AppColors.successColor,
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(16.r),
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.surface(context),
                        borderRadius: BorderRadius.circular(16.r),
                        border: Border.all(
                          color: AppColors.border(context),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.description,
                            size: 32.sp,
                            color: AppColors.primary,
                          ),
                          SizedBox(height: 8.h),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8.w),
                            child: Text(
                              template.name,
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: AppTypography.bodySmall(
                                context,
                              ).copyWith(fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 16.h),
          ],
        ),
      ),
    );
  }

  void _handleShare(BuildContext context, NoteEditorBloc editorBloc) {
    AppLogger.i('EnhancedNoteEditorScreen: _handleShare triggered');
    final state = editorBloc.state;
    if (state is NoteEditorLoaded) {
      AppLogger.i(
        'EnhancedNoteEditorScreen: Navigating to export for note: ${state.params.title}',
      );
      Navigator.pushNamed(
        context,
        AppRoutes.exportOptions,
        arguments: {
          'title': state.params.title,
          'content': state.params.content,
          'tags': state.params.tags,
          'createdDate': DateTime.now(),
          'noteId': state.params.noteId,
        },
      );
    } else {
      AppLogger.w(
        'EnhancedNoteEditorScreen: Attempted to export while state is not NoteEditorLoaded',
      );
    }
  }

  void _showOCRSourcePicker(BuildContext context, NoteEditorBloc editorBloc) {
    AppLogger.i('EnhancedNoteEditorScreen: _showOCRSourcePicker triggered');
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => GlassContainer(
        // borderRadius:  BorderRadius.vertical(top: Radius.circular(24)),
        blur: 20,
        color: AppColors.surface(context).withOpacity(0.9),
        padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 40.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40.w,
              height: 4.h,
              margin: EdgeInsets.only(bottom: 24.h),
              decoration: BoxDecoration(
                color: AppColors.textSecondary(context).withOpacity(0.2),
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            Text(
              'Extract Text (OCR)',
              style: AppTypography.heading3(
                context,
              ).copyWith(fontWeight: FontWeight.w700),
            ),
            SizedBox(height: 8.h),
            Text(
              'Select an image to scan for text',
              style: AppTypography.bodySmall(context),
            ),
            SizedBox(height: 32.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildSourceOption(
                  context: context,
                  icon: Icons.camera_alt_rounded,
                  label: 'Camera',
                  onTap: () async {
                    AppLogger.i(
                      'EnhancedNoteEditorScreen: OCR Camera source selected',
                    );
                    Navigator.pop(context);
                    final picker = ImagePicker();
                    final image = await picker.pickImage(
                      source: ImageSource.camera,
                    );
                    if (image != null) {
                      AppLogger.i(
                        'EnhancedNoteEditorScreen: OCR Camera image captured: ${image.path}',
                      );
                      editorBloc.add(TextExtractionRequested(image.path));
                    } else {
                      AppLogger.i(
                        'EnhancedNoteEditorScreen: OCR Camera capture cancelled',
                      );
                    }
                  },
                ),
                _buildSourceOption(
                  context: context,
                  icon: Icons.photo_library_rounded,
                  label: 'Gallery',
                  onTap: () async {
                    AppLogger.i(
                      'EnhancedNoteEditorScreen: OCR Gallery source selected',
                    );
                    Navigator.pop(context);
                    final picker = ImagePicker();
                    final image = await picker.pickImage(
                      source: ImageSource.gallery,
                    );
                    if (image != null) {
                      AppLogger.i(
                        'EnhancedNoteEditorScreen: OCR Gallery image selected: ${image.path}',
                      );
                      editorBloc.add(TextExtractionRequested(image.path));
                    } else {
                      AppLogger.i(
                        'EnhancedNoteEditorScreen: OCR Gallery selection cancelled',
                      );
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSourceOption({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      borderRadius: BorderRadius.circular(20.r),
      child: Container(
        width: 120.w,
        padding: EdgeInsets.symmetric(vertical: 20.h),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.05),
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: AppColors.primary.withOpacity(0.1)),
        ),
        child: Column(
          children: [
            Icon(icon, size: 32.sp, color: AppColors.primary),
            SizedBox(height: 12.h),
            Text(
              label,
              style: AppTypography.heading4(context).copyWith(fontSize: 14.sp),
            ),
          ],
        ),
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
    final bool isDirty = state.isDirty;

    return GlassAppBar(
      title: 'Edit Note',
      actions: [
        if (isDirty)
          AppAnimations.tapScale(
            child: IconButton(
              icon: Icon(Icons.cloud_upload_outlined, color: AppColors.primary),
              tooltip: 'Save Note',
              onPressed: () {
                AppLogger.i(
                  'EnhancedNoteEditorScreen: Appbar Save button tapped',
                );
                editorBloc.add(const SaveNoteRequested());
              },
            ),
          ),
        IconButton(
          icon: Icon(
            state.params.isPinned ? Icons.push_pin : Icons.push_pin_outlined,
            color: state.params.isPinned ? AppColors.primary : null,
          ),
          tooltip: 'Pin Note',
          onPressed: () {
            AppLogger.i(
              'EnhancedNoteEditorScreen: Pin toggle button tapped. Current: ${state.params.isPinned}',
            );
            HapticFeedback.lightImpact();
            editorBloc.add(const PinToggled());
          },
        ),
        IconButton(
          icon: const Icon(Icons.more_horiz),
          tooltip: 'More Options',
          onPressed: () {
            AppLogger.i('EnhancedNoteEditorScreen: More options button tapped');
            _showMoreOptions(context, editorBloc);
          },
        ),
      ],
    );
  }

  // Widget _buildSummaryCard(BuildContext context, String summary) {
  //   return AppAnimations.tapScale(
  //     child: GlassContainer(
  //       margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
  //       borderRadius: 16.r,
  //       blur: 10,
  //       color: AppColors.primary.withOpacity(0.05),
  //       padding: EdgeInsets.all(16.w),
  //       child: Column(
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         children: [
  //           Row(
  //             children: [
  //               Icon(
  //                 Icons.summarize_outlined,
  //                 color: AppColors.primary,
  //                 size: 18.sp,
  //               ),
  //               SizedBox(width: 8.w),
  //               Text(
  //                 'AI SUMMARY',
  //                 style: AppTypography.caption(context).copyWith(
  //                   color: AppColors.primary,
  //                   fontWeight: FontWeight.w700,
  //                   letterSpacing: 1.2,
  //                 ),
  //               ),
  //               const Spacer(),
  //               InkWell(
  //                 onTap: () {
  //                   HapticFeedback.lightImpact();
  //                   // Optional: Copy summary or expand
  //                 },
  //                 child: Icon(
  //                   Icons.copy_rounded,
  //                   size: 14.sp,
  //                   color: AppColors.textSecondary(context),
  //                 ),
  //               ),
  //             ],
  //           ),
  //           SizedBox(height: 10.h),
  //           Text(
  //             summary,
  //             style: AppTypography.body1(
  //               context,
  //             ).copyWith(fontSize: 14.sp, height: 1.5),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  Widget _buildTitleField(
    BuildContext context,
    TextEditingController titleController,
    FocusNode titleFocusNode,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.borderLight.withOpacity(0.1)),
        ),
      ),
      child: TextField(
        controller: titleController,
        focusNode: titleFocusNode,
        autofocus: note == null, // Auto-focus only for new notes
        style: AppTypography.heading1(context).copyWith(
          fontSize: 24.sp,
          fontWeight: FontWeight.w800,
          color: AppColors.textPrimary(context),
        ),
        decoration: InputDecoration(
          hintText: 'Note Title',
          hintStyle: AppTypography.heading1(context).copyWith(
            fontSize: 24.sp,
            fontWeight: FontWeight.w800,
            color: AppColors.textSecondary(context).withOpacity(0.3),
          ),
          border: InputBorder.none,
          isDense: true,
          contentPadding: EdgeInsets.zero,
        ),
        maxLines: 1,
        onChanged: (val) {
          context.read<NoteEditorBloc>().add(TitleChanged(val));
        },
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
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: quill.QuillEditor.basic(
        controller: quillController,
        config: quill.QuillEditorConfig(
          autoFocus: false,
          expands: false,
          padding: EdgeInsets.zero,
          embedBuilders: FlutterQuillEmbeds.editorBuilders(),
        ),
      ),
    );
  }

  Widget _buildFormattingToolbar(
    BuildContext context,
    quill.QuillController quillController,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        border: Border(
          top: BorderSide(color: AppColors.borderLight.withOpacity(0.5)),
        ),
      ),
      child: quill.QuillSimpleToolbar(
        controller: quillController,
        config: quill.QuillSimpleToolbarConfig(
          showAlignmentButtons: true,
          showCenterAlignment: true,
          showJustifyAlignment: true,
          showLeftAlignment: true,
          showRightAlignment: true,
          showDirection: false,
          showUndo: true,
          showRedo: true,
          // showHeaderSelection: true,
          showListNumbers: true,
          showListBullets: true,
          showListCheck: true,
          showCodeBlock: true,
          showQuote: true,
          showInlineCode: true,
          showLink: true,
          showSearchButton: true,
          showFontFamily: false,
          showFontSize: true,
          showSubscript: false,
          showSuperscript: false,
          showSmallButton: true,
          multiRowsDisplay: false,
          buttonOptions: quill.QuillSimpleToolbarButtonOptions(
            base: quill.QuillToolbarBaseButtonOptions(
              iconTheme: quill.QuillIconTheme(
                iconButtonSelectedData: quill.IconButtonData(
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomActionButtons(
    BuildContext context,
    NoteEditorState state,
    NoteEditorBloc editorBloc,
    quill.QuillController quillController,
  ) {
    return GlassContainer(
      borderRadius: 0,
      blur: 20,
      color: AppColors.surface(context).withOpacity(0.8),
      padding: EdgeInsets.zero,
      child: Container(
        height: 65.h,
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(color: AppColors.borderLight.withOpacity(0.3)),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildPremiumIconButton(
              icon: Icons.add_circle_outline,
              color: AppColors.primary,
              tooltip: 'Add Attachment',
              onPressed: () {
                AppLogger.i(
                  'EnhancedNoteEditorScreen: Add Attachment button tapped',
                );
                _showUnifiedMediaSheet(context, editorBloc, quillController);
              },
            ),
            _buildPremiumIconButton(
              icon: Icons.mic_none,
              color: Colors.red.shade400,
              tooltip: 'Record Audio',
              onPressed: () {
                AppLogger.i(
                  'EnhancedNoteEditorScreen: Record Audio button tapped',
                );
                _openAudioRecorder(context, editorBloc);
              },
            ),
            _buildPremiumIconButton(
              icon: Icons.brush_outlined,
              color: Colors.green.shade400,
              tooltip: 'Sketch',
              onPressed: () {
                AppLogger.i('EnhancedNoteEditorScreen: Sketch button tapped');
                _openDrawingCanvas(context, editorBloc, quillController);
              },
            ),
            _buildPremiumIconButton(
              icon: Icons.sell_outlined,
              color: Colors.orange.shade400,
              tooltip: 'Tags',
              onPressed: () {
                AppLogger.i('EnhancedNoteEditorScreen: Tags button tapped');
                _showTagPicker(context, editorBloc);
              },
            ),
            _buildPremiumIconButton(
              icon: Icons.notifications_active_outlined,
              color: Colors.blue.shade400,
              tooltip: 'Reminder',
              onPressed: () {
                AppLogger.i('EnhancedNoteEditorScreen: Reminder button tapped');
                _openReminderPicker(context, editorBloc);
              },
            ),
            _buildPremiumIconButton(
              icon: Icons.hub_outlined,
              color: Colors.indigo.shade400,
              tooltip: 'Graph View',
              onPressed: () {
                AppLogger.i(
                  'EnhancedNoteEditorScreen: Graph View button tapped',
                );
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const GraphViewPage(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPremiumIconButton({
    required IconData icon,
    required Color color,
    required String tooltip,
    required VoidCallback onPressed,
  }) {
    return IconButton(
      icon: Icon(icon, color: color, size: 24.sp),
      tooltip: tooltip,
      onPressed: () {
        HapticFeedback.lightImpact();
        onPressed();
      },
    );
  }

  Widget _buildFAB(
    BuildContext context,
    NoteEditorState state,
    TextEditingController titleController,
    quill.QuillController quillController,
  ) {
    return FloatingActionButton(
      heroTag: 'note_editor_fab',
      onPressed: () {
        AppLogger.i('EnhancedNoteEditorScreen: FAB Save pressed');
        _saveNote(context, state, titleController, quillController);
      },
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
          AppLogger.i(
            'EnhancedNoteEditorScreen: Media option selected: $option',
          );
          switch (option) {
            case MediaOption.photo:
              _pickImage(context, editorBloc, quillController);
              break;
            case MediaOption.video:
              _pickVideo(editorBloc);
              break;
            case MediaOption.camera:
              _takePhoto(context, editorBloc, quillController);
              break;
            case MediaOption.audio:
              _openAudioRecorder(context, editorBloc);
              break;
            case MediaOption.dictate:
              _startDictation(context, quillController);
              break;
            case MediaOption.scan:
              _openDocumentScanner(context, editorBloc, quillController);
              break;
            case MediaOption.sketch:
              _openDrawingCanvas(context, editorBloc, quillController);
              break;
            case MediaOption.document:
              _pickDocument(context, editorBloc);
              break;
            case MediaOption.graph:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const GraphViewPage()),
              );
              break;
            case MediaOption.link:
              _showAddLinkDialog(context, quillController);
              break;
          }
        },
      ),
    );
  }

  Future<void> _startDictation(
    BuildContext context,
    quill.QuillController quillController,
  ) async {
    final speechService = SpeechService();
    final isAvailable = await speechService.initialize();

    if (!isAvailable) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Speech recognition not available')),
        );
      }
      return;
    }

    if (context.mounted) {
      showModalBottomSheet(
        context: context,
        builder: (context) => StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: EdgeInsets.all(24.w),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Listening...',
                    style: AppTypography.titleMedium(
                      context,
                      AppColors.primary,
                    ),
                  ),
                  SizedBox(height: 24.h),
                  const CircularProgressIndicator(),
                  SizedBox(height: 24.h),
                  ElevatedButton(
                    onPressed: () {
                      AppLogger.i(
                        'EnhancedNoteEditorScreen: Dictation stopped by user',
                      );
                      speechService.stopListening();
                      Navigator.pop(context);
                    },
                    child: const Text('Stop'),
                  ),
                ],
              ),
            );
          },
        ),
      );
    }

    await speechService.startListening(
      onResult: (text) {
        if (text.isNotEmpty) {
          final index = quillController.selection.baseOffset;
          quillController.document.insert(index, text);
          // Update selection
          quillController.updateSelection(
            TextSelection.collapsed(offset: index + text.length),
            quill.ChangeSource.local,
          );
        }
      },
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
            onPressed: () {
              AppLogger.i(
                'EnhancedNoteEditorScreen: Add Link dialog cancelled',
              );
              Navigator.pop(dialogContext);
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final url = urlController.text.trim();
              AppLogger.i(
                'EnhancedNoteEditorScreen: Add Link dialog - Add tapped: $url',
              );
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
            onCancel: () {
              AppLogger.i('EnhancedNoteEditorScreen: Document scan cancelled');
              Navigator.pop(routeContext);
            },
          ),
        ),
      ),
    );
  }

  void _openReminderPicker(BuildContext context, NoteEditorBloc editorBloc) {
    AppLogger.i('EnhancedNoteEditorScreen: Opening reminder picker');
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => AddReminderBottomSheet(
        onReminderCreated: (alarm) {
          AppLogger.i(
            'EnhancedNoteEditorScreen: Reminder created: ${alarm.id}',
          );
          editorBloc.add(AlarmAdded(alarm));
        },
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
        allowedExtensions: ['pdf', 'doc', 'docx', 'ppt', 'pptx', 'ptx', 'txt'],
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
            onPressed: () {
              AppLogger.i(
                'EnhancedNoteEditorScreen: Extraction prompt cancelled',
              );
              Navigator.pop(dialogContext);
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              AppLogger.i(
                'EnhancedNoteEditorScreen: Extraction prompt accepted for $name',
              );
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
    if (state.params.media.isEmpty &&
        state.suggestions.isEmpty &&
        state.linkedNotes.isEmpty &&
        (state.summary == null || state.summary!.isEmpty)) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (state.isSummarizing)
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: LinearProgressIndicator(),
          ),
        if (state.summary != null && state.summary!.isNotEmpty)
          _buildSummaryCard(summary: state.summary!),
        if (state.suggestions.isNotEmpty)
          _buildSuggestionsList(state, editorBloc),
        if (state.linkedNotes.isNotEmpty) _buildBacklinksSection(state),
        _buildMediaGallery(context, state, editorBloc),
      ],
    );
  }

  Widget _buildSummaryCard({required String summary}) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.primary.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.auto_awesome, color: AppColors.primary, size: 20.sp),
              SizedBox(width: 8.w),
              Text(
                'AI Summary',
                style: AppTypography.bodySmall().copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Text(summary, style: AppTypography.bodyMedium()),
        ],
      ),
    );
  }

  Widget _buildSuggestionsList(NoteEditorState state, NoteEditorBloc bloc) {
    return Container(
      height: 50.h,
      margin: EdgeInsets.symmetric(vertical: 8.h),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        itemCount: state.suggestions.length,
        itemBuilder: (context, index) {
          final suggestion = state.suggestions[index];
          return Padding(
            padding: EdgeInsets.only(right: 8.w),
            child: ActionChip(
              avatar: Icon(
                suggestion.type == SuggestionType.todo
                    ? Icons.check_circle_outline
                    : Icons.notifications_active_outlined,
                size: 16.sp,
                color: AppColors.primary,
              ),
              label: Text(suggestion.title),
              onPressed: () {
                AppLogger.i(
                  'EnhancedNoteEditorScreen: Horizontal suggestion chip tapped: ${suggestion.title}',
                );
                bloc.add(SuggestionActionAccepted(suggestion));
              },
              backgroundColor: AppColors.primary.withOpacity(0.05),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBacklinksSection(NoteEditorState state) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Linked Notes', style: AppTypography.bodySmall()),
          SizedBox(height: 8.h),
          Wrap(
            spacing: 8.w,
            children: state.linkedNotes.map((note) {
              return Chip(
                label: Text(note.title),
                backgroundColor: AppColors.secondaryText.withOpacity(0.1),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildMediaGallery(
    BuildContext context,
    NoteEditorState state,
    NoteEditorBloc editorBloc,
  ) {
    final media = state.params.media;
    if (media.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Attachments (${media.length})',
                style: AppTypography.heading2(context),
              ),
              if (media.length > 3)
                TextButton(
                  onPressed: () {
                    AppLogger.i(
                      'EnhancedNoteEditorScreen: View All Attachments tapped',
                    );
                    // TODO: Show full gallery
                  },
                  child: const Text('View All'),
                ),
            ],
          ),
        ),
        SizedBox(
          height: 160.h,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            itemCount: media.length,
            itemBuilder: (context, index) {
              final item = media[index];
              return Padding(
                padding: EdgeInsets.only(right: 12.w),
                child: _buildMediaPreviewItem(
                  context,
                  item,
                  index,
                  editorBloc,
                  state,
                ),
              );
            },
          ),
        ),
        SizedBox(height: 16.h),
      ],
    );
  }

  Widget _buildMediaPreviewItem(
    BuildContext context,
    MediaItem item,
    int index,
    NoteEditorBloc bloc,
    NoteEditorState state,
  ) {
    final isVideo = item.type == MediaType.video;
    final isProcessing = state.isProcessing;

    return GestureDetector(
      onTap: () {
        AppLogger.i(
          'EnhancedNoteEditorScreen: Media preview tapped: ${item.name} ($index)',
        );
        _openMediaViewer(context, bloc, state, index, item.type);
      },
      child: Container(
        width: 140.w,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.r),
          color: AppColors.surface(context),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16.r),
          child: Stack(
            children: [
              _buildMediaThumbnail(item),
              _buildMediaOverlay(item),
              // M010/M011: Processing overlay
              if (isProcessing)
                Container(
                  color: Colors.black.withOpacity(0.5),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 40.w,
                          height: 40.w,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation(
                              AppColors.primary.withOpacity(0.8),
                            ),
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          state.processingMessage ?? 'Processing...',
                          style: TextStyle(color: Colors.white, fontSize: 9.sp),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              // Close button
              Positioned(
                top: 4,
                right: 4,
                child: GestureDetector(
                  onTap: () {
                    AppLogger.i(
                      'EnhancedNoteEditorScreen: Removing media attachment at index $index: ${item.name}',
                    );
                    bloc.add(MediaRemoved(index));
                  },
                  child: Container(
                    padding: EdgeInsets.all(4.w),
                    decoration: const BoxDecoration(
                      color: Colors.black54,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.close, color: Colors.white, size: 14.sp),
                  ),
                ),
              ),
              // M010: Trim button (for videos)
              if (isVideo && !isProcessing)
                Positioned(
                  top: 4,
                  left: 4,
                  child: _buildActionButton(
                    icon: Icons.content_cut,
                    tooltip: 'Trim',
                    onTap: () =>
                        _onTrimVideoTapped(context, bloc, state, index, item),
                  ),
                ),
              // M011: Edit button (for videos)
              if (isVideo && !isProcessing)
                Positioned(
                  top: 4,
                  left: 40,
                  child: _buildActionButton(
                    icon: Icons.edit,
                    tooltip: 'Edit',
                    onTap: () =>
                        _onEditVideoTapped(context, bloc, state, index, item),
                  ),
                ),
              // Media name overlay
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.7),
                      ],
                    ),
                  ),
                  child: Text(
                    item.name,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// M010/M011: Build action button for trim/edit
  Widget _buildActionButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onTap,
  }) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.all(4.w),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.8),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.white, size: 14.sp),
        ),
      ),
    );
  }

  /// M010: Handle trim button tap - launch VideoTrimmingScreen
  /// Dispatches VideoTrimmingRequested with trim range when screen closes
  void _onTrimVideoTapped(
    BuildContext context,
    NoteEditorBloc bloc,
    NoteEditorState state,
    int index,
    MediaItem item,
  ) {
    AppLogger.i(
      'EnhancedNoteEditorScreen: Trim video button tapped for ${item.name}',
    );

    // Calculate default trim range (trim 5% from start, 95% end)
    final videoDurationMs = item.durationMs > 0 ? item.durationMs : 60000;
    final startMs = (videoDurationMs * 0.05).toInt();
    final endMs = (videoDurationMs * 0.95).toInt();

    // Launch VideoTrimmingScreen with required videoTitle parameter
    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (context) => VideoTrimmingScreen(
              videoPath: item.filePath,
              videoTitle: item.name,
              videoDurationMs: videoDurationMs,
            ),
          ),
        )
        .then((result) {
          // When user closes VideoTrimmingScreen, dispatch trim event
          AppLogger.i(
            'EnhancedNoteEditorScreen: Trim screen closed, dispatching VideoTrimmingRequested',
          );
          bloc.add(
            VideoTrimmingRequested(
              mediaIndex: index,
              startMs: startMs,
              endMs: endMs,
            ),
          );
        });
  }

  /// M011: Handle edit button tap - show filter selection
  void _onEditVideoTapped(
    BuildContext context,
    NoteEditorBloc bloc,
    NoteEditorState state,
    int index,
    MediaItem item,
  ) {
    AppLogger.i(
      'EnhancedNoteEditorScreen: Edit video button tapped for ${item.name}',
    );

    _showVideoFilterDialog(context, bloc, state, index, item);
  }

  /// M011: Show filter/quality selection dialog
  void _showVideoFilterDialog(
    BuildContext context,
    NoteEditorBloc bloc,
    NoteEditorState state,
    int index,
    MediaItem item,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface(context),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Text(
              'Edit Video',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            SizedBox(height: 24.h),
            // Quality selection section
            Text(
              'Video Quality',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.surface(context),
              ),
            ),
            SizedBox(height: 16.h),
            // Quality buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildQualityButton(
                  context,
                  label: 'Low\n20%',
                  qualityFactor: 0.2,
                  onTap: () {
                    Navigator.pop(context);
                    _applyVideoEdit(bloc, state, index, 0.2, 'quality_low');
                  },
                ),
                _buildQualityButton(
                  context,
                  label: 'Medium\n50%',
                  qualityFactor: 0.5,
                  onTap: () {
                    Navigator.pop(context);
                    _applyVideoEdit(bloc, state, index, 0.5, 'quality_medium');
                  },
                ),
                _buildQualityButton(
                  context,
                  label: 'High\n80%',
                  qualityFactor: 0.8,
                  onTap: () {
                    Navigator.pop(context);
                    _applyVideoEdit(bloc, state, index, 0.8, 'quality_high');
                  },
                ),
              ],
            ),
            SizedBox(height: 24.h),
            // Filter options (future enhancements)
            Text(
              'Filters (Coming Soon)',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.surface(context),
              ),
            ),
            SizedBox(height: 16.h),
            Wrap(
              spacing: 8.w,
              runSpacing: 8.h,
              children: [
                _buildFilterTag('Grayscale', enabled: false),
                _buildFilterTag('Sepia', enabled: false),
                _buildFilterTag('Brightness', enabled: false),
                _buildFilterTag('Contrast', enabled: false),
              ],
            ),
            SizedBox(height: 24.h),
            // Close button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.surface(context),
                  side: BorderSide(color: AppColors.primary),
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                child: Text(
                  'Close',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// M011: Build quality selection button
  Widget _buildQualityButton(
    BuildContext context, {
    required String label,
    required double qualityFactor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          border: Border.all(color: AppColors.primary, width: 1.5),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Column(
          children: [
            Icon(Icons.video_library, color: AppColors.primary, size: 24.sp),
            SizedBox(height: 8.h),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// M011: Build disabled filter tag
  Widget _buildFilterTag(String label, {required bool enabled}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: enabled
            ? AppColors.primary.withOpacity(0.2)
            : Colors.grey.withOpacity(0.2),
        border: Border.all(
          color: enabled ? AppColors.primary : Colors.grey,
          width: 1,
        ),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11.sp,
          color: enabled ? AppColors.primary : Colors.grey,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  /// M011: Apply video edit with quality selection
  void _applyVideoEdit(
    NoteEditorBloc bloc,
    NoteEditorState state,
    int index,
    double qualityFactor,
    String filterType,
  ) {
    AppLogger.i(
      'EnhancedNoteEditorScreen: Applying video edit - quality: $qualityFactor, filter: $filterType',
    );
    bloc.add(
      VideoEditingRequested(
        mediaIndex: index,
        qualityFactor: qualityFactor,
        filterType: filterType,
      ),
    );
  }

  Widget _buildMediaThumbnail(MediaItem item) {
    switch (item.type) {
      case MediaType.image:
        return Image.file(
          File(item.filePath),
          width: 140.w,
          height: 160.h,
          fit: BoxFit.cover,
        );
      case MediaType.video:
        return Image.file(
          File(item.thumbnailPath),
          width: 140.w,
          height: 160.h,
          fit: BoxFit.cover,
        );
      case MediaType.audio:
        return Container(
          color: AppColors.primary.withOpacity(0.1),
          child: Center(
            child: Icon(
              Icons.audiotrack,
              color: AppColors.primary,
              size: 40.sp,
            ),
          ),
        );
      case MediaType.document:
        return Container(
          color: Colors.orange.withOpacity(0.1),
          child: Center(
            child: Icon(Icons.description, color: Colors.orange, size: 40.sp),
          ),
        );
    }
  }

  Widget _buildMediaOverlay(MediaItem item) {
    if (item.type == MediaType.video) {
      return Center(
        child: Container(
          padding: EdgeInsets.all(8.w),
          decoration: const BoxDecoration(
            color: Colors.black26,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.play_arrow, color: Colors.white),
        ),
      );
    }
    if (item.type == MediaType.audio) {
      return Center(
        child: Text(
          '${(item.durationMs / 1000).toStringAsFixed(1)}s',
          style: TextStyle(
            color: AppColors.primary,
            fontSize: 12.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }
    return const SizedBox.shrink();
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
    extends State<_NoteEditorLifecycleWrapper>
    with WidgetsBindingObserver {
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
    AppLogger.i('EnhancedNoteEditorScreen: LifecycleWrapper initState');

    // Register lifecycle observer for app pause/resume events
    WidgetsBinding.instance.addObserver(this);

    _editorBloc =
        NoteEditorBloc(
          speechService: _speechService,
          commandService: _commandService,
          feedbackService: _feedbackService,
          ocrService: OCRService(),
          mediaProcessingService: getIt<MediaProcessingService>(),
          noteRepository: NoteRepositoryImpl(database: CoreDatabase()),
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

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    AppLogger.i('EnhancedNoteEditorScreen: AppLifecycleState = $state');

    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      // App is pausing or being closed - auto-save any unsaved changes
      if (_editorBloc.state is NoteEditorLoaded) {
        final editorState = _editorBloc.state as NoteEditorLoaded;
        if (editorState.isDirty) {
          AppLogger.i('EnhancedNoteEditorScreen: Auto-saving on app pause');
          _editorBloc.add(const SaveNoteRequested());
        }
      }
    }
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
    AppLogger.i('EnhancedNoteEditorScreen: LifecycleWrapper dispose');
    // Remove lifecycle observer before disposal
    WidgetsBinding.instance.removeObserver(this);

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
    return BlocProvider.value(
      value: _editorBloc,
      child: BlocListener<NoteEditorBloc, NoteEditorState>(
        listenWhen: (previous, current) {
          if (previous is NoteEditorLoaded && current is NoteEditorLoaded) {
            // Only trigger listener if content/title changed EXTERNALLY
            // (e.g. template applied, OCR, or initial load)
            // If it's just user typing, the controllers are already in sync.
            return (previous.params.content != current.params.content ||
                    previous.params.title != current.params.title) &&
                !_isUndoingOrRedoing;
          }
          return previous is NoteEditorInitial && current is NoteEditorLoaded;
        },
        listener: (context, state) {
          if (state is NoteEditorLoaded) {
            final params = state.params;

            // Sync Title
            if (_titleController.text != params.title) {
              _titleController.text = params.title;
            }

            // Sync Content
            try {
              final json = jsonDecode(params.content);
              final delta = Delta.fromJson(json);
              if (jsonEncode(_quillController.document.toDelta().toJson()) !=
                  params.content) {
                _isUndoingOrRedoing = true;
                _quillController.document = quill.Document.fromDelta(delta);
                _isUndoingOrRedoing = false;
              }
            } catch (e) {
              // If not JSON, insert as plain text
              if (_quillController.document.toPlainText().trim() !=
                  params.content.trim()) {
                _isUndoingOrRedoing = true;
                _quillController.document = quill.Document();
                _quillController.document.insert(0, params.content);
                _isUndoingOrRedoing = false;
              }
            }
          }
        },
        child: PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, result) async {
            if (didPop) return;

            // Check if there are unsaved changes
            final state = _editorBloc.state;
            if (state is NoteEditorLoaded && state.isDirty) {
              final shouldDiscard =
                  await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Unsaved Changes'),
                      content: const Text(
                        'You have unsaved changes. Do you want to discard them?',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, false),
                          child: const Text('Keep Editing'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, true),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.red,
                          ),
                          child: const Text('Discard'),
                        ),
                      ],
                    ),
                  ) ??
                  false;

              if (shouldDiscard == true && context.mounted) {
                Navigator.pop(context);
              }
            } else {
              // No unsaved changes, pop normally
              if (context.mounted) {
                Navigator.pop(context);
              }
            }
          },
          child: widget.builder(
            context,
            _editorBloc,
            _quillController,
            _titleController,
            _titleFocusNode,
            _contentFocusNode,
            _scrollController,
            _quillScrollController,
          ),
        ),
      ),
    );
  }
}


