import 'package:flutter/material.dart';

/// Recurrence pattern for recurring tasks
enum RecurrenceType { none, daily, weekly, monthly, yearly }

/// Recurrence pattern entity (REC-001)
class RecurrencePattern {
  final RecurrenceType type;
  final int interval; // Every N days/weeks/months
  final List<int> daysOfWeek; // 0-6, Monday-Sunday
  final int? dayOfMonth; // 1-31
  final DateTime? endDate;
  final int? maxOccurrences;

  RecurrencePattern({
    required this.type,
    this.interval = 1,
    this.daysOfWeek = const [],
    this.dayOfMonth,
    this.endDate,
    this.maxOccurrences,
  });

  bool isActive() => type != RecurrenceType.none;

  String getDisplayLabel() {
    switch (type) {
      case RecurrenceType.none:
        return 'No repeat';
      case RecurrenceType.daily:
        return interval == 1 ? 'Daily' : 'Every $interval days';
      case RecurrenceType.weekly:
        return interval == 1 ? 'Weekly' : 'Every $interval weeks';
      case RecurrenceType.monthly:
        return interval == 1 ? 'Monthly' : 'Every $interval months';
      case RecurrenceType.yearly:
        return interval == 1 ? 'Yearly' : 'Every $interval years';
    }
  }

  /// Calculate next occurrence date
  DateTime? getNextOccurrence(DateTime currentDate) {
    if (!isActive()) return null;

    DateTime nextDate = currentDate.add(Duration(days: 1));

    switch (type) {
      case RecurrenceType.daily:
        nextDate = currentDate.add(Duration(days: interval));
        break;
      case RecurrenceType.weekly:
        nextDate = currentDate.add(Duration(days: interval * 7));
        break;
      case RecurrenceType.monthly:
        nextDate = DateTime(
          currentDate.year,
          currentDate.month + interval,
          currentDate.day,
        );
        break;
      case RecurrenceType.yearly:
        nextDate = DateTime(
          currentDate.year + interval,
          currentDate.month,
          currentDate.day,
        );
        break;
      case RecurrenceType.none:
        return null;
    }

    // Check end date
    if (endDate != null && nextDate.isAfter(endDate!)) {
      return null;
    }

    return nextDate;
  }

  RecurrencePattern copyWith({
    RecurrenceType? type,
    int? interval,
    List<int>? daysOfWeek,
    int? dayOfMonth,
    DateTime? endDate,
    int? maxOccurrences,
  }) {
    return RecurrencePattern(
      type: type ?? this.type,
      interval: interval ?? this.interval,
      daysOfWeek: daysOfWeek ?? this.daysOfWeek,
      dayOfMonth: dayOfMonth ?? this.dayOfMonth,
      endDate: endDate ?? this.endDate,
      maxOccurrences: maxOccurrences ?? this.maxOccurrences,
    );
  }
}

/// Recurrence picker widget (REC-002)
class RecurrencePickerWidget extends StatefulWidget {
  final RecurrencePattern initialPattern;
  final ValueChanged<RecurrencePattern> onPatternChanged;

  const RecurrencePickerWidget({
    Key? key,
    required this.initialPattern,
    required this.onPatternChanged,
  }) : super(key: key);

  @override
  State<RecurrencePickerWidget> createState() => _RecurrencePickerWidgetState();
}

class _RecurrencePickerWidgetState extends State<RecurrencePickerWidget> {
  late RecurrencePattern pattern;
  late TextEditingController intervalController;

  @override
  void initState() {
    super.initState();
    pattern = widget.initialPattern;
    intervalController = TextEditingController(
      text: pattern.interval.toString(),
    );
  }

  @override
  void dispose() {
    intervalController.dispose();
    super.dispose();
  }

  void _updatePattern(RecurrencePattern newPattern) {
    setState(() => pattern = newPattern);
    widget.onPatternChanged(newPattern);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Repeat Pattern',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            // Recurrence type selector
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: RecurrenceType.values.map((type) {
                final label = type == RecurrenceType.none
                    ? 'None'
                    : type.toString().split('.').last[0].toUpperCase() +
                          type.toString().split('.').last.substring(1);

                return ChoiceChip(
                  label: Text(label),
                  selected: pattern.type == type,
                  onSelected: (selected) {
                    if (selected) {
                      _updatePattern(pattern.copyWith(type: type));
                    }
                  },
                );
              }).toList(),
            ),
            if (pattern.isActive()) ...[
              SizedBox(height: 16),
              // Interval selector
              Row(
                children: [
                  Text('Every'),
                  SizedBox(width: 8),
                  Expanded(
                    flex: 2,
                    child: TextField(
                      controller: intervalController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onChanged: (value) {
                        final interval = int.tryParse(value) ?? 1;
                        _updatePattern(pattern.copyWith(interval: interval));
                      },
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    flex: 3,
                    child: Text(
                      _getIntervalLabel(),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12),
              // End date selector
              if (pattern.type != RecurrenceType.none) ...[
                ListTile(
                  title: Text('End Date'),
                  subtitle: pattern.endDate != null
                      ? Text(_formatDate(pattern.endDate!))
                      : Text('No end date'),
                  trailing: IconButton(
                    icon: Icon(Icons.calendar_today),
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: pattern.endDate ?? DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(Duration(days: 365 * 5)),
                      );
                      if (picked != null) {
                        _updatePattern(pattern.copyWith(endDate: picked));
                      }
                    },
                  ),
                ),
              ],
            ],
            SizedBox(height: 12),
            // Summary
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue, size: 18),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Repeats ${pattern.getDisplayLabel()}',
                      style: TextStyle(color: Colors.blue, fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getIntervalLabel() {
    switch (pattern.type) {
      case RecurrenceType.daily:
        return pattern.interval == 1 ? 'day' : 'days';
      case RecurrenceType.weekly:
        return pattern.interval == 1 ? 'week' : 'weeks';
      case RecurrenceType.monthly:
        return pattern.interval == 1 ? 'month' : 'months';
      case RecurrenceType.yearly:
        return pattern.interval == 1 ? 'year' : 'years';
      case RecurrenceType.none:
        return '';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}

/// Recurrence display widget
class RecurrenceDisplay extends StatelessWidget {
  final RecurrencePattern pattern;
  final VoidCallback? onEdit;

  const RecurrenceDisplay({Key? key, required this.pattern, this.onEdit})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (!pattern.isActive()) return SizedBox.shrink();

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.purple.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.purple.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.repeat, size: 16, color: Colors.purple),
          SizedBox(width: 6),
          Text(
            pattern.getDisplayLabel(),
            style: TextStyle(
              fontSize: 12,
              color: Colors.purple,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (onEdit != null) ...[
            SizedBox(width: 8),
            GestureDetector(
              onTap: onEdit,
              child: Icon(Icons.edit, size: 14, color: Colors.purple),
            ),
          ],
        ],
      ),
    );
  }
}
