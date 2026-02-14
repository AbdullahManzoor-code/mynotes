/// Advanced media filtering and ranking service
class MediaFilteringService {
  static final MediaFilteringService _instance =
      MediaFilteringService._internal();

  factory MediaFilteringService() {
    return _instance;
  }

  MediaFilteringService._internal();

  /// Advanced filter by multiple criteria
  Future<List<dynamic>> advancedFilter({
    required List<dynamic> mediaItems,
    String? typeFilter,
    DateTime? fromDate,
    DateTime? toDate,
    int? minSizeBytes,
    int? maxSizeBytes,
    List<String>? tags,
    bool excludeArchived = true,
  }) async {
    try {
      var filtered = List.from(mediaItems);

      // Filter by type
      if (typeFilter != null && typeFilter.isNotEmpty) {
        filtered = filtered
            .where((m) => m.type?.toLowerCase() == typeFilter.toLowerCase())
            .toList();
      }

      // Filter by date range
      if (fromDate != null || toDate != null) {
        filtered = filtered.where((m) {
          final itemDate = DateTime.tryParse(m.createdAt ?? '');
          if (itemDate == null) return false;

          if (fromDate != null && itemDate.isBefore(fromDate)) return false;
          if (toDate != null && itemDate.isAfter(toDate)) return false;

          return true;
        }).toList();
      }

      // Filter by file size
      if (minSizeBytes != null) {
        filtered = filtered
            .where((m) => (m.size ?? 0) >= minSizeBytes)
            .toList();
      }
      if (maxSizeBytes != null) {
        filtered = filtered
            .where((m) => (m.size ?? 0) <= maxSizeBytes)
            .toList();
      }

      // Filter by tags (if any match)
      if (tags != null && tags.isNotEmpty) {
        filtered = filtered.where((m) {
          final itemTags = (m.tags as List<String>?) ?? [];
          return tags.any(
            (tag) => itemTags.any((t) => t.toLowerCase() == tag.toLowerCase()),
          );
        }).toList();
      }

      // Exclude archived
      if (excludeArchived) {
        filtered = filtered.where((m) => !(m.isArchived ?? false)).toList();
      }

      return filtered;
    } catch (e) {
      throw Exception('Advanced filter failed: ${e.toString()}');
    }
  }

  /// Smart search with ranking algorithm
  Future<List<dynamic>> smartSearch(
    List<dynamic> mediaItems,
    String query, {
    bool fuzzyMatch = true,
    bool boostRecent = true,
  }) async {
    if (query.isEmpty) return mediaItems;

    try {
      final searchQuery = query.toLowerCase();

      // Score each item
      final scoredItems = <(dynamic item, double score)>[];

      for (final item in mediaItems) {
        double score = 0;

        final itemName = (item.name ?? '').toLowerCase();

        // Exact match (highest priority)
        if (itemName == searchQuery) {
          score += 100;
        }
        // Starts with query
        else if (itemName.startsWith(searchQuery)) {
          score += 75;
        }
        // Contains query as word boundary
        else if (RegExp(r'\b$searchQuery\b').hasMatch(itemName)) {
          score += 50;
        }
        // Contains query
        else if (itemName.contains(searchQuery)) {
          score += 30;
        }
        // Fuzzy match (Levenshtein distance)
        else if (fuzzyMatch && _fuzzyMatch(itemName, searchQuery)) {
          score += 15;
        }

        // Boost recent items (if enabled)
        if (boostRecent && item.createdAt != null) {
          final itemDate = DateTime.tryParse(item.createdAt!);
          if (itemDate != null) {
            final daysOld = DateTime.now().difference(itemDate).inDays;
            final recencyBoost = (30 - daysOld.clamp(0, 30)) / 30 * 10;
            score += recencyBoost;
          }
        }

        // Tag bonus
        if (item.tags != null) {
          final tagMatches =
              (item.tags as List<String>?)
                  ?.where((tag) => tag.toLowerCase().contains(searchQuery))
                  .length ??
              0;
          score += tagMatches * 5;
        }

        if (score > 0) {
          scoredItems.add((item, score));
        }
      }

      // Sort by score (descending)
      scoredItems.sort((a, b) => b.$2.compareTo(a.$2));

      return scoredItems.map((scored) => scored.$1).toList();
    } catch (e) {
      throw Exception('Smart search failed: ${e.toString()}');
    }
  }

  /// Fuzzy string matching using Levenshtein distance
  bool _fuzzyMatch(String str, String pattern) {
    const maxDistance = 2;
    final distance = _levenshteinDistance(str, pattern);
    return distance <= maxDistance;
  }

  /// Calculate Levenshtein distance between two strings
  int _levenshteinDistance(String s1, String s2) {
    final len1 = s1.length;
    final len2 = s2.length;

    final d = List<List<int>>.generate(
      len1 + 1,
      (i) => List<int>.filled(len2 + 1, 0),
    );

    for (int i = 0; i <= len1; i++) {
      d[i][0] = i;
    }
    for (int j = 0; j <= len2; j++) {
      d[0][j] = j;
    }

    for (int i = 1; i <= len1; i++) {
      for (int j = 1; j <= len2; j++) {
        final cost = s1[i - 1] == s2[j - 1] ? 0 : 1;
        d[i][j] = [
          d[i - 1][j] + 1,
          d[i][j - 1] + 1,
          d[i - 1][j - 1] + cost,
        ].reduce((a, b) => a < b ? a : b);
      }
    }

    return d[len1][len2];
  }

  /// Get media statistics and analytics
  Future<Map<String, dynamic>> getMediaAnalytics(
    List<dynamic> mediaItems,
  ) async {
    try {
      if (mediaItems.isEmpty) {
        return {
          'totalCount': 0,
          'totalSize': 0,
          'averageSize': 0,
          'typeBreakdown': {},
          'oldestItem': null,
          'newestItem': null,
          'averageItemsPerDay': 0,
        };
      }

      int totalSize = 0;
      final typeCount = <String, int>{};
      DateTime? oldest, newest;

      for (final item in mediaItems) {
        totalSize += (item.size ?? 0) as int;

        final type = item.type ?? 'unknown';
        typeCount[type] = (typeCount[type] ?? 0) + 1;

        if (item.createdAt != null) {
          final date = DateTime.tryParse(item.createdAt!);
          if (date != null) {
            oldest ??= date;
            newest ??= date;
            if (date.isBefore(oldest)) oldest = date;
            if (date.isAfter(newest)) newest = date;
          }
        }
      }

      // Calculate average items per day
      double avgPerDay = 0;
      if (oldest != null && newest != null) {
        final daysDiff = newest.difference(oldest).inDays + 1;
        avgPerDay = mediaItems.length / daysDiff;
      }

      return {
        'totalCount': mediaItems.length,
        'totalSize': totalSize,
        'averageSize': totalSize ~/ mediaItems.length,
        'typeBreakdown': typeCount,
        'oldestItem': oldest?.toString(),
        'newestItem': newest?.toString(),
        'averageItemsPerDay': avgPerDay,
      };
    } catch (e) {
      throw Exception('Analytics calculation failed: ${e.toString()}');
    }
  }

  /// Group media by specified criteria
  Future<Map<String, List<dynamic>>> groupMedia(
    List<dynamic> mediaItems, {
    required String groupBy, // 'type', 'date', 'size'
  }) async {
    try {
      final grouped = <String, List<dynamic>>{};

      for (final item in mediaItems) {
        String key;

        switch (groupBy.toLowerCase()) {
          case 'type':
            key = item.type ?? 'unknown';
            break;
          case 'date':
            if (item.createdAt != null) {
              final date = DateTime.tryParse(item.createdAt!);
              key = date != null
                  ? '${date.year}-${date.month}-${date.day}'
                  : 'unknown';
            } else {
              key = 'unknown';
            }
            break;
          case 'size':
            final size = item.size ?? 0;
            if (size < 1024 * 1024) {
              key = '< 1 MB';
            } else if (size < 10 * 1024 * 1024) {
              key = '1-10 MB';
            } else if (size < 100 * 1024 * 1024) {
              key = '10-100 MB';
            } else {
              key = '> 100 MB';
            }
            break;
          default:
            key = 'other';
        }

        grouped.putIfAbsent(key, () => []).add(item);
      }

      return grouped;
    } catch (e) {
      throw Exception('Grouping failed: ${e.toString()}');
    }
  }
}
