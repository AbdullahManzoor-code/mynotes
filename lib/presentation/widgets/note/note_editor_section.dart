import 'package:flutter/material.dart';
import 'package:mynotes/core/extensions/context_extensions.dart';
import 'package:mynotes/presentation/design_system/design_system.dart';
import 'package:mynotes/core/constants/app_strings.dart';

/// Unified note editor section with formatting toolbar
/// Provides text editing capabilities with formatting options
class NoteEditorSection extends StatefulWidget {
  final TextEditingController contentController;
  final VoidCallback? onBold;
  final VoidCallback? onItalic;
  final VoidCallback? onUnderline;
  final VoidCallback? onBulletPoint;
  final VoidCallback? onNumberPoint;
  final bool isEditing;
  final ValueChanged<String>? onContentChanged;

  const NoteEditorSection({
    super.key,
    required this.contentController,
    this.onBold,
    this.onItalic,
    this.onUnderline,
    this.onBulletPoint,
    this.onNumberPoint,
    this.isEditing = true,
    this.onContentChanged,
  });

  @override
  State<NoteEditorSection> createState() => _NoteEditorSectionState();
}

class _NoteEditorSectionState extends State<NoteEditorSection> {
  late final TextEditingController contentController;

  @override
  void initState() {
    super.initState();
    contentController = widget.contentController;
  }

  @override
  void dispose() {
    contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Formatting toolbar
        if (widget.isEditing) _buildFormattingToolbar(context),
        if (widget.isEditing) SizedBox(height: 12.h),
        // Content editor
        _buildContentEditor(context),
      ],
    );
  }

  Widget _buildFormattingToolbar(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildToolbarButton(
            icon: Icons.format_bold,
            label: AppStrings.bold,
            onTap: widget.onBold,
            context: context,
          ),
          SizedBox(width: 8.w),
          _buildToolbarButton(
            icon: Icons.format_italic,
            label: AppStrings.italic,
            onTap: widget.onItalic,
            context: context,
          ),
          SizedBox(width: 8.w),
          _buildToolbarButton(
            icon: Icons.format_underlined,
            label: AppStrings.underline,
            onTap: widget.onUnderline,
            context: context,
          ),
          SizedBox(width: 8.w),
          _buildToolbarButton(
            icon: Icons.format_list_bulleted,
            label: AppStrings.bulletPoint,
            onTap: widget.onBulletPoint,
            context: context,
          ),
          SizedBox(width: 8.w),
          _buildToolbarButton(
            icon: Icons.format_list_numbered,
            label: AppStrings.numberedPoint,
            onTap: widget.onNumberPoint,
            context: context,
          ),
        ],
      ),
    );
  }

  Widget _buildToolbarButton({
    required IconData icon,
    required String label,
    required VoidCallback? onTap,
    required BuildContext context,
  }) {
    return Tooltip(
      message: label,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8.r),
          child: Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: context.theme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(icon, size: 20.r, color: context.primaryColor),
          ),
        ),
      ),
    );
  }

  Widget _buildContentEditor(BuildContext context) {
    return TextFormField(
      controller: contentController,
      readOnly: !widget.isEditing,
      maxLines: null,
      minLines: 8,
      textAlignVertical: TextAlignVertical.top,
      style: AppTypography.body1(context).copyWith(fontSize: 14.sp),
      onChanged: widget.onContentChanged,
      decoration: InputDecoration(
        hintText: AppStrings.noteContent,
        hintStyle: AppTypography.body1(
          context,
        ).copyWith(fontSize: 14.sp, color: Colors.grey.shade400),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: context.theme.dividerColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: context.theme.dividerColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: context.primaryColor, width: 2),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: context.theme.dividerColor),
        ),
        contentPadding: EdgeInsets.all(16.w),
        filled: widget.isEditing,
        fillColor: widget.isEditing
            ? context.theme.primaryColor.withOpacity(0.02)
            : Colors.transparent,
      ),
    );
  }
}
