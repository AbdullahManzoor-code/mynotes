part of 'export_bloc.dart';

abstract class ExportEvent extends Equatable {
  const ExportEvent();

  @override
  List<Object?> get props => [];
}

class ExportSingleNoteEvent extends ExportEvent {
  final String noteId;
  final String format; // 'txt', 'md', 'html', 'pdf'

  const ExportSingleNoteEvent({
    required this.noteId,
    required this.format,
  });

  @override
  List<Object?> get props => [noteId, format];
}

class ExportMultipleNotesEvent extends ExportEvent {
  final List<String> noteIds;
  final String format; // 'zip', 'pdf', 'md'

  const ExportMultipleNotesEvent({
    required this.noteIds,
    required this.format,
  });

  @override
  List<Object?> get props => [noteIds, format];
}

class CalculateExportSizeEvent extends ExportEvent {
  final List<String> noteIds;

  const CalculateExportSizeEvent({required this.noteIds});

  @override
  List<Object?> get props => [noteIds];
}

class CancelExportEvent extends ExportEvent {
  const CancelExportEvent();
}
