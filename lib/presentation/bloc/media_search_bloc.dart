import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/services/advanced_search_ranking_service.dart';
import '../../domain/repositories/media_repository.dart';

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
