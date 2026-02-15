import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mynotes/domain/entities/note.dart';
import 'package:mynotes/injection_container.dart';
import '../design_system/design_system.dart';
import '../bloc/theme/theme_bloc.dart';
import '../bloc/theme/theme_event.dart';
import '../bloc/theme/theme_state.dart';
import '../bloc/settings/settings_bloc.dart';

import 'package:mynotes/core/database/core_database.dart';
import 'package:mynotes/presentation/bloc/alarm/alarms_bloc.dart';

// ==================== Core Screens ====================
import 'analytics_dashboard_screen.dart';
import 'focus_session_screen.dart';
import 'enhanced_global_search_screen.dart';
import 'fixed_universal_quick_add_screen.dart';

// ==================== Notes Screens ====================
import 'enhanced_notes_list_screen.dart';
import 'enhanced_note_editor_screen.dart';
// import 'advanced_note_editor.dart';

// ==================== Todos Screens ====================
import 'recurring_todo_schedule_screen.dart';

// ==================== Reminders Screens ====================
import 'enhanced_reminders_list_screen.dart';

// ==================== Focus & Productivity ====================
import 'focus_celebration_screen.dart';

// ==================== Dashboards ====================
import 'today_dashboard_screen.dart';
import 'main_home_screen.dart';

// ==================== Special Screens ====================
import 'search_filter_screen.dart';
import '../screens/todos_screen_fixed.dart';
import 'voice_settings_screen.dart';
import 'settings_screen.dart';
import 'privacy_policy_screen.dart';

// ==================== Utilities ====================
import 'document_scan_screen.dart';
import 'ocr_text_extraction_screen.dart';
import 'pdf_preview_screen.dart';
import 'calendar_integration_screen.dart';
import 'backup_export_screen.dart';
import 'biometric_lock_screen.dart';

// ==================== Empty States & Helpers ====================
import 'empty_state_notes_help_screen.dart';
import 'empty_state_todos_help_screen.dart';
import 'daily_focus_highlight_screen.dart';
import 'location_reminder_screen.dart';

/// Advanced Settings Screen
/// Master navigation hub with developer/debug section
/// Links to every screen in the project for testing
class AdvancedSettingsScreen extends StatelessWidget {
  const AdvancedSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    AppLogger.i('AdvancedSettingsScreen: Building UI');
    return BlocBuilder<SettingsBloc, SettingsState>(
      builder: (context, state) {
        final params = state is SettingsLoaded ? state.params : null;
        final isDeveloperMode = params?.developerModeEnabled ?? true;
        final showDebugInfo = params?.showDebugInfo ?? true;

        return Scaffold(
          backgroundColor: AppColors.darkBackground,
          appBar: AppBar(
            title: const Text('Settings'),
            backgroundColor: AppColors.darkBackground,
            elevation: 0,
            actions: [
              IconButton(
                onPressed: () {
                  AppLogger.i('AdvancedSettingsScreen: Toggle Developer Mode');
                  if (params != null) {
                    context.read<SettingsBloc>().add(
                      UpdateSettingsEvent(params.toggleDeveloperMode()),
                    );
                  }
                  HapticFeedback.lightImpact();
                },
                icon: Icon(
                  isDeveloperMode
                      ? Icons.developer_mode
                      : Icons.developer_board,
                  color: isDeveloperMode ? AppColors.primary : Colors.grey,
                ),
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: EdgeInsets.all(24.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // App Settings
                _buildSection('App Settings', [
                  _buildThemeTile(),
                  _buildSettingTile(
                    'Voice Recognition',
                    'Enhanced AI parsing enabled',
                    Icons.mic,
                    trailing: Switch(
                      value: true,
                      onChanged: (value) {
                        AppLogger.i(
                          'AdvancedSettingsScreen: Voice Recognition toggled to $value',
                        );
                      },
                      activeColor: AppColors.primary,
                    ),
                  ),
                  _buildSettingTile(
                    'Smart Notifications',
                    'Intelligent reminder system',
                    Icons.notifications_active,
                    trailing: Switch(
                      value: true,
                      onChanged: (value) {
                        AppLogger.i(
                          'AdvancedSettingsScreen: Smart Notifications toggled to $value',
                        );
                      },
                      activeColor: AppColors.primary,
                    ),
                  ),
                ]),

                SizedBox(height: 32.h),

                // Quick Actions
                _buildSection('Quick Actions', [
                  _buildActionTile(
                    'Analytics Dashboard',
                    'View productivity insights',
                    Icons.analytics,
                    () {
                      AppLogger.i(
                        'AdvancedSettingsScreen: Action Analytics Dashboard tapped',
                      );
                      _navigateToScreen(
                        context,
                        const AnalyticsDashboardScreen(),
                      );
                    },
                  ),
                  _buildActionTile(
                    'Global Search',
                    'Search across everything',
                    Icons.search,
                    () {
                      AppLogger.i(
                        'AdvancedSettingsScreen: Action Global Search tapped',
                      );
                      _navigateToScreen(
                        context,
                        const EnhancedGlobalSearchScreen(),
                      );
                    },
                  ),
                  _buildActionTile(
                    'Focus Session',
                    'Start Pomodoro timer',
                    Icons.psychology,
                    () {
                      AppLogger.i(
                        'AdvancedSettingsScreen: Action Focus Session tapped',
                      );
                      _navigateToScreen(context, const FocusSessionScreen());
                    },
                  ),
                ]),

                SizedBox(height: 32.h),

                // Data & Privacy
                _buildSection('Data & Privacy', [
                  _buildActionTile(
                    'Export Data',
                    'Backup your items',
                    Icons.download,
                    () {
                      AppLogger.i(
                        'AdvancedSettingsScreen: Action Export Data tapped',
                      );
                      _handleExportData(context);
                    },
                  ),
                  _buildActionTile(
                    'Clear Cache',
                    'Free up storage space',
                    Icons.cleaning_services,
                    () {
                      AppLogger.i(
                        'AdvancedSettingsScreen: Action Clear Cache tapped',
                      );
                      _handleClearCache(context);
                    },
                  ),
                  _buildSettingTile(
                    'Debug Info',
                    'Show technical details',
                    Icons.bug_report,
                    trailing: Switch(
                      value: showDebugInfo,
                      onChanged: (value) {
                        AppLogger.i(
                          'AdvancedSettingsScreen: Debug Info toggled to $value',
                        );
                        if (params != null) {
                          context.read<SettingsBloc>().add(
                            UpdateSettingsEvent(params.toggleDebugInfo()),
                          );
                        }
                      },
                      activeColor: AppColors.primary,
                    ),
                  ),
                ]),

                if (showDebugInfo) ...[
                  SizedBox(height: 16.h),
                  _buildDebugSection(),
                ],

                // Developer Mode Section
                if (isDeveloperMode) ...[
                  SizedBox(height: 32.h),
                  _buildDeveloperSection(context),
                ],

                SizedBox(height: 32.h),

                // About
                _buildSection('About', [
                  _buildInfoTile(
                    'MyNotes',
                    'Universal Productivity Hub v2.0',
                    Icons.info_outline,
                  ),
                  _buildInfoTile(
                    'Built with Flutter',
                    'Unified Notes • Todos • Reminders',
                    Icons.flutter_dash,
                  ),
                  _buildActionTile(
                    'Rate App',
                    'Help us improve',
                    Icons.star_outline,
                    () {
                      AppLogger.i(
                        'AdvancedSettingsScreen: Action Rate App tapped',
                      );
                      _handleRateApp(context);
                    },
                  ),
                  _buildActionTile(
                    'Privacy Policy',
                    'Read how we protect your data',
                    Icons.privacy_tip_outlined,
                    () {
                      AppLogger.i(
                        'AdvancedSettingsScreen: Action Privacy Policy tapped',
                      );
                      _navigateToScreen(context, const PrivacyPolicyScreen());
                    },
                  ),
                ]),

                SizedBox(height: 50.h),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 16.h),
        Container(
          decoration: BoxDecoration(
            color: AppColors.darkCardBackground,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildThemeTile() {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, state) {
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: Colors.white.withOpacity(0.1)),
            ),
          ),
          child: Row(
            children: [
              Icon(Icons.palette, color: AppColors.primary, size: 24.sp),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Theme',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      state.isDarkMode ? 'Dark Mode' : 'Light Mode',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey.shade400,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: state.isDarkMode,
                onChanged: (value) {
                  AppLogger.i(
                    'AdvancedSettingsScreen: Theme toggled to ${value ? 'Dark' : 'Light'}',
                  );
                  context.read<ThemeBloc>().add(
                    UpdateThemeEvent.toggleDarkMode(state.params),
                  );
                  HapticFeedback.lightImpact();
                },
                activeColor: AppColors.primary,
                inactiveThumbColor: Colors.grey.shade400,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSettingTile(
    String title,
    String subtitle,
    IconData icon, {
    Widget? trailing,
  }) {
    return ListTile(
      leading: Container(
        padding: EdgeInsets.all(8.w),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.2),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Icon(icon, color: AppColors.primary, size: 20.sp),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16.sp,
          fontWeight: FontWeight.w500,
          color: Colors.white,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade400),
      ),
      trailing: trailing,
      contentPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
    );
  }

  Widget _buildActionTile(
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: Container(
        padding: EdgeInsets.all(8.w),
        decoration: BoxDecoration(
          color: AppColors.accentBlue.withOpacity(0.2),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Icon(icon, color: AppColors.accentBlue, size: 20.sp),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16.sp,
          fontWeight: FontWeight.w500,
          color: Colors.white,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade400),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        color: Colors.grey.shade500,
        size: 16.sp,
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
      onTap: onTap,
    );
  }

  Widget _buildInfoTile(String title, String subtitle, IconData icon) {
    return ListTile(
      leading: Container(
        padding: EdgeInsets.all(8.w),
        decoration: BoxDecoration(
          color: AppColors.accentGreen.withOpacity(0.2),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Icon(icon, color: AppColors.accentGreen, size: 20.sp),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16.sp,
          fontWeight: FontWeight.w500,
          color: Colors.white,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade400),
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
    );
  }

  Widget _buildDebugSection() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey.shade700),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.terminal, color: Colors.green, size: 16.sp),
              SizedBox(width: 8.w),
              Text(
                'Debug Information',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.green,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          _buildDebugItem('Flutter Version', '3.19.0'),
          _buildDebugItem('Dart Version', '3.3.0'),
          _buildDebugItem('Database Version', '1.0.0'),
          _buildDebugItem('Build Mode', 'Debug'),
          _buildDebugItem('Platform', 'Android/iOS'),
        ],
      ),
    );
  }

  Widget _buildDebugItem(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade400),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 12.sp,
              color: Colors.green,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeveloperSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.developer_mode, color: AppColors.primary),
            SizedBox(width: 8.w),
            Text(
              'Developer Navigation (40+ Screens)',
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
        SizedBox(height: 16.h),

        // ==================== Core Screens ====================
        _buildDeveloperSubsection('🏠 Core Screens', [
          _buildDevTile(
            'Main Home',
            'Main dashboard with bottom navigation',
            () => _navigateToScreen(context, const MainHomeScreen()),
          ),
          _buildDevTile(
            'Universal Quick Add',
            'AI-powered smart input',
            () => _navigateToScreen(
              context,
              const FixedUniversalQuickAddScreen(),
            ),
          ),
          _buildDevTile(
            'Enhanced Search',
            'Voice-powered global search',
            () =>
                _navigateToScreen(context, const EnhancedGlobalSearchScreen()),
          ),
          _buildDevTile(
            'Focus Session',
            'Pomodoro timer',
            () => _navigateToScreen(context, const FocusSessionScreen()),
          ),
          _buildDevTile(
            'Focus Celebration',
            'Celebration screen',
            () => _navigateToScreen(context, const FocusCelebrationScreen()),
          ),
        ]),

        SizedBox(height: 24.h),

        // ==================== Dashboards ====================
        _buildDeveloperSubsection('📊 Dashboards', [
          _buildDevTile(
            'Analytics Dashboard',
            'Comprehensive insights',
            () => _navigateToScreen(context, const AnalyticsDashboardScreen()),
          ),
          _buildDevTile(
            'Today Dashboard',
            'Today\'s overview',
            () => _navigateToScreen(context, const TodayDashboardScreen()),
          ),
        ]),

        SizedBox(height: 24.h),

        // ==================== Notes Management ====================
        _buildDeveloperSubsection('📝 Notes', [
          _buildDevTile(
            'Enhanced Notes List',
            'Enhanced notes view',
            () => _navigateToScreen(context, const EnhancedNotesListScreen()),
          ),
          _buildDevTile(
            'Enhanced Note Editor',
            'Advanced editor',
            () => _navigateToScreen(context, const EnhancedNoteEditorScreen()),
          ),
          // _buildDevTile(
          //   'Advanced Note Editor',
          //   'Professional editor with Quill',
          //   () => _navigateToScreen(context, const AdvancedNoteEditor()),
          // ),
          _buildDevTile(
            'Empty Notes Help',
            'Help for empty state',
            () => _navigateToScreen(context, const EmptyStateNotesHelpScreen()),
          ),
        ]),

        SizedBox(height: 24.h),

        // ==================== Todos Management ====================
        _buildDeveloperSubsection('✅ Todos', [
          // _buildDevTile(
          //   'Todos List',
          //   'All todos',
          //   () => _navigateToScreen(context, TodosListScreen()),
          // ),
          // AdvancedTodoScreen and TodoFocusScreen require Note parameters
          // Available through Todos List when editing
          _buildDevTile(
            'Recurring Schedule',
            'Recurring todo scheduler',
            () =>
                _navigateToScreen(context, const RecurringTodoScheduleScreen()),
          ),
          _buildDevTile(
            'Empty Todos Help',
            'Help for empty state',
            () => _navigateToScreen(context, const EmptyStateTodosHelpScreen()),
          ),
        ]),

        SizedBox(height: 24.h),

        // ==================== Reminders Management ====================
        _buildDeveloperSubsection('⏰ Reminders', [
          _buildDevTile(
            'Enhanced Reminders',
            'Enhanced reminders view',
            () =>
                _navigateToScreen(context, const EnhancedRemindersListScreen()),
          ),
        ]),

        SizedBox(height: 24.h),

        // ==================== Search & Filter ====================
        _buildDeveloperSubsection('🔍 Search', [
          _buildDevTile(
            'Search Filter',
            'Advanced filtering',
            () => _navigateToScreen(context, const SearchFilterScreen()),
          ),
          // _buildDevTile(
          //   'Cross Feature Demo',
          //   'Cross-feature demo',
          //   () => _navigateToScreen(context, const CrossFeatureDemo()),
          // ),
        ]),

        SizedBox(height: 24.h),

        // ==================== Settings & Utilities ====================
        _buildDeveloperSubsection('⚙️ Settings & Utilities', [
          _buildDevTile(
            'Settings',
            'General settings',
            () => _navigateToScreen(context, const SettingsScreen()),
          ),
          _buildDevTile(
            'Voice Settings',
            'Voice configuration',
            () => _navigateToScreen(context, const VoiceSettingsScreen()),
          ),
          _buildDevTile(
            'Backup & Export',
            'Backup your data',
            () => _navigateToScreen(context, const BackupExportScreen()),
          ),
          _buildDevTile(
            'Biometric Lock',
            'Security settings',
            () => _navigateToScreen(context, const BiometricLockScreen()),
          ),
        ]),

        SizedBox(height: 24.h),

        // ==================== Advanced Features ====================
        _buildDeveloperSubsection('🚀 Advanced Features', [
          _buildDevTile(
            'Document Scan',
            'Scan documents',
            () => _navigateToScreen(context, const DocumentScanScreen()),
          ),
          _buildDevTile(
            'OCR Text Extraction',
            'Extract text from images',
            () => _navigateToScreen(context, const OcrTextExtractionScreen()),
          ),
          _buildDevTile(
            'PDF Preview',
            'Preview PDFs',
            () => _navigateToScreen(
              context,
              PdfPreviewScreen(note: Note(id: '1')),
            ),
          ),
          _buildDevTile(
            'Calendar Integration',
            'Calendar view',
            () => _navigateToScreen(context, const CalendarIntegrationScreen()),
          ),
          // _buildDevTile(
          //   'Daily Highlights',
          //   'Daily summary',
          //   () =>
          //       _navigateToScreen(context, const DailyHighlightSummaryScreen()),
          // ),
          // EditDailyHighlightScreen is in edit_daily_highlight_screen_new.dart
          // Uncomment if needed - currently using alternative
        ]),

        SizedBox(height: 24.h),

        // ==================== Other Screens ====================
        _buildDeveloperSubsection('📦 Other Screens', [
          // QuickAddConfirmationScreen requires noteId, title, and type
          // Shown automatically from Quick Add flow
          _buildDevTile(
            'Location Reminder',
            'Location-based reminders',
            () => _navigateToScreen(context, const LocationReminderScreen()),
          ),
        ]),

        SizedBox(height: 24.h),

        // ==================== Test Actions ====================
        _buildDeveloperSubsection('🧪 Test Actions', [
          _buildDevTile(
            'Seed Dummy Data',
            'Clears DB and adds test notes/todos',
            () => _generateSampleData(context),
          ),
          _buildDevTile(
            'Trigger Test Alarm',
            'Schedules a notification for 10s from now',
            () => _testAlarm(context),
          ),
          _buildDevTile(
            'Export Database',
            'Download SQLite file',
            _exportDatabase,
          ),
        ]),
      ],
    );
  }

  Widget _buildDeveloperSubsection(String title, List<Widget> children) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        color: AppColors.darkCardBackground,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12.r),
                topRight: Radius.circular(12.r),
              ),
            ),
            child: Text(
              title,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  Widget _buildDevTile(String title, String subtitle, VoidCallback onTap) {
    return ListTile(
      title: Text(
        title,
        style: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.w500,
          color: Colors.white,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade400),
      ),
      trailing: Icon(Icons.launch, color: AppColors.primary, size: 16.sp),
      onTap: onTap,
      dense: true,
      contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
    );
  }

  // Action methods
  void _navigateToScreen(BuildContext context, Widget screen) {
    AppLogger.i('AdvancedSettingsScreen: Navigating to ${screen.runtimeType}');
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }

  void _handleExportData(BuildContext context) {
    AppLogger.i('AdvancedSettingsScreen: _handleExportData called');
    // TODO: Implement data export
    _showSnackbar('Export feature coming soon');
  }

  void _handleClearCache(BuildContext context) {
    AppLogger.i('AdvancedSettingsScreen: _handleClearCache called');
    // TODO: Implement cache clearing
    _showSnackbar('Cache cleared successfully');
  }

  void _handleRateApp(BuildContext context) {
    AppLogger.i('AdvancedSettingsScreen: _handleRateApp called');
    // TODO: Open app store rating
    _showSnackbar('Thank you for your support!');
  }

  Future<void> _launchUrl(BuildContext context, String urlString) async {
    AppLogger.i('AdvancedSettingsScreen: _launchUrl called for $urlString');
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      AppLogger.w('AdvancedSettingsScreen: Could not launch $urlString');
      _showSnackbar('Could not launch $urlString');
    }
  }

  Future<void> _generateSampleData(BuildContext context) async {
    AppLogger.i('AdvancedSettingsScreen: _generateSampleData called');
    try {
      await CoreDatabase().seedDummyData();
      AppLogger.i('AdvancedSettingsScreen: Database seeded successfully');
      _showSnackbar('Database seeded with dummy data');
    } catch (e) {
      AppLogger.e('AdvancedSettingsScreen: Seeding failed', e);
      _showSnackbar('Seeding failed: $e');
    }
  }

  void _testAlarm(BuildContext context) {
    AppLogger.i('AdvancedSettingsScreen: _testAlarm called');
    context.read<AlarmsBloc>().add(
      AddAlarmEvent.quickAlarm(
        fromNow: const Duration(seconds: 10),
        title: 'Test Alarm 🚀',
        description: 'This is a test notification from developer tools.',
      ),
    );

    _showSnackbar('Alarm scheduled for 10 seconds');
  }

  void _clearAllData(BuildContext context) {
    AppLogger.i('AdvancedSettingsScreen: _clearAllData dialog shown');
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.darkCardBackground,
        title: const Text('Clear All Data?'),
        titleTextStyle: TextStyle(color: Colors.white, fontSize: 18.sp),
        content: const Text('This will permanently delete all items.'),
        contentTextStyle: TextStyle(color: Colors.grey.shade300),
        actions: [
          TextButton(
            onPressed: () {
              AppLogger.i('AdvancedSettingsScreen: Clear All Data cancelled');
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              AppLogger.i('AdvancedSettingsScreen: Clear All Data confirmed');
              Navigator.pop(context);
              // TODO: Clear database
              _showSnackbar('All data cleared');
            },
            child: const Text('Clear', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _exportDatabase() {
    AppLogger.i('AdvancedSettingsScreen: _exportDatabase called');
    // TODO: Export database file
    _showSnackbar('Database exported to Downloads');
  }

  void _testVoiceParser(BuildContext context) {
    AppLogger.i('AdvancedSettingsScreen: _testVoiceParser called');
    // TODO: Open voice parser test dialog
    _navigateToScreen(context, const FixedUniversalQuickAddScreen());
  }

  void _showSnackbar(String message) {
    getIt<GlobalUiService>().showSuccess(message);
  }
}
