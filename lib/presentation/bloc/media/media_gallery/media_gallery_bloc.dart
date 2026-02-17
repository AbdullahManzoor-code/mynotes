import 'package:equatable/equatable.dart' show Equatable;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:mynotes/domain/repositories/media_repository.dart';
import '../../../../domain/entities/media_item.dart';

/* ════════════════════════════════════════════════════════════════════════════
   PRIMARY MEDIA MANAGEMENT (SESSION 15 CONSOLIDATION M013)
   
   This is the CONSOLIDATED primary BLoC for all media gallery operations:
   
   ✅ RESPONSIBILITIES:
      - Load all media items
      - Filter by type (image, audio, video)
      - Search media by query
      - Select/deselect for batch operations
      - Delete media
      - Archive media
   
   ✅ REPLACES/CONSOLIDATES:
      - MediaFilterBloc → Use FilterMediaEvent instead
      - MediaSearchBloc → Use SearchMediaEvent instead
      - MediaFiltersBloc → Keep separate (visual effects, not gallery)
      - MediaOrganizationBloc → Keep separate (grouping/organization)
      - MediaPickerBloc → Keep separate (media selection UI)
      - MediaViewerBloc → Keep separate (media display)
   
   ✅ UNIFIED INTERFACES:
      Events: LoadAllMediaEvent, FilterMediaEvent, SearchMediaEvent,
              DeleteMediaEvent, ArchiveMediaEvent, SelectMediaEvent, ClearSelectionEvent
      States: MediaGalleryLoaded, MediaGalleryLoading, MediaGalleryError, etc.
   
   MIGRATION NOTES:
   If any code still uses MediaFilterBloc or MediaSearchBloc, migrate to:
   - MediaFilterBloc.FilterMediaEvent → MediaGalleryBloc.FilterMediaEvent
   - MediaSearchBloc.PerformMediaSearchEvent → MediaGalleryBloc.SearchMediaEvent
   
   Related BLoCs (kept separate, not consolidated):
   - AudioRecorderBloc: Recording management
   - AudioPlaybackBloc: Playback control
   - VideoEditorBloc: Video editing (minimal)
   - MediaFiltersBloc: Visual effects (separate concern)
   - MediaOrganizationBloc: Media grouping (feature extension)
   - MediaViewerBloc: Media display
   - MediaPickerBloc: Media selection UI
════════════════════════════════════════════════════════════════════════════ */

// Media Gallery BLoC - Events
abstract class MediaGalleryEvent extends Equatable {
  const MediaGalleryEvent();
  @override
  List<Object?> get props => [];
}

class LoadAllMediaEvent extends MediaGalleryEvent {
  const LoadAllMediaEvent();
}

class FilterMediaEvent extends MediaGalleryEvent {
  final String? filterType;
  final DateTime? fromDate;
  final DateTime? toDate;
  final int? minSizeBytes;
  final int? maxSizeBytes;
  final List<String>? tags;

  const FilterMediaEvent({
    this.filterType,
    this.fromDate,
    this.toDate,
    this.minSizeBytes,
    this.maxSizeBytes,
    this.tags,
  });

  @override
  List<Object?> get props => [
    filterType,
    fromDate,
    toDate,
    minSizeBytes,
    maxSizeBytes,
    tags,
  ];
}

class SearchMediaEvent extends MediaGalleryEvent {
  final String query;
  const SearchMediaEvent({required this.query});
  @override
  List<Object?> get props => [query];
}

class DeleteMediaEvent extends MediaGalleryEvent {
  final String mediaId;
  const DeleteMediaEvent({required this.mediaId});
  @override
  List<Object?> get props => [mediaId];
}

class ArchiveMediaEvent extends MediaGalleryEvent {
  final String mediaId;
  const ArchiveMediaEvent({required this.mediaId});
  @override
  List<Object?> get props => [mediaId];
}

class SelectMediaEvent extends MediaGalleryEvent {
  final String mediaId;
  const SelectMediaEvent({required this.mediaId});
  @override
  List<Object?> get props => [mediaId];
}

class ClearSelectionEvent extends MediaGalleryEvent {
  const ClearSelectionEvent();
}

// Media Gallery BLoC - States
abstract class MediaGalleryState extends Equatable {
  const MediaGalleryState();
  @override
  List<Object?> get props => [];
}

class MediaGalleryInitial extends MediaGalleryState {
  const MediaGalleryInitial();
}

class MediaGalleryLoading extends MediaGalleryState {
  const MediaGalleryLoading();
}

class MediaGalleryLoaded extends MediaGalleryState {
  final List<Map<String, dynamic>> mediaItems;
  final String filterType;
  final int totalCount;
  final int imageCount;
  final int videoCount;
  final int audioCount;
  final Set<String> selectedIds;

  const MediaGalleryLoaded({
    required this.mediaItems,
    required this.filterType,
    required this.totalCount,
    required this.imageCount,
    required this.videoCount,
    required this.audioCount,
    required this.selectedIds,
  });

  @override
  List<Object?> get props => [
    mediaItems,
    filterType,
    totalCount,
    imageCount,
    videoCount,
    audioCount,
    selectedIds,
  ];
}

class MediaGalleryError extends MediaGalleryState {
  final String message;
  const MediaGalleryError({required this.message});
  @override
  List<Object?> get props => [message];
}

// Media Gallery BLoC - Implementation
class MediaGalleryBloc extends Bloc<MediaGalleryEvent, MediaGalleryState> {
  final MediaRepository mediaRepository;

  MediaGalleryBloc({required this.mediaRepository})
    : super(const MediaGalleryInitial()) {
    on<LoadAllMediaEvent>(_onLoadAllMedia);
    on<FilterMediaEvent>(_onFilterMedia);
    on<SearchMediaEvent>(_onSearchMedia);
    on<DeleteMediaEvent>(_onDeleteMedia);
    on<ArchiveMediaEvent>(_onArchiveMedia);
    on<SelectMediaEvent>(_onSelectMedia);
    on<ClearSelectionEvent>(_onClearSelection);
  }

  Future<void> _onLoadAllMedia(
    LoadAllMediaEvent event,
    Emitter<MediaGalleryState> emit,
  ) async {
    try {
      emit(const MediaGalleryLoading());

      // Load all media from repository
      final mediaItems = await mediaRepository.getAllMedia();

      // Convert to map format for display
      final allMedia = mediaItems
          .map(
            (item) => {
              'id': item.id,
              'name': item.name,
              'type': item.type,
              'size': _formatBytes(item.size),
              'date': item.createdAt.toString(),
              'icon': _getMediaIcon(item.type.name),
            },
          )
          .toList();

      final imageCount = allMedia
          .where((m) => m['type'] == MediaType.image)
          .length;
      final videoCount = allMedia
          .where((m) => m['type'] == MediaType.video)
          .length;
      final audioCount = allMedia
          .where((m) => m['type'] == MediaType.audio)
          .length;

      emit(
        MediaGalleryLoaded(
          mediaItems: allMedia,
          filterType: 'all',
          totalCount: allMedia.length,
          imageCount: imageCount,
          videoCount: videoCount,
          audioCount: audioCount,
          selectedIds: {},
        ),
      );
    } catch (e) {
      emit(MediaGalleryError(message: 'Failed to load media: ${e.toString()}'));
    }
  }

  Future<void> _onFilterMedia(
    FilterMediaEvent event,
    Emitter<MediaGalleryState> emit,
  ) async {
    try {
      if (state is! MediaGalleryLoaded) return;

      final currentState = state as MediaGalleryLoaded;

      late List<Map<String, dynamic>> filtered;

      if (event.filterType == 'all') {
        final mediaItems = await mediaRepository.getAllMedia();
        filtered = mediaItems
            .map(
              (item) => {
                'id': item.id,
                'name': item.name,
                'type': item.type,
                'size': _formatBytes(item.size),
                'date': item.createdAt.toString(),
                'icon': _getMediaIcon(item.type.name),
              },
            )
            .toList();
      } else {
        final mediaItems = await mediaRepository.filterMediaByType(
          event.filterType ?? "",
        );
        filtered = mediaItems
            .map(
              (item) => {
                'id': item.id,
                'name': item.name,
                'type': item.type,
                'size': _formatBytes(item.size),
                'date': item.createdAt.toString(),
                'icon': _getMediaIcon(item.type.name),
              },
            )
            .toList();
      }

      final allMedia = await mediaRepository.getAllMedia();
      final imageCount = allMedia
          .where((m) => m.type == MediaType.image)
          .length;
      final videoCount = allMedia
          .where((m) => m.type == MediaType.video)
          .length;
      final audioCount = allMedia
          .where((m) => m.type == MediaType.audio)
          .length;

      emit(
        MediaGalleryLoaded(
          mediaItems: filtered,
          filterType: event.filterType ?? '',
          totalCount: allMedia.length,
          imageCount: imageCount,
          videoCount: videoCount,
          audioCount: audioCount,
          selectedIds: currentState.selectedIds,
        ),
      );
    } catch (e) {
      emit(
        MediaGalleryError(message: 'Failed to filter media: ${e.toString()}'),
      );
    }
  }

  Future<void> _onSearchMedia(
    SearchMediaEvent event,
    Emitter<MediaGalleryState> emit,
  ) async {
    try {
      if (state is! MediaGalleryLoaded) return;

      final currentState = state as MediaGalleryLoaded;

      // Search media using repository
      final searchResults = await mediaRepository.searchMedia(event.query);
      final filtered = searchResults
          .map(
            (item) => {
              'id': item.id,
              'name': item.name,
              'type': item.type,
              'size': _formatBytes(item.size),
              'date': item.createdAt.toString(),
              'icon': _getMediaIcon(item.type.name),
            },
          )
          .toList();

      final allMedia = await mediaRepository.getAllMedia();
      final imageCount = allMedia
          .where((m) => m.type == MediaType.image)
          .length;
      final videoCount = allMedia
          .where((m) => m.type == MediaType.video)
          .length;
      final audioCount = allMedia
          .where((m) => m.type == MediaType.audio)
          .length;

      emit(
        MediaGalleryLoaded(
          mediaItems: filtered,
          filterType: currentState.filterType,
          totalCount: allMedia.length,
          imageCount: imageCount,
          videoCount: videoCount,
          audioCount: audioCount,
          selectedIds: currentState.selectedIds,
        ),
      );
    } catch (e) {
      emit(
        MediaGalleryError(message: 'Failed to search media: ${e.toString()}'),
      );
    }
  }

  Future<void> _onDeleteMedia(
    DeleteMediaEvent event,
    Emitter<MediaGalleryState> emit,
  ) async {
    try {
      await mediaRepository.deleteMedia(event.mediaId);
      add(const LoadAllMediaEvent());
    } catch (e) {
      emit(
        MediaGalleryError(message: 'Failed to delete media: ${e.toString()}'),
      );
    }
  }

  Future<void> _onArchiveMedia(
    ArchiveMediaEvent event,
    Emitter<MediaGalleryState> emit,
  ) async {
    try {
      await mediaRepository.archiveMedia(event.mediaId);
      add(const LoadAllMediaEvent());
    } catch (e) {
      emit(
        MediaGalleryError(message: 'Failed to archive media: ${e.toString()}'),
      );
    }
  }

  // Helper methods
  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  String _getMediaIcon(String type) {
    switch (type) {
      case 'image':
        return '🖼️';
      case 'video':
        return '🎬';
      case 'audio':
        return '🎙️';
      default:
        return '📄';
    }
  }

  Future<void> _onSelectMedia(
    SelectMediaEvent event,
    Emitter<MediaGalleryState> emit,
  ) async {
    try {
      if (state is! MediaGalleryLoaded) return;

      final currentState = state as MediaGalleryLoaded;
      final updatedSelection = Set<String>.from(currentState.selectedIds);

      if (updatedSelection.contains(event.mediaId)) {
        updatedSelection.remove(event.mediaId);
      } else {
        updatedSelection.add(event.mediaId);
      }

      final allMedia = await mediaRepository.getAllMedia();
      final imageCount = allMedia
          .where((m) => m.type == MediaType.image)
          .length;
      final videoCount = allMedia
          .where((m) => m.type == MediaType.video)
          .length;
      final audioCount = allMedia
          .where((m) => m.type == MediaType.audio)
          .length;

      emit(
        MediaGalleryLoaded(
          mediaItems: currentState.mediaItems,
          filterType: currentState.filterType,
          totalCount: allMedia.length,
          imageCount: imageCount,
          videoCount: videoCount,
          audioCount: audioCount,
          selectedIds: updatedSelection,
        ),
      );
    } catch (e) {
      emit(
        MediaGalleryError(message: 'Failed to select media: ${e.toString()}'),
      );
    }
  }

  Future<void> _onClearSelection(
    ClearSelectionEvent event,
    Emitter<MediaGalleryState> emit,
  ) async {
    try {
      if (state is! MediaGalleryLoaded) return;

      final currentState = state as MediaGalleryLoaded;

      final allMedia = await mediaRepository.getAllMedia();
      final imageCount = allMedia
          .where((m) => m.type == MediaType.image)
          .length;
      final videoCount = allMedia
          .where((m) => m.type == MediaType.video)
          .length;
      final audioCount = allMedia
          .where((m) => m.type == MediaType.audio)
          .length;

      emit(
        MediaGalleryLoaded(
          mediaItems: currentState.mediaItems,
          filterType: currentState.filterType,
          totalCount: allMedia.length,
          imageCount: imageCount,
          videoCount: videoCount,
          audioCount: audioCount,
          selectedIds: {},
        ),
      );
    } catch (e) {
      emit(
        MediaGalleryError(
          message: 'Failed to clear selection: ${e.toString()}',
        ),
      );
    }
  }
}
