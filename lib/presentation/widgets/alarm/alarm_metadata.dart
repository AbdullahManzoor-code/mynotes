import 'package:flutter/material.dart';
import 'package:mynotes/core/extensions/context_extensions.dart';
import 'package:mynotes/presentation/design_system/design_system.dart';
import 'package:mynotes/domain/entities/alarm.dart';

/// Unified alarm metadata widget for displaying alarm details
/// Shows: Next occurrence, linked items, statistics, sound settings
class AlarmMetadata extends StatelessWidget {
  final Alarm alarm;
  final bool showFullInfo;

  const AlarmMetadata({
    super.key,
    required this.alarm,
    this.showFullInfo = false,
  });

  @override
  Widget build(BuildContext context) {
    final nextOccurrence = alarm.getNextOccurrence();

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Next Occurrence
          _buildNextOccurrenceSection(context, nextOccurrence),
          // Sound & Vibration
          _buildSoundSection(context),
          // Linked Items
          if (alarm.hasLinkedItem) _buildLinkedItemsSection(context),
          // Statistics
          if (showFullInfo) _buildStatisticsSection(context),
          // Timestamps
          if (showFullInfo) _buildTimestampsSection(context),
        ],
      ),
    );
  }

  /// Build next occurrence section
  Widget _buildNextOccurrenceSection(
    BuildContext context,
    DateTime? nextOccurrence,
  ) {
    final isOverdue = alarm.isOverdue;
    final isDueSoon = alarm.isDueSoon;

    return Container(
      margin: EdgeInsets.all(16.w),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: _getStatusColor(context).withOpacity(0.08),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(
          color: _getStatusColor(context).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Status',
                style: AppTypography.body1(context).copyWith(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: context.theme.disabledColor,
                ),
              ),
              if (alarm.isSnoozed)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                  child: Text(
                    'Snoozed',
                    style: AppTypography.caption(context).copyWith(
                      fontSize: 10.sp,
                      color: Colors.orange,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              if (isOverdue && !alarm.isSnoozed)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                  child: Text(
                    'Overdue',
                    style: AppTypography.caption(context).copyWith(
                      fontSize: 10.sp,
                      color: Colors.red,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              if (isDueSoon && !isOverdue && !alarm.isSnoozed)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                  decoration: BoxDecoration(
                    color: Colors.amber.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                  child: Text(
                    'Due Soon',
                    style: AppTypography.caption(context).copyWith(
                      fontSize: 10.sp,
                      color: Colors.amber.shade700,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            '${alarm.timeRemaining} (${_formatDateTime(alarm.scheduledTime)})',
            style: AppTypography.body2(
              context,
            ).copyWith(fontSize: 13.sp, fontWeight: FontWeight.w500),
          ),
          if (nextOccurrence != null &&
              alarm.recurrence != AlarmRecurrence.none)
            Padding(
              padding: EdgeInsets.only(top: 8.h),
              child: Text(
                'Next: ${_formatDateTime(nextOccurrence)}',
                style: AppTypography.caption(
                  context,
                ).copyWith(fontSize: 11.sp, color: context.theme.disabledColor),
              ),
            ),
        ],
      ),
    );
  }

  /// Build sound section
  Widget _buildSoundSection(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Sound & Notifications',
            style: AppTypography.body1(context).copyWith(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: context.theme.disabledColor,
            ),
          ),
          SizedBox(height: 8.h),
          Row(
            children: [
              Icon(
                Icons.notifications,
                size: 16.r,
                color: context.primaryColor,
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  alarm.soundPath != null
                      ? alarm.soundPath!.split('/').last
                      : 'Default sound',
                  style: AppTypography.body2(context).copyWith(fontSize: 13.sp),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Row(
            children: [
              Icon(
                Icons.vibration,
                size: 16.r,
                color: alarm.vibrate
                    ? context.primaryColor
                    : context.theme.disabledColor,
              ),
              SizedBox(width: 8.w),
              Text(
                alarm.vibrate ? 'Vibration enabled' : 'Vibration disabled',
                style: AppTypography.body2(context).copyWith(
                  fontSize: 13.sp,
                  color: alarm.vibrate
                      ? context.primaryColor
                      : context.theme.disabledColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Build linked items section
  Widget _buildLinkedItemsSection(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: context.primaryColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(
          color: context.primaryColor.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.link, size: 18.r, color: context.primaryColor),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              alarm.linkedNoteId != null ? 'Linked to Note' : 'Linked to Todo',
              style: AppTypography.body2(context).copyWith(
                fontSize: 12.sp,
                color: context.primaryColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Icon(Icons.navigate_next, size: 18.r, color: context.primaryColor),
        ],
      ),
    );
  }

  /// Build statistics section
  Widget _buildStatisticsSection(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Statistics',
            style: AppTypography.body1(context).copyWith(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: context.theme.disabledColor,
            ),
          ),
          SizedBox(height: 8.h),
          _buildMetadataItem(context, 'Snooze count', '${alarm.snoozeCount}x'),
          SizedBox(height: 4.h),
          _buildMetadataItem(
            context,
            'Last triggered',
            alarm.lastTriggered != null
                ? _formatDateTime(alarm.lastTriggered!)
                : 'Never',
          ),
        ],
      ),
    );
  }

  /// Build timestamps section
  Widget _buildTimestampsSection(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Details',
            style: AppTypography.body1(context).copyWith(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: context.theme.disabledColor,
            ),
          ),
          SizedBox(height: 8.h),
          _buildMetadataItem(
            context,
            'Created',
            _formatDateTime(alarm.createdAt),
          ),
          SizedBox(height: 4.h),
          _buildMetadataItem(
            context,
            'Updated',
            _formatDateTime(alarm.updatedAt),
          ),
          if (alarm.completedAt != null)
            Padding(
              padding: EdgeInsets.only(top: 4.h),
              child: _buildMetadataItem(
                context,
                'Completed',
                _formatDateTime(alarm.completedAt!),
              ),
            ),
        ],
      ),
    );
  }

  /// Generic metadata item builder
  Widget _buildMetadataItem(BuildContext context, String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTypography.caption(
            context,
          ).copyWith(fontSize: 11.sp, color: context.theme.disabledColor),
        ),
        Text(
          value,
          style: AppTypography.caption(
            context,
          ).copyWith(fontSize: 11.sp, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Color _getStatusColor(BuildContext context) {
    if (alarm.isSnoozed) return Colors.orange;
    if (alarm.isOverdue) return Colors.red;
    if (alarm.isDueSoon) return Colors.amber;
    return context.primaryColor;
  }

  String _formatDateTime(DateTime dateTime) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final day = dateTime.day.toString().padLeft(2, '0');
    final month = dateTime.month.toString().padLeft(2, '0');
    return '$day/$month at $hour:$minute';
  }
}
