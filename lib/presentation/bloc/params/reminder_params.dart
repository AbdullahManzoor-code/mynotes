import 'package:equatable/equatable.dart';

/// Complete Param Model for Reminder Operations
/// 📦 Container for all reminder-related data
/// Single object instead of multiple parameters
class ReminderParams extends Equatable {
  final String? reminderId;
  final String title;
  final String description;
  final DateTime reminderTime;
  final String? noteId;
  final String? todoId;
  final bool isRecurring;
  final String? recurringPattern; // daily, weekly, monthly, etc.
  final bool isEnabled;
  final String? sound;
  final bool vibrate;
  final List<String> tags;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const ReminderParams({
    this.reminderId,
    this.title = '',
    this.description = '',
    required this.reminderTime,
    this.noteId,
    this.todoId,
    this.isRecurring = false,
    this.recurringPattern,
    this.isEnabled = true,
    this.sound,
    this.vibrate = true,
    this.tags = const [],
    this.createdAt,
    this.updatedAt,
  });

  /// ✨ Create a copy with modified fields
  ReminderParams copyWith({
    String? reminderId,
    String? title,
    String? description,
    DateTime? reminderTime,
    String? noteId,
    String? todoId,
    bool? isRecurring,
    String? recurringPattern,
    bool? isEnabled,
    String? sound,
    bool? vibrate,
    List<String>? tags,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ReminderParams(
      reminderId: reminderId ?? this.reminderId,
      title: title ?? this.title,
      description: description ?? this.description,
      reminderTime: reminderTime ?? this.reminderTime,
      noteId: noteId ?? this.noteId,
      todoId: todoId ?? this.todoId,
      isRecurring: isRecurring ?? this.isRecurring,
      recurringPattern: recurringPattern ?? this.recurringPattern,
      isEnabled: isEnabled ?? this.isEnabled,
      sound: sound ?? this.sound,
      vibrate: vibrate ?? this.vibrate,
      tags: tags ?? this.tags,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Toggle enabled status
  ReminderParams toggleEnabled() {
    return copyWith(isEnabled: !isEnabled);
  }

  /// Toggle vibration
  ReminderParams toggleVibrate() {
    return copyWith(vibrate: !vibrate);
  }

  /// Change reminder time
  ReminderParams withReminderTime(DateTime newTime) {
    return copyWith(reminderTime: newTime);
  }

  /// Enable recurring
  ReminderParams makeRecurring(String pattern) {
    return copyWith(isRecurring: true, recurringPattern: pattern);
  }

  /// Disable recurring
  ReminderParams makeOneTime() {
    return copyWith(isRecurring: false, recurringPattern: null);
  }

  /// Add tag
  ReminderParams withTag(String tag) {
    if (tags.contains(tag)) return this;
    return copyWith(tags: [...tags, tag]);
  }

  @override
  List<Object?> get props => [
    reminderId,
    title,
    description,
    reminderTime,
    noteId,
    todoId,
    isRecurring,
    recurringPattern,
    isEnabled,
    sound,
    vibrate,
    tags,
    createdAt,
    updatedAt,
  ];
}
