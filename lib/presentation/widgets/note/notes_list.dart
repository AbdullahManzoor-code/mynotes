import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:mynotes/domain/entities/note.dart';
import 'package:mynotes/presentation/design_system/design_system.dart'
    hide NoteCard;
import 'package:mynotes/presentation/widgets/note/note_card.dart';
import 'package:mynotes/core/extensions/extensions.dart';

/// Notes list builder component
/// Handles display of notes in list or grid view with pinned/unpinned sections
class NotesList extends StatelessWidget {
  final List<Note> pinnedNotes;
  final List<Note> unpinnedNotes;
  final bool isGridView;
  final ValueChanged<Note> onNoteTap;
  final ValueChanged<Note>? onNoteDelete;
  final ValueChanged<Note>? onNotePin;
  final ValueChanged<Note>? onNoteArchive;

  const NotesList({
    super.key,
    required this.pinnedNotes,
    required this.unpinnedNotes,
    this.isGridView = false,
    required this.onNoteTap,
    this.onNoteDelete,
    this.onNotePin,
    this.onNoteArchive,
  });

  @override
  Widget build(BuildContext context) {
    if (pinnedNotes.isEmpty && unpinnedNotes.isEmpty) {
      return _buildEmptyState(context);
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Pinned notes section
          if (pinnedNotes.isNotEmpty) ...[
            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 8.h),
              child: Text(
                'Pinned',
                style: AppTypography.heading3(
                  context,
                ).copyWith(fontSize: 16.sp, fontWeight: FontWeight.w600),
              ),
            ),
            _buildNotesList(context, pinnedNotes),
            SizedBox(height: 16.h),
          ],

          // Unpinned notes section
          if (unpinnedNotes.isNotEmpty) ...[
            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 8.h),
              child: Text(
                'Notes',
                style: AppTypography.heading3(
                  context,
                ).copyWith(fontSize: 16.sp, fontWeight: FontWeight.w600),
              ),
            ),
            _buildNotesList(context, unpinnedNotes),
          ],
        ],
      ),
    );
  }

  Widget _buildNotesList(BuildContext context, List<Note> notes) {
    if (isGridView) {
      return MasonryGridView.count(
        crossAxisCount: 2,
        mainAxisSpacing: 12.w,
        crossAxisSpacing: 12.w,
        padding: EdgeInsets.symmetric(horizontal: 12.w),
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: notes.length,
        itemBuilder: (context, index) => _buildNoteCard(context, notes[index]),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: notes.length,
      itemBuilder: (context, index) => _buildNoteCard(context, notes[index]),
    );
  }

  Widget _buildNoteCard(BuildContext context, Note note) {
    return NoteCard(
      note: note,
      onTap: () => onNoteTap(note),
      onLongPress: () {},
      onEdit: () => onNoteTap(note),
      onDelete: onNoteDelete != null ? () => onNoteDelete!(note) : null,
      onPin: onNotePin != null ? () => onNotePin!(note) : null,
      onUnpin: onNotePin != null ? () => onNotePin!(note) : null,
      onArchive: onNoteArchive != null ? () => onNoteArchive!(note) : null,
      enableActions: true,
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.note_outlined,
            size: 80.r,
            color: context.theme.disabledColor,
          ),
          SizedBox(height: 16.h),
          Text(
            'No notes yet',
            style: AppTypography.heading2(
              context,
            ).copyWith(fontSize: 18.sp, color: context.theme.disabledColor),
          ),
          SizedBox(height: 8.h),
          Text(
            'Create your first note to get started',
            style: AppTypography.body2(context).copyWith(
              fontSize: 14.sp,
              color: context.theme.disabledColor.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }
}
