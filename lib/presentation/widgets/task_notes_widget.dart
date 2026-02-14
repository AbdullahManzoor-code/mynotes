import 'package:flutter/material.dart';

/// Task notes widget - Add description/notes to tasks (TD-008)
class TaskNotesWidget extends StatefulWidget {
  final String initialNotes;
  final ValueChanged<String> onNotesChanged;
  final VoidCallback? onSave;

  const TaskNotesWidget({
    super.key,
    this.initialNotes = '',
    required this.onNotesChanged,
    this.onSave,
  });

  @override
  State<TaskNotesWidget> createState() => _TaskNotesWidgetState();
}

class _TaskNotesWidgetState extends State<TaskNotesWidget> {
  late TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    _notesController = TextEditingController(text: widget.initialNotes);
    _notesController.addListener(() {
      widget.onNotesChanged(_notesController.text);
    });
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Task Notes',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        TextField(
          controller: _notesController,
          maxLines: 4,
          minLines: 3,
          decoration: InputDecoration(
            hintText: 'Add notes about this task...',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            prefixIcon: Icon(Icons.note_outlined),
            suffixIcon: _notesController.text.isNotEmpty
                ? IconButton(
                    icon: Icon(Icons.clear),
                    onPressed: () => _notesController.clear(),
                  )
                : null,
          ),
        ),
        if (widget.onSave != null) ...[
          SizedBox(height: 12),
          ElevatedButton.icon(
            icon: Icon(Icons.save),
            label: Text('Save Notes'),
            onPressed: widget.onSave,
          ),
        ],
      ],
    );
  }
}

/// Task notes editor bottom sheet
void showTaskNotesEditor(
  BuildContext context, {
  required String initialNotes,
  required ValueChanged<String> onSave,
}) {
  String tempNotes = initialNotes;

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (context) => DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) => Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Edit Task Notes',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                IconButton(
                  icon: Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            Expanded(
              child: TaskNotesWidget(
                initialNotes: initialNotes,
                onNotesChanged: (value) => tempNotes = value,
                onSave: () {
                  onSave(tempNotes);
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

/// Task notes display widget
class TaskNotesDisplay extends StatelessWidget {
  final String notes;
  final VoidCallback? onEdit;

  const TaskNotesDisplay({super.key, required this.notes, this.onEdit});

  @override
  Widget build(BuildContext context) {
    if (notes.isEmpty) return SizedBox.shrink();

    return Card(
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.note_outlined, size: 18, color: Colors.grey),
                    SizedBox(width: 8),
                    Text(
                      'Notes',
                      style: Theme.of(
                        context,
                      ).textTheme.labelMedium?.copyWith(color: Colors.grey),
                    ),
                  ],
                ),
                if (onEdit != null)
                  IconButton(
                    icon: Icon(Icons.edit, size: 18),
                    onPressed: onEdit,
                    padding: EdgeInsets.zero,
                    constraints: BoxConstraints(),
                  ),
              ],
            ),
            SizedBox(height: 8),
            Text(
              notes,
              style: Theme.of(context).textTheme.bodyMedium,
              maxLines: 5,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
