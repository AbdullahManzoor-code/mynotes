import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/note.dart';
import '../design_system/design_system.dart' hide OutlinedButton;
import '../bloc/note/note_bloc.dart';
import '../bloc/note/note_event.dart';
import '../bloc/note/note_state.dart';

/// Enhanced Search Bar for Notes with advanced filtering (ORG-003)
/// Provides real-time search with tag, color, and content filtering
/// Updated to use NotesBloc for state management
class NotesSearchBar extends StatefulWidget {
  final VoidCallback? onAdvancedSearch;
  final bool showAdvancedOptions;

  const NotesSearchBar({
    super.key,
    this.onAdvancedSearch,
    this.showAdvancedOptions = true,
  });

  @override
  State<NotesSearchBar> createState() => _NotesSearchBarState();
}

class _NotesSearchBarState extends State<NotesSearchBar>
    with SingleTickerProviderStateMixin {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  late AnimationController _animationController;
  late Animation<double> _expandAnimation;

  bool _showClearButton = false;
  Timer? _debounceTimer;

  // Sample tags (in real app, these would come from notes data or settings)
  final List<String> _availableTags = [
    'work',
    'personal',
    'important',
    'ideas',
    'todo',
    'meeting',
    'project',
  ];

  // Available colors for filtering from NoteColor enum
  final List<NoteColor> _availableColors = [
    NoteColor.red,
    NoteColor.orange,
    NoteColor.yellow,
    NoteColor.green,
    NoteColor.blue,
    NoteColor.purple,
    NoteColor.pink,
    NoteColor.brown,
    NoteColor.grey,
  ];

  @override
  void initState() {
    super.initState();
    final notesBloc = context.read<NotesBloc>();
    final currentState = notesBloc.state;
    String initialQuery = '';

    if (currentState is NotesLoaded) {
      initialQuery = currentState.searchQuery;
    }

    _controller = TextEditingController(text: initialQuery);
    _focusNode = FocusNode();
    _showClearButton = _controller.text.isNotEmpty;

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _expandAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    // Initial animation state based on BLoC
    if (currentState is NotesLoaded && currentState.isSearchExpanded) {
      _animationController.value = 1.0;
    }

    _controller.addListener(_onSearchTextChanged);
    _focusNode.addListener(_onFocusChanged);
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _controller.dispose();
    _focusNode.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _onSearchTextChanged() {
    final query = _controller.text;

    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      context.read<NotesBloc>().add(
        UpdateNoteViewConfigEvent(searchQuery: query),
      );
    });
  }

  void _onFocusChanged() {
    if (_focusNode.hasFocus && widget.showAdvancedOptions) {
      _expandSearchOptions();
    }
  }

  void _expandSearchOptions() {
    final state = context.read<NotesBloc>().state;
    if (state is NotesLoaded && !state.isSearchExpanded) {
      context.read<NotesBloc>().add(
        const ToggleSearchExpandedEvent(isExpanded: true),
      );
      _animationController.forward();
    }
  }

  void _collapseSearchOptions() {
    final state = context.read<NotesBloc>().state;
    if (state is NotesLoaded && state.isSearchExpanded) {
      context.read<NotesBloc>().add(
        const ToggleSearchExpandedEvent(isExpanded: false),
      );
      _animationController.reverse();
      _focusNode.unfocus();
    }
  }

  void _clearSearch() {
    _controller.clear();
    context.read<NotesBloc>().add(
      const UpdateNoteViewConfigEvent(
        searchQuery: '',
        selectedTags: [],
        selectedColors: [],
        filterPinned: false,
        filterWithMedia: false,
      ),
    );
    HapticFeedback.lightImpact();
  }

  void _toggleTag(String tag, List<String> currentTags) {
    final newTags = List<String>.from(currentTags);
    if (newTags.contains(tag)) {
      newTags.remove(tag);
    } else {
      newTags.add(tag);
    }
    context.read<NotesBloc>().add(
      UpdateNoteViewConfigEvent(selectedTags: newTags),
    );
    HapticFeedback.lightImpact();
  }

  void _toggleColor(NoteColor color, List<NoteColor> currentColors) {
    final newColors = List<NoteColor>.from(currentColors);
    if (newColors.contains(color)) {
      newColors.remove(color);
    } else {
      newColors.add(color);
    }
    context.read<NotesBloc>().add(
      UpdateNoteViewConfigEvent(selectedColors: newColors),
    );
    HapticFeedback.lightImpact();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<NotesBloc, NoteState>(
      listener: (context, state) {
        if (state is NotesLoaded) {
          // Sync animation with BLoC state if it changed externally
          if (state.isSearchExpanded &&
              _animationController.status == AnimationStatus.dismissed) {
            _animationController.forward();
          } else if (!state.isSearchExpanded &&
              _animationController.status == AnimationStatus.completed) {
            _animationController.reverse();
          }

          // Sync text controller if query changed from BLoC (e.g. clear search)
          if (state.searchQuery != _controller.text) {
            _controller.text = state.searchQuery;
          }
        }
      },
      builder: (context, state) {
        final bool isExpanded = state is NotesLoaded
            ? state.isSearchExpanded
            : false;

        return GestureDetector(
          onTap: () {
            if (!_focusNode.hasFocus && isExpanded) {
              _collapseSearchOptions();
            }
          },
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.surface(context),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _focusNode.hasFocus
                    ? AppColors.primary.withOpacity(0.5)
                    : AppColors.border(context),
              ),
              boxShadow: _focusNode.hasFocus
                  ? [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.1),
                        blurRadius: 8,
                        spreadRadius: 0,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: Column(
              children: [
                // Main search input
                _buildSearchInput(isExpanded),

                // Advanced options (animated)
                if (widget.showAdvancedOptions)
                  AnimatedBuilder(
                    animation: _expandAnimation,
                    builder: (context, child) {
                      return SizeTransition(
                        sizeFactor: _expandAnimation,
                        child: child,
                      );
                    },
                    child: _buildAdvancedOptions(state),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSearchInput(bool isExpanded) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Row(
        children: [
          Icon(
            Icons.search,
            color: _focusNode.hasFocus
                ? AppColors.primary
                : AppColors.textSecondary(context),
            size: 20,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: TextField(
              controller: _controller,
              focusNode: _focusNode,
              style: AppTypography.bodyMedium(
                context,
                AppColors.textPrimary(context),
              ),
              decoration: InputDecoration(
                hintText: 'Search notes, tags, or content...',
                hintStyle: AppTypography.bodyMedium(
                  context,
                  AppColors.textSecondary(context),
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
              textInputAction: TextInputAction.search,
              onSubmitted: (_) {
                _focusNode.unfocus();
                if (isExpanded && widget.showAdvancedOptions) {
                  _collapseSearchOptions();
                }
              },
            ),
          ),
          if (_showClearButton) ...[
            SizedBox(width: 8.w),
            GestureDetector(
              onTap: _clearSearch,
              child: Icon(
                Icons.clear,
                color: AppColors.textSecondary(context),
                size: 20,
              ),
            ),
          ],
          if (widget.showAdvancedOptions && isExpanded) ...[
            SizedBox(width: 8.w),
            GestureDetector(
              onTap: _collapseSearchOptions,
              child: Icon(
                Icons.keyboard_arrow_up,
                color: AppColors.textSecondary(context),
                size: 20,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAdvancedOptions(NoteState state) {
    if (state is! NotesLoaded) return const SizedBox.shrink();

    return Container(
      padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // General Filters (Pinned, Media)
          _buildGeneralFilters(state),

          SizedBox(height: 16.h),

          // Divider
          Container(
            height: 1,
            color: AppColors.border(context),
            margin: EdgeInsets.only(bottom: 16.h),
          ),

          // Filter by Tags
          _buildTagFilters(state),

          SizedBox(height: 16.h),

          // Filter by Colors
          _buildColorFilters(state),

          SizedBox(height: 16.h),

          // Advanced Search Button
          if (widget.onAdvancedSearch != null) _buildAdvancedSearchButton(),
        ],
      ),
    );
  }

  Widget _buildTagFilters(NotesLoaded state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Filter by Tags',
          style: AppTypography.labelSmall(
            context,
            AppColors.textSecondary(context),
          ),
        ),
        SizedBox(height: 12.h),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _availableTags.map((tag) {
            final isSelected = state.selectedTags.contains(tag);
            return GestureDetector(
              onTap: () => _toggleTag(tag, state.selectedTags),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary.withOpacity(0.1)
                      : AppColors.background(context),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.border(context),
                  ),
                ),
                child: Text(
                  tag,
                  style: AppTypography.labelSmall(
                    context,
                    isSelected
                        ? AppColors.primary
                        : AppColors.textSecondary(context),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildColorFilters(NotesLoaded state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Filter by Color',
          style: AppTypography.labelSmall(
            context,
            AppColors.textSecondary(context),
          ),
        ),
        SizedBox(height: 8.h),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _availableColors.map((noteColor) {
            final isSelected = state.selectedColors.contains(noteColor);
            final colorValue = Color(
              noteColor.getColorValue(
                Theme.of(context).brightness == Brightness.dark,
              ),
            );
            return GestureDetector(
              onTap: () => _toggleColor(noteColor, state.selectedColors),
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: colorValue,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected
                        ? AppColors.textPrimary(context)
                        : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: isSelected
                    ? const Icon(
                        Icons.check,
                        color: AppColors.lightText,
                        size: 16,
                      )
                    : null,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildGeneralFilters(NotesLoaded state) {
    return Row(
      children: [
        _buildFilterChip(
          label: 'Pinned Only',
          isSelected: state.filterPinned,
          onTap: () {
            context.read<NotesBloc>().add(
              UpdateNoteViewConfigEvent(filterPinned: !state.filterPinned),
            );
            HapticFeedback.lightImpact();
          },
        ),
        SizedBox(width: 8.w),
        _buildFilterChip(
          label: 'With Media',
          isSelected: state.filterWithMedia,
          onTap: () {
            context.read<NotesBloc>().add(
              UpdateNoteViewConfigEvent(
                filterWithMedia: !state.filterWithMedia,
              ),
            );
            HapticFeedback.lightImpact();
          },
        ),
        SizedBox(width: 8.w),
        _buildFilterChip(
          label: 'With Reminders',
          isSelected: state.filterWithReminders,
          onTap: () {
            context.read<NotesBloc>().add(
              UpdateNoteViewConfigEvent(
                filterWithReminders: !state.filterWithReminders,
              ),
            );
            HapticFeedback.lightImpact();
          },
        ),
      ],
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withOpacity(0.1)
              : AppColors.background(context),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border(context),
          ),
        ),
        child: Text(
          label,
          style: AppTypography.labelSmall(
            context,
            isSelected ? AppColors.primary : AppColors.textSecondary(context),
          ),
        ),
      ),
    );
  }

  Widget _buildAdvancedSearchButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: widget.onAdvancedSearch,
        icon: const Icon(Icons.auto_awesome, size: 18),
        label: const Text('Advanced Search Ranking'),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: BorderSide(color: AppColors.primary),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: EdgeInsets.symmetric(vertical: 12.h),
        ),
      ),
    );
  }
}
