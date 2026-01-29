/// Advanced search ranking and relevance scoring service
class AdvancedSearchRankingService {
  static final AdvancedSearchRankingService _instance =
      AdvancedSearchRankingService._internal();

  factory AdvancedSearchRankingService() {
    return _instance;
  }

  AdvancedSearchRankingService._internal();

  /// Constants for TF-IDF scoring
  static const double exactMatchWeight = 100.0;
  static const double titleMatchWeight = 50.0;
  static const double contentMatchWeight = 30.0;
  static const double tagMatchWeight = 20.0;
  static const double recencyWeight = 10.0;
  static const double popularityWeight = 5.0;

  /// Perform advanced search with TF-IDF ranking
  Future<List<({dynamic item, double score})>> advancedSearch({
    required List<dynamic> items,
    required String query,
    Map<String, dynamic>? filters,
    Map<String, double>? weightOverrides,
  }) async {
    try {
      if (query.isEmpty) return [];

      // Prepare items with scores
      final scoredItems = <({dynamic item, double score})>[];

      // Tokenize and analyze query
      final queryTokens = _tokenize(query);
      final queryLength = queryTokens.length;

      // Calculate IDF values
      final idfValues = _calculateIDF(items, queryTokens);

      for (final item in items) {
        double score = 0;

        // Exact match for query
        if (_matchesExactly(item, query)) {
          score += exactMatchWeight;
        }

        // Term frequency and IDF scoring
        final itemText = _getItemText(item);
        final itemTokens = _tokenize(itemText);

        for (final token in queryTokens) {
          final tf = _calculateTF(itemTokens, token);
          final idf = idfValues[token] ?? 1.0;
          final tfidf = tf * idf;

          score += tfidf * (contentMatchWeight / queryLength);
        }

        // Title-based scoring
        final itemTitle = (item.title ?? item.name ?? '').toLowerCase();
        for (final token in queryTokens) {
          if (itemTitle.contains(token)) {
            score += titleMatchWeight / queryLength;
          }
        }

        // Tag-based scoring
        if (item.tags != null) {
          final tags = (item.tags as List<String>?) ?? [];
          for (final token in queryTokens) {
            if (tags.any((tag) => tag.toLowerCase().contains(token))) {
              score += tagMatchWeight / queryLength;
            }
          }
        }

        // Recency boost
        final recencyScore = _calculateRecencyScore(item);
        score += recencyScore * recencyWeight;

        // Popularity boost
        final popularityScore = _calculatePopularityScore(item);
        score += popularityScore * popularityWeight;

        // Apply weight overrides
        if (weightOverrides != null) {
          final customWeight = weightOverrides['customWeight'] ?? 1.0;
          score *= customWeight;
        }

        // Apply filters
        if (filters != null && !_applyFilters(item, filters)) {
          continue;
        }

        if (score > 0) {
          scoredItems.add((item: item, score: score));
        }
      }

      // Sort by score (descending)
      scoredItems.sort((a, b) => b.score.compareTo(a.score));

      return scoredItems;
    } catch (e) {
      throw Exception('Advanced search failed: ${e.toString()}');
    }
  }

  /// Calculate TF-IDF for better relevance ranking
  Map<String, double> _calculateIDF(List<dynamic> items, List<String> tokens) {
    final idfMap = <String, double>{};
    final docCount = items.length.toDouble();

    for (final token in tokens) {
      int docsContainingToken = 0;

      for (final item in items) {
        final itemText = _getItemText(item).toLowerCase();
        if (itemText.contains(token)) {
          docsContainingToken++;
        }
      }

      // IDF formula: log(total_docs / docs_containing_term)
      final idf = docsContainingToken > 0
          ? (docCount / docsContainingToken).toStringAsFixed(4)
          : '0.0';
      idfMap[token] = double.parse(idf);
    }

    return idfMap;
  }

  /// Calculate term frequency in a document
  double _calculateTF(List<String> tokens, String term) {
    if (tokens.isEmpty) return 0;

    int count = 0;
    for (final token in tokens) {
      if (token == term) count++;
    }

    return count / tokens.length;
  }

  /// Calculate recency score (newer items score higher)
  double _calculateRecencyScore(dynamic item) {
    try {
      if (item.createdAt == null) return 0;

      final itemDate = DateTime.tryParse(item.createdAt!);
      if (itemDate == null) return 0;

      final daysOld = DateTime.now().difference(itemDate).inDays;

      // Score decreases over time
      // 0 days old = 1.0, 30 days old = 0.5, 60 days old = 0.0
      return (1.0 - (daysOld / 60)).clamp(0, 1);
    } catch (e) {
      return 0;
    }
  }

  /// Calculate popularity score based on usage/views
  double _calculatePopularityScore(dynamic item) {
    try {
      // Use views count if available
      final views = item.viewCount ?? 0;

      // Use access count if available
      final accessCount = item.accessCount ?? 0;

      // Score based on combined metrics
      final combinedScore = (views + accessCount) / 100;

      return combinedScore.clamp(0, 1);
    } catch (e) {
      return 0;
    }
  }

  /// Tokenize text for better matching
  List<String> _tokenize(String text) {
    return text
        .toLowerCase()
        .split(RegExp(r'[^a-z0-9]+'))
        .where((token) => token.isNotEmpty && token.length > 2)
        .toList();
  }

  /// Get searchable text from item
  String _getItemText(dynamic item) {
    final parts = <String>[];

    if (item.title != null) parts.add(item.title.toString());
    if (item.name != null) parts.add(item.name.toString());
    if (item.description != null) parts.add(item.description.toString());
    if (item.content != null) parts.add(item.content.toString());

    return parts.join(' ');
  }

  /// Check if item matches search query exactly
  bool _matchesExactly(dynamic item, String query) {
    final itemTitle = (item.title ?? item.name ?? '').toString().toLowerCase();
    final queryLower = query.toLowerCase();

    return itemTitle == queryLower;
  }

  /// Apply additional filters to results
  bool _applyFilters(dynamic item, Map<String, dynamic> filters) {
    if (filters.isEmpty) return true;

    // Type filter
    if (filters['type'] != null) {
      if (item.type != filters['type']) return false;
    }

    // Date range filter
    if (filters['fromDate'] != null || filters['toDate'] != null) {
      final itemDate = DateTime.tryParse(item.createdAt ?? '');
      if (itemDate != null) {
        if (filters['fromDate'] != null &&
            itemDate.isBefore(filters['fromDate'] as DateTime)) {
          return false;
        }
        if (filters['toDate'] != null &&
            itemDate.isAfter(filters['toDate'] as DateTime)) {
          return false;
        }
      }
    }

    // Category filter
    if (filters['category'] != null) {
      if (item.category != filters['category']) return false;
    }

    // Status filter
    if (filters['status'] != null) {
      if (item.status != filters['status']) return false;
    }

    // Priority filter
    if (filters['priority'] != null) {
      if (item.priority != filters['priority']) return false;
    }

    return true;
  }

  /// Get detailed ranking metrics for debugging
  Future<Map<String, dynamic>> getRankingMetrics({
    required dynamic item,
    required String query,
  }) async {
    try {
      final queryTokens = _tokenize(query);

      return {
        'item': item,
        'query': query,
        'exactMatch': _matchesExactly(item, query),
        'recencyScore': _calculateRecencyScore(item),
        'popularityScore': _calculatePopularityScore(item),
        'textContent': _getItemText(item),
        'tokenizedQuery': queryTokens,
        'title': item.title ?? item.name,
        'tags': item.tags,
        'createdAt': item.createdAt,
      };
    } catch (e) {
      throw Exception('Metrics calculation failed: ${e.toString()}');
    }
  }

  /// Rank items by multiple criteria
  Future<List<dynamic>> rankByMultipleCriteria({
    required List<dynamic> items,
    required Map<String, double> criteriaWeights,
  }) async {
    try {
      final rankedItems = <({dynamic item, double score})>[];

      for (final item in items) {
        double totalScore = 0;

        // Score by recency
        if (criteriaWeights['recency'] != null) {
          totalScore +=
              _calculateRecencyScore(item) * criteriaWeights['recency']!;
        }

        // Score by popularity
        if (criteriaWeights['popularity'] != null) {
          totalScore +=
              _calculatePopularityScore(item) * criteriaWeights['popularity']!;
        }

        // Score by title match
        if (criteriaWeights['titleMatch'] != null) {
          final titleScore = (item.title != null && item.title.isNotEmpty
              ? 1.0
              : 0.0);
          totalScore += titleScore * criteriaWeights['titleMatch']!;
        }

        // Score by completeness
        if (criteriaWeights['completeness'] != null) {
          final completenessScore = _calculateCompleteness(item);
          totalScore += completenessScore * criteriaWeights['completeness']!;
        }

        rankedItems.add((item: item, score: totalScore));
      }

      // Sort by total score
      rankedItems.sort((a, b) => b.score.compareTo(a.score));

      return rankedItems.map((r) => r.item).toList();
    } catch (e) {
      throw Exception('Multi-criteria ranking failed: ${e.toString()}');
    }
  }

  /// Calculate completeness score (how much metadata is filled)
  double _calculateCompleteness(dynamic item) {
    int fieldsFilled = 0;
    int totalFields = 0;

    final fieldsToCheck = [
      'title',
      'description',
      'category',
      'tags',
      'priority',
      'status',
      'dueDate',
    ];

    for (final field in fieldsToCheck) {
      totalFields++;
      try {
        final value = (item as dynamic).toMap()[field];
        if (value != null && value.toString().isNotEmpty) {
          fieldsFilled++;
        }
      } catch (e) {
        // Field doesn't exist or can't be accessed
      }
    }

    return totalFields > 0 ? fieldsFilled / totalFields : 0;
  }

  /// Get search suggestions based on partial query
  Future<List<String>> getSearchSuggestions({
    required List<dynamic> items,
    required String partialQuery,
    int maxSuggestions = 5,
  }) async {
    try {
      final suggestions = <String>{};

      for (final item in items) {
        // Get title suggestions
        final title = (item.title ?? item.name ?? '').toString().toLowerCase();
        if (title.contains(partialQuery.toLowerCase())) {
          suggestions.add(title);
        }

        // Get tag suggestions
        if (item.tags != null) {
          final tags = (item.tags as List<String>?) ?? [];
          for (final tag in tags) {
            if (tag.toLowerCase().contains(partialQuery.toLowerCase())) {
              suggestions.add(tag);
            }
          }
        }

        // Get category suggestions
        final category = (item.category ?? '').toString().toLowerCase();
        if (category.contains(partialQuery.toLowerCase())) {
          suggestions.add(category);
        }
      }

      return suggestions.take(maxSuggestions).toList();
    } catch (e) {
      throw Exception('Suggestion retrieval failed: ${e.toString()}');
    }
  }
}
