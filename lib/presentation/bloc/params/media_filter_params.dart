import 'package:equatable/equatable.dart';

/// Parameters for Advanced Media Filtering (Batch 4)
/// 📸 Encapsulates all filter criteria for media gallery
class MediaFilterParams extends Equatable {
  final String? selectedType;
  final DateTime? fromDate;
  final DateTime? toDate;
  final int? minSizeBytes;
  final int? maxSizeBytes;
  final List<String> selectedTags;
  final bool excludeArchived;

  const MediaFilterParams({
    this.selectedType,
    this.fromDate,
    this.toDate,
    this.minSizeBytes,
    this.maxSizeBytes,
    this.selectedTags = const [],
    this.excludeArchived = true,
  });

  factory MediaFilterParams.initial() {
    return const MediaFilterParams();
  }

  MediaFilterParams copyWith({
    String? selectedType,
    DateTime? fromDate,
    DateTime? toDate,
    int? minSizeBytes,
    int? maxSizeBytes,
    List<String>? selectedTags,
    bool? excludeArchived,
  }) {
    return MediaFilterParams(
      selectedType:
          selectedType ?? (selectedType == null ? this.selectedType : null),
      fromDate: fromDate ?? this.fromDate,
      toDate: toDate ?? this.toDate,
      minSizeBytes: minSizeBytes ?? this.minSizeBytes,
      maxSizeBytes: maxSizeBytes ?? this.maxSizeBytes,
      selectedTags: selectedTags ?? this.selectedTags,
      excludeArchived: excludeArchived ?? this.excludeArchived,
    );
  }

  /// Special copyWith specifically to handle "setting to null" for dates and types
  MediaFilterParams resetField({
    bool selectedType = false,
    bool fromDate = false,
    bool toDate = false,
    bool minSizeBytes = false,
    bool maxSizeBytes = false,
  }) {
    return MediaFilterParams(
      selectedType: selectedType ? null : this.selectedType,
      fromDate: fromDate ? null : this.fromDate,
      toDate: toDate ? null : this.toDate,
      minSizeBytes: minSizeBytes ? null : this.minSizeBytes,
      maxSizeBytes: maxSizeBytes ? null : this.maxSizeBytes,
      selectedTags: this.selectedTags,
      excludeArchived: this.excludeArchived,
    );
  }

  @override
  List<Object?> get props => [
    selectedType,
    fromDate,
    toDate,
    minSizeBytes,
    maxSizeBytes,
    selectedTags,
    excludeArchived,
  ];
}
