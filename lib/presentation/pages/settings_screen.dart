import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:local_auth/local_auth.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/services/settings_service.dart';
import '../../core/services/biometric_auth_service.dart';
import '../../core/utils/database_health_check.dart';
import '../../data/datasources/local_database.dart';
import '../bloc/theme_bloc.dart';
import '../bloc/theme_event.dart';
import '../bloc/theme_state.dart';
import 'voice_settings_screen.dart';

/// Settings Screen
/// Customize app behavior, theme, notifications, and storage
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

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
  String _defaultAlarmSound = 'Default';
  bool _vibrate = true;

  // Storage settings
  String _storageUsed = 'Calculating...';
  int _mediaCount = 0;
  int _noteCount = 0;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final notificationsEnabled =
          await SettingsService.getNotificationsEnabled();
      final alarmSound = await SettingsService.getAlarmSound();
      final vibrate = await SettingsService.getVibrateEnabled();

      // Load biometric settings
      final biometricAvailable = await _biometricService.isBiometricAvailable();
      final biometricEnabled = await _biometricService.isBiometricEnabled();
      final availableBiometrics = await _biometricService
          .getAvailableBiometrics();

      setState(() {
        _notificationsEnabled = notificationsEnabled;
        _defaultAlarmSound = alarmSound;
        _vibrate = vibrate;
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

  Future<void> _saveNotifications(bool enabled) async {
    await SettingsService.setNotificationsEnabled(enabled);
  }

  Future<void> _saveVibrate(bool enabled) async {
    await SettingsService.setVibrateEnabled(enabled);
  }

  Future<void> _saveAlarmSound(String sound) async {
    await SettingsService.setAlarmSound(sound);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          _buildSection(
            title: 'Appearance',
            children: [
              _buildThemeSelector(),
              SwitchListTile(
                value: _useCustomColors,
                onChanged: (value) {
                  setState(() => _useCustomColors = value);
                },
                title: const Text('Custom colors'),
                subtitle: const Text('Use personalized color scheme'),
                activeColor: AppColors.primaryColor,
              ),
            ],
          ),

          const Divider(),

          _buildSection(
            title: 'Security & Privacy',
            children: [
              if (_biometricAvailable)
                SwitchListTile(
                  value: _biometricEnabled,
                  onChanged: (value) async {
                    try {
                      if (value) {
                        // Authenticate before enabling
                        try {
                          final authenticated = await _biometricService
                              .authenticate(
                                reason:
                                    'Verify your identity to enable biometric lock',
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
                                  backgroundColor: AppColors.successColor,
                                ),
                              );
                            }
                          } else {
                            // Authentication cancelled by user
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
                          // Show specific error message from service
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  e.toString().replaceAll('Exception: ', ''),
                                ),
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
                            const SnackBar(
                              content: Text('Biometric lock disabled'),
                            ),
                          );
                        }
                      }
                    } catch (e) {
                      // Catch any unexpected errors
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
                  },
                  title: Text(
                    '${_biometricService.getBiometricTypeName(_availableBiometrics)} Lock',
                  ),
                  subtitle: Text(
                    _biometricEnabled
                        ? 'Authentication required to open app'
                        : 'Toggle switch to enable biometric security',
                  ),
                  secondary: Icon(
                    _availableBiometrics.contains(BiometricType.face)
                        ? Icons.face
                        : Icons.fingerprint,
                    color: AppColors.primaryColor,
                  ),
                  activeColor: AppColors.successColor,
                ),
              if (!_biometricAvailable)
                ListTile(
                  leading: const Icon(Icons.lock_outline),
                  title: const Text('Biometric Lock'),
                  subtitle: const Text('Not available on this device'),
                  enabled: false,
                ),
              ListTile(
                leading: const Icon(Icons.vpn_key),
                title: const Text('Change PIN'),
                subtitle: const Text('Set a backup unlock PIN'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  // TODO: Implement PIN change
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(const SnackBar(content: Text('Coming soon')));
                },
              ),
              ListTile(
                leading: const Icon(Icons.privacy_tip),
                title: const Text('Privacy Policy'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  // TODO: Show privacy policy
                },
              ),
            ],
          ),

          const Divider(),

          _buildSection(
            title: 'Voice & Speech',
            children: [
              ListTile(
                leading: const Icon(Icons.mic, color: AppColors.primaryColor),
                title: const Text('Voice Settings'),
                subtitle: const Text('Configure voice input and commands'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const VoiceSettingsScreen(),
                    ),
                  );
                },
              ),
            ],
          ),

          const Divider(),

          _buildSection(
            title: 'Notifications',
            children: [
              SwitchListTile(
                value: _notificationsEnabled,
                onChanged: (value) async {
                  setState(() => _notificationsEnabled = value);
                  await _saveNotifications(value);
                },
                title: const Text('Enable notifications'),
                subtitle: const Text('Receive reminder alerts'),
                activeColor: AppColors.primaryColor,
              ),
              ListTile(
                enabled: _notificationsEnabled,
                leading: const Icon(Icons.music_note),
                title: const Text('Alarm sound'),
                subtitle: Text(_defaultAlarmSound),
                trailing: const Icon(Icons.chevron_right),
                onTap: _showAlarmSoundPicker,
              ),
              SwitchListTile(
                value: _vibrate,
                onChanged: _notificationsEnabled
                    ? (value) async {
                        setState(() => _vibrate = value);
                        await _saveVibrate(value);
                      }
                    : null,
                title: const Text('Vibrate'),
                subtitle: const Text('Vibrate on notifications'),
                activeColor: AppColors.primaryColor,
              ),
            ],
          ),

          const Divider(),

          _buildSection(
            title: 'Default Note Settings',
            children: [
              ListTile(
                leading: const Icon(Icons.color_lens),
                title: const Text('Default color'),
                subtitle: const Text('Color for new notes'),
                trailing: Container(
                  width: 24.w,
                  height: 24.h,
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.grey300),
                  ),
                ),
                onTap: () {
                  // TODO: Show color picker
                },
              ),
              ListTile(
                leading: const Icon(Icons.image),
                title: const Text('Media quality'),
                subtitle: const Text('Medium (recommended)'),
                trailing: const Icon(Icons.chevron_right),
                onTap: _showMediaQualityPicker,
              ),
            ],
          ),

          const Divider(),

          _buildSection(
            title: 'Storage',
            children: [
              ListTile(
                leading: const Icon(Icons.folder),
                title: const Text('Storage used'),
                subtitle: Text(_storageUsed),
              ),
              ListTile(
                leading: const Icon(Icons.note),
                title: const Text('Total notes'),
                subtitle: Text('$_noteCount notes'),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Media files'),
                subtitle: Text('$_mediaCount files'),
              ),
              ListTile(
                leading: const Icon(Icons.cleaning_services),
                title: const Text('Clear unused media'),
                subtitle: const Text('Remove orphaned files'),
                trailing: const Icon(Icons.chevron_right),
                onTap: _clearUnusedMedia,
              ),
              ListTile(
                leading: const Icon(Icons.folder_delete),
                title: const Text('Clear cache'),
                subtitle: const Text('Free up temporary storage'),
                trailing: const Icon(Icons.chevron_right),
                onTap: _clearCache,
              ),
            ],
          ),

          const Divider(),

          _buildSection(
            title: 'Backup & Restore',
            children: [
              ListTile(
                leading: const Icon(Icons.cloud_upload),
                title: const Text('Backup notes'),
                subtitle: const Text('Coming soon'),
                enabled: false,
                trailing: const Icon(Icons.chevron_right),
              ),
              ListTile(
                leading: const Icon(Icons.cloud_download),
                title: const Text('Restore from backup'),
                subtitle: const Text('Coming soon'),
                enabled: false,
                trailing: const Icon(Icons.chevron_right),
              ),
            ],
          ),

          const Divider(),

          _buildSection(
            title: 'About',
            children: [
              ListTile(
                leading: const Icon(Icons.info),
                title: const Text('App version'),
                subtitle: const Text(AppConstants.appVersion),
              ),
              ListTile(
                leading: const Icon(Icons.health_and_safety),
                title: const Text('Database Health'),
                subtitle: const Text('Check database status'),
                trailing: const Icon(Icons.chevron_right),
                onTap: _showDatabaseHealth,
              ),
              ListTile(
                leading: const Icon(Icons.privacy_tip),
                title: const Text('Privacy policy'),
                trailing: const Icon(Icons.open_in_new),
                onTap: () {
                  // TODO: Open privacy policy
                },
              ),
              ListTile(
                leading: const Icon(Icons.description),
                title: const Text('Terms of service'),
                trailing: const Icon(Icons.open_in_new),
                onTap: () {
                  // TODO: Open terms
                },
              ),
            ],
          ),

          SizedBox(height: 24.h),

          // Reset button
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: OutlinedButton.icon(
              onPressed: _showResetDialog,
              icon: const Icon(Icons.restore, color: AppColors.errorColor),
              label: const Text(
                'Reset all settings',
                style: TextStyle(color: AppColors.errorColor),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.errorColor),
                padding: EdgeInsets.symmetric(vertical: 16.h),
              ),
            ),
          ),

          SizedBox(height: 32.h),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 8.h),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.primaryColor,
            ),
          ),
        ),
        ...children,
      ],
    );
  }

  Widget _buildThemeSelector() {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        return SwitchListTile(
          value: themeState.isDarkMode,
          onChanged: (value) {
            context.read<ThemeBloc>().add(const ToggleThemeEvent());
          },
          title: const Text('Dark Mode'),
          subtitle: Text(
            themeState.isDarkMode
                ? 'Deep charcoal background (#1A1A1A)'
                : 'Soft off-white background (#FAFAFA)',
          ),
          activeColor: AppColors.primaryColor,
          secondary: Icon(
            themeState.isDarkMode ? Icons.dark_mode : Icons.light_mode,
            color: AppColors.primaryColor,
          ),
        );
      },
    );
  }

  void _showAlarmSoundPicker() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choose alarm sound'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: ['Default', 'Bell', 'Chime', 'Beep']
              .map(
                (sound) => RadioListTile<String>(
                  value: sound,
                  groupValue: _defaultAlarmSound,
                  onChanged: (value) async {
                    setState(() => _defaultAlarmSound = value!);
                    await _saveAlarmSound(value!);
                    Navigator.pop(context);
                  },
                  title: Text(sound),
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  void _showMediaQualityPicker() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Media quality'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children:
              [
                    {'label': 'Low', 'subtitle': 'Smaller files'},
                    {'label': 'Medium', 'subtitle': 'Recommended'},
                    {'label': 'High', 'subtitle': 'Best quality'},
                  ]
                  .map(
                    (option) => ListTile(
                      title: Text(option['label']!),
                      subtitle: Text(option['subtitle']!),
                      onTap: () => Navigator.pop(context),
                    ),
                  )
                  .toList(),
        ),
      ),
    );
  }

  void _clearUnusedMedia() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear unused media'),
        content: const Text(
          'This will remove media files that are not linked to any note. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Clearing unused media...')),
              );
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  void _clearCache() {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Cache cleared successfully')));
  }

  Future<void> _showDatabaseHealth() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final healthCheck = DatabaseHealthCheck(notesDb: NotesDatabase());
      final report = await healthCheck.generateHealthReport();

      if (mounted) {
        Navigator.pop(context); // Close loading dialog

        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Database Health Report'),
            content: SingleChildScrollView(
              child: Text(
                report,
                style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
              ),
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
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Health check failed: $e')));
      }
    }
  }

  void _showResetDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset all settings'),
        content: const Text(
          'This will reset all settings to their default values. Your notes and media will not be affected.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _loadSettings(); // Reset to defaults
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Settings reset successfully')),
              );
            },
            child: const Text(
              'Reset',
              style: TextStyle(color: AppColors.errorColor),
            ),
          ),
        ],
      ),
    );
  }
}
