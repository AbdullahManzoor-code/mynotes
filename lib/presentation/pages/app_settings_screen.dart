import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../presentation/design_system/app_colors.dart';
import '../../presentation/design_system/app_typography.dart';
import '../../presentation/design_system/app_spacing.dart';
import '../widgets/theme_toggle_button.dart';

/// App Settings and Privacy Screen
/// Comprehensive settings management with privacy controls
class AppSettingsScreen extends StatefulWidget {
  const AppSettingsScreen({Key? key}) : super(key: key);

  @override
  State<AppSettingsScreen> createState() => _AppSettingsScreenState();
}

class _AppSettingsScreenState extends State<AppSettingsScreen> {
  bool _notificationsEnabled = true;
  bool _biometricEnabled = false;
  bool _analyticsEnabled = false;
  bool _crashReportsEnabled = true;
  String _selectedTheme = 'System';
  String _selectedLanguage = 'English';
  
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: AppColors.textPrimary(context),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Settings',
          style: AppTypography.heading2(context, AppColors.textPrimary(context)),
        ),
        actions: [
          const SizedBox(width: 48), // Balance for centering
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.screenPaddingHorizontal,
          vertical: AppSpacing.lg,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Account Section
            _buildSection(
              context,
              'Account',
              [
                _buildSettingsTile(
                  context,
                  'Profile Settings',
                  'Manage your profile and account information',
                  Icons.person_outline,
                  onTap: () {
                    // Navigate to profile settings
                  },
                ),
                _buildSettingsTile(
                  context,
                  'Backup & Export',
                  'Export your data and manage backups',
                  Icons.backup_outlined,
                  onTap: () {
                    Navigator.pushNamed(context, '/backup-export');
                  },
                ),
              ],
            ),
            
            // Preferences Section
            _buildSection(
              context,
              'Preferences',
              [
                _buildSwitchTile(
                  context,
                  'Push Notifications',
                  'Receive reminders and updates',
                  Icons.notifications_outlined,
                  _notificationsEnabled,
                  (value) {
                    setState(() {
                      _notificationsEnabled = value;
                    });
                  },
                ),
                _buildDropdownTile(
                  context,
                  'Theme',
                  'Choose your preferred theme',
                  Icons.palette_outlined,
                  _selectedTheme,
                  ['Light', 'Dark', 'System'],
                  (value) {
                    setState(() {
                      _selectedTheme = value!;
                    });
                  },
                ),
                _buildDropdownTile(
                  context,
                  'Language',
                  'Select your language',
                  Icons.language_outlined,
                  _selectedLanguage,
                  ['English', 'Spanish', 'French', 'German'],
                  (value) {
                    setState(() {
                      _selectedLanguage = value!;
                    });
                  },
                ),
              ],
            ),
            
            // Security & Privacy Section
            _buildSection(
              context,
              'Security & Privacy',
              [
                _buildSwitchTile(
                  context,
                  'Biometric Authentication',
                  'Use fingerprint or face unlock',
                  Icons.fingerprint_outlined,
                  _biometricEnabled,
                  (value) {
                    setState(() {
                      _biometricEnabled = value;
                    });
                  },
                ),
                _buildSettingsTile(
                  context,
                  'Data & Privacy',
                  'Manage your privacy settings',
                  Icons.privacy_tip_outlined,
                  onTap: () {
                    // Navigate to privacy settings
                  },
                ),
                _buildSwitchTile(
                  context,
                  'Analytics & Crash Reports',
                  'Help improve the app by sharing usage data',
                  Icons.analytics_outlined,
                  _crashReportsEnabled,
                  (value) {
                    setState(() {
                      _crashReportsEnabled = value;
                    });
                  },
                ),
              ],
            ),
            
            // Storage Section
            _buildSection(
              context,
              'Storage',
              [
                _buildSettingsTile(
                  context,
                  'Manage Storage',
                  '2.4 GB used • Clear cache and unused files',
                  Icons.storage_outlined,
                  onTap: () {
                    // Navigate to storage management
                  },
                ),
                _buildSettingsTile(
                  context,
                  'Calendar Integration',
                  'Connect with your calendar app',
                  Icons.calendar_today_outlined,
                  onTap: () {
                    Navigator.pushNamed(context, '/calendar-integration');
                  },
                ),
              ],
            ),
            
            // Help & Support Section
            _buildSection(
              context,
              'Help & Support',
              [
                _buildSettingsTile(
                  context,
                  'Help Center',
                  'Get help and learn how to use the app',
                  Icons.help_outline,
                  onTap: () {
                    // Navigate to help center
                  },
                ),
                _buildSettingsTile(
                  context,
                  'Contact Support',
                  'Get in touch with our support team',
                  Icons.support_agent_outlined,
                  onTap: () {
                    // Navigate to contact support
                  },
                ),
                _buildSettingsTile(
                  context,
                  'About',
                  'Version 1.0.0 • Terms of Service',
                  Icons.info_outline,
                  onTap: () {
                    // Navigate to about page
                  },
                ),
              ],
            ),
            
            const SizedBox(height: 100), // Bottom padding
          ],
        ),
      ),
    );
  }
  
  Widget _buildSection(BuildContext context, String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(
            left: AppSpacing.md,
            bottom: AppSpacing.sm,
            top: AppSpacing.xl,
          ),
          child: Text(
            title,
            style: AppTypography.caption(
              context,
              AppColors.textSecondary(context),
              FontWeight.w600,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark
                ? AppColors.darkCardBackground
                : AppColors.lightCardBackground,
            borderRadius: BorderRadius.circular(AppSpacing.radiusLG),
          ),
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }
  
  Widget _buildSettingsTile(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon, {
    VoidCallback? onTap,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm,
      ),
      leading: Icon(
        icon,
        color: AppColors.primaryColor,
        size: 24,
      ),
      title: Text(
        title,
        style: AppTypography.bodyMedium(context, AppColors.textPrimary(context)),
      ),
      subtitle: Text(
        subtitle,
        style: AppTypography.caption(context, AppColors.textSecondary(context)),
      ),
      trailing: Icon(
        Icons.chevron_right,
        color: AppColors.textSecondary(context),
      ),
      onTap: onTap,
    );
  }
  
  Widget _buildSwitchTile(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm,
      ),
      leading: Icon(
        icon,
        color: AppColors.primaryColor,
        size: 24,
      ),
      title: Text(
        title,
        style: AppTypography.bodyMedium(context, AppColors.textPrimary(context)),
      ),
      subtitle: Text(
        subtitle,
        style: AppTypography.caption(context, AppColors.textSecondary(context)),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: AppColors.primaryColor,
      ),
    );
  }
  
  Widget _buildDropdownTile(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    String value,
    List<String> options,
    ValueChanged<String?> onChanged,
  ) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm,
      ),
      leading: Icon(
        icon,
        color: AppColors.primaryColor,
        size: 24,
      ),
      title: Text(
        title,
        style: AppTypography.bodyMedium(context, AppColors.textPrimary(context)),
      ),
      subtitle: Text(
        subtitle,
        style: AppTypography.caption(context, AppColors.textSecondary(context)),
      ),
      trailing: DropdownButton<String>(
        value: value,
        onChanged: onChanged,
        underline: const SizedBox(),
        items: options.map((String option) {
          return DropdownMenuItem<String>(
            value: option,
            child: Text(
              option,
              style: AppTypography.caption(context, AppColors.textPrimary(context)),
            ),
          );
        }).toList(),
      ),
    );
  }
}