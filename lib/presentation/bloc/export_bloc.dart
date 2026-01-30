import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/repositories/note_repository.dart';

part 'export_event.dart';
part 'export_state.dart';

/// Export BLoC for managing note export operations
/// Handles single and bulk exports in multiple formats
class ExportBloc extends Bloc<ExportEvent, ExportState> {
  final NoteRepository _noteRepository;

  ExportBloc({required NoteRepository noteRepository})
    : _noteRepository = noteRepository,
      super(const ExportInitial()) {
    on<ExportSingleNoteEvent>(_onExportSingleNote);
    on<ExportMultipleNotesEvent>(_onExportMultipleNotes);
    on<CalculateExportSizeEvent>(_onCalculateExportSize);
    on<CancelExportEvent>(_onCancelExport);
  }

  Future<void> _onExportSingleNote(
    ExportSingleNoteEvent event,
    Emitter<ExportState> emit,
  ) async {
    try {
      emit(const ExportInProgress());

      final note = await _noteRepository.getNoteById(event.noteId);
      if (note == null) {
        emit(const ExportError(message: 'Note not found'));
        return;
      }

      String filePath;
      switch (event.format.toLowerCase()) {
        case 'pdf':
          filePath = await _exportNoteToPdf(note);
          break;
        case 'txt':
          filePath = _exportToTxt(note);
          break;
        case 'md':
        case 'markdown':
          filePath = _exportToMarkdown(note);
          break;
        case 'html':
          filePath = _exportToHtml(note);
          break;
        default:
          filePath = _exportToTxt(note);
      }

      emit(ExportSuccess(filePath: filePath));
    } catch (e) {
      emit(ExportError(message: 'Export failed: ${e.toString()}'));
    }
  }

  Future<void> _onExportMultipleNotes(
    ExportMultipleNotesEvent event,
    Emitter<ExportState> emit,
  ) async {
    try {
      emit(const ExportInProgress());

      final notes = <dynamic>[];
      for (int i = 0; i < event.noteIds.length; i++) {
        final note = await _noteRepository.getNoteById(event.noteIds[i]);
        if (note != null) {
          notes.add(note);
        }
        // Update progress
        emit(ExportInProgress(progress: (i + 1) / event.noteIds.length));
      }

      if (notes.isEmpty) {
        emit(const ExportError(message: 'No valid notes to export'));
        return;
      }

      String filePath;
      switch (event.format.toLowerCase()) {
        case 'pdf':
          filePath = await _exportNotesToCombinedPdf(notes);
          break;
        case 'zip':
        case 'markdown':
          filePath = _exportNotesToZip(notes, event.format);
          break;
        default:
          filePath = _exportNotesToZip(notes, 'zip');
      }

      emit(ExportSuccess(filePath: filePath));
    } catch (e) {
      emit(ExportError(message: 'Bulk export failed: ${e.toString()}'));
    }
  }

  Future<void> _onCalculateExportSize(
    CalculateExportSizeEvent event,
    Emitter<ExportState> emit,
  ) async {
    try {
      for (final noteId in event.noteIds) {
        final note = await _noteRepository.getNoteById(noteId);
        if (note != null) {
          // Estimate size based on content (unused but kept for future integration)
          note.toString().length;
        }
      }
      // For now, just complete the calculation
      // In production, use actual file sizes
      emit(const ExportInProgress());
    } catch (e) {
      emit(ExportError(message: 'Size calculation failed: ${e.toString()}'));
    }
  }

  Future<void> _onCancelExport(
    CancelExportEvent event,
    Emitter<ExportState> emit,
  ) async {
    emit(const ExportInitial());
  }

  String _exportToTxt(dynamic note) {
    // Placeholder: In production, write to actual file
    return '/export/${note.id}.txt'; // Mock path
  }

  String _exportToMarkdown(dynamic note) {
    // Placeholder: In production, write to actual file
    return '/export/${note.id}.md'; // Mock path
  }

  String _exportToHtml(dynamic note) {
    // Placeholder: In production, write to actual file
    return '/export/${note.id}.html'; // Mock path
  }

  String _exportNotesToZip(List<dynamic> notes, String format) {
    // Placeholder: In production, create actual ZIP
    return '/export/notes_${DateTime.now().millisecondsSinceEpoch}.zip'; // Mock path
  }

  Future<String> _exportNoteToPdf(dynamic note) async {
    // Placeholder: In production, use PdfExportService
    // For now, just return mock path
    return '/export/${note.id}.pdf'; // Mock path
  }

  Future<String> _exportNotesToCombinedPdf(List<dynamic> notes) async {
    // Placeholder: In production, create combined PDF using PdfExportService
    return '/export/combined_${DateTime.now().millisecondsSinceEpoch}.pdf'; // Mock path
  }
}
