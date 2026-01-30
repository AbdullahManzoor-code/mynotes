import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/note.dart';
import '../../domain/entities/todo_item.dart';
import '../design_system/design_system.dart';
import '../bloc/note_bloc.dart';
import '../bloc/note_event.dart';

/// Universal Quick Add Smart Input
/// AI-powered parsing for notes, todos, and reminders
/// Based on template: universal_quick_add_smart_input_1
class QuickAddBottomSheet extends StatefulWidget {
  const QuickAddBottomSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const QuickAddBottomSheet(),
    );
  }

  @override
  State<QuickAddBottomSheet> createState() => _QuickAddBottomSheetState();
}

class _QuickAddBottomSheetState extends State<QuickAddBottomSheet>
    with SingleTickerProviderStateMixin {
  final TextEditingController _inputController = TextEditingController();
  final FocusNode _inputFocus = FocusNode();
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;

  String _selectedType = 'Todo';
  List<ParsedEntity> _parsedEntities = [];
  bool _isVoiceListening = false;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _slideAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutQuart),
    );

    _animationController.forward();

    // Auto-focus input
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _inputFocus.requestFocus();
    });

    // Smart parsing on text change
    _inputController.addListener(_parseInput);
  }

  @override
  void dispose() {
    _inputController.removeListener(_parseInput);
    _inputController.dispose();
    _inputFocus.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _parseInput() {
    final text = _inputController.text.toLowerCase();
    final entities = <ParsedEntity>[];

    // Smart detection patterns
    if (text.contains(RegExp(r'\b(todo|task|do)\b'))) {
      entities.add(
        ParsedEntity(
          icon: Icons.check_circle_outline,
          label: 'Todo detected',
          type: 'Todo',
          color: AppColors.primary,
        ),
      );
    }

    if (text.contains(RegExp(r'\b(remind|reminder|alert)\b'))) {
      entities.add(
        ParsedEntity(
          icon: Icons.notification_add,
          label: 'Reminder detected',
          type: 'Reminder',
          color: AppColors.accentColor,
        ),
      );
    }

    if (text.contains(RegExp(r'\b(note|write|remember)\b'))) {
      entities.add(
        ParsedEntity(
          icon: Icons.note_add,
          label: 'Note detected',
          type: 'Note',
          color: AppColors.success,
        ),
      );
    }

    setState(() {
      _parsedEntities = entities;
      if (entities.isNotEmpty) {
        _selectedType = entities.first.type;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final bgColor = colorScheme.surface;
    final textColor = colorScheme.onSurface;
    final hintColor = colorScheme.onSurfaceVariant;
    final screenSize = MediaQuery.of(context).size;

    return AnimatedBuilder(
      animation: _slideAnimation,
      builder: (context, child) => Transform.translate(
        offset: Offset(
          0,
          MediaQuery.of(context).size.height * _slideAnimation.value,
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            color: AppColors.accentBlueDark.withOpacity(0.2),
            child: DraggableScrollableSheet(
              initialChildSize: 0.75,
              minChildSize: 0.45,
              maxChildSize: 0.96,
              snap: true,
              snapSizes: const [0.45, 0.75, 0.96],
              builder: (context, scrollController) => Container(
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(32.r),
                  ),
                  border: Border(
                    top: BorderSide(
                      color: colorScheme.outlineVariant,
                      width: 1.w,
                    ),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: colorScheme.shadow.withOpacity(0.25),
                      blurRadius: 32,
                      offset: const Offset(0, -12),
                      spreadRadius: 4,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _buildHeader(colorScheme),
                    Expanded(
                      child: SingleChildScrollView(
                        controller: scrollController,
                        physics: const BouncingScrollPhysics(),
                        child: Column(
                          children: [
                            _buildInputArea(colorScheme, textColor, hintColor),
                            if (_parsedEntities.isNotEmpty)
                              _buildParsePreview(colorScheme),
                            _buildTypeSelector(colorScheme, textColor),
                            _buildActionButton(colorScheme),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ColorScheme colorScheme) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: AppSpacing.lg),
      child: Column(
        children: [
          Container(
            width: 48.w,
            height: 5.h,
            decoration: BoxDecoration(
              color: colorScheme.outlineVariant.withOpacity(0.3),
              borderRadius: BorderRadius.circular(3.r),
            ),
          ),
          SizedBox(height: AppSpacing.lg),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Create',
                  style: TextStyle(
                    fontSize: 28.sp,
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(
                    Icons.close_rounded,
                    color: colorScheme.onSurfaceVariant,
                    size: 24.r,
                  ),
                  style: IconButton.styleFrom(
                    backgroundColor: colorScheme.surfaceContainerHighest
                        .withOpacity(0.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
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

  Widget _buildInputArea(
    ColorScheme colorScheme,
    Color textColor,
    Color? hintColor,
  ) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.lg,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: colorScheme.outlineVariant, width: 1.w),
          boxShadow: [
            BoxShadow(
              color: colorScheme.shadow.withOpacity(0.08),
              blurRadius: 8.r,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                constraints: BoxConstraints(minHeight: 110.h),
                child: TextField(
                  controller: _inputController,
                  focusNode: _inputFocus,
                  maxLines: null,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w500,
                    height: 1.5,
                  ),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: "What's on your mind?",
                    hintStyle: TextStyle(
                      color: hintColor,
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w400,
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                      vertical: AppSpacing.lg,
                    ),
                  ),
                  cursorColor: AppColors.primary,
                  cursorWidth: 2.w,
                  cursorHeight: 24.h,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(AppSpacing.md),
              child: GestureDetector(
                onTap: _toggleVoiceInput,
                child: Container(
                  padding: EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: _isVoiceListening
                        ? AppColors.primary.withOpacity(0.2)
                        : colorScheme.surfaceContainerHighest,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: _isVoiceListening
                          ? AppColors.primary.withOpacity(0.3)
                          : Colors.transparent,
                      width: 2.w,
                    ),
                  ),
                  child: Icon(
                    _isVoiceListening ? Icons.mic : Icons.mic_none,
                    color: _isVoiceListening ? AppColors.primary : textColor,
                    size: 20.r,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildParsePreview(ColorScheme colorScheme) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.lg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'DETECTED',
            style: TextStyle(
              color: colorScheme.onSurfaceVariant,
              fontSize: 11.sp,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
            ),
          ),
          SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.md,
            runSpacing: AppSpacing.md,
            children: _parsedEntities
                .map((entity) => _buildEntityChip(entity, colorScheme))
                .toList(),
          ),
          SizedBox(height: AppSpacing.md),
        ],
      ),
    );
  }

  Widget _buildEntityChip(ParsedEntity entity, ColorScheme colorScheme) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: entity.color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: entity.color.withOpacity(0.3), width: 1.2.w),
        boxShadow: [
          BoxShadow(
            color: entity.color.withOpacity(0.1),
            blurRadius: 8.r,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(entity.icon, color: entity.color, size: 16.r),
          SizedBox(width: AppSpacing.sm),
          Text(
            entity.label,
            style: TextStyle(
              color: colorScheme.onSurface,
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(width: AppSpacing.xs),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: entity.color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(6.r),
            ),
            child: Text(
              entity.type.toUpperCase(),
              style: TextStyle(
                color: entity.color,
                fontSize: 9.sp,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeSelector(ColorScheme colorScheme, Color textColor) {
    final types = ['Note', 'Todo', 'Reminder'];

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.lg,
      ),
      child: Container(
        height: 52.h,
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: colorScheme.outlineVariant, width: 1.w),
        ),
        child: Row(
          children: types
              .asMap()
              .entries
              .map(
                (entry) => Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedType = entry.value),
                    child: Container(
                      margin: EdgeInsets.all(4.w),
                      decoration: BoxDecoration(
                        color: _selectedType == entry.value
                            ? AppColors.primary
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(11.r),
                      ),
                      child: Center(
                        child: Text(
                          entry.value,
                          style: TextStyle(
                            color: _selectedType == entry.value
                                ? Colors.white
                                : textColor,
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  Widget _buildActionButton(ColorScheme colorScheme) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.xl,
      ),
      child: SizedBox(
        width: double.infinity,
        height: 56.h,
        child: ElevatedButton(
          onPressed: _inputController.text.isNotEmpty ? _saveItem : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            elevation: _inputController.text.isNotEmpty ? 4 : 0,
            shadowColor: AppColors.primary.withOpacity(0.4),
            disabledBackgroundColor: colorScheme.surfaceContainerHighest,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.r),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(_getActionIcon(), size: 20.r),
              SizedBox(width: AppSpacing.lg),
              Text(
                'Save $_selectedType',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'Note':
        return Icons.note_add;
      case 'Todo':
        return Icons.check_circle_outline;
      case 'Reminder':
        return Icons.notification_add;
      default:
        return Icons.add;
    }
  }

  IconData _getActionIcon() {
    switch (_selectedType) {
      case 'Note':
        return Icons.description;
      case 'Todo':
        return Icons.add_task;
      case 'Reminder':
        return Icons.notification_add;
      default:
        return Icons.add;
    }
  }

  void _toggleVoiceInput() {
    setState(() {
      _isVoiceListening = !_isVoiceListening;
    });

    // TODO: Implement actual voice input
    if (_isVoiceListening) {
      // Start voice recognition
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() {
            _isVoiceListening = false;
          });
        }
      });
    }
  }

  void _saveItem() {
    if (_inputController.text.isEmpty) return;

    final text = _inputController.text.trim();
    final notesBloc = context.read<NotesBloc>();
    final now = DateTime.now();

    try {
      if (_selectedType == 'Note') {
        // Simple note creation using CreateNoteEvent
        notesBloc.add(
          CreateNoteEvent(
            title: text,
            content: '',
            color: NoteColor.defaultColor,
          ),
        );
      } else if (_selectedType == 'Todo') {
        // Create note with embedded todo
        final todoId = now.millisecondsSinceEpoch.toString();

        final todoItem = TodoItem(
          id: todoId,
          text: text,
          isCompleted: false,
          priority: TodoPriority.medium,
          category: TodoCategory.personal,
          createdAt: now,
          updatedAt: now,
        );

        final noteWithTodo = Note(
          id: now.millisecondsSinceEpoch.toString(),
          title: text,
          content: '',
          todos: [todoItem],
          color: NoteColor.defaultColor,
          isPinned: false,
          isArchived: false,
          createdAt: now,
          updatedAt: now,
        );

        notesBloc.add(UpdateNoteEvent(noteWithTodo));
      } else if (_selectedType == 'Reminder') {
        // Create note with reminder tag
        notesBloc.add(
          CreateNoteEvent(
            title: text,
            content: 'Reminder: $text',
            color: NoteColor.defaultColor,
            tags: ['reminder'],
          ),
        );
      }

      // Close the sheet after saving
      _closeSheet();
    } catch (e) {
      // Show error message if something fails
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving $_selectedType: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _closeSheet() {
    _animationController.reverse().then((_) {
      Navigator.of(context).pop();
    });
  }
}

class ParsedEntity {
  final IconData icon;
  final String label;
  final String type;
  final Color color;

  ParsedEntity({
    required this.icon,
    required this.label,
    required this.type,
    required this.color,
  });
}
