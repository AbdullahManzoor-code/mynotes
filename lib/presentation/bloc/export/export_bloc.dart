import 'dart:io';
import 'package:archive/archive_io.dart';
import 'package:path_provider/path_provider.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/repositories/note_repository.dart';
import '../../../core/pdf/pdf_export_service.dart';
import '../../../core/services/export_service.dart';
import '../../../domain/entities/note.dart';

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
    on<ExportCustomContentEvent>(_onExportCustomContent);
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
          filePath = await _exportToTxt(note);
          break;
        case 'md':
        case 'markdown':
          filePath = await _exportToMarkdown(note);
          break;
        case 'html':
          filePath = await _exportToHtml(note);
          break;
        default:
          filePath = await _exportToTxt(note);
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

      final notes = <Note>[];
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
          filePath = await _exportNotesToZip(notes, event.format);
          break;
        default:
          filePath = await _exportNotesToZip(notes, 'zip');
      }

      emit(ExportSuccess(filePath: filePath));
    } catch (e) {
      emit(ExportError(message: 'Bulk export failed: ${e.toString()}'));
    }
  }

  Future<void> _onExportCustomContent(
    ExportCustomContentEvent event,
    Emitter<ExportState> emit,
  ) async {
    try {
      emit(const ExportInProgress());
      final service = ExportService();
      File? file;

      switch (event.format.toLowerCase()) {
        case 'markdown':
        case 'md':
          file = await service.exportMarkdown(
            title: event.title,
            content: event.content,
            tags: event.tags,
            createdDate: event.createdDate,
            includeTags: event.includeTags,
            includeTimestamps: event.includeTimestamps,
            includeMediaRefs: event.includeMediaRefs,
          );
          break;
        case 'json':
          file = await service.exportJson(
            title: event.title,
            content: event.content,
            tags: event.tags,
            createdDate: event.createdDate,
            includeTags: event.includeTags,
            includeTimestamps: event.includeTimestamps,
            includeMediaRefs: event.includeMediaRefs,
          );
          break;
        case 'pdf':
        default:
          file = await service.exportPdf(
            title: event.title,
            content: event.content,
            tags: event.tags,
            createdDate: event.createdDate,
            includeTags: event.includeTags,
            includeTimestamps: event.includeTimestamps,
            includeMediaRefs: event.includeMediaRefs,
          );
      }

      if (file == null) {
        emit(const ExportError(message: 'Export failed'));
        return;
      }

      emit(ExportSuccess(filePath: file.path));
    } catch (e) {
      emit(ExportError(message: 'Export failed: ${e.toString()}'));
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

  Future<String> _exportToTxt(dynamic note) async {
    final file = await ExportService.saveToFile(note as Note, format: 'text');
    return file.path;
  }

  Future<String> _exportToMarkdown(dynamic note) async {
    final file = await ExportService.saveToFile(
      note as Note,
      format: 'markdown',
    );
    return file.path;
  }

  Future<String> _exportToHtml(dynamic note) async {
    final file = await ExportService.saveToFile(note as Note, format: 'html');
    return file.path;
  }

  Future<String> _exportNotesToZip(List<dynamic> notes, String format) async {
    final encoder = ZipFileEncoder();
    final directory = await getTemporaryDirectory();
    final zipPath =
        '${directory.path}/notes_export_${DateTime.now().millisecondsSinceEpoch}.zip';
    encoder.create(zipPath);

    for (final note in notes) {
      final content = format == 'markdown'
          ? ExportService.exportAsMarkdown(note as Note)
          : ExportService.exportAsText(note as Note);
      final extension = format == 'markdown' ? 'md' : 'txt';

      final tempFile = File('${directory.path}/${note.id}.$extension');
      await tempFile.writeAsString(content);
      encoder.addFile(tempFile);
    }

    encoder.close();
    return zipPath;
  }

  Future<String> _exportNoteToPdf(dynamic note) async {
    return await PdfExportService.exportNoteToPdf(note);
  }

  Future<String> _exportNotesToCombinedPdf(List<dynamic> notes) async {
    return await PdfExportService.exportMultipleNotesToPdf(notes);
  }
}
