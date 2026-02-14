import 'package:flutter/material.dart';

class NLFilter {
  final DateTime? startDate;
  final DateTime? endDate;
  final String remainingText;
  final List<String> tags;
  final int? priority;
  final bool? isCompleted;

  NLFilter({
    this.startDate,
    this.endDate,
    this.remainingText = '',
    this.tags = const [],
    this.priority,
    this.isCompleted,
  });

  bool get hasDateRange => startDate != null || endDate != null;

  DateTimeRange? get dateRange {
    if (startDate == null && endDate == null) return null;
    return DateTimeRange(
      start: startDate ?? DateTime(2000),
      end: endDate ?? DateTime(2100),
    );
  }
}

class NLFilterParser {
  /// Parses natural language strings into filter configurations.
  static NLFilter parse(String query) {
    if (query.isEmpty) return NLFilter();

    final lower = query.toLowerCase();
    DateTime? start;
    DateTime? end;
    String remaining = query;
    List<String> tags = [];
    int? priorityValue;
    bool? isCompleted;

    // 1. Detect Time Range
    final now = DateTime.now();
    if (lower.contains('today')) {
      start = DateTime(now.year, now.month, now.day);
      end = DateTime(now.year, now.month, now.day, 23, 59);
    } else if (lower.contains('yesterday')) {
      start = DateTime(now.year, now.month, now.day - 1);
      end = DateTime(now.year, now.month, now.day - 1, 23, 59);
    } else if (lower.contains('this week')) {
      start = now.subtract(Duration(days: now.weekday - 1));
    } else if (lower.contains('last week')) {
      final lastWeek = now.subtract(const Duration(days: 7));
      start = lastWeek.subtract(Duration(days: lastWeek.weekday - 1));
      end = start.add(const Duration(days: 6, hours: 23, minutes: 59));
    }

    // 2. Detect Priority
    if (lower.contains('urgent') ||
        lower.contains('important') ||
        lower.contains('high priority')) {
      priorityValue = 3;
    } else if (lower.contains('low priority')) {
      priorityValue = 1;
    }

    // 3. Detect Tags
    final tagMatches = RegExp(r'#(\w+)').allMatches(query);
    tags = tagMatches.map((m) => m.group(1)!).toList();

    // 4. Detect Completion Status
    if (lower.contains('done') ||
        lower.contains('completed') ||
        lower.contains('finished')) {
      isCompleted = true;
    } else if (lower.contains('todo') ||
        lower.contains('pending') ||
        lower.contains('active')) {
      isCompleted = false;
    }

    // 5. Remaining text
    remaining = query
        .replaceAll(
          RegExp(
            r'(today|yesterday|this week|last week|urgent|important|high priority|low priority|done|completed|finished|todo|pending|active)',
            caseSensitive: false,
          ),
          '',
        )
        .replaceAll(RegExp(r'#\w+'), '')
        .trim();

    return NLFilter(
      startDate: start,
      endDate: end,
      remainingText: remaining,
      tags: tags,
      priority: priorityValue,
      isCompleted: isCompleted,
    );
  }
}
