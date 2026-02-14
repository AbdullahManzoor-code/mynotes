import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../domain/services/media_filtering_service.dart';
import '../../../../domain/repositories/media_repository.dart';

// Events
abstract class MediaAnalyticsEvent extends Equatable {
  const MediaAnalyticsEvent();
  @override
  List<Object?> get props => [];
}

class LoadMediaAnalyticsEvent extends MediaAnalyticsEvent {}

// States
abstract class MediaAnalyticsState extends Equatable {
  const MediaAnalyticsState();
  @override
  List<Object?> get props => [];
}

class MediaAnalyticsInitial extends MediaAnalyticsState {}

class MediaAnalyticsLoading extends MediaAnalyticsState {}

class MediaAnalyticsLoaded extends MediaAnalyticsState {
  final Map<String, dynamic> analytics;
  const MediaAnalyticsLoaded(this.analytics);
  @override
  List<Object?> get props => [analytics];
}

class MediaAnalyticsError extends MediaAnalyticsState {
  final String message;
  const MediaAnalyticsError(this.message);
  @override
  List<Object?> get props => [message];
}

// BLoC
class MediaAnalyticsBloc
    extends Bloc<MediaAnalyticsEvent, MediaAnalyticsState> {
  final MediaRepository mediaRepository;
  final MediaFilteringService _filteringService = MediaFilteringService();

  MediaAnalyticsBloc({required this.mediaRepository})
    : super(MediaAnalyticsInitial()) {
    on<LoadMediaAnalyticsEvent>(_onLoadAnalytics);
  }

  Future<void> _onLoadAnalytics(
    LoadMediaAnalyticsEvent event,
    Emitter<MediaAnalyticsState> emit,
  ) async {
    emit(MediaAnalyticsLoading());
    try {
      final items = await mediaRepository.getAllMedia();
      final analytics = await _filteringService.getMediaAnalytics(items);
      emit(MediaAnalyticsLoaded(analytics));
    } catch (e) {
      emit(MediaAnalyticsError('Failed to load analytics: ${e.toString()}'));
    }
  }
}
