import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../core/services/speech_settings_service.dart';
import '../../core/services/language_service.dart';
import '../../core/services/audio_feedback_service.dart';
import '../../core/services/voice_command_service.dart';
import '../design_system/design_system.dart';
import '../widgets/language_picker.dart';

/// Voice and Speech Settings Screen
class VoiceSettingsScreen extends StatefulWidget {
  const VoiceSettingsScreen({super.key});

  @override
  State<VoiceSettingsScreen> createState() => _VoiceSettingsScreenState();
}

class _VoiceSettingsScreenState extends State<VoiceSettingsScreen> {
  final SpeechSettingsService _settingsService = SpeechSettingsService();
  final LanguageService _languageService = LanguageService();
  final AudioFeedbackService _feedbackService = AudioFeedbackService();
  final VoiceCommandService _commandService = VoiceCommandService();

  String _currentLocale = 'en_US';
  double _minConfidence = 0.5;
  int _timeout = 30;
  bool _autoPunctuation = true;
  bool _autoCapitalize = true;
  bool _commandsEnabled = true;
  bool _hapticsEnabled = true;
  bool _soundFeedback = false;
  bool _batteryOptimization = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    setState(() => _isLoading = true);

    _currentLocale = await _languageService.getSavedLanguage();
    _minConfidence = await _settingsService.getMinConfidence();
    _timeout = await _settingsService.getTimeout();
    _autoPunctuation = await _settingsService.getAutoPunctuation();
    _autoCapitalize = await _settingsService.getAutoCapitalize();
    _commandsEnabled = await _settingsService.getCommandsEnabled();
    _hapticsEnabled = await _settingsService.getHapticsEnabled();
    _soundFeedback = await _settingsService.getSoundFeedback();
    _batteryOptimization = await _settingsService.getBatteryOptimization();

    _feedbackService.setHapticsEnabled(_hapticsEnabled);
    _feedbackService.setSoundEnabled(_soundFeedback);

    setState(() => _isLoading = false);
  }

  Future<void> _changeLanguage() async {
    await _feedbackService.lightHaptic();

    final selectedLocale = await LanguagePicker.show(
      context,
      currentLocale: _currentLocale,
    );

    if (selectedLocale != null && selectedLocale != _currentLocale) {
      setState(() => _currentLocale = selectedLocale);
      await _languageService.saveLanguage(selectedLocale);
      await _feedbackService.successHaptic();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Language changed to ${_languageService.getLanguageName(selectedLocale)}',
            ),
            backgroundColor: AppColors.successColor,
          ),
        );
      }
    }
  }

  Future<void> _showVoiceCommandsHelp() async {
    await _feedbackService.lightHaptic();

    final commands = _commandService.getCommandDescriptions();

    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;

        return Container(
          height: MediaQuery.of(context).size.height * 0.7,
          decoration: BoxDecoration(
            color: AppColors.surface(context),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20.r),
              topRight: Radius.circular(20.r),
            ),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: EdgeInsets.only(top: 12.h),
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),

              // Header
              Padding(
                padding: EdgeInsets.all(20.w),
                child: Row(
                  children: [
                    Icon(
                      Icons.keyboard_voice,
                      color: AppColors.primaryColor,
                      size: 24.sp,
                    ),
                    SizedBox(width: 12.w),
                    Text(
                      'Voice Commands',
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),

              // Commands list
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  itemCount: commands.length,
                  itemBuilder: (context, index) {
                    final entry = commands.entries.elementAt(index);
                    return Card(
                      margin: EdgeInsets.only(bottom: 12.h),
                      color: isDark
                          ? Colors.grey.shade800
                          : Colors.grey.shade50,
                      child: Padding(
                        padding: EdgeInsets.all(16.w),
                        child: Text(
                          entry.value,
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: isDark ? Colors.white70 : Colors.black87,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _resetSettings() async {
    await _feedbackService.lightHaptic();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Settings'),
        content: const Text(
          'Are you sure you want to reset all voice settings to defaults?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Reset'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _settingsService.resetToDefaults();
      await _feedbackService.successHaptic();
      await _loadSettings();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Settings reset to defaults'),
            backgroundColor: AppColors.successColor,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_isLoading) {
      return Scaffold(
        backgroundColor: isDark ? AppColors.darkBackground : Colors.white,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60.h),
        child: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: AppBar(
              backgroundColor: AppColors.background(context).withOpacity(0.8),
              elevation: 0,
              leading: IconButton(
                icon: Icon(Icons.arrow_back_ios_new, size: 20.sp),
                onPressed: () => Navigator.pop(context),
              ),
              centerTitle: true,
              title: Text(
                'Voice Settings',
                style: AppTypography.bodyLarge(null, null, FontWeight.w600),
              ),
              actions: [
                IconButton(
                  icon: Icon(Icons.restore, size: 22.sp),
                  tooltip: 'Reset to Defaults',
                  onPressed: _resetSettings,
                ),
                SizedBox(width: 4.w),
              ],
            ),
          ),
        ),
      ),
      body: ListView(
        padding: EdgeInsets.all(20.w),
        children: [
          // Language Section
          _buildSectionHeader('Language & Region', Icons.language),
          _buildLanguageTile(isDark),

          SizedBox(height: 24.h),

          // Recognition Settings
          _buildSectionHeader('Recognition Settings', Icons.tune),
          _buildConfidenceSlider(isDark),
          _buildTimeoutSlider(isDark),

          SizedBox(height: 24.h),

          // Smart Features
          _buildSectionHeader('Smart Features', Icons.auto_awesome),
          _buildSwitchTile(
            'Auto-Punctuation',
            'Automatically add punctuation marks',
            _autoPunctuation,
            (value) async {
              setState(() => _autoPunctuation = value);
              await _settingsService.setAutoPunctuation(value);
              await _feedbackService.lightHaptic();
            },
            isDark,
          ),
          _buildSwitchTile(
            'Auto-Capitalize',
            'Capitalize first letter of sentences',
            _autoCapitalize,
            (value) async {
              setState(() => _autoCapitalize = value);
              await _settingsService.setAutoCapitalize(value);
              await _feedbackService.lightHaptic();
            },
            isDark,
          ),

          SizedBox(height: 24.h),

          // Voice Commands
          _buildSectionHeader('Voice Commands', Icons.keyboard_voice),
          _buildSwitchTile(
            'Enable Voice Commands',
            'Recognize formatting and navigation commands',
            _commandsEnabled,
            (value) async {
              setState(() => _commandsEnabled = value);
              await _settingsService.setCommandsEnabled(value);
              await _feedbackService.lightHaptic();
            },
            isDark,
          ),
          _buildCommandsHelpTile(isDark),

          SizedBox(height: 24.h),

          // Feedback
          _buildSectionHeader('Feedback', Icons.vibration),
          _buildSwitchTile(
            'Haptic Feedback',
            'Vibrate on actions and recognition',
            _hapticsEnabled,
            (value) async {
              setState(() => _hapticsEnabled = value);
              await _settingsService.setHapticsEnabled(value);
              _feedbackService.setHapticsEnabled(value);
              await _feedbackService.lightHaptic();
            },
            isDark,
          ),
          _buildSwitchTile(
            'Sound Feedback',
            'Play sounds for start/stop recording',
            _soundFeedback,
            (value) async {
              setState(() => _soundFeedback = value);
              await _settingsService.setSoundFeedback(value);
              _feedbackService.setSoundEnabled(value);
              await _feedbackService.lightHaptic();
            },
            isDark,
          ),

          SizedBox(height: 24.h),

          // Performance
          _buildSectionHeader('Performance', Icons.battery_charging_full),
          _buildSwitchTile(
            'Battery Optimization',
            'Reduce recognition quality to save battery',
            _batteryOptimization,
            (value) async {
              setState(() => _batteryOptimization = value);
              await _settingsService.setBatteryOptimization(value);
              await _feedbackService.lightHaptic();
            },
            isDark,
          ),

          SizedBox(height: 40.h),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primaryColor, size: 20.sp),
          SizedBox(width: 8.w),
          Text(
            title,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageTile(bool isDark) {
    return Card(
      color: AppColors.surface(context),
      elevation: 1,
      child: ListTile(
        leading: const Icon(Icons.language, color: AppColors.primaryColor),
        title: const Text('Speech Language'),
        subtitle: Text(_languageService.getLanguageName(_currentLocale)),
        trailing: const Icon(Icons.chevron_right),
        onTap: _changeLanguage,
      ),
    );
  }

  Widget _buildConfidenceSlider(bool isDark) {
    return Card(
      color: AppColors.surface(context),
      elevation: 1,
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Confidence Threshold',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                Text(
                  '${(_minConfidence * 100).toInt()}%',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: AppColors.primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            Slider(
              value: _minConfidence,
              min: 0.0,
              max: 1.0,
              divisions: 10,
              activeColor: AppColors.primaryColor,
              onChanged: (value) async {
                setState(() => _minConfidence = value);
                await _settingsService.setMinConfidence(value);
                await _feedbackService.selectionHaptic();
              },
            ),
            Text(
              'Higher values = more accurate but may miss words',
              style: TextStyle(fontSize: 11.sp, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeoutSlider(bool isDark) {
    return Card(
      color: AppColors.surface(context),
      elevation: 1,
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recording Timeout',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                Text(
                  '$_timeout seconds',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: AppColors.primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            Slider(
              value: _timeout.toDouble(),
              min: 5,
              max: 120,
              divisions: 23,
              activeColor: AppColors.primaryColor,
              onChanged: (value) async {
                setState(() => _timeout = value.toInt());
                await _settingsService.setTimeout(value.toInt());
                await _feedbackService.selectionHaptic();
              },
            ),
            Text(
              'Maximum duration for voice input',
              style: TextStyle(fontSize: 11.sp, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchTile(
    String title,
    String subtitle,
    bool value,
    Function(bool) onChanged,
    bool isDark,
  ) {
    return Card(
      color: AppColors.surface(context),
      elevation: 1,
      margin: EdgeInsets.only(bottom: 8.h),
      child: SwitchListTile(
        title: Text(
          title,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(fontSize: 12.sp, color: Colors.grey),
        ),
        value: value,
        activeColor: AppColors.primaryColor,
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildCommandsHelpTile(bool isDark) {
    return Card(
      color: AppColors.surface(context),
      elevation: 1,
      child: ListTile(
        leading: const Icon(Icons.help_outline, color: AppColors.primaryColor),
        title: const Text('View Available Commands'),
        subtitle: const Text('See all voice commands you can use'),
        trailing: const Icon(Icons.chevron_right),
        onTap: _showVoiceCommandsHelp,
      ),
    );
  }
}

