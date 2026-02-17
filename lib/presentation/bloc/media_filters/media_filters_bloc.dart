import 'package:flutter_bloc/flutter_bloc.dart';
import 'media_filters_event.dart';
import 'media_filters_state.dart';

/* ════════════════════════════════════════════════════════════════════════════
   STATUS (SESSION 15 REVIEW M013): Visual Media Filters
   
   FINDING:
   This BLoC manages visual effects filters (ApplyFilter, UpdateIntensity, etc.)
   Different from MediaFilterBloc (gallery filtering) and MediaSearchBloc.
   
   OVERLAP ANALYSIS:
   - MediaFiltersBloc: Visual effects (brightness, contrast, filters)
   - VideoEditorBloc: Video editing (export, preview)
   - Potential duplication of functionality
   
   CURRENT STATUS: Kept active, used in media_filters_screen.dart
   
   RECOMMENDATION:
   1. Review UI usage in media_filters_screen.dart
   2. Consider merging with VideoEditorBloc if both handle visual effects
   3. Consolidate ApplyFilterEvent handling
   
   KEPT: As-is for now since it's actively used
   REVIEW: Possible future consolidation with VideoEditorBloc
══════════════════════════════════════════════════════════════════════════════ */

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
