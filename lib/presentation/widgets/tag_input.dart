import 'package:flutter/material.dart';

/// Tag entity
class Tag {
  final int? id;
  final String name;
  final String color;
  final int count; // Number of items with this tag

  Tag({this.id, required this.name, this.color = '0xFF2196F3', this.count = 0});

  Tag copyWith({int? id, String? name, String? color, int? count}) {
    return Tag(
      id: id ?? this.id,
      name: name ?? this.name,
      color: color ?? this.color,
      count: count ?? this.count,
    );
  }
}

/// Chip for displaying a tag
class TagChip extends StatelessWidget {
  final Tag tag;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;
  final bool isSelectable;
  final bool isSelected;

  const TagChip({
    Key? key,
    required this.tag,
    this.onTap,
    this.onDelete,
    this.isSelectable = false,
    this.isSelected = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(tag.name),
      selected: isSelectable ? isSelected : false,
      onSelected: isSelectable ? (_) => onTap?.call() : null,
      onDeleted: onDelete,
      backgroundColor: Color(int.parse(tag.color)).withOpacity(0.3),
      selectedColor: Color(int.parse(tag.color)),
      labelStyle: TextStyle(
        color: isSelectable && isSelected ? Colors.white : Colors.black,
      ),
    );
  }
}

/// Tag input widget with autocomplete
class TagInput extends StatefulWidget {
  final List<Tag> selectedTags;
  final List<Tag> availableTags;
  final Function(Tag) onTagAdded;
  final Function(Tag) onTagRemoved;

  const TagInput({
    Key? key,
    required this.selectedTags,
    required this.availableTags,
    required this.onTagAdded,
    required this.onTagRemoved,
  }) : super(key: key);

  @override
  State<TagInput> createState() => _TagInputState();
}

class _TagInputState extends State<TagInput> {
  late TextEditingController _controller;
  List<Tag> _suggestions = [];
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _controller.addListener(_updateSuggestions);
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _updateSuggestions() {
    final query = _controller.text.toLowerCase();
    final selectedNames = widget.selectedTags.map((t) => t.name).toSet();

    if (query.isEmpty) {
      setState(() => _suggestions = []);
    } else {
      setState(() {
        _suggestions = widget.availableTags
            .where(
              (tag) =>
                  tag.name.toLowerCase().contains(query) &&
                  !selectedNames.contains(tag.name),
            )
            .toList();
      });
    }
  }

  void _addTag(Tag tag) {
    widget.onTagAdded(tag);
    _controller.clear();
    _updateSuggestions();
    _focusNode.requestFocus();
  }

  void _createNewTag(String name) {
    if (name.trim().isEmpty) return;

    final newTag = Tag(
      name: name.trim(),
      color: '0xFF2196F3', // Default blue color
    );

    widget.onTagAdded(newTag);
    _controller.clear();
    _updateSuggestions();
    _focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Selected tags
        if (widget.selectedTags.isNotEmpty) ...[
          Text('Selected Tags', style: Theme.of(context).textTheme.labelMedium),
          SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: widget.selectedTags
                .map(
                  (tag) => TagChip(
                    tag: tag,
                    onDelete: () => widget.onTagRemoved(tag),
                  ),
                )
                .toList(),
          ),
          SizedBox(height: 16),
        ],

        // Tag input field
        TextField(
          controller: _controller,
          focusNode: _focusNode,
          decoration: InputDecoration(
            hintText: 'Add tags... (type to search)',
            prefixIcon: Icon(Icons.local_offer),
            suffixIcon: _controller.text.isNotEmpty
                ? IconButton(
                    icon: Icon(Icons.close),
                    onPressed: () {
                      _controller.clear();
                      _updateSuggestions();
                    },
                  )
                : null,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
          onSubmitted: (value) {
            if (value.isNotEmpty && _suggestions.isEmpty) {
              _createNewTag(value);
            }
          },
        ),

        // Suggestions dropdown
        if (_suggestions.isNotEmpty)
          Container(
            margin: EdgeInsets.only(top: 8),
            decoration: BoxDecoration(
              border: Border.all(color: Theme.of(context).colorScheme.outline),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                ..._suggestions.map(
                  (tag) => InkWell(
                    onTap: () => _addTag(tag),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(child: Text(tag.name)),
                          Text(
                            '${tag.count}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                if (_controller.text.isNotEmpty &&
                    _suggestions.every(
                      (t) => t.name != _controller.text.trim(),
                    ))
                  Divider(height: 1),
                if (_controller.text.isNotEmpty &&
                    _suggestions.every(
                      (t) => t.name != _controller.text.trim(),
                    ))
                  InkWell(
                    onTap: () => _createNewTag(_controller.text),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.add, size: 20),
                          SizedBox(width: 8),
                          Text('Create "${_controller.text.trim()}"'),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),

        // Popular tags (when input is empty)
        if (_controller.text.isEmpty && widget.availableTags.isNotEmpty) ...[
          SizedBox(height: 16),
          Text('Popular Tags', style: Theme.of(context).textTheme.labelMedium),
          SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: widget.availableTags
                .take(6)
                .map((tag) => TagChip(tag: tag, onTap: () => _addTag(tag)))
                .toList(),
          ),
        ],
      ],
    );
  }
}

/// Tag filter widget
class TagFilter extends StatelessWidget {
  final List<Tag> tags;
  final List<Tag> selectedTags;
  final Function(Tag) onTagSelected;
  final Function(Tag) onTagDeselected;

  const TagFilter({
    Key? key,
    required this.tags,
    required this.selectedTags,
    required this.onTagSelected,
    required this.onTagDeselected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final selectedNames = selectedTags.map((t) => t.name).toSet();

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: tags.map((tag) {
        final isSelected = selectedNames.contains(tag.name);
        return FilterChip(
          label: Text('${tag.name} (${tag.count})'),
          selected: isSelected,
          onSelected: (_) {
            if (isSelected) {
              onTagDeselected(tag);
            } else {
              onTagSelected(tag);
            }
          },
        );
      }).toList(),
    );
  }
}
