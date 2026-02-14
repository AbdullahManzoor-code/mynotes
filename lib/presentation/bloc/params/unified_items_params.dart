import 'package:equatable/equatable.dart';
import '../../../core/utils/nl_filter_parser.dart';

class UnifiedItemsParams extends Equatable {
  final String selectedFilter; // 'all', 'notes', 'todos', 'reminders'
  final String sortBy; // 'recent', 'priority', 'due-date'
  final bool showOnlyPinned;
  final String searchQuery;
  final NLFilter? smartFilter;

  const UnifiedItemsParams({
    this.selectedFilter = 'all',
    this.sortBy = 'recent',
    this.showOnlyPinned = false,
    this.searchQuery = '',
    this.smartFilter,
  });

  UnifiedItemsParams copyWith({
    String? selectedFilter,
    String? sortBy,
    bool? showOnlyPinned,
    String? searchQuery,
    NLFilter? smartFilter,
  }) {
    return UnifiedItemsParams(
      selectedFilter: selectedFilter ?? this.selectedFilter,
      sortBy: sortBy ?? this.sortBy,
      showOnlyPinned: showOnlyPinned ?? this.showOnlyPinned,
      searchQuery: searchQuery ?? this.searchQuery,
      smartFilter: smartFilter ?? this.smartFilter,
    );
  }

  @override
  List<Object?> get props => [
    selectedFilter,
    sortBy,
    showOnlyPinned,
    searchQuery,
    smartFilter,
  ];
}
