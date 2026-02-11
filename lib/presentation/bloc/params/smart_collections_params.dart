import 'package:equatable/equatable.dart';
import '../../../domain/entities/smart_collection.dart';

class SmartCollectionsParams extends Equatable {
  final List<SmartCollection> collections;
  final String selectedFilter;
  final bool isLoading;
  final String? searchQuery;

  const SmartCollectionsParams({
    this.collections = const [],
    this.selectedFilter = 'all',
    this.isLoading = false,
    this.searchQuery,
  });

  List<SmartCollection> get filteredCollections {
    var items = collections;

    // Apply type filter
    if (selectedFilter == 'active') {
      items = items.where((c) => c.isActive).toList();
    } else if (selectedFilter == 'archived') {
      items = items.where((c) => !c.isActive).toList();
    }

    // Apply search query
    if (searchQuery != null && searchQuery!.isNotEmpty) {
      final query = searchQuery!.toLowerCase();
      items = items
          .where(
            (c) =>
                c.name.toLowerCase().contains(query) ||
                c.description.toLowerCase().contains(query),
          )
          .toList();
    }

    return items;
  }

  SmartCollectionsParams copyWith({
    List<SmartCollection>? collections,
    String? selectedFilter,
    bool? isLoading,
    String? searchQuery,
  }) {
    return SmartCollectionsParams(
      collections: collections ?? this.collections,
      selectedFilter: selectedFilter ?? this.selectedFilter,
      isLoading: isLoading ?? this.isLoading,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  @override
  List<Object?> get props => [
    collections,
    selectedFilter,
    isLoading,
    searchQuery,
  ];
}
