import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../design_system/design_system.dart';
import '../bloc/note_bloc.dart';
import '../bloc/note_state.dart';
import '../bloc/todo_bloc.dart';
import '../bloc/todo_state.dart';
import '../bloc/alarm_bloc.dart';
import '../bloc/alarm_state.dart';
import '../../domain/entities/note.dart';

/// Unified Items Screen - Displays notes, todos, and reminders in one place
/// Allows filtering by type, priority, and due date
class UnifiedItemsScreen extends StatefulWidget {
  const UnifiedItemsScreen({super.key});

  @override
  State<UnifiedItemsScreen> createState() => _UnifiedItemsScreenState();
}

class _UnifiedItemsScreenState extends State<UnifiedItemsScreen>
    with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();

  // Filter states
  String _selectedFilter = 'all'; // 'all', 'notes', 'todos', 'reminders'
  String _sortBy = 'recent'; // 'recent', 'priority', 'due-date'
  bool _showOnlyPinned = false;

  late AnimationController _filterAnimationController;
  late AnimationController _fabController;

  @override
  void initState() {
    super.initState();
    _filterAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fabController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _filterAnimationController.dispose();
    _fabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.getSurfaceColor(Theme.of(context).brightness),
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildSearchAndFilterBar(),
          _buildFilterChips(),
          Expanded(child: _buildUnifiedItemsList()),
        ],
      ),
      floatingActionButton: _buildFAB(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.getSurfaceColor(Theme.of(context).brightness),
      elevation: 0,
      title: Text(
        'All Items',
        style: TextStyle(
          fontSize: 24.sp,
          fontWeight: FontWeight.w700,
          color: AppColors.getTextColor(Theme.of(context).brightness),
        ),
      ),
      actions: [
        Padding(
          padding: EdgeInsets.only(right: 16.w),
          child: Center(
            child: GestureDetector(
              onTap: _showSortOptions,
              child: Icon(
                Icons.sort,
                color: AppColors.getTextColor(Theme.of(context).brightness),
                size: 24.sp,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchAndFilterBar() {
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Column(
        children: [
          // Search bar
          TextField(
            controller: _searchController,
            style: TextStyle(
              fontSize: 16.sp,
              color: AppColors.getTextColor(Theme.of(context).brightness),
            ),
            decoration: InputDecoration(
              hintText: 'Search notes, todos, reminders...',
              hintStyle: TextStyle(
                fontSize: 16.sp,
                color: AppColors.getSecondaryTextColor(
                  Theme.of(context).brightness,
                ),
              ),
              prefixIcon: Icon(
                Icons.search,
                color: AppColors.primary,
                size: 20.sp,
              ),
              suffixIcon: _searchController.text.isNotEmpty
                  ? GestureDetector(
                      onTap: () {
                        _searchController.clear();
                        setState(() {});
                      },
                      child: Icon(
                        Icons.close,
                        color: AppColors.getSecondaryTextColor(
                          Theme.of(context).brightness,
                        ),
                        size: 20.sp,
                      ),
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(
                  color: AppColors.primary.withOpacity(0.3),
                  width: 1,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(
                  color: AppColors.getSecondaryTextColor(
                    Theme.of(context).brightness,
                  ).withOpacity(0.2),
                  width: 1,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(color: AppColors.primary, width: 2),
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 12.w,
                vertical: 12.h,
              ),
              filled: true,
              fillColor: AppColors.getSurfaceColor(
                Theme.of(context).brightness,
              ),
            ),
            onChanged: (_) {
              setState(() {});
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Row(
        children: [
          _buildFilterChip('All', 'all'),
          SizedBox(width: 8.w),
          _buildFilterChip('Notes', 'notes'),
          SizedBox(width: 8.w),
          _buildFilterChip('Todos', 'todos'),
          SizedBox(width: 8.w),
          _buildFilterChip('Reminders', 'reminders'),
          SizedBox(width: 8.w),
          GestureDetector(
            onTap: () {
              setState(() {
                _showOnlyPinned = !_showOnlyPinned;
              });
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: _showOnlyPinned
                    ? AppColors.primary.withOpacity(0.2)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(
                  color: _showOnlyPinned
                      ? AppColors.primary
                      : AppColors.getSecondaryTextColor(
                          Theme.of(context).brightness,
                        ).withOpacity(0.3),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.push_pin,
                    size: 14.sp,
                    color: _showOnlyPinned
                        ? AppColors.primary
                        : AppColors.getSecondaryTextColor(
                            Theme.of(context).brightness,
                          ),
                  ),
                  SizedBox(width: 4.w),
                  Text(
                    'Pinned',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                      color: _showOnlyPinned
                          ? AppColors.primary
                          : AppColors.getSecondaryTextColor(
                              Theme.of(context).brightness,
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _selectedFilter == value;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = value;
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withOpacity(0.2)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : AppColors.getSecondaryTextColor(
                    Theme.of(context).brightness,
                  ).withOpacity(0.3),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w500,
            color: isSelected
                ? AppColors.primary
                : AppColors.getSecondaryTextColor(Theme.of(context).brightness),
          ),
        ),
      ),
    );
  }

  Widget _buildUnifiedItemsList() {
    // Debug: Current sort strategy is _sortBy (can be expanded for actual sorting)
    // sortStrategy: recent, priority, due-date
    return ListView(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      children: [
        // Notes section
        if (_selectedFilter == 'all' || _selectedFilter == 'notes')
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Notes',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.getSecondaryTextColor(
                    Theme.of(context).brightness,
                  ),
                ),
              ),
              SizedBox(height: 8.h),
              BlocBuilder<NotesBloc, NoteState>(
                builder: (context, state) {
                  if (state is NotesLoaded) {
                    var notes = state.notes;
                    // Apply sorting based on _sortBy
                    if (_sortBy == 'recent') {
                      notes = notes.toList()
                        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
                    }
                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: notes.length,
                      itemBuilder: (context, index) {
                        return _buildNoteItem(notes[index]);
                      },
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
              SizedBox(height: 20.h),
            ],
          ),

        // Todos section
        if (_selectedFilter == 'all' || _selectedFilter == 'todos')
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Todos',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.getSecondaryTextColor(
                    Theme.of(context).brightness,
                  ),
                ),
              ),
              SizedBox(height: 8.h),
              BlocBuilder<TodoBloc, TodoState>(
                builder: (context, state) {
                  if (state is TodosLoaded) {
                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: state.todos.length,
                      itemBuilder: (context, index) {
                        return _buildTodoItem(state.todos[index]);
                      },
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
              SizedBox(height: 20.h),
            ],
          ),

        // Reminders section
        if (_selectedFilter == 'all' || _selectedFilter == 'reminders')
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Reminders',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.getSecondaryTextColor(
                    Theme.of(context).brightness,
                  ),
                ),
              ),
              SizedBox(height: 8.h),
              BlocBuilder<AlarmBloc, AlarmState>(
                builder: (context, state) {
                  if (state is AlarmSuccess) {
                    return _buildReminderItem(state.result);
                  }
                  return const SizedBox.shrink();
                },
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildNoteItem(Note note) {
    final noteColor = note.color is Color
        ? note.color as Color
        : AppColors.primary.withOpacity(0.1);
    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: noteColor,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(
          color: AppColors.getSecondaryTextColor(
            Theme.of(context).brightness,
          ).withOpacity(0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  note.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.getTextColor(Theme.of(context).brightness),
                  ),
                ),
              ),
              if (note.isPinned)
                Icon(Icons.push_pin, size: 14.sp, color: AppColors.primary),
            ],
          ),
          SizedBox(height: 4.h),
          Text(
            note.content,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12.sp,
              color: AppColors.getSecondaryTextColor(
                Theme.of(context).brightness,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTodoItem(dynamic todo) {
    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppColors.getSurfaceColor(Theme.of(context).brightness),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(
          color: AppColors.getSecondaryTextColor(
            Theme.of(context).brightness,
          ).withOpacity(0.1),
        ),
      ),
      child: Row(
        children: [
          Checkbox(
            value: todo.isCompleted ?? false,
            onChanged: (_) {},
            fillColor: MaterialStateProperty.all(AppColors.primary),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  todo.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: AppColors.getTextColor(Theme.of(context).brightness),
                    decoration: (todo.isCompleted ?? false)
                        ? TextDecoration.lineThrough
                        : null,
                  ),
                ),
                if (todo.dueDate != null)
                  Text(
                    'Due: ${todo.dueDate}',
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: AppColors.getSecondaryTextColor(
                        Theme.of(context).brightness,
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

  Widget _buildReminderItem(dynamic reminder) {
    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppColors.getSurfaceColor(Theme.of(context).brightness),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(Icons.alarm, color: AppColors.primary, size: 18.sp),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Reminder',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: AppColors.getTextColor(Theme.of(context).brightness),
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  'Scheduled reminder',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: AppColors.getSecondaryTextColor(
                      Theme.of(context).brightness,
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

  void _showSortOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: AppColors.getSurfaceColor(Theme.of(context).brightness),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20.r),
            topRight: Radius.circular(20.r),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40.w,
              height: 4.h,
              margin: EdgeInsets.symmetric(vertical: 12.h),
              decoration: BoxDecoration(
                color: Colors.grey,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(16.w),
              child: Text(
                'Sort By',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.getTextColor(Theme.of(context).brightness),
                ),
              ),
            ),
            ListTile(
              leading: Icon(
                Icons.schedule,
                color: AppColors.getTextColor(Theme.of(context).brightness),
              ),
              title: Text(
                'Most Recent',
                style: TextStyle(
                  color: AppColors.getTextColor(Theme.of(context).brightness),
                ),
              ),
              onTap: () {
                setState(() {
                  _sortBy = 'recent';
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(
                Icons.priority_high,
                color: AppColors.getTextColor(Theme.of(context).brightness),
              ),
              title: Text(
                'Priority',
                style: TextStyle(
                  color: AppColors.getTextColor(Theme.of(context).brightness),
                ),
              ),
              onTap: () {
                setState(() {
                  _sortBy = 'priority';
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(
                Icons.date_range,
                color: AppColors.getTextColor(Theme.of(context).brightness),
              ),
              title: Text(
                'Due Date',
                style: TextStyle(
                  color: AppColors.getTextColor(Theme.of(context).brightness),
                ),
              ),
              onTap: () {
                setState(() {
                  _sortBy = 'due-date';
                });
                Navigator.pop(context);
              },
            ),
            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }

  Widget _buildFAB() {
    return ScaleTransition(
      scale: Tween<double>(
        begin: 0.8,
        end: 1.0,
      ).animate(CurvedAnimation(parent: _fabController, curve: Curves.easeOut)),
      child: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () {
          // Open create menu
        },
        child: Icon(Icons.add, color: Colors.white, size: 24.sp),
      ),
    );
  }
}

