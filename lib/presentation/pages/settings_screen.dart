import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:local_auth/local_auth.dart';
import '../../core/services/settings_service.dart';
import '../../core/services/biometric_auth_service.dart';
import '../bloc/theme_bloc.dart';
import '../bloc/theme_event.dart';
import '../bloc/theme_state.dart';
import '../design_system/design_system.dart';
import 'voice_settings_screen.dart';
import 'backup_export_screen.dart';
import 'biometric_lock_screen.dart';
import '../widgets/developer_test_links_sheet.dart';

/// Settings Screen
/// Customize app behavior, theme, notifications, and storage
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final BiometricAuthService _biometricService = BiometricAuthService();

  // Theme settings
  bool _useCustomColors = false;

  // Security settings
  bool _biometricEnabled = true;
  bool _biometricAvailable = false;
  List<BiometricType> _availableBiometrics = [];

  // Notification settings
  bool _notificationsEnabled = true;
  bool _vibrate = true;
  String _selectedNotificationSound = 'Default';
  bool _vibrationEnabled = true;
  bool _ledEnabled = true;
  bool _quietHoursEnabled = false;
  String _quietHoursStart = '22:00';
  String _quietHoursEnd = '08:00';

  // Storage settings
  String _storageUsed = '45.2 MB';
  int _mediaCount = 127;
  int _noteCount = 48;

  // SettingsService instance
  late SettingsService _settingsService;

  @override
  void initState() {
    super.initState();
    _settingsService = SettingsService();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final notificationsEnabled =
          await SettingsService.getNotificationsEnabled();
      final alarmSound = await SettingsService.getAlarmSound();
      final vibrate = await SettingsService.getVibrateEnabled();
      final vibrationEnabled = await _settingsService.getVibrationEnabled();
      final ledEnabled = await _settingsService.getLedEnabled();
      final quietHoursEnabled = await _settingsService.getQuietHoursEnabled();
      final quietHoursStart =
          await _settingsService.getQuietHoursStart() ?? '22:00';
      final quietHoursEnd =
          await _settingsService.getQuietHoursEnd() ?? '08:00';

      // Load biometric settings
      final biometricAvailable = await _biometricService.isBiometricAvailable();
      final biometricEnabled = await _biometricService.isBiometricEnabled();
      final availableBiometrics = await _biometricService
          .getAvailableBiometrics();

      setState(() {
        _notificationsEnabled = notificationsEnabled;
        _selectedNotificationSound = alarmSound;
        _vibrate = vibrate;
        _vibrationEnabled = vibrationEnabled;
        _ledEnabled = ledEnabled;
        _quietHoursEnabled = quietHoursEnabled;
        _quietHoursStart = quietHoursStart;
        _quietHoursEnd = quietHoursEnd;
        _biometricAvailable = biometricAvailable;
        _biometricEnabled = biometricEnabled;
        _availableBiometrics = availableBiometrics;
        _storageUsed = '45.2 MB';
        _mediaCount = 127;
        _noteCount = 48;
      });
    } catch (e) {
      print('Error loading settings: $e');
    }
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 8.h),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 12.sp,
          fontWeight: FontWeight.bold,
          color: AppColors.textMuted,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildAppearanceSection(bool isDark) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        return Container(
          margin: EdgeInsets.symmetric(horizontal: 16.w),
          decoration: BoxDecoration(
            color: AppColors.surface(context),
            borderRadius: BorderRadius.circular(AppSpacing.radiusXL),
            border: Border.all(
              color: isDark
                  ? AppColors.borderDark.withOpacity(0.2)
                  : AppColors.borderLight,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              _buildSettingTile(
                icon: isDark ? Icons.dark_mode : Icons.light_mode,
                title: 'Dark Mode',
                subtitle: isDark
                    ? 'Currently using dark theme'
                    : 'Currently using light theme',
                trailing: _buildSwitch(themeState.themeMode == ThemeMode.dark, (
                  value,
                ) {
                  context.read<ThemeBloc>().add(const ToggleThemeEvent());
                }),
                hasDivider: true,
              ),
              _buildSettingTile(
                icon: Icons.auto_awesome,
                title: 'Micro-animations',
                subtitle: 'Smooth transitions for focus',
                trailing: _buildSwitch(_useCustomColors, (value) {
                  setState(() => _useCustomColors = value);
                }),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPrivacySection(bool isDark) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(AppSpacing.radiusXL),
        border: Border.all(
          color: isDark
              ? AppColors.borderDark.withOpacity(0.2)
              : AppColors.borderLight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildSettingTile(
            icon: Icons.visibility_off,
            title: 'Private Reflection',
            subtitle: 'Hide sensitive note previews',
            trailing: _buildSwitch(false, (value) {}),
            hasDivider: true,
          ),
          _buildSettingTile(
            icon: _availableBiometrics.contains(BiometricType.face)
                ? Icons.face
                : Icons.fingerprint,
            title: _biometricAvailable
                ? '${_biometricService.getBiometricTypeName(_availableBiometrics)} Lock'
                : 'Biometric Lock',
            subtitle: _biometricAvailable
                ? (_biometricEnabled
                      ? 'Require ${_biometricService.getBiometricTypeName(_availableBiometrics)} to open app'
                      : 'Toggle switch to enable')
                : 'Not available on this device',
            trailing: _biometricAvailable
                ? _buildSwitch(_biometricEnabled, _handleBiometricToggle)
                : null,
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationsSection(bool isDark) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(AppSpacing.radiusXL),
        border: Border.all(
          color: isDark
              ? AppColors.borderDark.withOpacity(0.2)
              : AppColors.borderLight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Notifications Toggle
          _buildSettingTile(
            icon: Icons.notifications,
            title: 'Notifications',
            subtitle: 'Receive alerts and reminders',
            trailing: _buildSwitch(_notificationsEnabled, (value) {
              setState(() {
                _notificationsEnabled = value;
                SettingsService.setNotificationsEnabled(value);
              });
            }),
            hasDivider: true,
          ),

          // Notification Sound
          if (_notificationsEnabled)
            _buildSettingTile(
              icon: Icons.volume_up,
              title: 'Notification Sound',
              subtitle: _selectedNotificationSound,
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.chevron_right,
                    size: 18.sp,
                    color: AppColors.textMuted,
                  ),
                ],
              ),
              hasDivider: true,
              onTap: () => _showNotificationSoundPicker(),
            ),

          // Vibration
          if (_notificationsEnabled)
            _buildSettingTile(
              icon: Icons.vibration,
              title: 'Vibration',
              subtitle: 'Haptic feedback for alerts',
              trailing: _buildSwitch(_vibrationEnabled, (value) {
                setState(() {
                  _vibrationEnabled = value;
                  _settingsService.setVibrationEnabled(value);
                });
              }),
              hasDivider: true,
            ),

          // LED Notifications
          if (_notificationsEnabled)
            _buildSettingTile(
              icon: Icons.lightbulb,
              title: 'LED Notifications',
              subtitle: 'Flash LED indicator',
              trailing: _buildSwitch(_ledEnabled, (value) {
                setState(() {
                  _ledEnabled = value;
                  _settingsService.setLedEnabled(value);
                });
              }),
              hasDivider: true,
            ),

          // Quiet Hours
          if (_notificationsEnabled)
            _buildSettingTile(
              icon: Icons.schedule,
              title: 'Quiet Hours',
              subtitle: _quietHoursEnabled
                  ? '$_quietHoursStart - $_quietHoursEnd'
                  : 'Not set',
              trailing: _buildSwitch(_quietHoursEnabled, (value) {
                setState(() {
                  _quietHoursEnabled = value;
                  _settingsService.setQuietHoursEnabled(value);
                });
              }),
              hasDivider: !_quietHoursEnabled,
              onTap: _quietHoursEnabled ? () => _showQuietHoursPicker() : null,
            ),
        ],
      ),
    );
  }

  Widget _buildVoiceInputSection(bool isDark) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(AppSpacing.radiusXL),
        border: Border.all(
          color: isDark
              ? AppColors.borderDark.withOpacity(0.2)
              : AppColors.borderLight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildSettingTile(
            icon: Icons.mic,
            title: 'Dictation Language',
            subtitle: null,
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'English',
                  style: TextStyle(fontSize: 14.sp, color: AppColors.textMuted),
                ),
                SizedBox(width: 8.w),
                Icon(
                  Icons.chevron_right,
                  size: 18.sp,
                  color: AppColors.textMuted,
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
            icon: Icons.vibration,
            title: 'Haptic Feedback',
            subtitle: null,
            trailing: _buildSwitch(_vibrate, (value) async {
              setState(() => _vibrate = value);
              await SettingsService.setVibrateEnabled(value);
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildDataManagementSection(bool isDark) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.surface(context),
            AppColors.surface(context).withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(AppSpacing.radiusXL),
        border: Border.all(
          color: isDark
              ? AppColors.borderDark.withOpacity(0.2)
              : AppColors.borderLight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
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
                    '$_storageUsed storage used',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary(context),
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    '$_noteCount notes • $_mediaCount media files',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
              Icon(
                Icons.cloud_done,
                color: AppColors.successGreen,
                size: 20.sp,
              ),
            ],
          ),
          SizedBox(height: 16.h),
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
                padding: EdgeInsets.symmetric(vertical: 12.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusLG),
                ),
                elevation: 0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.backup, size: 20.sp),
                  SizedBox(width: 8.w),
                  Text(
                    'Backup & Export Wizard',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
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

  Widget _buildDeveloperSection(bool isDark) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(AppSpacing.radiusXL),
        border: Border.all(
          color: isDark
              ? AppColors.borderDark.withOpacity(0.2)
              : AppColors.borderLight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: _buildSettingTile(
        icon: Icons.terminal,
        title: 'Developer Test Links',
        subtitle: 'Quick navigation to 25+ screens',
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 16.sp,
          color: AppColors.textMuted,
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

  Widget _buildFooter(bool isDark) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 32.h),
      child: Column(
        children: [
          Text(
            'MyNotes version 4.2.0 (Build 882)',
            style: TextStyle(
              fontSize: 12.sp,
              color: AppColors.textMuted.withOpacity(0.5),
            ),
          ),
          SizedBox(height: 12.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () {},
                child: Text(
                  'Privacy Policy',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: AppColors.primary,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
              SizedBox(width: 16.w),
              GestureDetector(
                onTap: () {},
                child: Text(
                  'Terms of Service',
                  style: TextStyle(
                    fontSize: 12.sp,
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

  Widget _buildSettingTile({
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
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            child: Row(
              children: [
                Container(
                  width: 40.w,
                  height: 40.w,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusLG),
                  ),
                  child: Icon(icon, color: AppColors.primary, size: 20.sp),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary(context),
                        ),
                      ),
                      if (subtitle != null) ...[
                        SizedBox(height: 2.h),
                        Text(
                          subtitle,
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (trailing != null) ...[SizedBox(width: 12.w), trailing],
              ],
            ),
          ),
        ),
        if (hasDivider)
          Divider(
            height: 1,
            thickness: 1,
            indent: 72.w,
            color: isDark
                ? AppColors.borderDark.withOpacity(0.2)
                : AppColors.borderLight,
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

  Future<void> _handleBiometricToggle(bool value) async {
    try {
      if (value) {
        try {
          final authenticated = await _biometricService.authenticate(
            reason: 'Verify your identity to enable biometric lock',
          );

          if (authenticated) {
            await _biometricService.enableBiometric();
            setState(() => _biometricEnabled = true);
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    '${_biometricService.getBiometricTypeName(_availableBiometrics)} lock enabled successfully',
                  ),
                  backgroundColor: AppColors.successGreen,
                ),
              );
            }
          } else {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Authentication cancelled'),
                  backgroundColor: Colors.orange,
                ),
              );
            }
          }
        } on Exception catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(e.toString().replaceAll('Exception: ', '')),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 4),
              ),
            );
          }
        }
      } else {
        await _biometricService.disableBiometric();
        setState(() => _biometricEnabled = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Biometric lock disabled')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Unexpected error: ${e.toString().replaceAll('Exception: ', '')}',
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(
        backgroundColor: AppColors.background(context),
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: AppColors.textPrimary(context),
            size: 20.sp,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Settings',
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary(context),
          ),
        ),
        centerTitle: true,
        actions: [
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, color: AppColors.primary),
            onSelected: (value) => _handleSettingsMenu(value),
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
      ),
      body: ListView(
        padding: EdgeInsets.only(bottom: 40.h),
        children: [
          // Appearance Section
          _buildSectionHeader('APPEARANCE'),
          _buildAppearanceSection(isDark),

          // Privacy & Trust Section
          _buildSectionHeader('PRIVACY & TRUST'),
          _buildPrivacySection(isDark),

          // Notifications Section (NEW)
          _buildSectionHeader('NOTIFICATIONS'),
          _buildNotificationsSection(isDark),

          // Voice & Input Section
          _buildSectionHeader('VOICE & INPUT'),
          _buildVoiceInputSection(isDark),

          // Data Management Section
          _buildSectionHeader('DATA MANAGEMENT'),
          _buildDataManagementSection(isDark),

          // Developer Mode Section
          _buildSectionHeader('DEVELOPER TOOLS'),
          _buildDeveloperSection(isDark),

          // Footer
          _buildFooter(isDark),
        ],
      ),
    );
  }

  void _handleSettingsMenu(String value) {
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

  void _showNotificationSoundPicker() {
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
                groupValue: _selectedNotificationSound,
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedNotificationSound = value;
                      SettingsService.setAlarmSound(value);
                    });
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

  void _showQuietHoursPicker() {
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
              title: Text(_quietHoursStart),
              trailing: const Icon(Icons.edit),
              onTap: () => _selectQuietHourTime(true),
            ),
            const SizedBox(height: 16),
            const Text(
              'End Time:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ListTile(
              title: Text(_quietHoursEnd),
              trailing: const Icon(Icons.edit),
              onTap: () => _selectQuietHourTime(false),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              _settingsService.setQuietHoursStart(_quietHoursStart);
              _settingsService.setQuietHoursEnd(_quietHoursEnd);
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _selectQuietHourTime(bool isStart) async {
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (pickedTime != null) {
      final timeString =
          '${pickedTime.hour.toString().padLeft(2, '0')}:${pickedTime.minute.toString().padLeft(2, '0')}';
      setState(() {
        if (isStart) {
          _quietHoursStart = timeString;
        } else {
          _quietHoursEnd = timeString;
        }
      });
    }
  }
}

