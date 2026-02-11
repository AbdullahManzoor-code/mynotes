import 'package:equatable/equatable.dart';

class UnifiedItemsParams extends Equatable {
  final String selectedFilter; // 'all', 'notes', 'todos', 'reminders'
  final String sortBy; // 'recent', 'priority', 'due-date'
  final bool showOnlyPinned;
  final String searchQuery;

  const UnifiedItemsParams({
    this.selectedFilter = 'all',
    this.sortBy = 'recent',
    this.showOnlyPinned = false,
    this.searchQuery = '',
  });

  UnifiedItemsParams copyWith({
    String? selectedFilter,
    String? sortBy,
    bool? showOnlyPinned,
    String? searchQuery,
  }) {
    return UnifiedItemsParams(
      selectedFilter: selectedFilter ?? this.selectedFilter,
      sortBy: sortBy ?? this.sortBy,
      showOnlyPinned: showOnlyPinned ?? this.showOnlyPinned,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  @override
  List<Object?> get props => [selectedFilter, sortBy, showOnlyPinned, searchQuery];
}
