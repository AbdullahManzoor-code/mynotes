import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:ui';
import 'package:url_launcher/url_launcher.dart';
import '../../domain/entities/note.dart';
import '../../domain/entities/todo_item.dart';
import '../../domain/entities/alarm.dart';
import '../../domain/entities/link.dart';
import '../bloc/note_bloc.dart';
import '../bloc/note_event.dart';
import '../bloc/note_state.dart';
import '../bloc/media_bloc.dart';
import '../bloc/media_event.dart';
import '../bloc/media_state.dart';

import '../design_system/design_system.dart';
import '../widgets/alarm_bottom_sheet.dart';

/// Note Editor Page
/// Full-featured note editing with media and link support
class NoteEditorPage extends StatefulWidget {
  final Note? note;
  final String? initialContent;

  const NoteEditorPage({Key? key, this.note, this.initialContent})
    : super(key: key);

  @override
  State<NoteEditorPage> createState() => _NoteEditorPageState();
}

class _NoteEditorPageState extends State<NoteEditorPage> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  late NoteColor _selectedColor;
  final List<TodoItem> _todos = [];
  final List<String> _mediaIds = [];
  final List<Link> _links = [];
  List<Alarm> _activeAlarms = [];
  bool _isRecording = false;
  final FocusNode _titleFocus = FocusNode();
  final FocusNode _contentFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note?.title ?? '');
    _contentController = TextEditingController(
      text: widget.note?.content ?? widget.initialContent ?? '',
    );
    _selectedColor = widget.note?.color ?? NoteColor.defaultColor;
    if (widget.note != null) {
      _links.addAll(widget.note!.links);
      _activeAlarms = List.from(widget.note!.alarms ?? []);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _titleFocus.dispose();
    _contentFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<NotesBloc, NoteState>(
          listener: (context, state) {
            if (state is NoteCreated || state is NoteUpdated) {
              Navigator.pop(context);
            } else if (state is NoteError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Error: ${state.message}'),
                  backgroundColor: AppColors.errorColor,
                ),
              );
            }
          },
        ),
        BlocListener<MediaBloc, MediaState>(
          listener: (context, state) {
            if (state is MediaAdded) {
              setState(() {
                _mediaIds.add(state.media.id);
              });
            } else if (state is MediaError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Error: ${state.message}'),
                  backgroundColor: AppColors.errorColor,
                ),
              );
            } else if (state is AudioRecordingState) {
              setState(() {
                _isRecording = state.isRecording;
              });
            }
          },
        ),
      ],
      child: Scaffold(
        backgroundColor: AppColors.background(context),
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(60.h),
          child: ClipRRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: AppBar(
                backgroundColor: AppColors.background(context).withOpacity(0.8),
                elevation: 0,
                leading: IconButton(
                  icon: Icon(Icons.arrow_back_ios_new, size: 20.sp),
                  onPressed: () => Navigator.pop(context),
                ),
                centerTitle: true,
                title: Text(
                  widget.note?.title.isEmpty ?? true
                      ? 'New Note'
                      : widget.note!.title,
                  style: AppTypography.bodyLarge(null, null, FontWeight.w600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                actions: [
                  // Pin button
                  IconButton(
                    icon: Icon(
                      widget.note?.isPinned ?? false
                          ? Icons.push_pin
                          : Icons.push_pin_outlined,
                      size: 22.sp,
                    ),
                    color: widget.note?.isPinned ?? false
                        ? AppColors.primary
                        : null,
                    onPressed: () {
                      // Toggle pin would be handled here
                    },
                  ),
                  // More options
                  IconButton(
                    icon: Icon(Icons.more_horiz, size: 22.sp),
                    onPressed: _showMoreOptions,
                  ),
                  SizedBox(width: 4.w),
                ],
              ),
            ),
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: _titleController,
                      focusNode: _titleFocus,
                      style: AppTypography.heading1(
                        context,
                      ).copyWith(fontWeight: FontWeight.bold),
                      decoration: InputDecoration(
                        hintText: 'Title',
                        hintStyle: AppTypography.heading1(context).copyWith(
                          color: AppColors.textSecondary(
                            context,
                          ).withOpacity(0.5),
                          fontWeight: FontWeight.bold,
                        ),
                        border: InputBorder.none,
                      ),
                      textInputAction: TextInputAction.next,
                      onSubmitted: (_) => _contentFocus.requestFocus(),
                    ),
                    SizedBox(height: AppSpacing.md),
                    _buildColorToolbar(),
                    SizedBox(height: AppSpacing.lg),
                    TextField(
                      controller: _contentController,
                      focusNode: _contentFocus,
                      style: AppTypography.bodyLarge(context),
                      decoration: InputDecoration(
                        hintText: 'Start writing...',
                        hintStyle: AppTypography.bodyLarge(context).copyWith(
                          color: AppColors.textSecondary(
                            context,
                          ).withOpacity(0.5),
                        ),
                        border: InputBorder.none,
                      ),
                      maxLines: null,
                      keyboardType: TextInputType.multiline,
                    ),
                    SizedBox(height: AppSpacing.xl),
                    if (_activeAlarms.isNotEmpty) _buildSectionHeader('Alarms'),
                    ..._activeAlarms.map(_buildAlarmItem),
                    if (_links.isNotEmpty) _buildSectionHeader('Links'),
                    ..._links.map(_buildLinkItem),
                    SizedBox(height: 100.h),
                  ],
                ),
              ),
            ),
            _buildActionToolbar(),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
      child: Text(
        title.toUpperCase(),
        style: AppTypography.captionSmall(context).copyWith(
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
          color: AppColors.textSecondary(context),
        ),
      ),
    );
  }

  Widget _buildColorToolbar() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: NoteColor.values.map((color) {
          final isSelected = _selectedColor == color;
          final uiColor = AppColors.getNoteColor(context, color);
          return GestureDetector(
            onTap: () => setState(() => _selectedColor = color),
            child: Container(
              width: 32.w,
              height: 32.w,
              margin: EdgeInsets.only(right: AppSpacing.sm),
              decoration: BoxDecoration(
                color: uiColor.withOpacity(0.15),
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? uiColor : Colors.transparent,
                  width: 2,
                ),
              ),
              child: Center(
                child: Container(
                  width: 16.w,
                  height: 16.w,
                  decoration: BoxDecoration(
                    color: uiColor,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildActionToolbar() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.background(context).withOpacity(0),
            AppColors.background(context),
            AppColors.background(context),
          ],
        ),
      ),
      child: GlassContainer(
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
        borderRadius: AppSpacing.radiusFull,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _ToolbarAction(
              icon: Icons.format_bold,
              onTap: () {
                // Bold formatting
              },
            ),
            _ToolbarAction(
              icon: Icons.format_italic,
              onTap: () {
                // Italic formatting
              },
            ),
            _ToolbarAction(
              icon: Icons.format_list_bulleted,
              onTap: () {
                // List formatting
              },
            ),
            Container(
              width: 1.w,
              height: 24.h,
              color: AppColors.borderLight.withOpacity(0.3),
            ),
            _ToolbarAction(
              icon: Icons.alternate_email,
              onTap: _showAddLinkDialog,
              iconColor: AppColors.primary,
              backgroundColor: AppColors.primary.withOpacity(0.1),
            ),
            _ToolbarAction(icon: Icons.image_outlined, onTap: _pickImage),
            _ToolbarAction(
              icon: Icons.alarm_on_outlined,
              onTap: _showAlarmPicker,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAlarmItem(Alarm alarm) {
    return CardContainer(
      margin: EdgeInsets.only(bottom: AppSpacing.sm),
      onTap: () => _editAlarm(alarm),
      child: Row(
        children: [
          Icon(Icons.alarm, color: AppColors.primaryColor, size: 20.sp),
          SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              '${alarm.alarmTime.day}/${alarm.alarmTime.month} at ${alarm.alarmTime.hour}:${alarm.alarmTime.minute.toString().padLeft(2, '0')}',
              style: AppTypography.bodySmall(context),
            ),
          ),
          AppIconButton(
            icon: Icons.close,
            onPressed: () => setState(() => _activeAlarms.remove(alarm)),
            size: 16,
          ),
        ],
      ),
    );
  }

  Widget _buildLinkItem(Link link) {
    return CardContainer(
      margin: EdgeInsets.only(bottom: AppSpacing.sm),
      onTap: () => _launchLink(link.url),
      child: Row(
        children: [
          Icon(Icons.link, color: AppColors.primaryColor, size: 20.sp),
          SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (link.title != null)
                  Text(
                    link.title!,
                    style: AppTypography.bodySmall(
                      context,
                    ).copyWith(fontWeight: FontWeight.w600),
                  ),
                Text(
                  link.url,
                  style: AppTypography.captionSmall(
                    context,
                  ).copyWith(color: AppColors.textSecondary(context)),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          AppIconButton(
            icon: Icons.close,
            onPressed: () => setState(() => _links.remove(link)),
            size: 16,
          ),
        ],
      ),
    );
  }

  /// Save note
  void _saveNote() {
    if (_titleController.text.isEmpty && _contentController.text.isEmpty) {
      return;
    }

    try {
      final note = Note(
        id: widget.note?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        title: _titleController.text,
        content: _contentController.text,
        color: _selectedColor,
        alarms: _activeAlarms,
        links: _links,
        createdAt: widget.note?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      if (widget.note != null) {
        context.read<NotesBloc>().add(UpdateNoteEvent(note));
      } else {
        context.read<NotesBloc>().add(
          CreateNoteEvent(
            title: note.title,
            content: note.content,
            color: note.color,
            isPinned: note.isPinned,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: AppColors.errorColor,
        ),
      );
    }
  }

  void _pickImage() {
    final noteId =
        widget.note?.id ?? DateTime.now().millisecondsSinceEpoch.toString();
    context.read<MediaBloc>().add(AddImageToNoteEvent(noteId, ''));
  }

  void _toggleAudioRecording() {
    final noteId =
        widget.note?.id ?? DateTime.now().millisecondsSinceEpoch.toString();
    if (_isRecording) {
      context.read<MediaBloc>().add(StopAudioRecordingEvent(noteId));
    } else {
      context.read<MediaBloc>().add(StartAudioRecordingEvent(noteId));
    }
  }

  void _showAddTodoDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add Todo', style: AppTypography.heading2(context)),
        content: SearchTextField(controller: controller, hintText: 'Todo text'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: AppColors.textSecondary(context)),
            ),
          ),
          PrimaryButton(
            text: 'Add',
            onPressed: () {
              if (controller.text.isNotEmpty) {
                setState(() {
                  _todos.add(
                    TodoItem(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      text: controller.text,
                    ),
                  );
                });
                Navigator.pop(context);
              }
            },
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.xs,
            ),
          ),
        ],
      ),
    );
  }

  void _showAlarmPicker() async {
    final tempNote =
        widget.note ??
        Note(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          title: _titleController.text,
          content: _contentController.text,
          color: _selectedColor,
        );

    final result = await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AlarmBottomSheet(note: tempNote),
    );

    if (result != null && result is Alarm) {
      setState(() => _activeAlarms.add(result));
    }
  }

  void _editAlarm(Alarm alarm) async {
    final tempNote =
        widget.note ??
        Note(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          title: _titleController.text,
        );

    final result = await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) =>
          AlarmBottomSheet(note: tempNote, existingAlarm: alarm),
    );

    if (result != null && result is Alarm) {
      setState(() {
        final index = _activeAlarms.indexWhere((a) => a.id == alarm.id);
        if (index >= 0) _activeAlarms[index] = result;
      });
    }
  }

  void _showAddLinkDialog() {
    final urlController = TextEditingController();
    final titleController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add Link', style: AppTypography.heading2(context)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SearchTextField(controller: urlController, hintText: 'URL'),
            SizedBox(height: AppSpacing.md),
            SearchTextField(
              controller: titleController,
              hintText: 'Title (optional)',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: AppColors.textSecondary(context)),
            ),
          ),
          PrimaryButton(
            text: 'Add',
            onPressed: () {
              if (urlController.text.isNotEmpty) {
                setState(() {
                  _links.add(
                    Link(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      url: Link.ensureScheme(urlController.text),
                      title: titleController.text.isNotEmpty
                          ? titleController.text
                          : null,
                      createdAt: DateTime.now(),
                    ),
                  );
                });
                Navigator.pop(context);
              }
            },
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.xs,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _launchLink(String url) async {
    try {
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
      }
    } catch (_) {}
  }

  void _showMoreOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: AppColors.surface(context),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.check, color: AppColors.primary),
              title: Text('Save Note'),
              onTap: () {
                Navigator.pop(context);
                _saveNote();
              },
            ),
            ListTile(
              leading: Icon(Icons.delete_outline, color: AppColors.error),
              title: Text('Delete Note'),
              onTap: () {
                Navigator.pop(context);
                // Delete logic
              },
            ),
            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }
}

class _ToolbarAction extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color? iconColor;
  final Color? backgroundColor;

  const _ToolbarAction({
    required this.icon,
    required this.onTap,
    this.iconColor,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40.w,
        height: 40.w,
        decoration: BoxDecoration(
          color: backgroundColor ?? Colors.transparent,
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Icon(
          icon,
          color: iconColor ?? AppColors.textSecondary(context),
          size: 22.sp,
        ),
      ),
    );
  }
}
