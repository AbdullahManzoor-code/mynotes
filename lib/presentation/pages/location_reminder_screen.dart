// lib/presentation/pages/location_reminder_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mynotes/presentation/bloc/location_reminder/location_reminder_bloc.dart';
import 'package:mynotes/presentation/widgets/lottie_animation_widget.dart';
import 'package:mynotes/presentation/widgets/location/location_reminder_card.dart';
import 'package:mynotes/presentation/widgets/location/location_permission_dialog.dart';
import 'package:mynotes/domain/entities/location_reminder_model.dart';
import 'package:mynotes/presentation/pages/location_picker_screen.dart';
import 'package:mynotes/presentation/pages/saved_locations_screen.dart';
import 'package:mynotes/core/services/location_reminders_manager.dart';
import '../design_system/design_system.dart';
import 'dart:ui' as ui;

/// Location Reminder Screen - Polished & Functional
/// Merged premium design with real location intelligence logic
class LocationReminderScreen extends StatelessWidget {
  const LocationReminderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return _LocationLifecycleWrapper(
      child: BlocBuilder<LocationReminderBloc, LocationReminderState>(
        builder: (context, state) {
          final isDark = Theme.of(context).brightness == Brightness.dark;

          return Scaffold(
            backgroundColor: isDark
                ? AppColors.darkBackground
                : AppColors.lightBackground,
            extendBodyBehindAppBar: true,
            appBar: _buildPremiumAppBar(context),
            body: _buildBody(context, state),
            floatingActionButton: _buildSmartFAB(context),
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildPremiumAppBar(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark
        ? AppColors.darkSurface
        : AppColors.lightSurface;

    return AppBar(
      elevation: 0,
      backgroundColor: Colors.transparent,
      flexibleSpace: ClipRect(
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  surfaceColor.withOpacity(0.8),
                  surfaceColor.withOpacity(0.6),
                ],
              ),
              border: Border(
                bottom: BorderSide(
                  color: AppColors.primary.withOpacity(0.1),
                  width: 0.5,
                ),
              ),
            ),
          ),
        ),
      ),
      title: Text(
        'Location Reminders',
        style: AppTypography.heading3(
          context,
          AppColors.textPrimary(context),
        ).copyWith(fontWeight: FontWeight.w600),
      ),
      centerTitle: false,
      leading: Container(
        margin: EdgeInsets.all(8.w),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.primary.withOpacity(0.1),
        ),
        child: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: AppColors.textPrimary(context),
            size: 20.sp,
          ),
          onPressed: () => Navigator.pop(context),
          splashRadius: 24.r,
        ),
      ),
      actions: [
        Container(
          margin: EdgeInsets.only(right: 8.w),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.primary.withOpacity(0.1),
          ),
          child: IconButton(
            icon: Icon(
              Icons.bookmark_outline,
              color: AppColors.textPrimary(context),
              size: 20.sp,
            ),
            onPressed: () {
              AppLogger.i('LocationReminderScreen: Saved Locations pressed');
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SavedLocationsScreen()),
              );
            },
            splashRadius: 24.r,
          ),
        ),
        Container(
          margin: EdgeInsets.only(right: 16.w),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.primary.withOpacity(0.1),
          ),
          child: IconButton(
            icon: Icon(
              Icons.help_outline,
              color: AppColors.textPrimary(context),
              size: 20.sp,
            ),
            onPressed: () {
              AppLogger.i('LocationReminderScreen: Help dialog pressed');
              _showHelpDialog(context);
            },
            splashRadius: 24.r,
          ),
        ),
      ],
    );
  }

  Widget _buildBody(BuildContext context, LocationReminderState state) {
    if (state is LocationReminderInitial) {
      context.read<LocationReminderBloc>().add(LoadLocationReminders());
      return const Center(child: CircularProgressIndicator());
    }

    if (state is LocationReminderLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is LocationReminderError) {
      return _buildErrorState(context, state.message);
    }

    if (state is LocationReminderLoaded) {
      if (state.reminders.isEmpty) {
        return _buildEmptyState(context);
      }
      return _buildReminderList(context, state);
    }

    return const Center(child: CircularProgressIndicator());
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            LottieAnimationWidget('location_empty', height: 200.h),
            SizedBox(height: 24.h),
            Text(
              'No Location Reminders',
              style: AppTypography.heading3(
                context,
                AppColors.textPrimary(context),
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 12.h),
            Text(
              'Create reminders that trigger when you arrive at or leave a specific place.',
              style: AppTypography.body1(
                context,
                AppColors.textSecondary(context),
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 32.h),
            _buildSmartActionButton(
              context,
              'Create First Reminder',
              Icons.add_location_alt_outlined,
              () => _createNewReminder(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReminderList(
    BuildContext context,
    LocationReminderLoaded state,
  ) {
    final activeReminders = state.reminders.where((r) => r.isActive).toList();
    final inactiveReminders = state.reminders
        .where((r) => !r.isActive)
        .toList();

    return ListView(
      padding: EdgeInsets.fromLTRB(16.w, 100.h, 16.w, 100.h),
      children: [
        if (!state.hasLocationPermission)
          LocationPermissionBanner(
            onPermissionGranted: () {
              LocationRemindersManager().startMonitoring();
              context.read<LocationReminderBloc>().add(LoadLocationReminders());
            },
          ),

        if (activeReminders.isNotEmpty) ...[
          _buildSectionHeader(context, 'Active', activeReminders.length),
          SizedBox(height: 12.h),
          ...activeReminders.map(
            (reminder) => Padding(
              padding: EdgeInsets.only(bottom: 12.h),
              child: LocationReminderCard(
                reminder: reminder,
                onTap: () => _editReminder(context, reminder),
                onToggle: (active) =>
                    _toggleReminder(context, reminder, active),
                onDelete: () => _deleteReminder(context, reminder),
              ),
            ),
          ),
        ],

        if (inactiveReminders.isNotEmpty) ...[
          SizedBox(height: 24.h),
          _buildSectionHeader(context, 'Inactive', inactiveReminders.length),
          SizedBox(height: 12.h),
          ...inactiveReminders.map(
            (reminder) => Padding(
              padding: EdgeInsets.only(bottom: 12.h),
              child: LocationReminderCard(
                reminder: reminder,
                onTap: () => _editReminder(context, reminder),
                onToggle: (active) =>
                    _toggleReminder(context, reminder, active),
                onDelete: () => _deleteReminder(context, reminder),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, int count) {
    return Row(
      children: [
        Text(
          title,
          style: AppTypography.heading4(
            context,
            AppColors.textPrimary(context),
          ).copyWith(fontWeight: FontWeight.bold),
        ),
        SizedBox(width: 8.w),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 2.h),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: Text(
            count.toString(),
            style: AppTypography.caption(
              context,
              AppColors.primary,
            ).copyWith(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget _buildSmartFAB(BuildContext context) {
    return Container(
      height: 56.h,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            AppLogger.i('LocationReminderScreen: New Reminder FAB tapped');
            HapticFeedback.mediumImpact();
            _createNewReminder(context);
          },
          borderRadius: BorderRadius.circular(28.r),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.add_location_alt, color: Colors.white, size: 24.sp),
                SizedBox(width: 12.w),
                Text(
                  'New Reminder',
                  style: AppTypography.body1(
                    context,
                    Colors.white,
                  ).copyWith(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSmartActionButton(
    BuildContext context,
    String label,
    IconData icon,
    VoidCallback onTap,
  ) {
    return Container(
      height: 52.h,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primary.withOpacity(0.9)],
        ),
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16.r),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: Colors.white, size: 20.sp),
                SizedBox(width: 12.w),
                Text(
                  label,
                  style: AppTypography.body1(
                    context,
                    Colors.white,
                  ).copyWith(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _createNewReminder(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const LocationPickerScreen()),
    );
  }

  void _editReminder(BuildContext context, LocationReminder reminder) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LocationPickerScreen(existingReminder: reminder),
      ),
    );
  }

  void _toggleReminder(
    BuildContext context,
    LocationReminder reminder,
    bool active,
  ) {
    context.read<LocationReminderBloc>().add(
      ToggleLocationReminder(reminderId: reminder.id, isActive: active),
    );
  }

  void _deleteReminder(BuildContext context, LocationReminder reminder) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        title: const Text('Delete Reminder?'),
        content: Text('Remove "${reminder.message}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<LocationReminderBloc>().add(
                DeleteLocationReminder(reminderId: reminder.id),
              );
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24.r),
        ),
        title: Row(
          children: [
            Icon(Icons.help_outline, color: AppColors.primary, size: 28.sp),
            SizedBox(width: 12.w),
            const Expanded(child: Text('How it Works')),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHelpItem(
                Icons.map_outlined,
                'Choose Location',
                'Search or drop a pin on the map.',
              ),
              _buildHelpItem(
                Icons.notifications_active_outlined,
                'Set Trigger',
                'Get notified when you arrive or leave.',
              ),
              _buildHelpItem(
                Icons.radar_outlined,
                'Adjust Radius',
                'Set proximity distance from 50m to 500m.',
              ),
              _buildHelpItem(
                Icons.settings_input_antenna_outlined,
                'Always Allow',
                'Reminders work best with "Always" location access.',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'Got it',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHelpItem(IconData icon, String title, String subtitle) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.primary, size: 20.sp),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 13.sp, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64.sp, color: Colors.red),
          SizedBox(height: 16.h),
          Text(message),
          SizedBox(height: 16.h),
          ElevatedButton(
            onPressed: () {
              context.read<LocationReminderBloc>().add(LoadLocationReminders());
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}

class _LocationLifecycleWrapper extends StatefulWidget {
  final Widget child;
  const _LocationLifecycleWrapper({required this.child});

  @override
  State<_LocationLifecycleWrapper> createState() =>
      _LocationLifecycleWrapperState();
}

class _LocationLifecycleWrapperState extends State<_LocationLifecycleWrapper> {
  final _locationManager = LocationRemindersManager();

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    AppLogger.i('Initializing location manager...');
    try {
      await _locationManager.initialize();
      final permissionsGranted = await _locationManager.arePermissionsGranted();
      AppLogger.i('Location permissions granted: $permissionsGranted');

      if (!permissionsGranted && mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (dialogContext) => LocationPermissionDialog(
            onPermissionsGranted: () {
              AppLogger.i(
                'Permissions granted via dialog. Starting monitoring.',
              );
              _locationManager.startMonitoring();
              if (mounted) {
                context.read<LocationReminderBloc>().add(
                  LoadLocationReminders(),
                );
              }
            },
          ),
        );
      } else if (permissionsGranted) {
        AppLogger.i('Starting location monitoring...');
        await _locationManager.startMonitoring();
        if (mounted) {
          context.read<LocationReminderBloc>().add(LoadLocationReminders());
        }
      }
    } catch (e, stack) {
      AppLogger.e('Error initializing location services: $e', e, stack);
    }
  }

  @override
  void dispose() {
    AppLogger.i('Disposing location manager wrapper');
    _locationManager.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}


