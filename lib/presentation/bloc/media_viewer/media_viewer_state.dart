import 'package:equatable/equatable.dart';
import '../../../domain/entities/media_item.dart';
import '../../../domain/entities/annotation_stroke.dart';

abstract class MediaViewerState extends Equatable {
  const MediaViewerState();

  @override
  List<Object?> get props => [];
}

class MediaViewerInitial extends MediaViewerState {}

class MediaViewerLoading extends MediaViewerState {}

class MediaViewerUpdated extends MediaViewerState {
  final List<MediaItem> mediaItems;
  final int currentIndex;
  final bool isMarkupEnabled;
  final Map<int, List<AnnotationStroke>> annotationsByPage;
  final String? message;

  const MediaViewerUpdated({
    required this.mediaItems,
    required this.currentIndex,
    required this.isMarkupEnabled,
    required this.annotationsByPage,
    this.message,
  });

  MediaViewerUpdated copyWith({
    List<MediaItem>? mediaItems,
    int? currentIndex,
    bool? isMarkupEnabled,
    Map<int, List<AnnotationStroke>>? annotationsByPage,
    String? message,
  }) {
    return MediaViewerUpdated(
      mediaItems: mediaItems ?? this.mediaItems,
      currentIndex: currentIndex ?? this.currentIndex,
      isMarkupEnabled: isMarkupEnabled ?? this.isMarkupEnabled,
      annotationsByPage: annotationsByPage ?? this.annotationsByPage,
      message: message,
    );
  }

  @override
  List<Object?> get props => [
    mediaItems,
    currentIndex,
    isMarkupEnabled,
    annotationsByPage,
    message,
  ];
}

class MediaViewerDeleted extends MediaViewerState {
  final MediaItem media;
  const MediaViewerDeleted(this.media);

  @override
  List<Object?> get props => [media];
}

class MediaViewerFailure extends MediaViewerState {
  final String error;
  const MediaViewerFailure(this.error);

  @override
  List<Object?> get props => [error];
}
