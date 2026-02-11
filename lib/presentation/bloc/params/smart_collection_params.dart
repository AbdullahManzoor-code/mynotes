import 'package:equatable/equatable.dart';

/// Complete Param Model for Smart Collection Operations
/// 📦 Container for all smart collection-related data
class SmartCollectionParams extends Equatable {
  final String? collectionId;
  final String name;
  final String description;
  final List<String> filterTags;
  final String sortBy; // date, alphabetical, color
  final bool includeArchived;
  final bool isPinned;
  final String? iconEmoji;
  final int? maxItems;

  const SmartCollectionParams({
    this.collectionId,
    this.name = '',
    this.description = '',
    this.filterTags = const [],
    this.sortBy = 'date',
    this.includeArchived = false,
    this.isPinned = false,
    this.iconEmoji,
    this.maxItems,
  });

  SmartCollectionParams copyWith({
    String? collectionId,
    String? name,
    String? description,
    List<String>? filterTags,
    String? sortBy,
    bool? includeArchived,
    bool? isPinned,
    String? iconEmoji,
    int? maxItems,
  }) {
    return SmartCollectionParams(
      collectionId: collectionId ?? this.collectionId,
      name: name ?? this.name,
      description: description ?? this.description,
      filterTags: filterTags ?? this.filterTags,
      sortBy: sortBy ?? this.sortBy,
      includeArchived: includeArchived ?? this.includeArchived,
      isPinned: isPinned ?? this.isPinned,
      iconEmoji: iconEmoji ?? this.iconEmoji,
      maxItems: maxItems ?? this.maxItems,
    );
  }

  SmartCollectionParams addTag(String tag) {
    if (filterTags.contains(tag)) return this;
    return copyWith(filterTags: [...filterTags, tag]);
  }

  SmartCollectionParams removeTag(String tag) {
    return copyWith(filterTags: filterTags.where((t) => t != tag).toList());
  }

  SmartCollectionParams togglePin() => copyWith(isPinned: !isPinned);
  SmartCollectionParams toggleArchived() =>
      copyWith(includeArchived: !includeArchived);

  @override
  List<Object?> get props => [
    collectionId,
    name,
    description,
    filterTags,
    sortBy,
    includeArchived,
    isPinned,
    iconEmoji,
    maxItems,
  ];
}
