import 'package:equatable/equatable.dart';

class SearchFilters extends Equatable {
  final List<String> types;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? category;
  final String sortBy;
  final bool sortDescending;

  const SearchFilters({
    this.types = const [],
    this.startDate,
    this.endDate,
    this.category,
    this.sortBy = 'updated_at',
    this.sortDescending = true,
  });

  SearchFilters copyWith({
    List<String>? types,
    DateTime? startDate,
    DateTime? endDate,
    String? category,
    String? sortBy,
    bool? sortDescending,
  }) {
    return SearchFilters(
      types: types ?? this.types,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      category: category ?? this.category,
      sortBy: sortBy ?? this.sortBy,
      sortDescending: sortDescending ?? this.sortDescending,
    );
  }

  @override
  List<Object?> get props => [
    types,
    startDate,
    endDate,
    category,
    sortBy,
    sortDescending,
  ];
}
