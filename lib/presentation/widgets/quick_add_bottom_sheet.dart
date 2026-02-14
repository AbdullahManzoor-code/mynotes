import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mynotes/domain/entities/universal_item.dart';
import '../design_system/design_system.dart';
import '../bloc/alarm/alarms_bloc.dart';
import '../bloc/note/note_bloc.dart';
import '../bloc/note/note_event.dart';
import '../bloc/params/note_params.dart';
import '../bloc/params/todo_params.dart';
import '../bloc/todos/todos_bloc.dart';
import '../../injection_container.dart' show getIt;
import '../../core/utils/smart_voice_parser.dart';
import '../../domain/entities/alarm.dart';

enum QuickAddTab { note, todo, reminder }

class QuickAddBottomSheet extends StatefulWidget {
  final QuickAddTab initialTab;
  final String? initialText;

  const QuickAddBottomSheet({
    super.key,
    this.initialTab = QuickAddTab.note,
    this.initialText,
  });

  static Future<T?> show<T>(
    BuildContext context, {
    QuickAddTab initialTab = QuickAddTab.note,
    String? initialText,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) =>
          QuickAddBottomSheet(initialTab: initialTab, initialText: initialText),
    );
  }

  @override
  State<QuickAddBottomSheet> createState() => _QuickAddBottomSheetState();
}

class _QuickAddBottomSheetState extends State<QuickAddBottomSheet>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 3,
      vsync: this,
      initialIndex: widget.initialTab.index,
    );
    if (widget.initialText != null) {
      _textController.text = widget.initialText!;
    }
    _focusNode.requestFocus();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    setState(() => _isSaving = true);

    try {
      final currentTab = QuickAddTab.values[_tabController.index];
      final parseResult = SmartVoiceParser.parseComplexVoice(text);
      final item = parseResult['item'] as UniversalItem;

      switch (currentTab) {
        case QuickAddTab.note:
          await _createNoteFromItem(item);
          break;
        case QuickAddTab.todo:
          await _createTodoFromItem(item);
          break;
        case QuickAddTab.reminder:
          await _createReminderFromItem(item);
          break;
      }

      if (mounted) {
        Navigator.pop(context, true);
        getIt<GlobalUiService>().showSuccess(
          '${currentTab.name.toUpperCase()} added successfully',
        );
      }
    } catch (e) {
      if (mounted) {
        getIt<GlobalUiService>().showError('Error: $e');
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _createNoteFromItem(UniversalItem item) {
    final title = item.title.isNotEmpty
        ? item.title
        : (item.content.isNotEmpty ? item.content : 'Quick Note');
    final params = NoteParams(
      noteId: item.id,
      title: title,
      content: item.content,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    context.read<NotesBloc>().add(CreateNoteEvent(params: params));
    return Future.value();
  }

  Future<void> _createTodoFromItem(UniversalItem item) {
    final text = item.title.isNotEmpty
        ? item.title
        : (item.content.isNotEmpty ? item.content : 'Quick Todo');
    final params = TodoParams(
      todoId: item.id,
      text: text,
      notes: item.content.isNotEmpty ? item.content : null,
      dueDate: item.reminderTime,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    context.read<TodosBloc>().add(AddTodo(params));
    return Future.value();
  }

  Future<void> _createReminderFromItem(UniversalItem item) {
    final now = DateTime.now();
    final scheduledTime =
        item.reminderTime ?? now.add(const Duration(hours: 1));
    final alarm = Alarm(
      id: item.id,
      message: item.title.isNotEmpty
          ? item.title
          : (item.content.isNotEmpty ? item.content : 'Quick Reminder'),
      scheduledTime: scheduledTime,
      createdAt: now,
      updatedAt: now,
      recurrence: AlarmRecurrence.none,
      status: AlarmStatus.scheduled,
      isEnabled: true,
      vibrate: true,
    );
    context.read<AlarmsBloc>().add(AddAlarm(alarm));
    return Future.value();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 16.h,
        left: 16.w,
        right: 16.w,
        top: 8.h,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40.w,
            height: 4.h,
            margin: EdgeInsets.only(bottom: 16.h),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
          TabBar(
            controller: _tabController,
            labelColor: AppColors.primary,
            unselectedLabelColor: Colors.grey,
            indicatorColor: AppColors.primary,
            dividerColor: Colors.transparent,
            tabs: const [
              Tab(text: 'Note', icon: Icon(Icons.note_add_outlined)),
              Tab(text: 'Todo', icon: Icon(Icons.check_box_outlined)),
              Tab(
                text: 'Reminder',
                icon: Icon(Icons.notification_add_outlined),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          TextField(
            controller: _textController,
            focusNode: _focusNode,
            maxLines: 5,
            minLines: 1,
            decoration: InputDecoration(
              hintText: 'What\'s on your mind?',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: isDark ? Colors.grey.shade900 : Colors.grey.shade100,
            ),
          ),
          SizedBox(height: 16.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              SizedBox(width: 8.w),
              ElevatedButton(
                onPressed: _isSaving ? null : _handleSave,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                child: _isSaving
                    ? SizedBox(
                        width: 20.w,
                        height: 20.w,
                        child: const CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Add'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

