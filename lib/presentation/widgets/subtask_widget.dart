import 'package:flutter/material.dart';

/// Subtask entity for nested task management (SUB-001)
class Subtask {
  final String id;
  final String title;
  final String parentTodoId;
  bool isCompleted;
  final DateTime createdAt;
  DateTime? completedAt;

  Subtask({
    required this.id,
    required this.title,
    required this.parentTodoId,
    this.isCompleted = false,
    required this.createdAt,
    this.completedAt,
  });

  double calculateProgress(List<Subtask> allSubtasks) {
    final relatedSubtasks = allSubtasks
        .where((s) => s.parentTodoId == parentTodoId)
        .toList();
    if (relatedSubtasks.isEmpty) return 0;
    final completed = relatedSubtasks.where((s) => s.isCompleted).length;
    return completed / relatedSubtasks.length;
  }

  Subtask copyWith({
    String? id,
    String? title,
    String? parentTodoId,
    bool? isCompleted,
    DateTime? createdAt,
    DateTime? completedAt,
  }) {
    return Subtask(
      id: id ?? this.id,
      title: title ?? this.title,
      parentTodoId: parentTodoId ?? this.parentTodoId,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }
}

/// Subtask list widget (SUB-002)
class SubtaskListWidget extends StatefulWidget {
  final String parentTodoId;
  final List<Subtask> subtasks;
  final ValueChanged<Subtask> onSubtaskToggle;
  final ValueChanged<Subtask> onSubtaskDelete;
  final VoidCallback? onAddSubtask;

  const SubtaskListWidget({
    Key? key,
    required this.parentTodoId,
    required this.subtasks,
    required this.onSubtaskToggle,
    required this.onSubtaskDelete,
    this.onAddSubtask,
  }) : super(key: key);

  @override
  State<SubtaskListWidget> createState() => _SubtaskListWidgetState();
}

class _SubtaskListWidgetState extends State<SubtaskListWidget> {
  late TextEditingController _newSubtaskController;

  @override
  void initState() {
    super.initState();
    _newSubtaskController = TextEditingController();
  }

  @override
  void dispose() {
    _newSubtaskController.dispose();
    super.dispose();
  }

  List<Subtask> getRelatedSubtasks() {
    return widget.subtasks
        .where((s) => s.parentTodoId == widget.parentTodoId)
        .toList();
  }

  double getProgressPercentage() {
    final related = getRelatedSubtasks();
    if (related.isEmpty) return 0;
    final completed = related.where((s) => s.isCompleted).length;
    return (completed / related.length) * 100;
  }

  @override
  Widget build(BuildContext context) {
    final relatedSubtasks = getRelatedSubtasks();

    if (relatedSubtasks.isEmpty) {
      return SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Subtasks',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${relatedSubtasks.where((s) => s.isCompleted).length}/${relatedSubtasks.length}',
                  style: Theme.of(
                    context,
                  ).textTheme.labelMedium?.copyWith(color: Colors.grey),
                ),
              ],
            ),
            SizedBox(height: 8),
            // Progress bar
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: getProgressPercentage() / 100,
                minHeight: 6,
              ),
            ),
            SizedBox(height: 12),
            // Subtasks list
            ListView.separated(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: relatedSubtasks.length,
              separatorBuilder: (_, __) => Divider(),
              itemBuilder: (context, index) {
                final subtask = relatedSubtasks[index];
                return _buildSubtaskTile(context, subtask);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubtaskTile(BuildContext context, Subtask subtask) {
    return Dismissible(
      key: Key(subtask.id),
      background: Container(
        color: Colors.red.withOpacity(0.2),
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 16),
        child: Icon(Icons.delete_outline, color: Colors.red),
      ),
      onDismissed: (_) => widget.onSubtaskDelete(subtask),
      child: CheckboxListTile(
        value: subtask.isCompleted,
        onChanged: (_) => widget.onSubtaskToggle(subtask),
        title: Text(
          subtask.title,
          style: TextStyle(
            decoration: subtask.isCompleted ? TextDecoration.lineThrough : null,
            color: subtask.isCompleted ? Colors.grey : null,
          ),
        ),
        contentPadding: EdgeInsets.zero,
      ),
    );
  }
}

/// Subtask creator widget (SUB-003)
class SubtaskCreatorWidget extends StatefulWidget {
  final String parentTodoId;
  final ValueChanged<String> onSubtaskCreated;

  const SubtaskCreatorWidget({
    Key? key,
    required this.parentTodoId,
    required this.onSubtaskCreated,
  }) : super(key: key);

  @override
  State<SubtaskCreatorWidget> createState() => _SubtaskCreatorWidgetState();
}

class _SubtaskCreatorWidgetState extends State<SubtaskCreatorWidget> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _addSubtask() {
    if (_controller.text.trim().isNotEmpty) {
      widget.onSubtaskCreated(_controller.text.trim());
      _controller.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(12),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: 'Add a subtask...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: Icon(Icons.check_circle_outline),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
              onSubmitted: (_) => _addSubtask(),
            ),
          ),
          SizedBox(width: 8),
          ElevatedButton.icon(
            icon: Icon(Icons.add),
            label: Text('Add'),
            onPressed: _addSubtask,
          ),
        ],
      ),
    );
  }
}

/// Subtask progress indicator widget
class SubtaskProgressIndicator extends StatelessWidget {
  final List<Subtask> subtasks;
  final String parentTodoId;

  const SubtaskProgressIndicator({
    Key? key,
    required this.subtasks,
    required this.parentTodoId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final related = subtasks
        .where((s) => s.parentTodoId == parentTodoId)
        .toList();
    if (related.isEmpty) return SizedBox.shrink();

    final completed = related.where((s) => s.isCompleted).length;
    final percentage = (completed / related.length * 100).toStringAsFixed(0);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check_circle_outline, size: 16, color: Colors.blue),
          SizedBox(width: 4),
          Text(
            '$completed/${related.length} ($percentage%)',
            style: TextStyle(
              fontSize: 12,
              color: Colors.blue,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
