import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/services/media_filtering_service.dart';
import '../../domain/repositories/media_repository.dart';

// Events
abstract class MediaOrganizationEvent extends Equatable {
  const MediaOrganizationEvent();
  @override
  List<Object?> get props => [];
}

class LoadMediaOrganizationEvent extends MediaOrganizationEvent {
  final String groupBy;
  const LoadMediaOrganizationEvent({required this.groupBy});
  @override
  List<Object?> get props => [groupBy];
}

// States
abstract class MediaOrganizationState extends Equatable {
  const MediaOrganizationState();
  @override
  List<Object?> get props => [];
}

class MediaOrganizationInitial extends MediaOrganizationState {}

class MediaOrganizationLoading extends MediaOrganizationState {}

class MediaOrganizationLoaded extends MediaOrganizationState {
  final Map<String, List<dynamic>> groupedMedia;
  final String groupBy;
  const MediaOrganizationLoaded(this.groupedMedia, this.groupBy);
  @override
  List<Object?> get props => [groupedMedia, groupBy];
}

class MediaOrganizationError extends MediaOrganizationState {
  final String message;
  const MediaOrganizationError(this.message);
  @override
  List<Object?> get props => [message];
}

// BLoC
class MediaOrganizationBloc
    extends Bloc<MediaOrganizationEvent, MediaOrganizationState> {
  final MediaRepository mediaRepository;
  final MediaFilteringService _filteringService = MediaFilteringService();

  MediaOrganizationBloc({required this.mediaRepository})
    : super(MediaOrganizationInitial()) {
    on<LoadMediaOrganizationEvent>(_onLoadOrganization);
  }

  Future<void> _onLoadOrganization(
    LoadMediaOrganizationEvent event,
    Emitter<MediaOrganizationState> emit,
  ) async {
    emit(MediaOrganizationLoading());
    try {
      final items = await mediaRepository.getAllMedia();
      final grouped = await _filteringService.groupMedia(
        items,
        groupBy: event.groupBy,
      );
      emit(MediaOrganizationLoaded(grouped, event.groupBy));
    } catch (e) {
      emit(MediaOrganizationError('Failed to group media: ${e.toString()}'));
    }
  }
}
