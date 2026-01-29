import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../design_system/design_system.dart';

/// Enhanced Search Bar for Notes with advanced filtering (ORG-003)
/// Provides real-time search with tag, color, and content filtering
class NotesSearchBar extends StatefulWidget {
  final String? initialQuery;
  final Function(String) onSearchChanged;
  final Function(List<String>)? onTagsSelected;
  final Function(List<Color>)? onColorsSelected;
  final VoidCallback? onAdvancedSearch;
  final bool showAdvancedOptions;

  const NotesSearchBar({
    super.key,
    this.initialQuery,
    required this.onSearchChanged,
    this.onTagsSelected,
    this.onColorsSelected,
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
  final List<String> _selectedTags = [];
  final List<Color> _selectedColors = [];

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

  // Sample colors for filtering
  final List<Color> _availableColors = [
    Colors.blue,
    Colors.green,
    Colors.orange,
    Colors.red,
    Colors.purple,
    Colors.teal,
    Colors.pink,
    Colors.amber,
  ];

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialQuery);
    _focusNode = FocusNode();
    _showClearButton = _controller.text.isNotEmpty;

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
  void dispose() {
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
    widget.onSearchChanged(query);
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

  void _toggleColor(Color color) {
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
          children: _availableColors.map((color) {
            final isSelected = _selectedColors.contains(color);
            return GestureDetector(
              onTap: () => _toggleColor(color),
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: color,
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
