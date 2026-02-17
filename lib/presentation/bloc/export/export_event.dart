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

class ExportCustomContentEvent extends ExportEvent {
  final String title;
  final String content;
  final List<String>? tags;
  final DateTime createdDate;
  final String format; // 'pdf', 'markdown', 'json'
  final bool includeTags;
  final bool includeTimestamps;
  final bool includeMediaRefs;

  const ExportCustomContentEvent({
    required this.title,
    required this.content,
    required this.createdDate,
    required this.format,
    this.tags,
    this.includeTags = true,
    this.includeTimestamps = true,
    this.includeMediaRefs = true,
  });

  @override
  List<Object?> get props => [
    title,
    content,
    tags,
    createdDate,
    format,
    includeTags,
    includeTimestamps,
    includeMediaRefs,
  ];
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
