import 'package:equatable/equatable.dart';
import 'package:mynotes/presentation/widgets/universal_item_card.dart';
import '../../../domain/models/search_filters.dart';
import '../../../data/repositories/unified_repository.dart';

class GlobalSearchParams extends Equatable {
  final String query;
  final List<UniversalItem> searchResults;
  final bool isSearching;
  final SearchFilters filters;

  const GlobalSearchParams({
    this.query = '',
    this.searchResults = const [],
    this.isSearching = false,
    this.filters = const SearchFilters(),
  });

  GlobalSearchParams copyWith({
    String? query,
    List<UniversalItem>? searchResults,
    bool? isSearching,
    SearchFilters? filters,
  }) {
    return GlobalSearchParams(
      query: query ?? this.query,
      searchResults: searchResults ?? this.searchResults,
      isSearching: isSearching ?? this.isSearching,
      filters: filters ?? this.filters,
    );
  }

  @override
  List<Object?> get props => [query, searchResults, isSearching, filters];
}
