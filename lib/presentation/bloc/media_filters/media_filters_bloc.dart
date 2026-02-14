import 'package:flutter_bloc/flutter_bloc.dart';
import 'media_filters_event.dart';
import 'media_filters_state.dart';

class MediaFiltersBloc extends Bloc<MediaFiltersEvent, MediaFiltersState> {
  MediaFiltersBloc() : super(const MediaFiltersInitial()) {
    on<ApplyFilterEvent>((event, emit) {
      emit(
        MediaFiltersUpdated(
          selectedFilter: event.filter,
          intensity: 50.0,
          showPreview: state.showPreview,
        ),
      );
    });

    on<UpdateIntensityEvent>((event, emit) {
      emit(
        MediaFiltersUpdated(
          selectedFilter: state.selectedFilter,
          intensity: event.intensity,
          showPreview: state.showPreview,
        ),
      );
    });

    on<TogglePreviewEvent>((event, emit) {
      emit(
        MediaFiltersUpdated(
          selectedFilter: state.selectedFilter,
          intensity: state.intensity,
          showPreview: !state.showPreview,
        ),
      );
    });

    on<ResetFilterEvent>((event, emit) {
      emit(
        const MediaFiltersUpdated(
          selectedFilter: FilterType.none,
          intensity: 0.0,
          showPreview: true,
        ),
      );
    });
  }
}
