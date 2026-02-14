import 'dart:io' as io;

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mynotes/injection_container.dart';
import 'media_event.dart';
import 'media_state.dart';
import '../../../domain/repositories/media_repository.dart';

import '../../../core/services/media_capture_service.dart';
import '../../../core/services/document_scanner_service.dart';
import '../../../core/services/media_processing_service.dart';

class MediaBloc extends Bloc<MediaEvent, MediaState> {
  final MediaRepository repository;
  final MediaCaptureService _mediaCaptureService = MediaCaptureService();
  final DocumentScannerService _documentScannerService =
      DocumentScannerService();
  final MediaProcessingService _mediaProcessingService =
      getIt<MediaProcessingService>();

  MediaBloc({required this.repository}) : super(MediaInitial()) {
    on<LoadMediaEvent>(_onLoadMedia);
    on<FilterMediaEvent>(_onFilterMedia);
    on<AddImageToNoteEvent>(_onAddImageToNote);
    on<CapturePhotoEvent>(_onCapturePhoto);
    on<PickPhotoFromGalleryEvent>(_onPickPhotoFromGallery);
    on<RemoveImageFromNoteEvent>(_onRemoveImageFromNote);
    on<StartAudioRecordingEvent>(_onStartAudioRecording);
    on<StopAudioRecordingEvent>(_onStopAudioRecording);
    on<PlayAudioEvent>(_onPlayAudio);
    on<CaptureVideoEvent>(_onCaptureVideo);
    on<PickVideoFromGalleryEvent>(_onPickVideoFromGallery);
    on<AddVideoToNoteEvent>(_onAddVideoToNote);
    on<RemoveVideoFromNoteEvent>(_onRemoveVideoFromNote);
    on<ScanDocumentEvent>(_onScanDocument);
    on<CompressImageEvent>(_onCompressImage);
    on<CompressVideoEvent>(_onCompressVideo);
  }

  Future<void> _onAddImageToNote(
    AddImageToNoteEvent event,
    Emitter<MediaState> emit,
  ) async {
    try {
      emit(MediaLoading(event.noteId));
      final media = await repository.addImageToNote(
        event.noteId,
        event.imagePath,
      );
      emit(MediaAdded(event.noteId, media));
    } catch (e) {
      final errorMsg = e.toString().replaceAll('Exception: ', '');
      emit(MediaError(event.noteId, errorMsg));
    }
  }

  Future<void> _onCapturePhoto(
    CapturePhotoEvent event,
    Emitter<MediaState> emit,
  ) async {
    try {
      emit(MediaLoading(event.noteId));
      final photoPath = await _mediaCaptureService.capturePhoto();

      if (photoPath != null) {
        final media = await repository.addImageToNote(event.noteId, photoPath);
        emit(MediaAdded(event.noteId, media));
      } else {
        emit(MediaError(event.noteId, 'Failed to capture photo'));
      }
    } catch (e) {
      final errorMsg = e.toString().replaceAll('Exception: ', '');
      emit(MediaError(event.noteId, errorMsg));
    }
  }

  Future<void> _onPickPhotoFromGallery(
    PickPhotoFromGalleryEvent event,
    Emitter<MediaState> emit,
  ) async {
    try {
      emit(MediaLoading(event.noteId));
      final photoPath = await _mediaCaptureService.pickPhotoFromGallery();

      if (photoPath != null) {
        final media = await repository.addImageToNote(event.noteId, photoPath);
        emit(MediaAdded(event.noteId, media));
      } else {
        emit(MediaError(event.noteId, 'No photo selected'));
      }
    } catch (e) {
      final errorMsg = e.toString().replaceAll('Exception: ', '');
      emit(MediaError(event.noteId, errorMsg));
    }
  }

  Future<void> _onRemoveImageFromNote(
    RemoveImageFromNoteEvent event,
    Emitter<MediaState> emit,
  ) async {
    try {
      emit(MediaLoading(event.noteId));
      await repository.removeMediaFromNote(event.noteId, event.mediaId);
      emit(MediaRemoved(event.noteId, event.mediaId));
    } catch (e) {
      final errorMsg = e.toString().replaceAll('Exception: ', '');
      emit(MediaError(event.noteId, errorMsg));
    }
  }

  Future<void> _onStartAudioRecording(
    StartAudioRecordingEvent event,
    Emitter<MediaState> emit,
  ) async {
    try {
      emit(MediaLoading(event.noteId));
      final success = await _mediaCaptureService.startAudioRecording(
        event.fileName,
      );

      if (success) {
        emit(AudioRecordingStarted(event.noteId));
      } else {
        emit(MediaError(event.noteId, 'Failed to start recording'));
      }
    } catch (e) {
      final errorMsg = e.toString().replaceAll('Exception: ', '');
      emit(MediaError(event.noteId, errorMsg));
    }
  }

  Future<void> _onStopAudioRecording(
    StopAudioRecordingEvent event,
    Emitter<MediaState> emit,
  ) async {
    try {
      emit(MediaLoading(event.noteId));
      final audioPath = await _mediaCaptureService.stopAudioRecording();

      if (audioPath != null) {
        final media = await repository.addImageToNote(event.noteId, audioPath);
        emit(MediaAdded(event.noteId, media));
      } else {
        emit(MediaError(event.noteId, 'Failed to save recording'));
      }
    } catch (e) {
      final errorMsg = e.toString().replaceAll('Exception: ', '');
      emit(MediaError(event.noteId, errorMsg));
    }
  }

  Future<void> _onPlayAudio(
    PlayAudioEvent event,
    Emitter<MediaState> emit,
  ) async {
    try {
      // Delegate to media player service
      emit(AudioPlaybackStarted(event.noteId));
    } catch (e) {
      final errorMsg = e.toString().replaceAll('Exception: ', '');
      emit(MediaError(event.noteId, errorMsg));
    }
  }

  Future<void> _onCaptureVideo(
    CaptureVideoEvent event,
    Emitter<MediaState> emit,
  ) async {
    try {
      emit(MediaLoading(event.noteId));
      final videoPath = await _mediaCaptureService.captureVideo();

      if (videoPath != null) {
        final media = await repository.addVideoToNote(event.noteId, videoPath);
        emit(MediaAdded(event.noteId, media));
      } else {
        emit(MediaError(event.noteId, 'Failed to capture video'));
      }
    } catch (e) {
      final errorMsg = e.toString().replaceAll('Exception: ', '');
      emit(MediaError(event.noteId, errorMsg));
    }
  }

  Future<void> _onPickVideoFromGallery(
    PickVideoFromGalleryEvent event,
    Emitter<MediaState> emit,
  ) async {
    try {
      emit(MediaLoading(event.noteId));
      final videoPath = await _mediaCaptureService.pickVideoFromGallery();

      if (videoPath != null) {
        final media = await repository.addVideoToNote(event.noteId, videoPath);
        emit(MediaAdded(event.noteId, media));
      } else {
        emit(MediaError(event.noteId, 'No video selected'));
      }
    } catch (e) {
      final errorMsg = e.toString().replaceAll('Exception: ', '');
      emit(MediaError(event.noteId, errorMsg));
    }
  }

  Future<void> _onAddVideoToNote(
    AddVideoToNoteEvent event,
    Emitter<MediaState> emit,
  ) async {
    try {
      emit(MediaLoading(event.noteId));
      final media = await repository.addVideoToNote(
        event.noteId,
        event.videoPath,
      );
      emit(MediaAdded(event.noteId, media));
    } catch (e) {
      final errorMsg = e.toString().replaceAll('Exception: ', '');
      emit(MediaError(event.noteId, errorMsg));
    }
  }

  Future<void> _onRemoveVideoFromNote(
    RemoveVideoFromNoteEvent event,
    Emitter<MediaState> emit,
  ) async {
    try {
      emit(MediaLoading(event.noteId));
      await repository.removeMediaFromNote(event.noteId, event.mediaId);
      emit(MediaRemoved(event.noteId, event.mediaId));
    } catch (e) {
      final errorMsg = e.toString().replaceAll('Exception: ', '');
      emit(MediaError(event.noteId, errorMsg));
    }
  }

  Future<void> _onScanDocument(
    ScanDocumentEvent event,
    Emitter<MediaState> emit,
  ) async {
    try {
      emit(MediaLoading(event.noteId));
      final scannedDoc = await _documentScannerService.scanDocument(
        documentTitle: event.documentTitle,
      );

      if (scannedDoc != null && scannedDoc.pagePaths.isNotEmpty) {
        // Add scanned document as attachment
        final documentPath = scannedDoc.pagePaths.join(',');
        final media = await repository.addImageToNote(
          event.noteId,
          documentPath,
        );
        emit(MediaAdded(event.noteId, media));
      } else {
        emit(MediaError(event.noteId, 'Failed to scan document'));
      }
    } catch (e) {
      final errorMsg = e.toString().replaceAll('Exception: ', '');
      emit(MediaError(event.noteId, errorMsg));
    }
  }

  Future<void> _onCompressImage(
    CompressImageEvent event,
    Emitter<MediaState> emit,
  ) async {
    try {
      emit(MediaLoading(event.noteId));

      final file = io.File(event.mediaId);
      if (!await file.exists()) {
        emit(MediaError(event.noteId, 'File not found for compression'));
        return;
      }

      final compressedFile = await _mediaProcessingService.compressImage(file);

      if (compressedFile != null) {
        emit(MediaCompressed(event.noteId, event.mediaId, compressedFile.path));
      } else {
        emit(MediaError(event.noteId, 'Image compression failed'));
      }
    } catch (e) {
      final errorMsg = e.toString().replaceAll('Exception: ', '');
      emit(MediaError(event.noteId, errorMsg));
    }
  }

  Future<void> _onCompressVideo(
    CompressVideoEvent event,
    Emitter<MediaState> emit,
  ) async {
    try {
      emit(MediaLoading(event.noteId));

      final file = io.File(event.mediaId);
      if (!await file.exists()) {
        emit(MediaError(event.noteId, 'File not found for compression'));
        return;
      }

      final info = await _mediaProcessingService.compressVideo(file);

      if (info != null && info.path != null) {
        emit(MediaCompressed(event.noteId, event.mediaId, info.path!));
      } else {
        emit(MediaError(event.noteId, 'Video compression failed'));
      }
    } catch (e) {
      final errorMsg = e.toString().replaceAll('Exception: ', '');
      emit(MediaError(event.noteId, errorMsg));
    }
  }

  Future<void> _onLoadMedia(
    LoadMediaEvent event,
    Emitter<MediaState> emit,
  ) async {
    try {
      emit(MediaLoading(''));
      // In a real implementation, fetch media from repository
      // For now, emit MediaLoaded with empty list
      emit(const MediaLoaded([]));
    } catch (e) {
      final errorMsg = e.toString().replaceAll('Exception: ', '');
      emit(MediaError('', errorMsg));
    }
  }

  Future<void> _onFilterMedia(
    FilterMediaEvent event,
    Emitter<MediaState> emit,
  ) async {
    try {
      // Filter logic would be implemented here
      // For now, just emit loaded state
      emit(const MediaLoaded([]));
    } catch (e) {
      final errorMsg = e.toString().replaceAll('Exception: ', '');
      emit(MediaError('', errorMsg));
    }
  }
}
