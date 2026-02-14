// lib/presentation/bloc/alarm/alarm_filter.dart

/// Filter options for displaying alarms
enum AlarmFilter { all, today, upcoming, overdue, snoozed, completed }

extension AlarmFilterExtension on AlarmFilter {
  String get displayName {
    switch (this) {
      case AlarmFilter.all:
        return 'All';
      case AlarmFilter.today:
        return 'Today';
      case AlarmFilter.upcoming:
        return 'Upcoming';
      case AlarmFilter.overdue:
        return 'Overdue';
      case AlarmFilter.snoozed:
        return 'Snoozed';
      case AlarmFilter.completed:
        return 'Completed';
    }
  }
}
