import 'package:flutter/material.dart';
import '../design_system/design_system.dart';
import '../widgets/empty_state_help_body.dart';

/// Empty State Todos Help Screen
/// Provides guidance when user has no todos created yet
class EmptyStateTodosHelpScreen extends StatelessWidget {
  const EmptyStateTodosHelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      safeAreaTop: false,
      appBar: _buildTopAppBar(context),
      body: EmptyStateHelpBody(
        title: 'Ready to get things done?',
        subtitle:
            'Create your first task or choose from our productivity templates to get started.',
        templateHeader: 'PRODUCTIVITY TEMPLATES',
        animationKey: 'loading',
        templates: const [
          EmptyStateTemplateChip(
            label: 'Daily Goals',
            icon: Icons.today_outlined,
          ),
          EmptyStateTemplateChip(
            label: 'Project Tasks',
            icon: Icons.folder_outlined,
          ),
          EmptyStateTemplateChip(
            label: 'Quick Capture',
            icon: Icons.bolt_outlined,
          ),
          EmptyStateTemplateChip(
            label: 'Weekly Plan',
            icon: Icons.view_week_outlined,
          ),
        ],
        primaryActionLabel: 'Create Your First Task',
        primaryActionIcon: Icons.add,
        onPrimaryAction: () {
          AppLogger.i(
            'EmptyStateTodosHelpScreen: Create Your First Task pressed',
          );
          Navigator.pushNamed(context, '/todos/advanced');
        },
        secondaryActionLabel: 'Quick Add Task',
        secondaryActionIcon: Icons.bolt_outlined,
        onSecondaryAction: () {
          AppLogger.i('EmptyStateTodosHelpScreen: Quick Add Task pressed');
          Navigator.pushNamed(context, '/quick-add');
        },
      ),
    );
  }

  PreferredSizeWidget _buildTopAppBar(BuildContext context) {
    return AppBar(
      title: const Text(
        'Tasks',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.5,
        ),
      ),
      backgroundColor: Theme.of(
        context,
      ).scaffoldBackgroundColor.withOpacity(0.8),
      elevation: 0,
      scrolledUnderElevation: 0,
      leadingWidth: 56,
      leading: Container(
        margin: EdgeInsets.only(left: 16.w),
        child: IconButton(
          onPressed: () {
            AppLogger.i('EmptyStateTodosHelpScreen: Menu pressed');
            // Handle menu action
          },
          icon: const Icon(Icons.menu),
          iconSize: 24,
        ),
      ),
      actions: [
        Container(
          margin: EdgeInsets.only(right: 16.w),
          child: IconButton(
            onPressed: () {
              AppLogger.i('EmptyStateTodosHelpScreen: Settings pressed');
              // Handle settings action
            },
            icon: const Icon(Icons.settings_outlined),
            iconSize: 24,
          ),
        ),
      ],
    );
  }
}
