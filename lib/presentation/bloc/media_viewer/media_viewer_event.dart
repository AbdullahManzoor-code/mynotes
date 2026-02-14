import 'package:equatable/equatable.dart';
import '../../../domain/entities/media_item.dart';
import '../../../domain/entities/annotation_stroke.dart';

abstract class MediaViewerEvent extends Equatable {
  const MediaViewerEvent();

  @override
  List<Object?> get props => [];
}

class MediaViewerInitEvent extends MediaViewerEvent {
  final List<MediaItem> mediaItems;
  final int initialIndex;

  const MediaViewerInitEvent({
    required this.mediaItems,
    required this.initialIndex,
  });

  @override
  List<Object?> get props => [mediaItems, initialIndex];
}

class PageChangedEvent extends MediaViewerEvent {
  final int index;

  const PageChangedEvent(this.index);

  @override
  List<Object?> get props => [index];
}

class ToggleMarkupEvent extends MediaViewerEvent {
  const ToggleMarkupEvent();
}

class AddStrokeEvent extends MediaViewerEvent {
  final int pageIndex;
  final AnnotationStroke stroke;

  const AddStrokeEvent(this.pageIndex, this.stroke);

  @override
  List<Object?> get props => [pageIndex, stroke];
}

class UpdateMediaItemEvent extends MediaViewerEvent {
  final int index;
  final MediaItem updatedMedia;

  const UpdateMediaItemEvent(this.index, this.updatedMedia);

  @override
  List<Object?> get props => [index, updatedMedia];
}

class DeleteMediaItemEvent extends MediaViewerEvent {
  final MediaItem media;

  const DeleteMediaItemEvent(this.media);

  @override
  List<Object?> get props => [media];
}

class SaveMediaToGalleryEvent extends MediaViewerEvent {
  final MediaItem media;

  const SaveMediaToGalleryEvent(this.media);

  @override
  List<Object?> get props => [media];
}
