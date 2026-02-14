import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:package_info_plus/package_info_plus.dart';
import '../../core/services/global_ui_service.dart';
import '../bloc/theme/theme_bloc.dart';
import '../bloc/theme/theme_event.dart';
import '../bloc/theme/theme_state.dart';
import '../bloc/settings/settings_bloc.dart';
import '../bloc/params/settings_params.dart';
import '../design_system/design_system.dart';
import 'font_settings_screen.dart';
import 'voice_settings_screen.dart';
import 'backup_export_screen.dart';
import 'biometric_lock_screen.dart';
import '../../core/services/backup_service.dart';
import '../../injection_container.dart' show getIt;
import '../widgets/developer_test_links_sheet.dart';
import '../widgets/theme_color_picker_bottomsheet.dart';

/// Settings Screen (ORG-006)
/// Optimized settings management with BLoC and Design System
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SettingsBloc()..add(const LoadSettingsEvent()),
      child: const _SettingsScreenContent(),
    );
  }
}

class _SettingsScreenContent extends StatelessWidget {
  const _SettingsScreenContent({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocBuilder<SettingsBloc, SettingsState>(
      builder: (context, state) {
        if (state is SettingsInitial || state is SettingsLoading) {
          return Scaffold(
            backgroundColor: isDark
                ? AppColors.darkBackground
                : AppColors.lightBackground,
            appBar: _buildAppBar(context),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        if (state is SettingsError) {
          return Scaffold(
            backgroundColor: isDark
                ? AppColors.darkBackground
                : AppColors.lightBackground,
            appBar: _buildAppBar(context),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 48.sp,
                    color: AppColors.error,
                  ),
                  SizedBox(height: AppSpacing.md),
                  Text(
                    'Error loading settings',
                    style: AppTypography.titleMedium(context),
                  ),
                  Text(state.message, style: AppTypography.caption(context)),
                  SizedBox(height: AppSpacing.lg),
                  ElevatedButton(
                    onPressed: () => context.read<SettingsBloc>().add(
                      const LoadSettingsEvent(),
                    ),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }

        if (state is SettingsLoaded) {
          final params = state.params;

          return Scaffold(
            backgroundColor: isDark
                ? AppColors.darkBackground
                : AppColors.lightBackground,
            appBar: _buildAppBar(context),
            body: ListView(
              padding: EdgeInsets.only(bottom: AppSpacing.massive),
              children: [
                _buildSectionHeader(context, 'APPEARANCE'),
                _buildAppearanceSection(context, params, isDark),
                _buildSectionHeader(context, 'PRIVACY & TRUST'),
                _buildPrivacySection(context, params, isDark),
                _buildSectionHeader(context, 'NOTIFICATIONS'),
                _buildNotificationsSection(context, params, isDark),
                _buildSectionHeader(context, 'VOICE & INPUT'),
                _buildVoiceInputSection(context, params, isDark),
                _buildSectionHeader(context, 'DATA MANAGEMENT'),
                _buildDataManagementSection(context, params, isDark),
                _buildSectionHeader(context, 'DEVELOPER TOOLS'),
                _buildDeveloperSection(context, isDark),
                _buildFooter(context, isDark),
              ],
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AppBar(
      backgroundColor: isDark
          ? AppColors.darkBackground
          : AppColors.lightBackground,
      elevation: 0,
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back_ios,
          color: isDark ? AppColors.lightText : AppColors.darkText,
          size: 20.sp,
        ),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: Text(
        'Settings',
        style: AppTypography.heading2(
          context,
        ).copyWith(color: isDark ? AppColors.lightText : AppColors.darkText),
      ),
      centerTitle: true,
      actions: [
        PopupMenuButton<String>(
          icon: Icon(Icons.more_vert, color: AppColors.primary),
          onSelected: (value) => _handleSettingsMenu(context, value),
          itemBuilder: (BuildContext context) => [
            const PopupMenuItem(
              value: 'voice',
              child: Row(
                children: [
                  Icon(Icons.mic, size: 20),
                  SizedBox(width: 12),
                  Text('Voice Settings'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'security',
              child: Row(
                children: [
                  Icon(Icons.security, size: 20),
                  SizedBox(width: 12),
                  Text('Security'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'backup',
              child: Row(
                children: [
                  Icon(Icons.backup, size: 20),
                  SizedBox(width: 12),
                  Text('Backup & Export'),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _handleSettingsMenu(BuildContext context, String value) {
    switch (value) {
      case 'voice':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const VoiceSettingsScreen()),
        );
        break;
      case 'security':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const BiometricLockScreen()),
        );
        break;
      case 'backup':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const BackupExportScreen()),
        );
        break;
    }
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 8.h),
      child: Text(
        title,
        style: AppTypography.labelMedium(context).copyWith(
          color: AppColors.secondaryText,
          letterSpacing: 1.2,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildAppearanceSection(
    BuildContext context,
    SettingsParams params,
    bool isDark,
  ) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        return Container(
          margin: EdgeInsets.symmetric(horizontal: AppSpacing.md),
          decoration: BoxDecoration(
            color:
                (isDark ? AppColors.darkSurface : AppColors.surface) as Color?,
            borderRadius: BorderRadius.circular(AppSpacing.radiusXL),
            border: Border.all(
              color:
                  (isDark ? AppColors.dividerDark : AppColors.divider) as Color,
            ),
          ),
          child: Column(
            children: [
              _buildSettingTile(
                context,
                icon: isDark ? Icons.dark_mode : Icons.light_mode,
                title: 'Appearance',
                subtitle: isDark ? 'Dark Mode' : 'Light Mode',
                trailing: _buildSwitch(themeState.isDarkMode, (value) {
                  context.read<ThemeBloc>().add(
                    UpdateThemeEvent.toggleDarkMode(themeState.params),
                  );
                }),
                hasDivider: true,
              ),
              _buildSettingTile(
                context,
                icon: Icons.palette_outlined,
                title: 'Color Theme',
                subtitle: 'Customize your workspace palette',
                trailing: Icon(
                  Icons.chevron_right,
                  size: 18.sp,
                  color: AppColors.secondaryText,
                ),
                onTap: () => _showThemePicker(context),
                hasDivider: true,
              ),
              _buildSettingTile(
                context,
                icon: Icons.font_download_outlined,
                title: 'Typography',
                subtitle: 'Font face and readability',
                trailing: Icon(
                  Icons.chevron_right,
                  size: 18.sp,
                  color: AppColors.secondaryText,
                ),
                onTap: () => _showFontSettings(context),
                hasDivider: true,
              ),
              _buildSettingTile(
                context,
                icon: Icons.auto_awesome,
                title: 'Micro-animations',
                subtitle: 'Smooth transitions for focus',
                trailing: _buildSwitch(params.useCustomColors, (value) {
                  context.read<SettingsBloc>().add(
                    UpdateSettingsEvent(
                      params.copyWith(useCustomColors: value),
                    ),
                  );
                }),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPrivacySection(
    BuildContext context,
    SettingsParams params,
    bool isDark,
  ) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: AppSpacing.md),
      decoration: BoxDecoration(
        color: (isDark ? AppColors.darkSurface : AppColors.surface) as Color?,
        borderRadius: BorderRadius.circular(AppSpacing.radiusXL),
        border: Border.all(
          color: (isDark ? AppColors.dividerDark : AppColors.divider) as Color,
        ),
      ),
      child: Column(
        children: [
          _buildSettingTile(
            context,
            icon: Icons.lock_outline,
            title: 'Security Setup',
            subtitle: 'PIN and biometric management',
            trailing: Icon(
              Icons.chevron_right,
              size: 18.sp,
              color: AppColors.secondaryText,
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const BiometricLockScreen(),
                ),
              );
            },
            hasDivider: true,
          ),
          _buildSettingTile(
            context,
            icon: Icons.visibility_off,
            title: 'Private Reflection',
            subtitle: 'Hide sensitive note previews',
            trailing: _buildSwitch(false, (value) {
              getIt<GlobalUiService>().showInfo(
                'Private Reflection: This feature is coming soon.',
              );
            }),
            hasDivider: params.biometricAvailable,
          ),
          if (params.biometricAvailable)
            _buildSettingTile(
              context,
              icon: Icons.fingerprint,
              title: 'Biometric Lock',
              subtitle: params.biometricEnabled
                  ? 'Biometric protection active'
                  : 'Disabled',
              trailing: _buildSwitch(
                params.biometricEnabled,
                (value) => context.read<SettingsBloc>().add(
                  ToggleBiometricEvent(value),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildNotificationsSection(
    BuildContext context,
    SettingsParams params,
    bool isDark,
  ) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: AppSpacing.md),
      decoration: BoxDecoration(
        color: (isDark ? AppColors.darkSurface : AppColors.surface) as Color?,
        borderRadius: BorderRadius.circular(AppSpacing.radiusXL),
        border: Border.all(
          color: (isDark ? AppColors.dividerDark : AppColors.divider) as Color,
        ),
      ),
      child: Column(
        children: [
          _buildSettingTile(
            context,
            icon: Icons.notifications,
            title: 'Notifications',
            subtitle: 'Receive alerts and reminders',
            trailing: _buildSwitch(params.notificationsEnabled, (value) {
              context.read<SettingsBloc>().add(
                UpdateSettingsEvent(
                  params.copyWith(notificationsEnabled: value),
                ),
              );
            }),
            hasDivider: true,
          ),
          if (params.notificationsEnabled)
            _buildSettingTile(
              context,
              icon: Icons.volume_up,
              title: 'Notification Sound',
              subtitle: params.notificationFrequency,
              trailing: Icon(
                Icons.chevron_right,
                size: 18.sp,
                color: AppColors.secondaryText,
              ),
              hasDivider: true,
              onTap: () => _showNotificationSoundPicker(context, params),
            ),
          if (params.notificationsEnabled)
            _buildSettingTile(
              context,
              icon: Icons.vibration,
              title: 'Vibration',
              subtitle: 'Haptic feedback for alerts',
              trailing: _buildSwitch(params.vibrationEnabled, (value) {
                context.read<SettingsBloc>().add(
                  UpdateSettingsEvent(params.copyWith(vibrationEnabled: value)),
                );
              }),
              hasDivider: true,
            ),
          if (params.notificationsEnabled)
            _buildSettingTile(
              context,
              icon: Icons.lightbulb,
              title: 'LED Notifications',
              subtitle: 'Flash LED indicator',
              trailing: _buildSwitch(params.ledEnabled, (value) {
                context.read<SettingsBloc>().add(
                  UpdateSettingsEvent(params.copyWith(ledEnabled: value)),
                );
              }),
              hasDivider: true,
            ),
          if (params.notificationsEnabled)
            _buildSettingTile(
              context,
              icon: Icons.schedule,
              title: 'Quiet Hours',
              subtitle: params.quietHoursEnabled
                  ? '${params.quietHoursStart} - ${params.quietHoursEnd}'
                  : 'Not set',
              trailing: _buildSwitch(params.quietHoursEnabled, (value) {
                context.read<SettingsBloc>().add(
                  UpdateSettingsEvent(
                    params.copyWith(quietHoursEnabled: value),
                  ),
                );
              }),
              hasDivider: !params.quietHoursEnabled,
              onTap: params.quietHoursEnabled
                  ? () => _showQuietHoursPicker(context, params)
                  : null,
            ),
        ],
      ),
    );
  }

  Widget _buildVoiceInputSection(
    BuildContext context,
    SettingsParams params,
    bool isDark,
  ) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: AppSpacing.md),
      decoration: BoxDecoration(
        color: (isDark ? AppColors.darkSurface : AppColors.surface) as Color?,
        borderRadius: BorderRadius.circular(AppSpacing.radiusXL),
        border: Border.all(
          color: (isDark ? AppColors.dividerDark : AppColors.divider) as Color,
        ),
      ),
      child: Column(
        children: [
          _buildSettingTile(
            context,
            icon: Icons.mic,
            title: 'Dictation Language',
            subtitle: null,
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'English',
                  style: AppTypography.bodySmall(
                    context,
                  ).copyWith(color: AppColors.secondaryText),
                ),
                SizedBox(width: AppSpacing.xs),
                Icon(
                  Icons.chevron_right,
                  size: 18.sp,
                  color: AppColors.secondaryText,
                ),
              ],
            ),
            hasDivider: true,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const VoiceSettingsScreen(),
                ),
              );
            },
          ),
          _buildSettingTile(
            context,
            icon: Icons.vibration,
            title: 'Haptic Feedback',
            subtitle: null,
            trailing: _buildSwitch(params.vibrationEnabled, (value) {
              context.read<SettingsBloc>().add(
                UpdateSettingsEvent(params.copyWith(vibrationEnabled: value)),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildDataManagementSection(
    BuildContext context,
    SettingsParams params,
    bool isDark,
  ) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: AppSpacing.md),
      padding: EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: (isDark ? AppColors.darkSurface : AppColors.surface) as Color?,
        borderRadius: BorderRadius.circular(AppSpacing.radiusXL),
        border: Border.all(
          color: (isDark ? AppColors.dividerDark : AppColors.divider) as Color,
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${params.storageUsed} storage used',
                    style: AppTypography.titleMedium(context).copyWith(
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppColors.lightText : AppColors.darkText,
                    ),
                  ),
                  SizedBox(height: AppSpacing.xs),
                  Text(
                    '${params.noteCount} notes • ${params.mediaCount} files',
                    style: AppTypography.caption(
                      context,
                    ).copyWith(color: AppColors.secondaryText),
                  ),
                ],
              ),
              Icon(Icons.cloud_done, color: AppColors.success, size: 20.sp),
            ],
          ),
          SizedBox(height: AppSpacing.lg),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const BackupExportScreen(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.sm),
                ),
                elevation: 0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.backup, size: 20),
                  SizedBox(width: AppSpacing.sm),
                  Text(
                    'Backup & Export Wizard',
                    style: AppTypography.bodyMedium(context).copyWith(
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: AppSpacing.md),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => _clearCache(context),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.error,
                side: BorderSide(color: AppColors.error),
                padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.sm),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.delete_sweep_outlined, size: 20),
                  SizedBox(width: AppSpacing.sm),
                  Text(
                    'Clear Cache',
                    style: AppTypography.bodyMedium(context).copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.error,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeveloperSection(BuildContext context, bool isDark) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: AppSpacing.md),
      decoration: BoxDecoration(
        color: (isDark ? AppColors.darkSurface : AppColors.surface) as Color?,
        borderRadius: BorderRadius.circular(AppSpacing.radiusXL),
        border: Border.all(
          color: (isDark ? AppColors.dividerDark : AppColors.divider) as Color,
        ),
      ),
      child: _buildSettingTile(
        context,
        icon: Icons.terminal,
        title: 'Developer Test Links',
        subtitle: 'Quick navigation to 75+ screens for testing',
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 16.sp,
          color: AppColors.secondaryText,
        ),
        onTap: () {
          showModalBottomSheet(
            context: context,
            builder: (_) => const DeveloperTestLinksSheet(),
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
          );
        },
      ),
    );
  }

  Widget _buildFooter(BuildContext context, bool isDark) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: AppSpacing.massive),
      child: Column(
        children: [
          FutureBuilder<PackageInfo>(
            future: PackageInfo.fromPlatform(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                final info = snapshot.data!;
                return Text(
                  'MyNotes version ${info.version} (Build ${info.buildNumber})',
                  style: AppTypography.caption(
                    context,
                  ).copyWith(color: AppColors.secondaryText.withOpacity(0.5)),
                );
              }
              return const SizedBox.shrink();
            },
          ),
          SizedBox(height: AppSpacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () {},
                child: Text(
                  'Privacy Policy',
                  style: AppTypography.caption(context).copyWith(
                    color: AppColors.primary,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
              SizedBox(width: AppSpacing.md),
              GestureDetector(
                onTap: () {},
                child: Text(
                  'Terms of Service',
                  style: AppTypography.caption(context).copyWith(
                    color: AppColors.primary,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSettingTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    bool hasDivider = false,
    VoidCallback? onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        InkWell(
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.md,
            ),
            child: Row(
              children: [
                Container(
                  width: 40.w,
                  height: 40.w,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppSpacing.sm),
                  ),
                  child: Icon(icon, color: AppColors.primary, size: 20.sp),
                ),
                SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: AppTypography.bodyMedium(context).copyWith(
                          fontWeight: FontWeight.w500,
                          color: isDark
                              ? AppColors.lightText
                              : AppColors.darkText,
                        ),
                      ),
                      if (subtitle != null) ...[
                        SizedBox(height: AppSpacing.xxs),
                        Text(
                          subtitle,
                          style: AppTypography.caption(
                            context,
                          ).copyWith(color: AppColors.secondaryText),
                        ),
                      ],
                    ],
                  ),
                ),
                if (trailing != null) ...[
                  SizedBox(width: AppSpacing.sm),
                  trailing,
                ],
              ],
            ),
          ),
        ),
        if (hasDivider)
          Divider(
            height: 1,
            thickness: 1,
            indent: 72.w,
            color:
                (isDark ? AppColors.dividerDark : AppColors.divider) as Color?,
          ),
      ],
    );
  }

  Widget _buildSwitch(bool value, ValueChanged<bool> onChanged) {
    return SizedBox(
      width: 48.w,
      height: 28.h,
      child: Transform.scale(
        scale: 0.8,
        child: Switch(
          value: value,
          onChanged: onChanged,
          activeColor: AppColors.primary,
          activeTrackColor: AppColors.primary.withOpacity(0.5),
          inactiveThumbColor: Colors.white,
          inactiveTrackColor: AppColors.textMuted.withOpacity(0.3),
        ),
      ),
    );
  }

  void _showNotificationSoundPicker(
    BuildContext context,
    SettingsParams params,
  ) {
    final soundOptions = [
      'Default',
      'System Alert',
      'Alert Tone 1',
      'Alert Tone 2',
      'Chime',
      'Bell',
    ];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Notification Sound'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: soundOptions.length,
            itemBuilder: (context, index) {
              final sound = soundOptions[index];
              return RadioListTile<String>(
                title: Text(sound),
                value: sound,
                groupValue: params
                    .notificationFrequency, // Reuse as current selection for demo
                onChanged: (value) {
                  if (value != null) {
                    context.read<SettingsBloc>().add(
                      UpdateSettingsEvent(
                        params.copyWith(notificationFrequency: value),
                      ),
                    );
                    Navigator.pop(context);
                  }
                },
              );
            },
          ),
        ),
      ),
    );
  }

  void _showQuietHoursPicker(BuildContext context, SettingsParams params) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Set Quiet Hours'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 16),
            const Text(
              'Start Time:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ListTile(
              title: Text(params.quietHoursStart),
              trailing: const Icon(Icons.edit),
              onTap: () => _selectQuietHourTime(context, params, true),
            ),
            const SizedBox(height: 16),
            const Text(
              'End Time:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ListTile(
              title: Text(params.quietHoursEnd),
              trailing: const Icon(Icons.edit),
              onTap: () => _selectQuietHourTime(context, params, false),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Future<void> _selectQuietHourTime(
    BuildContext context,
    SettingsParams params,
    bool isStart,
  ) async {
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (pickedTime != null) {
      final timeString =
          '${pickedTime.hour.toString().padLeft(2, '0')}:${pickedTime.minute.toString().padLeft(2, '0')}';
      if (isStart) {
        context.read<SettingsBloc>().add(
          UpdateSettingsEvent(params.copyWith(quietHoursStart: timeString)),
        );
      } else {
        context.read<SettingsBloc>().add(
          UpdateSettingsEvent(params.copyWith(quietHoursEnd: timeString)),
        );
      }
    }
  }

  void _showFontSettings(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const FontSettingsScreen()),
    );
  }

  Future<void> _showThemePicker(BuildContext context) async {
    final themeBloc = context.read<ThemeBloc>();
    final themeParams = themeBloc.state.params;

    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) => ThemeColorPickerBottomSheet(
        initialColor: themeParams.primaryColor,
        onColorSelected: (Color p1) {
          themeBloc.add(UpdateThemeEvent.changeColor(themeParams, p1));
        },
      ),
    );
  }

  void _clearCache(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Cache'),
        content: const Text(
          'This will delete temporary files and cached media. Your notes and main data will not be affected.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await BackupService.clearCache();
              if (context.mounted) {
                Navigator.pop(context);
                getIt<GlobalUiService>().showSuccess(
                  'Cache cleared successfully',
                );
              }
            },
            child: const Text('Clear', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
