import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
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
import '../bloc/alarm_bloc.dart';
import '../bloc/alarm_event.dart';
import '../widgets/alarm_bottom_sheet.dart';

/// Note Editor Page
/// Full-featured note editing with media and link support
class NoteEditorPage extends StatefulWidget {
  final Note? note;

  const NoteEditorPage({Key? key, this.note, String? initialContent})
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

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note?.title ?? '');
    _contentController = TextEditingController(
      text: widget.note?.content ?? '',
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<NotesBloc, NoteState>(
          listener: (context, state) {
            if (state is NoteCreated || state is NoteUpdated) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Note saved successfully')),
              );
              Navigator.pop(context);
            } else if (state is NoteError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error: ${state.message}')),
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
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Media added')));
            } else if (state is MediaError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error: ${state.message}')),
              );
            } else if (state is AudioRecordingState) {
              setState(() {
                _isRecording = state.isRecording;
              });
            }
          },
        ),
      ],
      child: WillPopScope(
        onWillPop: () async {
          _saveNote();
          return true;
        },
        child: Scaffold(
          appBar: AppBar(
            title: widget.note != null
                ? const Text('Edit Note')
                : const Text('New Note'),
            actions: [
              IconButton(
                icon: const Icon(Icons.check),
                onPressed: () {
                  _saveNote();
                  Navigator.pop(context);
                },
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title field
                TextField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    hintText: 'Note title...',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 16),

                // Color selector
                _buildColorSelector(),

                const SizedBox(height: 16),

                // Content field
                TextField(
                  controller: _contentController,
                  decoration: const InputDecoration(
                    hintText: 'Start typing...',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                  maxLines: null,
                ),

                const SizedBox(height: 24),

                // Media section
                _buildMediaSection(),

                const SizedBox(height: 24),

                // Links section
                _buildLinksSection(),

                const SizedBox(height: 24),

                // Todo section
                _buildTodoSection(),

                const SizedBox(height: 24),

                // Alarm section
                _buildAlarmSection(),
              ],
            ),
          ),
          bottomNavigationBar: _buildMediaToolbar(),
        ),
      ),
    );
  }

  /// Build color selector
  Widget _buildColorSelector() {
    return Wrap(
      spacing: 8.w,
      runSpacing: 8.h,
      children: NoteColor.values.map((color) {
        return GestureDetector(
          onTap: () => setState(() => _selectedColor = color),
          child: Container(
            width: 40.w,
            height: 40.h,
            decoration: BoxDecoration(
              color: Color(color.lightColor),
              border: Border.all(
                color: _selectedColor == color
                    ? AppColors.shadow
                    : Colors.transparent,
                width: 2.w,
              ),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: _selectedColor == color
                ? Icon(Icons.check, size: 20.sp)
                : null,
          ),
        );
      }).toList(),
    );
  }

  /// Build media section
  Widget _buildMediaSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Media & Attachments',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 12.h),
        BlocBuilder<MediaBloc, MediaState>(
          builder: (context, state) {
            if (state is MediaLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (_mediaIds.isEmpty) {
              return Text(
                'No media attached',
                style: TextStyle(color: AppColors.grey),
              );
            }
            return Wrap(
              spacing: 8.w,
              runSpacing: 8.h,
              children: _mediaIds.map((id) {
                return Chip(
                  label: Text('Media $id'),
                  deleteIcon: const Icon(Icons.close, size: 18),
                  onDeleted: () {
                    setState(() {
                      _mediaIds.remove(id);
                    });
                  },
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }

  /// Build todo section
  Widget _buildTodoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Todos',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: _showAddTodoDialog,
            ),
          ],
        ),
        if (_todos.isEmpty)
          Text('No todos yet', style: TextStyle(color: AppColors.grey))
        else
          ..._todos.map((todo) {
            return ListTile(
              leading: Checkbox(
                value: todo.isCompleted,
                onChanged: (value) {
                  setState(() {
                    final index = _todos.indexOf(todo);
                    _todos[index] = todo.copyWith(isCompleted: value ?? false);
                  });
                },
              ),
              title: Text(
                todo.text,
                style: TextStyle(
                  decoration: todo.isCompleted
                      ? TextDecoration.lineThrough
                      : null,
                ),
              ),
              trailing: IconButton(
                icon: const Icon(Icons.delete, size: 20),
                onPressed: () {
                  setState(() {
                    _todos.remove(todo);
                  });
                },
              ),
            );
          }).toList(),
      ],
    );
  }

  /// Build links section
  Widget _buildLinksSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Links & Websites',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            IconButton(
              icon: const Icon(Icons.link),
              onPressed: _showAddLinkDialog,
            ),
          ],
        ),
        if (_links.isEmpty)
          Text('No links added', style: TextStyle(color: AppColors.grey))
        else
          ..._links.map((link) {
            return ListTile(
              leading: Icon(Icons.language, size: 20.sp),
              title: Text(link.title ?? link.url),
              subtitle: Text(
                link.url,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              onTap: () => _launchLink(link.url),
              trailing: IconButton(
                icon: const Icon(Icons.delete, size: 20),
                onPressed: () {
                  setState(() {
                    _links.remove(link);
                  });
                },
              ),
            );
          }).toList(),
      ],
    );
  }

  /// Build alarm section
  Widget _buildAlarmSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Alarms & Reminders',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: _showAlarmPicker,
            ),
          ],
        ),
        if ((widget.note?.alarms == null || widget.note!.alarms!.isEmpty) &&
            _activeAlarms.isEmpty)
          Text('No alarm set', style: TextStyle(color: AppColors.grey))
        else
          ..._activeAlarms.map((alarm) {
            return ListTile(
              leading: Icon(
                Icons.alarm,
                color: alarm.isActive ? AppColors.primaryColor : Colors.grey,
              ),
              title: Text(
                '${alarm.alarmTime.day}/${alarm.alarmTime.month}/${alarm.alarmTime.year} ${alarm.alarmTime.hour}:${alarm.alarmTime.minute.toString().padLeft(2, '0')}',
                style: TextStyle(
                  decoration: !alarm.isActive
                      ? TextDecoration.lineThrough
                      : null,
                ),
              ),
              subtitle: alarm.message != null && alarm.message!.isNotEmpty
                  ? Text(alarm.message!)
                  : null,
              trailing: IconButton(
                icon: Icon(Icons.delete, size: 20.sp),
                onPressed: () {
                  // Cancel notification via Bloc
                  context.read<AlarmBloc>().add(
                    DeleteAlarmEvent(
                      noteId: widget.note?.id ?? '',
                      alarmId: alarm.id,
                    ),
                  );

                  // Update local state
                  setState(() {
                    _activeAlarms.removeWhere((a) => a.id == alarm.id);
                  });
                },
              ),
              onTap: () => _editAlarm(alarm),
            );
          }).toList(),
      ],
    );
  }

  /// Build bottom media toolbar
  Widget _buildMediaToolbar() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.defaultPadding,
        vertical: AppConstants.smallPadding,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          IconButton(
            icon: const Icon(Icons.image),
            onPressed: _pickImage,
            tooltip: 'Add Image',
          ),
          IconButton(
            icon: Icon(_isRecording ? Icons.stop : Icons.mic),
            onPressed: _toggleAudioRecording,
            tooltip: _isRecording ? 'Stop Recording' : 'Record Audio',
            color: _isRecording ? AppColors.errorColor : null,
          ),
          IconButton(
            icon: const Icon(Icons.videocam),
            onPressed: _pickVideo,
            tooltip: 'Add Video',
          ),
          IconButton(
            icon: const Icon(Icons.alarm),
            onPressed: _showAlarmPicker,
            tooltip: 'Set Reminder',
          ),
          IconButton(
            icon: const Icon(Icons.check_box),
            onPressed: _showAddTodoDialog,
            tooltip: 'Add Todo',
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
        createdAt: widget.note?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      if (widget.note != null) {
        // Update existing note
        context.read<NotesBloc>().add(UpdateNoteEvent(note));
      } else {
        // Create new note
        context.read<NotesBloc>().add(
          CreateNoteEvent(
            title: note.title,
            content: note.content,
            color: note.color,
          ),
        );
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Note saved successfully'),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  /// Pick image from gallery
  void _pickImage() {
    final noteId =
        widget.note?.id ?? DateTime.now().millisecondsSinceEpoch.toString();
    context.read<MediaBloc>().add(AddImageToNoteEvent(noteId, ''));
  }

  /// Pick video from gallery
  void _pickVideo() {
    final noteId =
        widget.note?.id ?? DateTime.now().millisecondsSinceEpoch.toString();
    context.read<MediaBloc>().add(AddVideoToNoteEvent(noteId, ''));
  }

  /// Toggle audio recording
  void _toggleAudioRecording() {
    final noteId =
        widget.note?.id ?? DateTime.now().millisecondsSinceEpoch.toString();
    if (_isRecording) {
      context.read<MediaBloc>().add(StopAudioRecordingEvent(noteId));
    } else {
      context.read<MediaBloc>().add(StartAudioRecordingEvent(noteId));
    }
  }

  /// Show dialog to add todo
  void _showAddTodoDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Todo'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Enter todo text',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                setState(() {
                  _todos.add(
                    TodoItem(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      text: controller.text,
                      isCompleted: false,
                    ),
                  );
                });
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  /// Show date/time picker for alarm
  void _showAlarmPicker() async {
    // Create a temporary note object if creating new note
    final tempNote =
        widget.note ??
        Note(
          id:
              widget.note?.id ??
              DateTime.now().millisecondsSinceEpoch.toString(),
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
      setState(() {
        _activeAlarms.add(result);
      });
    }
  }

  /// Edit existing alarm
  void _editAlarm(Alarm alarm) async {
    final tempNote =
        widget.note ??
        Note(
          id:
              widget.note?.id ??
              DateTime.now().millisecondsSinceEpoch.toString(),
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
        if (index >= 0) {
          _activeAlarms[index] = result;
        } else {
          _activeAlarms.add(result);
        }
      });
    }
  }

  /// Show add link dialog
  void _showAddLinkDialog() {
    final urlController = TextEditingController();
    final titleController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Link'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: urlController,
              decoration: const InputDecoration(
                hintText: 'Enter URL (https://example.com)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.link),
              ),
              autofocus: true,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                hintText: 'Link title (optional)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.title),
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
              if (urlController.text.isNotEmpty) {
                final url = Link.ensureScheme(urlController.text);
                if (Link.isValidUrl(url)) {
                  setState(() {
                    _links.add(
                      Link(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        url: url,
                        title: titleController.text.isNotEmpty
                            ? titleController.text
                            : null,
                        createdAt: DateTime.now(),
                      ),
                    );
                  });
                  Navigator.pop(context);
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(const SnackBar(content: Text('Link added')));
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Invalid URL format')),
                  );
                }
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  /// Launch link in browser
  Future<void> _launchLink(String url) async {
    try {
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Could not open link')));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error opening link: $e')));
      }
    }
  }
}

