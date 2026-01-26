import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:async';
import '../../core/constants/app_colors.dart';
import '../../domain/entities/note.dart';
import '../bloc/note_bloc.dart';
import '../bloc/note_state.dart';
import '../bloc/note_event.dart';
import '../widgets/note_card_widget.dart';
import 'note_editor_page.dart';

/// Global Search Screen
/// Search across all notes, reminders, and todos
class GlobalSearchScreen extends StatefulWidget {
  const GlobalSearchScreen({Key? key}) : super(key: key);

  @override
  State<GlobalSearchScreen> createState() => _GlobalSearchScreenState();
}

class _GlobalSearchScreenState extends State<GlobalSearchScreen> {
  late TextEditingController _searchController;
  Timer? _debounce;
  String _selectedFilter = 'all'; // all, notes, todos, reminders

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      if (_searchController.text.trim().isNotEmpty) {
        context.read<NotesBloc>().add(
          SearchNotesEvent(_searchController.text.trim()),
        );
      }
    });
  }

  List<Note> _filterResults(List<Note> notes) {
    switch (_selectedFilter) {
      case 'notes':
        return notes.where((n) => !n.tags.contains('todo')).toList();
      case 'todos':
        return notes.where((n) => n.tags.contains('todo')).toList();
      case 'reminders':
        return notes
            .where((n) => n.alarms != null && n.alarms!.isNotEmpty)
            .toList();
      default:
        return notes;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.darkBackground
          : AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: isDark ? Colors.white : Colors.black,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: TextField(
          controller: _searchController,
          autofocus: true,
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black,
            fontSize: 16.sp,
          ),
          decoration: InputDecoration(
            hintText: 'Search everything...',
            hintStyle: TextStyle(color: Colors.grey),
            border: InputBorder.none,
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: Icon(Icons.clear, color: Colors.grey),
                    onPressed: () {
                      _searchController.clear();
                    },
                  )
                : null,
          ),
        ),
      ),
      body: Column(
        children: [
          // Filter chips
          Container(
            padding: EdgeInsets.all(16.w),
            color: isDark ? AppColors.surfaceDark : Colors.white,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip('All', 'all', isDark),
                  SizedBox(width: 8.w),
                  _buildFilterChip('Notes', 'notes', isDark),
                  SizedBox(width: 8.w),
                  _buildFilterChip('To-Dos', 'todos', isDark),
                  SizedBox(width: 8.w),
                  _buildFilterChip('Reminders', 'reminders', isDark),
                ],
              ),
            ),
          ),

          // Search results
          Expanded(
            child: BlocBuilder<NotesBloc, NoteState>(
              builder: (context, state) {
                if (state is NoteLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is NotesLoaded) {
                  final filteredResults = _filterResults(state.notes);

                  if (_searchController.text.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.search, size: 64.sp, color: Colors.grey),
                          SizedBox(height: 16.h),
                          Text(
                            'Start typing to search',
                            style: TextStyle(
                              fontSize: 16.sp,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  if (filteredResults.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search_off,
                            size: 64.sp,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 16.h),
                          Text(
                            'No results found',
                            style: TextStyle(
                              fontSize: 16.sp,
                              color: Colors.grey,
                            ),
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            'Try a different search term',
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: EdgeInsets.all(16.w),
                    itemCount: filteredResults.length,
                    itemBuilder: (context, index) {
                      final note = filteredResults[index];
                      return Padding(
                        padding: EdgeInsets.only(bottom: 12.h),
                        child: NoteCardWidget(
                          note: note,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => NoteEditorPage(note: note),
                              ),
                            );
                          },
                          onLongPress: () {},
                          onPin: () {
                            context.read<NotesBloc>().add(
                              UpdateNoteEvent(
                                note.copyWith(
                                  isPinned: !note.isPinned,
                                  updatedAt: DateTime.now(),
                                ),
                              ),
                            );
                          },
                          onColorChange: (color) {
                            context.read<NotesBloc>().add(
                              UpdateNoteEvent(
                                note.copyWith(
                                  color: color,
                                  updatedAt: DateTime.now(),
                                ),
                              ),
                            );
                          },
                          onDelete: () {
                            context.read<NotesBloc>().add(
                              DeleteNoteEvent(note.id),
                            );
                          },
                        ),
                      );
                    },
                  );
                }

                return const SizedBox();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value, bool isDark) {
    final isSelected = _selectedFilter == value;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() => _selectedFilter = value);
      },
      selectedColor: AppColors.primaryColor.withOpacity(0.2),
      checkmarkColor: AppColors.primaryColor,
      backgroundColor: isDark ? AppColors.darkBackground : Colors.grey.shade200,
      labelStyle: TextStyle(
        color: isSelected
            ? AppColors.primaryColor
            : (isDark ? Colors.white : Colors.black),
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }
}
