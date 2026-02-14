import 'package:flutter/material.dart';
import 'package:mynotes/presentation/design_system/app_colors.dart';
import 'package:mynotes/presentation/design_system/app_typography.dart';

/// Note tags input and display widget
class NoteTagsInput extends StatefulWidget {
  final List<String> initialTags;
  final Function(List<String>) onTagsChanged;
  final int maxTags;
  final String hintText;
  final bool readOnly;

  const NoteTagsInput({
    Key? key,
    required this.initialTags,
    required this.onTagsChanged,
    this.maxTags = 10,
    this.hintText = 'Add tags (e.g., work, personal)',
    this.readOnly = false,
  }) : super(key: key);

  @override
  State<NoteTagsInput> createState() => _NoteTagsInputState();
}

class _NoteTagsInputState extends State<NoteTagsInput> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  late List<String> _tags;

  @override
  void initState() {
    super.initState();
    _tags = List.from(widget.initialTags);
    _controller = TextEditingController();
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _addTag(String tag) {
    if (tag.trim().isEmpty || _tags.length >= widget.maxTags) return;

    final cleanTag = tag.trim().replaceAll('#', '').toLowerCase();
    if (!_tags.contains(cleanTag)) {
      setState(() => _tags.add(cleanTag));
      widget.onTagsChanged(_tags);
      _controller.clear();
    }
  }

  void _removeTag(String tag) {
    setState(() => _tags.remove(tag));
    widget.onTagsChanged(_tags);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Tag input field (hidden if read-only)
        if (!widget.readOnly)
          TextFormField(
            controller: _controller,
            focusNode: _focusNode,
            decoration: InputDecoration(
              hintText: widget.hintText,
              prefixIcon: const Icon(Icons.local_offer_outlined),
              suffixIcon: _controller.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.add_circle),
                      onPressed: () => _addTag(_controller.text),
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
            onChanged: (val) => setState(() {}),
            onFieldSubmitted: (val) {
              _addTag(val);
              _focusNode.requestFocus();
            },
          ),

        // Display tags
        if (_tags.isNotEmpty) ...[
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _tags.map((tag) {
              return Chip(
                label: Text(
                  '#$tag',
                  style: AppTypography.bodySmall(
                    context,
                    AppColors.primaryColor,
                  ),
                ),
                onDeleted: widget.readOnly ? null : () => _removeTag(tag),
                backgroundColor: AppColors.primaryColor.withOpacity(0.1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(
                    color: AppColors.primaryColor.withOpacity(0.3),
                  ),
                ),
              );
            }).toList(),
          ),

          // Tag counter
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              '${_tags.length}/${widget.maxTags} tags',
              style: AppTypography.caption(
                context,
                isDark ? Colors.grey.shade400 : Colors.grey.shade600,
              ),
            ),
          ),
        ] else if (!widget.readOnly)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              'No tags added yet',
              style: AppTypography.caption(
                context,
                isDark ? Colors.grey.shade500 : Colors.grey.shade500,
              ),
            ),
          ),
      ],
    );
  }
}

/// Display-only tags widget (for viewing tags without editing)
class NoteTagsDisplay extends StatelessWidget {
  final List<String> tags;
  final void Function(String tag)? onTagTap;

  const NoteTagsDisplay({Key? key, required this.tags, this.onTagTap})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (tags.isEmpty) return const SizedBox.shrink();

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: tags.map((tag) {
        return GestureDetector(
          onTap: () => onTagTap?.call(tag),
          child: Chip(
            label: Text(
              '#$tag',
              style: AppTypography.bodySmall(context, AppColors.primaryColor),
            ),
            backgroundColor: AppColors.primaryColor.withOpacity(0.1),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(color: AppColors.primaryColor.withOpacity(0.3)),
            ),
          ),
        );
      }).toList(),
    );
  }
}
