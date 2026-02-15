import 'dart:io' as io;

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mynotes/core/services/app_logger.dart' show AppLogger;
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
    AppLogger.i('Capturing photo for note: ${event.noteId}');
    try {
      emit(MediaLoading(event.noteId));
      final photoPath = await _mediaCaptureService.capturePhoto();

      if (photoPath != null) {
        AppLogger.i('Photo captured to path: $photoPath');
        final media = await repository.addImageToNote(event.noteId, photoPath);
        emit(MediaAdded(event.noteId, media));
      } else {
        AppLogger.w('Photo capture cancelled or failed');
        emit(MediaError(event.noteId, 'Failed to capture photo'));
      }
    } catch (e, stack) {
      final errorMsg = e.toString().replaceAll('Exception: ', '');
      AppLogger.e('Photo capture error: $errorMsg', e, stack);
      emit(MediaError(event.noteId, errorMsg));
    }
  }

  Future<void> _onPickPhotoFromGallery(
    PickPhotoFromGalleryEvent event,
    Emitter<MediaState> emit,
  ) async {
    AppLogger.i('Picking photo from gallery for note: ${event.noteId}');
    try {
      emit(MediaLoading(event.noteId));
      final photoPath = await _mediaCaptureService.pickPhotoFromGallery();

      if (photoPath != null) {
        AppLogger.i('Photo picked from path: $photoPath');
        final media = await repository.addImageToNote(event.noteId, photoPath);
        emit(MediaAdded(event.noteId, media));
      } else {
        AppLogger.i('Gallery pick cancelled');
        emit(MediaError(event.noteId, 'No photo selected'));
      }
    } catch (e, stack) {
      final errorMsg = e.toString().replaceAll('Exception: ', '');
      AppLogger.e('Gallery pick error: $errorMsg', e, stack);
      emit(MediaError(event.noteId, errorMsg));
    }
  }

  Future<void> _onRemoveImageFromNote(
    RemoveImageFromNoteEvent event,
    Emitter<MediaState> emit,
  ) async {
    AppLogger.i('Removing image ${event.mediaId} from note ${event.noteId}');
    try {
      emit(MediaLoading(event.noteId));
      await repository.removeMediaFromNote(event.noteId, event.mediaId);
      emit(MediaRemoved(event.noteId, event.mediaId));
    } catch (e, stack) {
      final errorMsg = e.toString().replaceAll('Exception: ', '');
      AppLogger.e('Image removal error: $errorMsg', e, stack);
      emit(MediaError(event.noteId, errorMsg));
    }
  }

  Future<void> _onStartAudioRecording(
    StartAudioRecordingEvent event,
    Emitter<MediaState> emit,
  ) async {
    AppLogger.i('Starting audio recording: ${event.fileName}');
    try {
      emit(MediaLoading(event.noteId));
      final success = await _mediaCaptureService.startAudioRecording(
        event.fileName,
      );

      if (success) {
        AppLogger.i('Audio recording started successfully');
        emit(AudioRecordingStarted(event.noteId));
      } else {
        AppLogger.w('Failed to start audio recording');
        emit(MediaError(event.noteId, 'Failed to start recording'));
      }
    } catch (e, stack) {
      final errorMsg = e.toString().replaceAll('Exception: ', '');
      AppLogger.e('Audio recording start error: $errorMsg', e, stack);
      emit(MediaError(event.noteId, errorMsg));
    }
  }

  Future<void> _onStopAudioRecording(
    StopAudioRecordingEvent event,
    Emitter<MediaState> emit,
  ) async {
    AppLogger.i('Stopping audio recording for note: ${event.noteId}');
    try {
      emit(MediaLoading(event.noteId));
      final audioPath = await _mediaCaptureService.stopAudioRecording();

      if (audioPath != null) {
        AppLogger.i('Audio recording saved to: $audioPath');
        final media = await repository.addImageToNote(event.noteId, audioPath);
        emit(MediaAdded(event.noteId, media));
      } else {
        AppLogger.w('No audio path returned from recorder');
        emit(MediaError(event.noteId, 'Failed to save recording'));
      }
    } catch (e, stack) {
      final errorMsg = e.toString().replaceAll('Exception: ', '');
      AppLogger.e('Audio recording stop error: $errorMsg', e, stack);
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
    AppLogger.i('Scanning document: ${event.documentTitle}');
    try {
      emit(MediaLoading(event.noteId));
      final scannedDoc = await _documentScannerService.scanDocument(
        documentTitle: event.documentTitle,
      );

      if (scannedDoc != null && scannedDoc.pagePaths.isNotEmpty) {
        AppLogger.i(
          'Document scanned with ${scannedDoc.pagePaths.length} pages',
        );
        // Add scanned document as attachment
        final documentPath = scannedDoc.pagePaths.join(',');
        final media = await repository.addImageToNote(
          event.noteId,
          documentPath,
        );
        emit(MediaAdded(event.noteId, media));
      } else {
        AppLogger.w('Document scanning failed or cancelled');
        emit(MediaError(event.noteId, 'Failed to scan document'));
      }
    } catch (e, stack) {
      final errorMsg = e.toString().replaceAll('Exception: ', '');
      AppLogger.e('Document scanner error: $errorMsg', e, stack);
      emit(MediaError(event.noteId, errorMsg));
    }
  }

  Future<void> _onCompressImage(
    CompressImageEvent event,
    Emitter<MediaState> emit,
  ) async {
    AppLogger.i('Compressing image: ${event.mediaId}');
    try {
      emit(MediaLoading(event.noteId));

      final file = io.File(event.mediaId);
      if (!await file.exists()) {
        AppLogger.w('Compression source file not found: ${event.mediaId}');
        emit(MediaError(event.noteId, 'File not found for compression'));
        return;
      }

      final compressedFile = await _mediaProcessingService.compressImage(file);

      if (compressedFile != null) {
        AppLogger.i('Image compressed: ${compressedFile.path}');
        emit(MediaCompressed(event.noteId, event.mediaId, compressedFile.path));
      } else {
        AppLogger.w('Image compression returned null');
        emit(MediaError(event.noteId, 'Image compression failed'));
      }
    } catch (e, stack) {
      final errorMsg = e.toString().replaceAll('Exception: ', '');
      AppLogger.e('Image compression error: $errorMsg', e, stack);
      emit(MediaError(event.noteId, errorMsg));
    }
  }

  Future<void> _onCompressVideo(
    CompressVideoEvent event,
    Emitter<MediaState> emit,
  ) async {
    AppLogger.i('Compressing video: ${event.mediaId}');
    try {
      emit(MediaLoading(event.noteId));

      final file = io.File(event.mediaId);
      if (!await file.exists()) {
        AppLogger.w('Compression source file not found: ${event.mediaId}');
        emit(MediaError(event.noteId, 'File not found for compression'));
        return;
      }

      final info = await _mediaProcessingService.compressVideo(file);

      if (info != null && info.path != null) {
        AppLogger.i('Video compressed: ${info.path}');
        emit(MediaCompressed(event.noteId, event.mediaId, info.path!));
      } else {
        AppLogger.w('Video compression failed or returned no path');
        emit(MediaError(event.noteId, 'Video compression failed'));
      }
    } catch (e, stack) {
      final errorMsg = e.toString().replaceAll('Exception: ', '');
      AppLogger.e('Video compression error: $errorMsg', e, stack);
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
