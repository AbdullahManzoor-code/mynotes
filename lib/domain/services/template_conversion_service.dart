// Removed unused import

/// Service for converting templates to reminders
class TemplateConversionService {
  static final TemplateConversionService _instance =
      TemplateConversionService._internal();

  factory TemplateConversionService() {
    return _instance;
  }

  TemplateConversionService._internal();

  /// Convert a template to a reminder with all required fields
  Future<Map<String, dynamic>> convertTemplateToReminder({
    required Map<String, dynamic> template,
    Map<String, dynamic>? overrides,
  }) async {
    try {
      final reminder = <String, dynamic>{};

      // Copy basic fields from template
      reminder['title'] =
          overrides?['title'] ?? template['title'] ?? 'Untitled Reminder';
      reminder['description'] =
          overrides?['description'] ?? template['description'] ?? '';

      // Handle schedule/timing
      final schedule = _calculateSchedule(template, overrides);
      reminder['scheduledTime'] = schedule['scheduledTime'];
      reminder['recurrencePattern'] =
          overrides?['recurrencePattern'] ?? template['recurrencePattern'];
      reminder['recurrenceFrequency'] =
          overrides?['recurrenceFrequency'] ?? template['recurrenceFrequency'];

      // Handle priority
      reminder['priority'] =
          overrides?['priority'] ?? template['priority'] ?? 'normal';

      // Handle categories/tags
      reminder['category'] = overrides?['category'] ?? template['category'];
      reminder['tags'] = _processTags(overrides?['tags'] ?? template['tags']);

      // Handle notification settings
      reminder['notificationEnabled'] =
          overrides?['notificationEnabled'] ??
          template['notificationEnabled'] ??
          true;
      reminder['notificationTime'] =
          overrides?['notificationTime'] ?? template['notificationTime'];

      // Handle attachments
      reminder['attachments'] =
          overrides?['attachments'] ?? template['attachments'] ?? [];

      // Add metadata
      reminder['createdFromTemplate'] = template['id'] ?? 'unknown';
      reminder['createdAt'] = DateTime.now().toString();

      // Fill any missing required fields with defaults
      reminder['isArchived'] = false;
      reminder['isCompleted'] = false;
      reminder['customFields'] = _processCustomFields(template, overrides);

      return reminder;
    } catch (e) {
      throw Exception('Template conversion failed: ${e.toString()}');
    }
  }

  /// Convert template to recurring reminder
  Future<Map<String, dynamic>> convertToRecurringReminder({
    required Map<String, dynamic> template,
    required String recurrencePattern,
    required int recurrenceCount,
    DateTime? startDate,
  }) async {
    try {
      final reminders = <Map<String, dynamic>>[];
      final start = startDate ?? DateTime.now();

      for (int i = 0; i < recurrenceCount; i++) {
        final scheduleDate = _calculateRecurrenceDate(
          start,
          recurrencePattern,
          i,
        );

        final reminder = await convertTemplateToReminder(
          template: template,
          overrides: {
            'scheduledTime': scheduleDate.toString(),
            'title': '${template['title']} - ${i + 1}',
          },
        );

        reminders.add(reminder);
      }

      return {
        'reminders': reminders,
        'pattern': recurrencePattern,
        'count': recurrenceCount,
        'generatedAt': DateTime.now().toString(),
      };
    } catch (e) {
      throw Exception('Recurring reminder conversion failed: ${e.toString()}');
    }
  }

  /// Create template from existing reminder
  Future<Map<String, dynamic>> createTemplateFromReminder({
    required Map<String, dynamic> reminder,
    required String templateName,
    String? templateDescription,
  }) async {
    try {
      return {
        'id': _generateTemplateId(),
        'name': templateName,
        'description': templateDescription ?? 'Template created from reminder',
        'title': reminder['title'],
        'description': reminder['description'],
        'priority': reminder['priority'] ?? 'normal',
        'category': reminder['category'],
        'tags': reminder['tags'] ?? [],
        'notificationEnabled': reminder['notificationEnabled'] ?? true,
        'notificationTime': reminder['notificationTime'],
        'attachments': reminder['attachments'] ?? [],
        'recurrencePattern': reminder['recurrencePattern'],
        'recurrenceFrequency': reminder['recurrenceFrequency'],
        'customFields': reminder['customFields'] ?? {},
        'createdFromReminder': reminder['id'] ?? 'unknown',
        'createdAt': DateTime.now().toString(),
        'isActive': true,
        'usageCount': 0,
      };
    } catch (e) {
      throw Exception('Template creation failed: ${e.toString()}');
    }
  }

  /// Batch convert templates to reminders
  Future<List<Map<String, dynamic>>> batchConvertTemplates({
    required List<Map<String, dynamic>> templates,
    Map<String, dynamic>? commonOverrides,
  }) async {
    try {
      final reminders = <Map<String, dynamic>>[];

      for (final template in templates) {
        final reminder = await convertTemplateToReminder(
          template: template,
          overrides: commonOverrides,
        );
        reminders.add(reminder);
      }

      return reminders;
    } catch (e) {
      throw Exception('Batch conversion failed: ${e.toString()}');
    }
  }

  /// Validate template before conversion
  Future<bool> validateTemplate(Map<String, dynamic> template) async {
    try {
      if (template['title'] == null || template['title'].toString().isEmpty) {
        throw Exception('Template must have a title');
      }

      if (template['recurrencePattern'] != null) {
        if (!_isValidRecurrencePattern(
          template['recurrencePattern'] as String,
        )) {
          throw Exception('Invalid recurrence pattern');
        }
      }

      return true;
    } catch (e) {
      throw Exception('Template validation failed: ${e.toString()}');
    }
  }

  /// Get schedule details from template
  Future<Map<String, dynamic>> getTemplateScheduleDetails(
    Map<String, dynamic> template,
  ) async {
    try {
      final schedule = _calculateSchedule(template, null);

      return {
        'scheduledTime': schedule['scheduledTime'],
        'recurringPattern': template['recurrencePattern'],
        'frequency': template['recurrenceFrequency'],
        'nextOccurrence': schedule['nextOccurrence'],
        'timezone': 'local',
        'type': schedule['type'],
      };
    } catch (e) {
      throw Exception('Schedule retrieval failed: ${e.toString()}');
    }
  }

  /// Calculate next reminder time based on recurrence pattern
  DateTime _calculateRecurrenceDate(
    DateTime baseDate,
    String pattern,
    int iteration,
  ) {
    switch (pattern.toLowerCase()) {
      case 'daily':
        return baseDate.add(Duration(days: iteration));
      case 'weekly':
        return baseDate.add(Duration(days: iteration * 7));
      case 'biweekly':
        return baseDate.add(Duration(days: iteration * 14));
      case 'monthly':
        return DateTime(
          baseDate.year,
          baseDate.month + iteration,
          baseDate.day,
        );
      case 'yearly':
        return DateTime(
          baseDate.year + iteration,
          baseDate.month,
          baseDate.day,
        );
      default:
        return baseDate;
    }
  }

  /// Calculate schedule from template
  Map<String, dynamic> _calculateSchedule(
    Map<String, dynamic> template,
    Map<String, dynamic>? overrides,
  ) {
    final now = DateTime.now();
    DateTime scheduledTime;

    if (overrides?['scheduledTime'] != null) {
      scheduledTime = DateTime.parse(overrides!['scheduledTime'] as String);
    } else if (template['scheduledTime'] != null) {
      scheduledTime = DateTime.parse(template['scheduledTime'] as String);
    } else {
      // Default to tomorrow at same time
      scheduledTime = now.add(const Duration(days: 1));
    }

    return {
      'scheduledTime': scheduledTime.toString(),
      'nextOccurrence': scheduledTime.toString(),
      'type': _determineScheduleType(template),
    };
  }

  /// Determine schedule type (one-time, daily, weekly, etc.)
  String _determineScheduleType(Map<String, dynamic> template) {
    final pattern = template['recurrencePattern'] as String?;

    if (pattern == null || pattern.isEmpty) {
      return 'one-time';
    }

    return pattern.toLowerCase();
  }

  /// Process and validate tags
  List<String> _processTags(dynamic tags) {
    if (tags is List) {
      return tags
          .map((t) => t.toString().trim())
          .where((t) => t.isNotEmpty)
          .toList();
    }

    if (tags is String) {
      return tags
          .split(',')
          .map((t) => t.trim())
          .where((t) => t.isNotEmpty)
          .toList();
    }

    return [];
  }

  /// Process custom fields from template
  Map<String, dynamic> _processCustomFields(
    Map<String, dynamic> template,
    Map<String, dynamic>? overrides,
  ) {
    final fields = <String, dynamic>{};

    // Copy custom fields from template
    if (template['customFields'] is Map) {
      fields.addAll(template['customFields'] as Map<String, dynamic>);
    }

    // Override with provided values
    if (overrides?['customFields'] is Map) {
      fields.addAll(overrides!['customFields'] as Map<String, dynamic>);
    }

    return fields;
  }

  /// Check if recurrence pattern is valid
  bool _isValidRecurrencePattern(String pattern) {
    const validPatterns = [
      'daily',
      'weekly',
      'biweekly',
      'monthly',
      'yearly',
      'custom',
    ];

    return validPatterns.contains(pattern.toLowerCase());
  }

  /// Generate unique template ID
  String _generateTemplateId() {
    return 'tpl_${DateTime.now().millisecondsSinceEpoch}';
  }

  /// Get template usage statistics
  Future<Map<String, dynamic>> getTemplateUsageStats(
    String templateId,
    List<Map<String, dynamic>> generatedReminders,
  ) async {
    try {
      final fromTemplate = generatedReminders
          .where((r) => r['createdFromTemplate'] == templateId)
          .length;

      return {
        'templateId': templateId,
        'usageCount': fromTemplate,
        'lastUsed': generatedReminders
            .where((r) => r['createdFromTemplate'] == templateId)
            .fold<DateTime?>(null, (prev, curr) {
              final date = DateTime.tryParse(curr['createdAt'] ?? '');
              if (prev == null || (date != null && date.isAfter(prev))) {
                return date;
              }
              return prev;
            })
            ?.toString(),
        'effectiveness':
            'high', // Could be calculated from reminder completion rates
      };
    } catch (e) {
      throw Exception('Usage stats retrieval failed: ${e.toString()}');
    }
  }
}
