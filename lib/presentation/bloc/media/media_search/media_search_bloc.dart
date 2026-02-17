import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../domain/services/advanced_search_ranking_service.dart';
import '../../../../domain/repositories/media_repository.dart';

/* ════════════════════════════════════════════════════════════════════════════
   CONSOLIDATED (SESSION 15 FIX M013): Media Search Consolidated
   
   REASON FOR CONSOLIDATION:
   This BLoC duplicates search functionality that exists in:
   - MediaGalleryBloc.SearchMediaEvent (PRIMARY search handler)
   - Dedicated search BLoC (separate concern)
   
   CONSOLIDATION STRATEGY:
   1. MediaGalleryBloc = Primary handler for:
      - SearchMediaEvent(query) → integrated gallery search
      - Uses same AdvancedSearchRankingService for ranking
      - Single state source for filtered + searched results
   
   2. MediaSearchBloc = DEPRECATED/SECONDARY  
      - Standalone search without gallery context
      - Kept for reference but not registered in DI
      - If used, migrate to MediaGalleryBloc.SearchMediaEvent
   
   MIGRATION PATH:
   - Old: MediaSearchBloc.add(PerformMediaSearchEvent('query'))
   - New: MediaGalleryBloc.add(SearchMediaEvent(query: 'query'))
   
   BENEFITS:
   ✅ Single media management source (MediaGalleryBloc)
   ✅ Consistent search across the app
   ✅ Easier maintenance and testing
   ✅ Reduced BLoC count (was 5+ separate)
══════════════════════════════════════════════════════════════════════════════ */

// Events
abstract class MediaSearchEvent extends Equatable {
  const MediaSearchEvent();
  @override
  List<Object?> get props => [];
}

class PerformMediaSearchEvent extends MediaSearchEvent {
  final String query;
  const PerformMediaSearchEvent(this.query);
  @override
  List<Object?> get props => [query];
}

// States
abstract class MediaSearchState extends Equatable {
  const MediaSearchState();
  @override
  List<Object?> get props => [];
}

class MediaSearchInitial extends MediaSearchState {}

class MediaSearchLoading extends MediaSearchState {}

class MediaSearchLoaded extends MediaSearchState {
  final List<({dynamic item, double score})> results;
  final String query;
  const MediaSearchLoaded(this.results, this.query);
  @override
  List<Object?> get props => [results, query];
}

class MediaSearchError extends MediaSearchState {
  final String message;
  const MediaSearchError(this.message);
  @override
  List<Object?> get props => [message];
}

// BLoC
class MediaSearchBloc extends Bloc<MediaSearchEvent, MediaSearchState> {
  final MediaRepository mediaRepository;
  final AdvancedSearchRankingService _searchService =
      AdvancedSearchRankingService();

  MediaSearchBloc({required this.mediaRepository})
    : super(MediaSearchInitial()) {
    on<PerformMediaSearchEvent>(_onPerformSearch);
  }

  Future<void> _onPerformSearch(
    PerformMediaSearchEvent event,
    Emitter<MediaSearchState> emit,
  ) async {
    if (event.query.isEmpty) {
      emit(const MediaSearchLoaded([], ''));
      return;
    }

    emit(MediaSearchLoading());
    try {
      final items = await mediaRepository.getAllMedia();
      final results = await _searchService.advancedSearch(
        items: items,
        query: event.query,
      );
      emit(MediaSearchLoaded(results, event.query));
    } catch (e) {
      emit(MediaSearchError('Search failed: ${e.toString()}'));
    }
  }
}
