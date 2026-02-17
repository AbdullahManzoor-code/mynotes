import 'package:flutter/material.dart';
import 'package:mynotes/core/extensions/context_extensions.dart';
import 'package:mynotes/presentation/design_system/design_system.dart';
import 'package:mynotes/domain/entities/note.dart';
import 'package:mynotes/core/constants/app_strings.dart';

/// Unified note header widget with title, color picker, and tags
/// Handles title input and visual customization for notes
class NoteHeader extends StatefulWidget {
  final Note note;
  final TextEditingController titleController;
  final ValueChanged<NoteColor> onColorChanged;
  final VoidCallback onAddTag;
  final ValueChanged<int> onRemoveTag;
  final bool isEditing;

  const NoteHeader({
    super.key,
    required this.note,
    required this.titleController,
    required this.onColorChanged,
    required this.onAddTag,
    required this.onRemoveTag,
    this.isEditing = true,
  });

  @override
  State<NoteHeader> createState() => _NoteHeaderState();
}

class _NoteHeaderState extends State<NoteHeader> {
  late final Note note;
  late final TextEditingController titleController;

  @override
  void initState() {
    super.initState();
    note = widget.note;
    titleController = widget.titleController;
  }

  @override
  void dispose() {
    titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title input field
        _buildTitleField(context),
        SizedBox(height: 16.h),
        // Color and tag row
        _buildColorAndTagsRow(context),
        SizedBox(height: 12.h),
        // Tags display
        if (note.tags.isNotEmpty) _buildTagsDisplay(context),
      ],
    );
  }

  Widget _buildTitleField(BuildContext context) {
    return TextFormField(
      controller: titleController,
      readOnly: !widget.isEditing,
      maxLines: null,
      style: AppTypography.heading2(
        context,
      ).copyWith(fontSize: 24.sp, fontWeight: FontWeight.bold),
      decoration: InputDecoration(
        hintText: AppStrings.untitledNote,
        hintStyle: AppTypography.heading2(
          context,
        ).copyWith(fontSize: 24.sp, color: Colors.grey.shade400),
        border: InputBorder.none,
        contentPadding: EdgeInsets.zero,
      ),
    );
  }

  Widget _buildColorAndTagsRow(BuildContext context) {
    return Row(
      children: [
        // Color picker
        _buildColorPicker(context),
        SizedBox(width: 16.w),
        // Add tag button
        if (widget.isEditing)
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: widget.onAddTag,
              borderRadius: BorderRadius.circular(20.r),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                decoration: BoxDecoration(
                  border: Border.all(color: context.primaryColor),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.add, size: 16.r, color: context.primaryColor),
                    SizedBox(width: 4.w),
                    Text(
                      AppStrings.addTag,
                      style: AppTypography.caption(
                        context,
                      ).copyWith(color: context.primaryColor, fontSize: 12.sp),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildColorPicker(BuildContext context) {
    return PopupMenuButton<NoteColor>(
      onSelected: widget.onColorChanged,
      itemBuilder: (context) => NoteColor.values.map((color) {
        return PopupMenuItem(
          value: color,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 20.r,
                height: 20.r,
                decoration: BoxDecoration(
                  color: _getColorValue(color),
                  shape: BoxShape.circle,
                  border: note.color == color
                      ? Border.all(color: Colors.black, width: 2)
                      : null,
                ),
              ),
              SizedBox(width: 8.w),
              Text(_getColorLabel(color)),
            ],
          ),
        );
      }).toList(),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      child: Container(
        width: 40.r,
        height: 40.r,
        decoration: BoxDecoration(
          color: _getColorValue(note.color),
          shape: BoxShape.circle,
          border: Border.all(color: context.theme.dividerColor, width: 1),
        ),
        child: Icon(Icons.palette, size: 20.r, color: Colors.white),
      ),
    );
  }

  Widget _buildTagsDisplay(BuildContext context) {
    return Wrap(
      spacing: 8.w,
      runSpacing: 8.h,
      children: List.generate(
        note.tags.length,
        (index) => Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
          decoration: BoxDecoration(
            color: context.theme.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(
              color: context.theme.primaryColor.withOpacity(0.3),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                note.tags[index],
                style: AppTypography.caption(
                  context,
                ).copyWith(fontSize: 12.sp, color: context.primaryColor),
              ),
              if (widget.isEditing) ...[
                SizedBox(width: 6.w),
                GestureDetector(
                  onTap: () => widget.onRemoveTag(index),
                  child: Icon(
                    Icons.close,
                    size: 14.r,
                    color: context.primaryColor,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Color _getColorValue(NoteColor color) {
    const colorMap = {
      NoteColor.defaultColor: Colors.blue,
      NoteColor.red: Colors.red,
      NoteColor.pink: Colors.pink,
      NoteColor.purple: Colors.purple,
      NoteColor.blue: Colors.blue,
      NoteColor.green: Colors.green,
      NoteColor.yellow: Colors.orange,
      NoteColor.orange: Colors.deepOrange,
      NoteColor.brown: Colors.brown,
      NoteColor.grey: Colors.grey,
    };
    return colorMap[color] ?? Colors.blue;
  }

  String _getColorLabel(NoteColor color) {
    const labelMap = {
      NoteColor.defaultColor: 'Default',
      NoteColor.red: 'Red',
      NoteColor.pink: 'Pink',
      NoteColor.purple: 'Purple',
      NoteColor.blue: 'Blue',
      NoteColor.green: 'Green',
      NoteColor.yellow: 'Yellow',
      NoteColor.orange: 'Orange',
      NoteColor.brown: 'Brown',
      NoteColor.grey: 'Grey',
    };
    return labelMap[color] ?? 'Default';
  }
}
