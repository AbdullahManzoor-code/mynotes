import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mynotes/injection_container.dart';
import '../design_system/design_system.dart';
import '../../domain/entities/todo_item.dart';
import '../../core/services/speech_service.dart';

/// Create Todo Bottom Sheet (TD-001)
/// Supports text input with voice, due date, priority, and category selection
class CreateTodoBottomSheet extends StatefulWidget {
  final Function(TodoItem) onTodoCreated;
  final TodoItem? editTodo; // For editing existing todos

  const CreateTodoBottomSheet({
    super.key,
    required this.onTodoCreated,
    this.editTodo,
  });

  @override
  State<CreateTodoBottomSheet> createState() => _CreateTodoBottomSheetState();
}

class _CreateTodoBottomSheetState extends State<CreateTodoBottomSheet>
    with SingleTickerProviderStateMixin {
  late TextEditingController _textController;
  late TextEditingController _notesController;
  final SpeechService _speechService = SpeechService();

  DateTime? _selectedDueDate;
  TodoPriority _selectedPriority = TodoPriority.medium;
  TodoCategory _selectedCategory = TodoCategory.personal;
  bool _isListening = false;
  bool _isLoading = false;

  late AnimationController _animationController;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController();
    _notesController = TextEditingController();

    // Initialize with existing todo data if editing
    if (widget.editTodo != null) {
      final todo = widget.editTodo!;
      _textController.text = todo.text;
      _notesController.text = todo.notes ?? '';
      _selectedDueDate = todo.dueDate;
      _selectedPriority = todo.priority;
      _selectedCategory = todo.category;
    }

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _slideAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _textController.dispose();
    _notesController.dispose();
    _speechService.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _startVoiceInput() async {
    if (_isListening) return;

    setState(() => _isListening = true);

    try {
      await _speechService.startListening(
        onResult: (text) {
          _textController.text = text;
        },
      );
      setState(() => _isListening = false);
    } catch (e) {
      setState(() => _isListening = false);
      getIt<GlobalUiService>().showError('Failed to start voice input: $e');
    }
  }

  void _stopVoiceInput() {
    _speechService.stopListening();
    setState(() => _isListening = false);
  }

  void _selectDueDate() async {
    final now = DateTime.now();

    // Show date shortcuts first
    final shortcutResult = await showModalBottomSheet<DateTime>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildDateShortcuts(),
    );

    if (shortcutResult != null) {
      setState(() => _selectedDueDate = shortcutResult);
      return;
    }

    // Show full date picker
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDueDate ?? now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );

    if (date != null) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedDueDate ?? now),
      );

      if (time != null) {
        setState(() {
          _selectedDueDate = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }

  Widget _buildDateShortcuts() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day, 17, 0); // 5 PM
    final tomorrow = today.add(const Duration(days: 1));
    final nextWeek = today.add(const Duration(days: 7));

    final shortcuts = [
      ('Today 5 PM', today),
      ('Tomorrow 5 PM', tomorrow),
      ('Next Week', nextWeek),
    ];

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(top: 12),
            decoration: BoxDecoration(
              color: AppColors.textSecondary(context).withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Due Date',
                  style: AppTypography.heading3(
                    context,
                    AppColors.textPrimary(context),
                  ),
                ),
                const SizedBox(height: 16),

                ...shortcuts.map(
                  (shortcut) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: SizedBox(
                      width: double.infinity,
                      child: TextButton(
                        onPressed: () => Navigator.pop(context, shortcut.$2),
                        style: TextButton.styleFrom(
                          backgroundColor: AppColors.surface(context),
                          foregroundColor: AppColors.textPrimary(context),
                          padding: const EdgeInsets.symmetric(
                            vertical: 16,
                            horizontal: 20,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(color: AppColors.border(context)),
                          ),
                        ),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            shortcut.$1,
                            style: AppTypography.bodyMedium(
                              context,
                              AppColors.textPrimary(context),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: TextButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.calendar_month, color: AppColors.primary),
                    label: Text(
                      'Custom Date & Time',
                      style: AppTypography.bodyMedium(
                        context,
                        AppColors.primary,
                      ),
                    ),
                    style: TextButton.styleFrom(
                      backgroundColor: AppColors.primary.withOpacity(0.1),
                      padding: const EdgeInsets.symmetric(
                        vertical: 16,
                        horizontal: 20,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _createTodo() async {
    if (_textController.text.trim().isEmpty) {
      getIt<GlobalUiService>().showWarning('Please enter a todo text');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final now = DateTime.now();
      final todo = TodoItem(
        id:
            widget.editTodo?.id ??
            DateTime.now().millisecondsSinceEpoch.toString(),
        text: _textController.text.trim(),
        dueDate: _selectedDueDate,
        priority: _selectedPriority,
        category: _selectedCategory,
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
        createdAt: widget.editTodo?.createdAt ?? now,
        updatedAt: now,
      );

      widget.onTodoCreated(todo);
      Navigator.pop(context);

      HapticFeedback.mediumImpact();
    } catch (e) {
      getIt<GlobalUiService>().showError('Error creating todo: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _slideAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(
            0,
            (1 - _slideAnimation.value) *
                MediaQuery.of(context).size.height *
                0.3,
          ),
          child: child,
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface(context),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(top: 12),
              decoration: BoxDecoration(
                color: AppColors.textSecondary(context).withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Header
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Text(
                    widget.editTodo != null ? 'Edit Todo' : 'New Todo',
                    style: AppTypography.heading2(
                      context,
                      AppColors.textPrimary(context),
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'Cancel',
                      style: AppTypography.labelMedium(
                        context,
                        AppColors.textSecondary(context),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Text Input with Voice
                    _buildTextInput(),
                    const SizedBox(height: 24),

                    // Priority Selection
                    _buildPrioritySelector(),
                    const SizedBox(height: 24),

                    // Category Selection
                    _buildCategorySelector(),
                    const SizedBox(height: 24),

                    // Due Date Selection
                    _buildDueDateSelector(),
                    const SizedBox(height: 24),

                    // Notes (Optional)
                    _buildNotesInput(),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),

            // Action Button
            Padding(
              padding: const EdgeInsets.all(20),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _createTodo,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          widget.editTodo != null
                              ? 'Update Todo'
                              : 'Create Todo',
                          style: AppTypography.labelLarge(
                            context,
                            Colors.white,
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'What needs to be done?',
              style: AppTypography.labelMedium(
                context,
                AppColors.textSecondary(context),
              ),
            ),
            const Spacer(),
            IconButton(
              onPressed: _isListening ? _stopVoiceInput : _startVoiceInput,
              icon: Icon(
                _isListening ? Icons.mic : Icons.mic_none,
                color: _isListening ? Colors.red : AppColors.primary,
              ),
              style: IconButton.styleFrom(
                backgroundColor: (_isListening ? Colors.red : AppColors.primary)
                    .withOpacity(0.1),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _textController,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: _isListening ? 'Listening...' : 'Enter your todo here',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.border(context)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.primary, width: 2),
            ),
            filled: true,
            fillColor: AppColors.background(context),
          ),
          style: AppTypography.bodyMedium(
            context,
            AppColors.textPrimary(context),
          ),
        ),
      ],
    );
  }

  Widget _buildPrioritySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Priority',
          style: AppTypography.labelMedium(
            context,
            AppColors.textSecondary(context),
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: TodoPriority.values.map((priority) {
            final isSelected = priority == _selectedPriority;
            final color = _getPriorityColor(priority);

            return GestureDetector(
              onTap: () {
                setState(() => _selectedPriority = priority);
                HapticFeedback.lightImpact();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? color.withOpacity(0.1)
                      : AppColors.background(context),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? color : AppColors.border(context),
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      priority.displayName,
                      style: AppTypography.labelMedium(
                        context,
                        isSelected ? color : AppColors.textPrimary(context),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildCategorySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Category',
          style: AppTypography.labelMedium(
            context,
            AppColors.textSecondary(context),
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: TodoCategory.values.map((category) {
            final isSelected = category == _selectedCategory;

            return GestureDetector(
              onTap: () {
                setState(() => _selectedCategory = category);
                HapticFeedback.lightImpact();
              },
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary.withOpacity(0.1)
                      : AppColors.background(context),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.border(context),
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Column(
                  children: [
                    Text(category.icon, style: const TextStyle(fontSize: 24)),
                    const SizedBox(height: 4),
                    Text(
                      category.displayName,
                      style: AppTypography.caption(
                        context,
                        isSelected
                            ? AppColors.primary
                            : AppColors.textSecondary(context),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildDueDateSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Due Date (Optional)',
          style: AppTypography.labelMedium(
            context,
            AppColors.textSecondary(context),
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _selectDueDate,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.background(context),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border(context)),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_month,
                  color: _selectedDueDate != null
                      ? AppColors.primary
                      : AppColors.textSecondary(context),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _selectedDueDate != null
                        ? '${_selectedDueDate!.day}/${_selectedDueDate!.month}/${_selectedDueDate!.year} at ${_selectedDueDate!.hour.toString().padLeft(2, '0')}:${_selectedDueDate!.minute.toString().padLeft(2, '0')}'
                        : 'No due date',
                    style: AppTypography.bodyMedium(
                      context,
                      _selectedDueDate != null
                          ? AppColors.textPrimary(context)
                          : AppColors.textSecondary(context),
                    ),
                  ),
                ),
                if (_selectedDueDate != null)
                  GestureDetector(
                    onTap: () => setState(() => _selectedDueDate = null),
                    child: Icon(
                      Icons.clear,
                      color: AppColors.textSecondary(context),
                      size: 20,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNotesInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Notes (Optional)',
          style: AppTypography.labelMedium(
            context,
            AppColors.textSecondary(context),
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _notesController,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'Add additional details...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.border(context)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.primary, width: 2),
            ),
            filled: true,
            fillColor: AppColors.background(context),
          ),
          style: AppTypography.bodyMedium(
            context,
            AppColors.textPrimary(context),
          ),
        ),
      ],
    );
  }

  Color _getPriorityColor(TodoPriority priority) {
    switch (priority) {
      case TodoPriority.low:
        return Colors.green;
      case TodoPriority.medium:
        return Colors.yellow[700]!;
      case TodoPriority.high:
        return Colors.orange;
      case TodoPriority.urgent:
        return Colors.red;
    }
  }
}
