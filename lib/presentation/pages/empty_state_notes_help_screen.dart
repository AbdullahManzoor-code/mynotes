import 'package:flutter/material.dart';
import '../../core/routes/app_routes.dart';
import '../design_system/design_system.dart';
import '../widgets/empty_state_help_body.dart';

/// Empty State Notes Help Screen
/// Provides guidance when user has no notes created yet
class EmptyStateNotesHelpScreen extends StatelessWidget {
  const EmptyStateNotesHelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      safeAreaTop: false,
      appBar: _buildTopAppBar(context),
      body: EmptyStateHelpBody(
        title: 'Your digital brain is empty.',
        subtitle:
            'Start with a template to structure your thoughts or begin with a blank canvas.',
        templateHeader: 'QUICK-START TEMPLATES',
        animationKey: 'empty_state',
        templates: const [
          EmptyStateTemplateChip(
            label: 'Meeting Notes',
            icon: Icons.calendar_today,
          ),
          EmptyStateTemplateChip(
            label: 'Daily Journal',
            icon: Icons.edit_square,
          ),
          EmptyStateTemplateChip(
            label: 'Brainstorm',
            icon: Icons.lightbulb_outline,
          ),
          EmptyStateTemplateChip(label: 'To-do List', icon: Icons.checklist),
        ],
        primaryActionLabel: 'Create New Note',
        primaryActionIcon: Icons.add,
        onPrimaryAction: () {
          AppLogger.i('EmptyStateNotesHelpScreen: Create New Note pressed');
          Navigator.pushNamed(context, AppRoutes.noteEditor);
        },
        secondaryActionLabel: 'Import existing notes',
        secondaryActionIcon: Icons.file_upload_outlined,
        onSecondaryAction: () {
          AppLogger.i(
            'EmptyStateNotesHelpScreen: Import existing notes pressed',
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildTopAppBar(BuildContext context) {
    return AppBar(
      title: Text('Notes', style: AppTypography.heading3(context)),
      backgroundColor: AppColors.getBackgroundColor(
        Theme.of(context).brightness,
      ).withOpacity(0.8),
      elevation: 0,
      scrolledUnderElevation: 0,
      leadingWidth: 56,
      leading: Container(
        margin: EdgeInsets.only(left: 16.w),
        child: IconButton(
          onPressed: () {
            AppLogger.i('EmptyStateNotesHelpScreen: Menu pressed');
            // Handle menu action
          },
          icon: Icon(Icons.menu, color: AppColors.textPrimary(context)),
          iconSize: 24,
        ),
      ),
      actions: [
        Container(
          margin: EdgeInsets.only(right: 16.w),
          child: IconButton(
            onPressed: () {
              AppLogger.i('EmptyStateNotesHelpScreen: Settings pressed');
              // Handle settings action
            },
            icon: Icon(
              Icons.settings_outlined,
              color: AppColors.textPrimary(context),
            ),
            iconSize: 24,
          ),
        ),
      ],
    );
  }
}
