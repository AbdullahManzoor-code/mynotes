import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../presentation/bloc/note_bloc.dart';
import '../../presentation/bloc/note_event.dart';
import '../../presentation/bloc/note_state.dart';
import '../../domain/entities/note.dart';
import '../design_system/design_system.dart';

/// Archive notes screen showing all archived notes
class ArchivedNotesScreen extends StatefulWidget {
  const ArchivedNotesScreen({Key? key}) : super(key: key);

  @override
  State<ArchivedNotesScreen> createState() => _ArchivedNotesScreenState();
}

class _ArchivedNotesScreenState extends State<ArchivedNotesScreen> {
  late List<Note> _archivedNotes;

  @override
  void initState() {
    super.initState();
    _archivedNotes = [];
  }

  void _unarchiveNote(Note note) {
    context.read<NotesBloc>().add(
      UpdateNoteEvent(note.copyWith(isArchived: false)),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Note unarchived'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            context.read<NotesBloc>().add(
              UpdateNoteEvent(note.copyWith(isArchived: true)),
            );
          },
        ),
      ),
    );
  }

  void _deleteNoteForever(Note note) {
    showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Delete permanently?'),
        content: const Text(
          'This action cannot be undone. The note and all its attachments will be deleted.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    ).then((confirmed) {
      if (confirmed ?? false) {
        context.read<NotesBloc>().add(DeleteNoteEvent(note.id));
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Note deleted permanently')),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Archived Notes'), elevation: 0),
      body: BlocBuilder<NotesBloc, NoteState>(
        builder: (context, state) {
          if (state is NoteLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is NotesLoaded) {
            _archivedNotes = state.notes
                .where((note) => note.isArchived)
                .toList();
          }

          if (_archivedNotes.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.archive_outlined,
                    size: 64.w,
                    color: Colors.grey[400],
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    'No archived notes',
                    style: AppTypography.bodyLarge(context),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'Notes you archive will appear here',
                    style: AppTypography.captionSmall(
                      context,
                    ).copyWith(color: Colors.grey[600]),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: EdgeInsets.all(8.w),
            itemCount: _archivedNotes.length,
            itemBuilder: (context, index) {
              final note = _archivedNotes[index];
              return Card(
                margin: EdgeInsets.symmetric(vertical: 8.h),
                child: ListTile(
                  title: Text(
                    note.title.isEmpty ? 'Untitled' : note.title,
                    style: AppTypography.bodyLarge(context),
                  ),
                  subtitle: Text(
                    note.content.isEmpty
                        ? 'No content'
                        : note.content.replaceAll('\n', ' '),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.captionSmall(context),
                  ),
                  trailing: PopupMenuButton<String>(
                    onSelected: (String value) {
                      if (value == 'unarchive') {
                        _unarchiveNote(note);
                      } else if (value == 'delete') {
                        _deleteNoteForever(note);
                      }
                    },
                    itemBuilder: (BuildContext context) => [
                      const PopupMenuItem(
                        value: 'unarchive',
                        child: Row(
                          children: [
                            Icon(Icons.unarchive, size: 18),
                            SizedBox(width: 12),
                            Text('Unarchive'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, size: 18, color: Colors.red),
                            SizedBox(width: 12),
                            Text('Delete', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
