import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:mynotes/presentation/bloc/params/media_filter_params.dart';

// --- Events ---
abstract class MediaFilterEvent extends Equatable {
  const MediaFilterEvent();
  @override
  List<Object?> get props => [];
}

class UpdateMediaTypeEvent extends MediaFilterEvent {
  final String? mediaType;
  const UpdateMediaTypeEvent(this.mediaType);
  @override
  List<Object?> get props => [mediaType];
}

class UpdateDateRangeEvent extends MediaFilterEvent {
  final DateTime? fromDate;
  final DateTime? toDate;
  const UpdateDateRangeEvent({this.fromDate, this.toDate});
  @override
  List<Object?> get props => [fromDate, toDate];
}

class UpdateSizeRangeEvent extends MediaFilterEvent {
  final int? minSize;
  final int? maxSize;
  const UpdateSizeRangeEvent({this.minSize, this.maxSize});
  @override
  List<Object?> get props => [minSize, maxSize];
}

class AddTagEvent extends MediaFilterEvent {
  final String tag;
  const AddTagEvent(this.tag);
  @override
  List<Object?> get props => [tag];
}

class RemoveTagEvent extends MediaFilterEvent {
  final String tag;
  const RemoveTagEvent(this.tag);
  @override
  List<Object?> get props => [tag];
}

class ToggleExcludeArchivedEvent extends MediaFilterEvent {
  final bool exclude;
  const ToggleExcludeArchivedEvent(this.exclude);
  @override
  List<Object?> get props => [exclude];
}

class ClearAllFiltersEvent extends MediaFilterEvent {
  const ClearAllFiltersEvent();
}

// --- State ---
abstract class MediaFilterState extends Equatable {
  final MediaFilterParams params;
  const MediaFilterState(this.params);
  @override
  List<Object?> get props => [params];
}

class MediaFilterInitial extends MediaFilterState {
  const MediaFilterInitial(super.params);
}

class MediaFilterUpdated extends MediaFilterState {
  const MediaFilterUpdated(super.params);
}

// --- Bloc ---
class MediaFilterBloc extends Bloc<MediaFilterEvent, MediaFilterState> {
  MediaFilterBloc() : super(MediaFilterInitial(MediaFilterParams.initial())) {
    on<UpdateMediaTypeEvent>((event, emit) {
      emit(
        MediaFilterUpdated(
          state.params.copyWith(selectedType: event.mediaType),
        ),
      );
    });

    on<UpdateDateRangeEvent>((event, emit) {
      emit(
        MediaFilterUpdated(
          state.params.copyWith(fromDate: event.fromDate, toDate: event.toDate),
        ),
      );
    });

    on<UpdateSizeRangeEvent>((event, emit) {
      emit(
        MediaFilterUpdated(
          state.params.copyWith(
            minSizeBytes: event.minSize,
            maxSizeBytes: event.maxSize,
          ),
        ),
      );
    });

    on<AddTagEvent>((event, emit) {
      if (!state.params.selectedTags.contains(event.tag)) {
        final newTags = List<String>.from(state.params.selectedTags)
          ..add(event.tag);
        emit(MediaFilterUpdated(state.params.copyWith(selectedTags: newTags)));
      }
    });

    on<RemoveTagEvent>((event, emit) {
      final newTags = List<String>.from(state.params.selectedTags)
        ..remove(event.tag);
      emit(MediaFilterUpdated(state.params.copyWith(selectedTags: newTags)));
    });

    on<ToggleExcludeArchivedEvent>((event, emit) {
      emit(
        MediaFilterUpdated(
          state.params.copyWith(excludeArchived: event.exclude),
        ),
      );
    });

    on<ClearAllFiltersEvent>((event, emit) {
      emit(MediaFilterUpdated(MediaFilterParams.initial()));
    });
  }
}
