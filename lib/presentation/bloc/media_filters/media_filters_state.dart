import 'package:equatable/equatable.dart';

enum FilterType {
  none,
  grayscale,
  sepia,
  blur,
  brightness,
  contrast,
  saturation,
  invert,
  vintage,
}

abstract class MediaFiltersState extends Equatable {
  final FilterType selectedFilter;
  final double intensity;
  final bool showPreview;

  const MediaFiltersState({
    this.selectedFilter = FilterType.none,
    this.intensity = 50.0,
    this.showPreview = true,
  });

  @override
  List<Object?> get props => [selectedFilter, intensity, showPreview];
}

class MediaFiltersInitial extends MediaFiltersState {
  const MediaFiltersInitial() : super();
}

class MediaFiltersUpdated extends MediaFiltersState {
  const MediaFiltersUpdated({
    required super.selectedFilter,
    required super.intensity,
    required super.showPreview,
  });
}
