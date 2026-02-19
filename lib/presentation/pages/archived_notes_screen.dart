import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mynotes/presentation/bloc/note/note_bloc.dart';
import 'package:mynotes/presentation/bloc/note/note_event.dart';
import 'package:mynotes/presentation/bloc/note/note_state.dart';

import '../../presentation/bloc/params/note_params.dart';
import '../../domain/entities/note.dart';
import '../design_system/design_system.dart' hide TextButton;
import '../widgets/note_card_widget.dart';
import '../../injection_container.dart' show getIt;

/// Archive notes screen showing all archived notes
class ArchivedNotesScreen extends StatelessWidget {
  final bool showAppBar;

  const ArchivedNotesScreen({super.key, this.showAppBar = true});

  @override
  Widget build(BuildContext context) {
    AppLogger.i('ArchivedNotesScreen: Building UI');
    final body = BlocBuilder<NotesBloc, NoteState>(
      builder: (context, state) {
        if (state is NoteLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is ArchivedNotesLoaded) {
          final archivedNotes = state.notes;
          AppLogger.i(
            'ArchivedNotesScreen: Loaded ${archivedNotes.length} archived notes',
          );

          if (archivedNotes.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.archive_outlined,
                    size: 64.w,
                    color: AppColors.textSecondary(context).withOpacity(0.3),
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    'No archived notes',
                    style: AppTypography.bodyLarge(
                      context,
                      AppColors.textPrimary(context),
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'Notes you archive will appear here',
                    style: AppTypography.caption(
                      context,
                      AppColors.textSecondary(context),
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            itemCount: archivedNotes.length,
            itemBuilder: (context, index) {
              final note = archivedNotes[index];
              return Padding(
                padding: EdgeInsets.only(bottom: 12.h),
                child: Dismissible(
                  key: Key('archive_${note.id}'),
                  direction: DismissDirection.horizontal,
                  background: _buildDismissBackground(
                    alignment: Alignment.centerLeft,
                    color: AppColors.primary,
                    icon: Icons.unarchive_outlined,
                  ),
                  secondaryBackground: _buildDismissBackground(
                    alignment: Alignment.centerRight,
                    color: AppColors.errorColor,
                    icon: Icons.delete_outline,
                  ),
                  onDismissed: (direction) {
                    AppLogger.i(
                      'ArchivedNotesScreen: Note $index dismissed in direction $direction',
                    );
                    if (direction == DismissDirection.startToEnd) {
                      _unarchiveNote(context, note);
                    } else {
                      _deleteNoteForever(context, note);
                    }
                  },
                  child: NoteCardWidget(
                    note: note,
                    isGridView: false,
                    onTap: () {
                      AppLogger.i(
                        'ArchivedNotesScreen: Note $index tapped - ${note.id}',
                      );
                      Navigator.pushNamed(
                        context,
                        '/notes/editor',
                        arguments: {'note': note},
                      );
                    },
                    onLongPress: () {
                      AppLogger.i(
                        'ArchivedNotesScreen: Note $index long-pressed - ${note.id}',
                      );
                      _showArchiveContextMenu(context, note);
                    },
                  ),
                ),
              );
            },
          );
        }

        if (state is NoteError) {
          AppLogger.e('ArchivedNotesScreen: Error state - ${state.message}');
          return Center(
            child: Padding(
              padding: EdgeInsets.all(20.r),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: AppColors.errorColor),
                  SizedBox(height: 8.h),
                  Text(state.message, textAlign: TextAlign.center),
                ],
              ),
            ),
          );
        }

        // If we're not in ArchivedNotesLoaded, it might be the first time opening the tab.
        // We can trigger the load here if we want, but it's better to do it in the parent.
        return const Center(child: CircularProgressIndicator());
      },
    );

    if (!showAppBar) return body;

    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(
        title: Text(
          'Archived Notes',
          style: AppTypography.heading2(
            context,
            AppColors.textPrimary(context),
          ),
        ),
        elevation: 0,
        backgroundColor: AppColors.background(context),
        iconTheme: IconThemeData(color: AppColors.textPrimary(context)),
      ),
      body: body,
    );
  }

  Widget _buildDismissBackground({
    required Alignment alignment,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      alignment: alignment,
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Icon(icon, color: Colors.white),
    );
  }

  void _unarchiveNote(BuildContext context, Note note) {
    AppLogger.i('ArchivedNotesScreen: Unarchiving note - ${note.id}');
    context.read<NotesBloc>().add(RestoreArchivedNoteEvent(note.id));

    getIt<GlobalUiService>().showSuccess(
      'Note unarchived',
      actionLabel: 'Undo',
      onActionPressed: () {
        AppLogger.i(
          'ArchivedNotesScreen: Undo unarchive pressed for ${note.id}',
        );
        context.read<NotesBloc>().add(
          ToggleArchiveNoteEvent(
            NoteParams.fromNote(note).copyWith(isArchived: true),
          ),
        );
      },
    );
  }

  void _deleteNoteForever(BuildContext context, Note note) {
    AppLogger.i(
      'ArchivedNotesScreen: Showing delete forever confirmation for ${note.id}',
    );
    showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        title: Text(
          'Delete permanently?',
          style: AppTypography.heading3(dialogContext),
        ),
        content: Text(
          'This action cannot be undone. The note and all its attachments will be deleted.',
          style: AppTypography.bodyMedium(dialogContext),
        ),
        actions: [
          TextButton(
            onPressed: () {
              AppLogger.i('ArchivedNotesScreen: Delete forever cancelled');
              Navigator.pop(dialogContext, false);
            },
            child: Text('Cancel', style: AppTypography.button(dialogContext)),
          ),
          TextButton(
            onPressed: () {
              AppLogger.i('ArchivedNotesScreen: Delete forever confirmed');
              Navigator.pop(dialogContext, true);
            },
            child: Text(
              'Delete',
              style: AppTypography.button(
                dialogContext,
              ).copyWith(color: AppColors.errorColor),
            ),
          ),
        ],
      ),
    ).then((confirmed) {
      if (confirmed ?? false) {
        context.read<NotesBloc>().add(DeleteNoteEvent(note.id));
        getIt<GlobalUiService>().showSuccess('Note deleted permanently');
      }
    });
  }

  void _showArchiveContextMenu(BuildContext context, Note note) {
    AppLogger.i('ArchivedNotesScreen: Showing context menu for ${note.id}');
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (modalContext) => Container(
        decoration: BoxDecoration(
          color: AppColors.surface(context),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(
                  Icons.unarchive_outlined,
                  color: AppColors.textPrimary(context),
                ),
                title: Text(
                  'Restore Note',
                  style: AppTypography.bodyLarge(
                    context,
                    AppColors.textPrimary(context),
                  ),
                ),
                onTap: () {
                  AppLogger.i(
                    'ArchivedNotesScreen: Restore from context menu - ${note.id}',
                  );
                  Navigator.pop(modalContext);
                  _unarchiveNote(context, note);
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.delete_outline,
                  color: AppColors.errorColor,
                ),
                title: Text(
                  'Delete Forever',
                  style: AppTypography.bodyLarge(context, AppColors.errorColor),
                ),
                onTap: () {
                  AppLogger.i(
                    'ArchivedNotesScreen: Delete forever from context menu - ${note.id}',
                  );
                  Navigator.pop(modalContext);
                  _deleteNoteForever(context, note);
                },
              ),
              SizedBox(height: 16.h),
            ],
          ),
        ),
      ),
    );
  }
}


