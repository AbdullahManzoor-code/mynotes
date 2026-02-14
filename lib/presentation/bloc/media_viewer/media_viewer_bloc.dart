import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gal/gal.dart';
import 'media_viewer_event.dart';
import 'media_viewer_state.dart';
import '../../../domain/entities/media_item.dart';
import '../../../domain/entities/annotation_stroke.dart';

class MediaViewerBloc extends Bloc<MediaViewerEvent, MediaViewerState> {
  MediaViewerBloc() : super(MediaViewerInitial()) {
    on<MediaViewerInitEvent>(_onInit);
    on<PageChangedEvent>(_onPageChanged);
    on<ToggleMarkupEvent>(_onToggleMarkup);
    on<AddStrokeEvent>(_onAddStroke);
    on<UpdateMediaItemEvent>(_onUpdateMediaItem);
    on<DeleteMediaItemEvent>(_onDeleteMediaItem);
    on<SaveMediaToGalleryEvent>(_onSaveMediaToGallery);
  }

  void _onInit(MediaViewerInitEvent event, Emitter<MediaViewerState> emit) {
    final annotationsByPage = <int, List<AnnotationStroke>>{};
    for (int i = 0; i < event.mediaItems.length; i++) {
      final media = event.mediaItems[i];
      if (media.metadata.containsKey('annotations')) {
        final list = media.metadata['annotations'] as List;
        annotationsByPage[i] = list
            .map(
              (item) => AnnotationStroke.fromJson(item as Map<String, dynamic>),
            )
            .toList();
      } else {
        annotationsByPage[i] = [];
      }
    }

    emit(
      MediaViewerUpdated(
        mediaItems: List.from(event.mediaItems),
        currentIndex: event.initialIndex,
        isMarkupEnabled: false,
        annotationsByPage: annotationsByPage,
      ),
    );
  }

  void _onPageChanged(PageChangedEvent event, Emitter<MediaViewerState> emit) {
    if (state is MediaViewerUpdated) {
      emit((state as MediaViewerUpdated).copyWith(currentIndex: event.index));
    }
  }

  void _onToggleMarkup(
    ToggleMarkupEvent event,
    Emitter<MediaViewerState> emit,
  ) {
    if (state is MediaViewerUpdated) {
      final currentState = state as MediaViewerUpdated;
      final newMarkupEnabled = !currentState.isMarkupEnabled;

      String? message;
      if (!newMarkupEnabled) {
        // Saving annotations logic (optional: could be done here or in another event)
        message = "Annotations saved";
      }

      emit(
        currentState.copyWith(
          isMarkupEnabled: newMarkupEnabled,
          message: message,
        ),
      );
    }
  }

  void _onAddStroke(AddStrokeEvent event, Emitter<MediaViewerState> emit) {
    if (state is MediaViewerUpdated) {
      final currentState = state as MediaViewerUpdated;
      final annotations = Map<int, List<AnnotationStroke>>.from(
        currentState.annotationsByPage,
      );
      annotations[event.pageIndex] = [
        ...(annotations[event.pageIndex] ?? []),
        event.stroke,
      ];

      // Also update the media item metadata in the list if we want it to persist across page changes
      final mediaItems = List<MediaItem>.from(currentState.mediaItems);
      final media = mediaItems[event.pageIndex];
      mediaItems[event.pageIndex] = media.copyWith(
        metadata: {
          ...media.metadata,
          'annotations': annotations[event.pageIndex]!
              .map((s) => s.toJson())
              .toList(),
        },
      );

      emit(
        currentState.copyWith(
          annotationsByPage: annotations,
          mediaItems: mediaItems,
        ),
      );
    }
  }

  void _onUpdateMediaItem(
    UpdateMediaItemEvent event,
    Emitter<MediaViewerState> emit,
  ) {
    if (state is MediaViewerUpdated) {
      final currentState = state as MediaViewerUpdated;
      final mediaItems = List<MediaItem>.from(currentState.mediaItems);
      mediaItems[event.index] = event.updatedMedia;
      emit(currentState.copyWith(mediaItems: mediaItems));
    }
  }

  void _onDeleteMediaItem(
    DeleteMediaItemEvent event,
    Emitter<MediaViewerState> emit,
  ) {
    emit(MediaViewerDeleted(event.media));
  }

  Future<void> _onSaveMediaToGallery(
    SaveMediaToGalleryEvent event,
    Emitter<MediaViewerState> emit,
  ) async {
    final media = event.media;
    try {
      final hasAccess = await Gal.hasAccess();
      if (!hasAccess) {
        final request = await Gal.requestAccess();
        if (!request) {
          emit(const MediaViewerFailure('Access denied to gallery'));
          return;
        }
      }

      if (media.type == MediaType.image) {
        await Gal.putImage(media.filePath);
      } else if (media.type == MediaType.video) {
        await Gal.putVideo(media.filePath);
      } else {
        emit(
          const MediaViewerFailure(
            'Only images and videos can be saved to gallery',
          ),
        );
        return;
      }

      if (state is MediaViewerUpdated) {
        emit(
          (state as MediaViewerUpdated).copyWith(message: 'Saved to gallery!'),
        );
      }
    } catch (e) {
      emit(MediaViewerFailure('Error saving: $e'));
    }
  }
}
