import 'package:flutter/material.dart';
import 'package:mynotes/presentation/design_system/design_system.dart';
import 'package:mynotes/domain/entities/note.dart';
import 'package:mynotes/domain/entities/media_item.dart';
import 'package:mynotes/core/extensions/extensions.dart';
import 'package:mynotes/core/constants/app_strings.dart';

/// Unified note card widget with responsive design
/// Displays note with title, preview, metadata, and actions
class NoteCard extends StatefulWidget {
  final Note note;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onArchive;
  final VoidCallback? onPin;
  final VoidCallback? onUnpin;
  final bool isSelected;
  final bool enableActions;

  const NoteCard({
    super.key,
    required this.note,
    required this.onTap,
    required this.onLongPress,
    this.onEdit,
    this.onDelete,
    this.onArchive,
    this.onPin,
    this.onUnpin,
    this.isSelected = false,
    this.enableActions = true,
  });

  @override
  State<NoteCard> createState() => _NoteCardState();
}

class _NoteCardState extends State<NoteCard> {
  late final Note note;

  @override
  void initState() {
    super.initState();
    note = widget.note;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onLongPress: widget.onLongPress,
      child: Card(
        margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        elevation: widget.isSelected ? 8 : 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        color: _getNoteColor(),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.r),
            border: widget.isSelected
                ? Border.all(color: context.primaryColor, width: 2)
                : null,
          ),
          child: Row(
            children: [
              // Color bar on left edge (4px)
              _buildColorBar(context),
              // Main card content
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(12.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Header with title and actions
                      _buildHeader(context),
                      SizedBox(height: 8.h),
                      // Content preview
                      _buildContentPreview(context),
                      SizedBox(height: 8.h),
                      // Media indicators
                      if (_hasMedia()) ...[
                        _buildMediaIndicators(context),
                        SizedBox(height: 8.h),
                      ],
                      // Metadata and footer
                      _buildFooter(context),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        // Pin icon indicator
        if (note.isPinned)
          Padding(
            padding: EdgeInsets.only(right: 4.w),
            child: Icon(
              Icons.push_pin,
              size: 16.r,
              color: context.primaryColor,
            ),
          ),
        // Title
        Expanded(
          child: Text(
            note.title.isEmpty ? AppStrings.untitledNote : note.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.heading3(
              context,
            ).copyWith(fontWeight: FontWeight.w600, fontSize: 16.sp),
          ),
        ),
        SizedBox(width: 8.w),
        // Top right icons: alarm and menu
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Alarm icon if note has active reminder
            if (_hasActiveAlarm())
              Padding(
                padding: EdgeInsets.only(right: 4.w),
                child: Stack(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 16.r,
                      color: context.theme.colorScheme.error,
                    ),
                    Positioned(
                      top: -2.r,
                      right: -2.r,
                      child: Container(
                        width: 6.r,
                        height: 6.r,
                        decoration: BoxDecoration(
                          color: context.theme.colorScheme.error,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            // Menu button
            if (widget.enableActions &&
                (widget.onEdit != null || widget.onDelete != null))
              PopupMenuButton(
                itemBuilder: (context) => [
                  if (widget.onEdit != null)
                    PopupMenuItem(
                      onTap: widget.onEdit,
                      child: Text(AppStrings.edit),
                    ),
                  if (widget.onPin != null && !note.isPinned)
                    PopupMenuItem(
                      onTap: widget.onPin,
                      child: Text(AppStrings.pinNote),
                    ),
                  if (widget.onUnpin != null && note.isPinned)
                    PopupMenuItem(
                      onTap: widget.onUnpin,
                      child: Text(AppStrings.unpinNote),
                    ),
                  if (widget.onArchive != null)
                    PopupMenuItem(
                      onTap: widget.onArchive,
                      child: Text(
                        note.isArchived
                            ? AppStrings.unarchiveNote
                            : AppStrings.archiveNote,
                      ),
                    ),
                  if (widget.onDelete != null)
                    PopupMenuItem(
                      onTap: widget.onDelete,
                      child: Text(
                        AppStrings.deleteNote,
                        style: TextStyle(color: context.errorColor),
                      ),
                    ),
                ],
                padding: EdgeInsets.zero,
                icon: Icon(Icons.more_vert, size: 20.r),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildContentPreview(BuildContext context) {
    final preview = note.content.isEmpty
        ? AppStrings.noteContent
        : note.content.replaceAll('\n', ' ').length > 100
        ? '${note.content.substring(0, 100)}...'
        : note.content;

    return Text(
      preview,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: AppTypography.body2(context).copyWith(
        fontSize: 14.sp,
        color: context.theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    final tagsToShow = note.tags.take(3).toList();
    final remainingTags = note.tags.length > 3 ? note.tags.length - 3 : 0;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Tags and labels
        Expanded(
          child: Wrap(
            spacing: 4.w,
            runSpacing: 4.h,
            children: [
              ...tagsToShow.map((tag) {
                return Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: context.theme.primaryColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Text(
                    tag,
                    style: AppTypography.caption(
                      context,
                    ).copyWith(fontSize: 11.sp, color: context.primaryColor),
                  ),
                );
              }),
              // "+X more" indicator for remaining tags
              if (remainingTags > 0)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: context.theme.primaryColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Text(
                    '+$remainingTags more',
                    style: AppTypography.caption(
                      context,
                    ).copyWith(fontSize: 11.sp, color: context.primaryColor),
                  ),
                ),
            ],
          ),
        ),
        // Modified date
        Padding(
          padding: EdgeInsets.only(left: 8.w),
          child: Text(
            note.updatedAt.timeAgo(),
            style: AppTypography.caption(
              context,
            ).copyWith(fontSize: 11.sp, color: Colors.grey.shade600),
          ),
        ),
      ],
    );
  }

  Color _getNoteColor() {
    final colorMap = {
      NoteColor.defaultColor: Colors.white,
      NoteColor.red: Colors.red.shade50,
      NoteColor.pink: Colors.pink.shade50,
      NoteColor.purple: Colors.purple.shade50,
      NoteColor.blue: Colors.blue.shade50,
      NoteColor.green: Colors.green.shade50,
      NoteColor.yellow: Colors.yellow.shade50,
      NoteColor.orange: Colors.orange.shade50,
      NoteColor.brown: Colors.brown.shade50,
      NoteColor.grey: Colors.grey.shade100,
    };
    return colorMap[note.color] ?? Colors.white;
  }

  Color _getColorBarColor() {
    final colorMap = {
      NoteColor.defaultColor: Colors.grey.shade400,
      NoteColor.red: Colors.red,
      NoteColor.pink: Colors.pink,
      NoteColor.purple: Colors.purple,
      NoteColor.blue: Colors.blue,
      NoteColor.green: Colors.green,
      NoteColor.yellow: Colors.amber,
      NoteColor.orange: Colors.orange,
      NoteColor.brown: Colors.brown,
      NoteColor.grey: Colors.grey,
    };
    return colorMap[note.color] ?? Colors.grey.shade400;
  }

  Widget _buildColorBar(BuildContext context) {
    return Container(
      width: 4.w,
      decoration: BoxDecoration(
        color: _getColorBarColor(),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(12.r),
          bottomLeft: Radius.circular(12.r),
        ),
      ),
    );
  }

  bool _hasMedia() {
    return note.media.isNotEmpty;
  }

  bool _hasActiveAlarm() {
    return note.alarms != null && note.alarms!.isNotEmpty;
  }

  Widget _buildMediaIndicators(BuildContext context) {
    final imageCount = note.media
        .where((m) => m.type == MediaType.image)
        .length;
    final audioCount = note.media
        .where((m) => m.type == MediaType.audio)
        .length;
    final videoCount = note.media
        .where((m) => m.type == MediaType.video)
        .length;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          if (imageCount > 0) ...[
            Icon(Icons.image, size: 14.r, color: Colors.grey.shade600),
            SizedBox(width: 2.w),
            Text(
              '$imageCount image${imageCount > 1 ? 's' : ''}',
              style: AppTypography.caption(
                context,
              ).copyWith(fontSize: 11.sp, color: Colors.grey.shade600),
            ),
            SizedBox(width: 12.w),
          ],
          if (audioCount > 0) ...[
            Icon(Icons.mic, size: 14.r, color: Colors.grey.shade600),
            SizedBox(width: 2.w),
            Text(
              '$audioCount audio',
              style: AppTypography.caption(
                context,
              ).copyWith(fontSize: 11.sp, color: Colors.grey.shade600),
            ),
            SizedBox(width: 12.w),
          ],
          if (videoCount > 0) ...[
            Icon(Icons.videocam, size: 14.r, color: Colors.grey.shade600),
            SizedBox(width: 2.w),
            Text(
              '$videoCount video${videoCount > 1 ? 's' : ''}',
              style: AppTypography.caption(
                context,
              ).copyWith(fontSize: 11.sp, color: Colors.grey.shade600),
            ),
          ],
        ],
      ),
    );
  }
}
