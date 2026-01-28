import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mynotes/presentation/widgets/universal_item_card.dart';
import '../../data/repositories/unified_repository.dart';

/// Smart Notifications Service
/// Unified notification system for Notes, Todos, and Reminders
/// Handles intelligent notification scheduling and delivery
class SmartNotificationsService {
  static SmartNotificationsService? _instance;
  static SmartNotificationsService get instance =>
      _instance ??= SmartNotificationsService._();
  SmartNotificationsService._();

  final _repository = UnifiedRepository.instance;
  Timer? _notificationTimer;
  StreamSubscription? _remindersSubscription;

  final List<NotificationItem> _pendingNotifications = [];
  final StreamController<List<NotificationItem>> _notificationsController =
      StreamController<List<NotificationItem>>.broadcast();

  Stream<List<NotificationItem>> get notificationsStream =>
      _notificationsController.stream;

  /// Initialize the smart notification system
  Future<void> initialize() async {
    await _repository.initialize();
    _startNotificationScheduler();
    _listenToRemindersStream();
  }

  void _startNotificationScheduler() {
    _notificationTimer?.cancel();
    _notificationTimer = Timer.periodic(
      const Duration(minutes: 1), // Check every minute
      (_) => _checkForDueNotifications(),
    );
  }

  void _listenToRemindersStream() {
    _remindersSubscription = _repository.remindersStream.listen((reminders) {
      _updatePendingNotifications(reminders);
    });
  }

  void _updatePendingNotifications(List<UniversalItem> reminders) {
    _pendingNotifications.clear();

    final now = DateTime.now();
    for (final reminder in reminders) {
      if (reminder.reminderTime != null &&
          reminder.reminderTime!.isAfter(now)) {
        final notification = _createSmartNotification(reminder);
        _pendingNotifications.add(notification);
      }
    }

    _pendingNotifications.sort(
      (a, b) => a.scheduledTime.compareTo(b.scheduledTime),
    );

    _notificationsController.add(List.from(_pendingNotifications));
  }

  NotificationItem _createSmartNotification(UniversalItem item) {
    return NotificationItem(
      id: item.id,
      title: _generateSmartTitle(item),
      body: _generateSmartBody(item),
      scheduledTime: item.reminderTime!,
      priority: _calculatePriority(item),
      type: _determineNotificationType(item),
      actions: _generateActions(item),
      item: item,
    );
  }

  String _generateSmartTitle(UniversalItem item) {
    if (item.isTodo && item.isReminder) {
      return 'Task Reminder';
    } else if (item.isTodo) {
      return 'Todo Due';
    } else if (item.isReminder) {
      return 'Reminder';
    } else {
      return 'Note Reminder';
    }
  }

  String _generateSmartBody(UniversalItem item) {
    String body = item.title;

    // Add context based on item type
    if (item.isTodo && !item.isCompleted) {
      body += ' - Tap to mark complete';
    } else if (item.category.isNotEmpty) {
      body += ' (${item.category})';
    }

    // Add time context
    final timeUntil = _getTimeUntilString(item.reminderTime!);
    if (timeUntil.isNotEmpty) {
      body += ' • $timeUntil';
    }

    return body;
  }

  NotificationPriority _calculatePriority(UniversalItem item) {
    // High priority for overdue items
    if (item.reminderTime!.isBefore(DateTime.now())) {
      return NotificationPriority.high;
    }

    // High priority based on item priority
    if (item.priority == ItemPriority.high) {
      return NotificationPriority.high;
    }

    // Medium priority for todos
    if (item.isTodo) {
      return NotificationPriority.medium;
    }

    return NotificationPriority.normal;
  }

  NotificationType _determineNotificationType(UniversalItem item) {
    if (item.isTodo) {
      return NotificationType.todo;
    } else if (item.isReminder) {
      return NotificationType.reminder;
    } else {
      return NotificationType.note;
    }
  }

  List<NotificationAction> _generateActions(UniversalItem item) {
    final actions = <NotificationAction>[];

    // Common actions
    actions.add(
      NotificationAction(id: 'view', title: 'View', icon: Icons.visibility),
    );

    // Todo-specific actions
    if (item.isTodo && !item.isCompleted) {
      actions.add(
        NotificationAction(
          id: 'complete',
          title: 'Mark Done',
          icon: Icons.check_circle,
        ),
      );
    }

    // Snooze action for all reminders
    if (item.isReminder) {
      actions.add(
        NotificationAction(id: 'snooze', title: 'Snooze', icon: Icons.snooze),
      );
    }

    return actions;
  }

  String _getTimeUntilString(DateTime reminderTime) {
    final now = DateTime.now();
    final difference = reminderTime.difference(now);

    if (difference.isNegative) {
      return 'Overdue';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m';
    } else {
      return 'Now';
    }
  }

  Future<void> _checkForDueNotifications() async {
    final now = DateTime.now();
    final dueNotifications = _pendingNotifications
        .where(
          (notification) =>
              notification.scheduledTime.isBefore(now) ||
              notification.scheduledTime.difference(now).inMinutes <= 0,
        )
        .toList();

    for (final notification in dueNotifications) {
      await _deliverNotification(notification);
      _pendingNotifications.remove(notification);
    }

    if (dueNotifications.isNotEmpty) {
      _notificationsController.add(List.from(_pendingNotifications));
    }
  }

  Future<void> _deliverNotification(NotificationItem notification) async {
    // In a real app, this would integrate with flutter_local_notifications
    debugPrint(
      'Delivering notification: ${notification.title} - ${notification.body}',
    );

    // For demo purposes, we'll add it to a delivered notifications list
    // This could trigger actual system notifications, in-app banners, etc.
  }

  /// Handle notification action (complete, snooze, etc.)
  Future<void> handleNotificationAction(
    String notificationId,
    String actionId,
  ) async {
    final notification = _pendingNotifications.firstWhere(
      (n) => n.id == notificationId,
      orElse: () => NotificationItem.empty(),
    );

    if (notification.id.isEmpty) return;

    switch (actionId) {
      case 'complete':
        if (notification.item.isTodo) {
          await _repository.toggleTodoCompletion(notification.item.id);
        }
        break;
      case 'snooze':
        await _snoozeNotification(notification, const Duration(minutes: 10));
        break;
      case 'view':
        // Navigate to item detail view
        break;
    }
  }

  Future<void> _snoozeNotification(
    NotificationItem notification,
    Duration snoozeDuration,
  ) async {
    final newReminderTime = DateTime.now().add(snoozeDuration);

    // Update the item's reminder time
    final updatedItem = notification.item.copyWith(
      reminderTime: newReminderTime,
    );

    await _repository.updateItem(updatedItem);
  }

  /// Get upcoming notifications summary
  Map<String, dynamic> getUpcomingNotificationsSummary() {
    final now = DateTime.now();
    final next24Hours = now.add(const Duration(days: 1));

    final upcoming = _pendingNotifications
        .where((n) => n.scheduledTime.isBefore(next24Hours))
        .toList();

    final byType = <String, int>{};
    for (final notification in upcoming) {
      final typeKey = notification.type.toString().split('.').last;
      byType[typeKey] = (byType[typeKey] ?? 0) + 1;
    }

    return {
      'total_upcoming': upcoming.length,
      'next_notification': upcoming.isNotEmpty ? upcoming.first : null,
      'by_type': byType,
      'next_24_hours': upcoming.length,
    };
  }

  /// Schedule a smart notification for an item
  Future<void> scheduleSmartNotification(
    UniversalItem item,
    DateTime scheduledTime, {
    Map<String, dynamic>? customSettings,
  }) async {
    final updatedItem = item.copyWith(reminderTime: scheduledTime);
    await _repository.updateItem(updatedItem);
  }

  void dispose() {
    _notificationTimer?.cancel();
    _remindersSubscription?.cancel();
    _notificationsController.close();
  }
}

/// Represents a smart notification item
class NotificationItem {
  final String id;
  final String title;
  final String body;
  final DateTime scheduledTime;
  final NotificationPriority priority;
  final NotificationType type;
  final List<NotificationAction> actions;
  final UniversalItem item;

  NotificationItem({
    required this.id,
    required this.title,
    required this.body,
    required this.scheduledTime,
    required this.priority,
    required this.type,
    required this.actions,
    required this.item,
  });

  factory NotificationItem.empty() {
    return NotificationItem(
      id: '',
      title: '',
      body: '',
      scheduledTime: DateTime.now(),
      priority: NotificationPriority.normal,
      type: NotificationType.note,
      actions: [],
      item: UniversalItem(
        id: '',
        title: '',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );
  }
}

class NotificationAction {
  final String id;
  final String title;
  final IconData icon;

  NotificationAction({
    required this.id,
    required this.title,
    required this.icon,
  });
}

enum NotificationPriority { low, normal, medium, high }

enum NotificationType { note, todo, reminder }

/// Smart Notifications Widget
/// Displays upcoming notifications with smart actions
class SmartNotificationsWidget extends StatelessWidget {
  const SmartNotificationsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<NotificationItem>>(
      stream: SmartNotificationsService.instance.notificationsStream,
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return _buildEmptyState();
        }

        final notifications = snapshot.data!;
        return _buildNotificationsList(notifications);
      },
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_off, size: 48, color: Colors.grey.shade500),
          SizedBox(height: 16),
          Text(
            'No upcoming notifications',
            style: TextStyle(fontSize: 16, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationsList(List<NotificationItem> notifications) {
    return ListView.builder(
      itemCount: notifications.length,
      itemBuilder: (context, index) {
        final notification = notifications[index];
        return _buildNotificationTile(notification);
      },
    );
  }

  Widget _buildNotificationTile(NotificationItem notification) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _getPriorityColor(notification.priority)),
      ),
      child: ListTile(
        leading: Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: _getTypeColor(notification.type).withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            _getTypeIcon(notification.type),
            color: _getTypeColor(notification.type),
          ),
        ),
        title: Text(
          notification.title,
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(notification.body),
            SizedBox(height: 4),
            Text(
              _formatScheduledTime(notification.scheduledTime),
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
          ],
        ),
        trailing: _buildActionButtons(notification),
        isThreeLine: true,
      ),
    );
  }

  Widget _buildActionButtons(NotificationItem notification) {
    if (notification.actions.length <= 2) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: notification.actions
            .map(
              (action) => IconButton(
                onPressed: () => SmartNotificationsService.instance
                    .handleNotificationAction(notification.id, action.id),
                icon: Icon(action.icon),
                iconSize: 20,
              ),
            )
            .toList(),
      );
    }

    return PopupMenuButton<String>(
      onSelected: (actionId) => SmartNotificationsService.instance
          .handleNotificationAction(notification.id, actionId),
      itemBuilder: (context) => notification.actions
          .map(
            (action) => PopupMenuItem<String>(
              value: action.id,
              child: Row(
                children: [
                  Icon(action.icon),
                  SizedBox(width: 8),
                  Text(action.title),
                ],
              ),
            ),
          )
          .toList(),
    );
  }

  Color _getPriorityColor(NotificationPriority priority) {
    switch (priority) {
      case NotificationPriority.high:
        return Colors.red;
      case NotificationPriority.medium:
        return Colors.orange;
      case NotificationPriority.normal:
        return Colors.blue;
      case NotificationPriority.low:
        return Colors.grey;
    }
  }

  Color _getTypeColor(NotificationType type) {
    switch (type) {
      case NotificationType.todo:
        return Colors.blue;
      case NotificationType.reminder:
        return Colors.purple;
      case NotificationType.note:
        return Colors.green;
    }
  }

  IconData _getTypeIcon(NotificationType type) {
    switch (type) {
      case NotificationType.todo:
        return Icons.task_alt;
      case NotificationType.reminder:
        return Icons.alarm;
      case NotificationType.note:
        return Icons.note;
    }
  }

  String _formatScheduledTime(DateTime time) {
    final now = DateTime.now();
    final difference = time.difference(now);

    if (difference.isNegative) {
      return 'Overdue';
    } else if (difference.inDays > 0) {
      return 'In ${difference.inDays} days';
    } else if (difference.inHours > 0) {
      return 'In ${difference.inHours} hours';
    } else if (difference.inMinutes > 0) {
      return 'In ${difference.inMinutes} minutes';
    } else {
      return 'Now';
    }
  }
}
