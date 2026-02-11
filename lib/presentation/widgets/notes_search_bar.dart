import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../domain/entities/note.dart';
import '../design_system/design_system.dart';

/// Enhanced Search Bar for Notes with advanced filtering (ORG-003)
/// Provides real-time search with tag, color, and content filtering
class NotesSearchBar extends StatefulWidget {
  final String? initialSearchQuery;
  final List<String>? initialSelectedTags;
  final List<NoteColor>? initialSelectedColors;
  final bool initialFilterPinned;
  final bool initialFilterWithMedia;
  final Function(String) onSearchChanged;
  final Function(List<String>)? onTagsSelected;
  final Function(List<NoteColor>)? onColorsSelected;
  final Function(bool)? onPinnedFilterChanged;
  final Function(bool)? onMediaFilterChanged;
  final VoidCallback? onAdvancedSearch;
  final bool showAdvancedOptions;

  const NotesSearchBar({
    super.key,
    this.initialSearchQuery,
    this.initialSelectedTags,
    this.initialSelectedColors,
    this.initialFilterPinned = false,
    this.initialFilterWithMedia = false,
    required this.onSearchChanged,
    this.onTagsSelected,
    this.onColorsSelected,
    this.onPinnedFilterChanged,
    this.onMediaFilterChanged,
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

  bool _isExpanded = false;
  bool _showClearButton = false;
  Timer? _debounceTimer;
  List<String> _selectedTags = [];
  List<NoteColor> _selectedColors = [];
  bool _filterPinned = false;
  bool _filterWithMedia = false;

  // Sample tags (in real app, these would come from notes data)
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
    _controller = TextEditingController(text: widget.initialSearchQuery);
    _focusNode = FocusNode();
    _showClearButton = _controller.text.isNotEmpty;

    _selectedTags = List.from(widget.initialSelectedTags ?? []);
    _selectedColors = List.from(widget.initialSelectedColors ?? []);
    _filterPinned = widget.initialFilterPinned;
    _filterWithMedia = widget.initialFilterWithMedia;

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _expandAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _controller.addListener(_onSearchTextChanged);
    _focusNode.addListener(_onFocusChanged);
  }

  @override
  void didUpdateWidget(NotesSearchBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialSearchQuery != oldWidget.initialSearchQuery &&
        widget.initialSearchQuery != _controller.text) {
      _controller.text = widget.initialSearchQuery ?? '';
    }
    if (widget.initialSelectedTags != oldWidget.initialSelectedTags) {
      _selectedTags = List.from(widget.initialSelectedTags ?? []);
    }
    if (widget.initialSelectedColors != oldWidget.initialSelectedColors) {
      _selectedColors = List.from(widget.initialSelectedColors ?? []);
    }
    if (widget.initialFilterPinned != oldWidget.initialFilterPinned) {
      _filterPinned = widget.initialFilterPinned;
    }
    if (widget.initialFilterWithMedia != oldWidget.initialFilterWithMedia) {
      _filterWithMedia = widget.initialFilterWithMedia;
    }
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
    setState(() {
      _showClearButton = query.isNotEmpty;
    });

    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      widget.onSearchChanged(query);
    });
  }

  void _onFocusChanged() {
    if (_focusNode.hasFocus && widget.showAdvancedOptions) {
      _expandSearchOptions();
    }
  }

  void _expandSearchOptions() {
    if (!_isExpanded) {
      setState(() {
        _isExpanded = true;
      });
      _animationController.forward();
    }
  }

  void _collapseSearchOptions() {
    if (_isExpanded) {
      setState(() {
        _isExpanded = false;
      });
      _animationController.reverse();
      _focusNode.unfocus();
    }
  }

  void _clearSearch() {
    _controller.clear();
    setState(() {
      _selectedTags.clear();
      _selectedColors.clear();
      _filterPinned = false;
      _filterWithMedia = false;
    });
    widget.onSearchChanged('');
    widget.onTagsSelected?.call([]);
    widget.onColorsSelected?.call([]);
    HapticFeedback.lightImpact();
  }

  void _toggleTag(String tag) {
    setState(() {
      if (_selectedTags.contains(tag)) {
        _selectedTags.remove(tag);
      } else {
        _selectedTags.add(tag);
      }
    });
    widget.onTagsSelected?.call(_selectedTags);
    HapticFeedback.lightImpact();
  }

  void _toggleColor(NoteColor color) {
    setState(() {
      if (_selectedColors.contains(color)) {
        _selectedColors.remove(color);
      } else {
        _selectedColors.add(color);
      }
    });
    widget.onColorsSelected?.call(_selectedColors);
    HapticFeedback.lightImpact();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (!_focusNode.hasFocus && _isExpanded) {
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
            _buildSearchInput(),

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
                child: _buildAdvancedOptions(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchInput() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(
            Icons.search,
            color: _focusNode.hasFocus
                ? AppColors.primary
                : AppColors.textSecondary(context),
            size: 20,
          ),
          const SizedBox(width: 12),
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
                if (_isExpanded && widget.showAdvancedOptions) {
                  _collapseSearchOptions();
                }
              },
            ),
          ),
          if (_showClearButton) ...[
            const SizedBox(width: 8),
            GestureDetector(
              onTap: _clearSearch,
              child: Icon(
                Icons.clear,
                color: AppColors.textSecondary(context),
                size: 20,
              ),
            ),
          ],
          if (widget.showAdvancedOptions && _isExpanded) ...[
            const SizedBox(width: 8),
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

  Widget _buildAdvancedOptions() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // General Filters (Pinned, Media)
          _buildGeneralFilters(),

          const SizedBox(height: 16),

          // Divider
          Container(
            height: 1,
            color: AppColors.border(context),
            margin: const EdgeInsets.only(bottom: 16),
          ),

          // Filter by Tags
          _buildTagFilters(),

          const SizedBox(height: 16),

          // Filter by Colors
          _buildColorFilters(),

          const SizedBox(height: 16),

          // Advanced Search Button
          if (widget.onAdvancedSearch != null) _buildAdvancedSearchButton(),
        ],
      ),
    );
  }

  Widget _buildTagFilters() {
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
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _availableTags.map((tag) {
            final isSelected = _selectedTags.contains(tag);
            return GestureDetector(
              onTap: () => _toggleTag(tag),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
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

  Widget _buildColorFilters() {
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
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _availableColors.map((noteColor) {
            final isSelected = _selectedColors.contains(noteColor);
            final colorValue = Color(
              noteColor.getColorValue(
                Theme.of(context).brightness == Brightness.dark,
              ),
            );
            return GestureDetector(
              onTap: () => _toggleColor(noteColor),
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
                    ? const Icon(Icons.check, color: Colors.white, size: 16)
                    : null,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildGeneralFilters() {
    return Row(
      children: [
        _buildFilterChip(
          label: 'Pinned Only',
          isSelected: _filterPinned,
          onTap: () {
            setState(() => _filterPinned = !_filterPinned);
            widget.onPinnedFilterChanged?.call(_filterPinned);
            HapticFeedback.lightImpact();
          },
        ),
        SizedBox(width: 8.w),
        _buildFilterChip(
          label: 'With Media',
          isSelected: _filterWithMedia,
          onTap: () {
            setState(() => _filterWithMedia = !_filterWithMedia);
            widget.onMediaFilterChanged?.call(_filterWithMedia);
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
          borderRadius: BorderRadius.circular(16.r),
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
      child: TextButton.icon(
        onPressed: widget.onAdvancedSearch,
        icon: Icon(Icons.tune, size: 16, color: AppColors.primary),
        label: Text(
          'Advanced Search Options',
          style: AppTypography.labelMedium(context, AppColors.primary),
        ),
        style: TextButton.styleFrom(
          backgroundColor: AppColors.primary.withOpacity(0.05),
          foregroundColor: AppColors.primary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }
}
