import 'package:equatable/equatable.dart';
import 'package:mynotes/presentation/bloc/media_filters/media_filters_state.dart'
    show FilterType;
import '../../pages/media_filters_screen.dart';

abstract class MediaFiltersEvent extends Equatable {
  const MediaFiltersEvent();

  @override
  List<Object?> get props => [];
}

class ApplyFilterEvent extends MediaFiltersEvent {
  final FilterType filter;
  const ApplyFilterEvent(this.filter);

  @override
  List<Object?> get props => [filter];
}

class UpdateIntensityEvent extends MediaFiltersEvent {
  final double intensity;
  const UpdateIntensityEvent(this.intensity);

  @override
  List<Object?> get props => [intensity];
}

class TogglePreviewEvent extends MediaFiltersEvent {
  const TogglePreviewEvent();
}

class ResetFilterEvent extends MediaFiltersEvent {
  const ResetFilterEvent();
}
