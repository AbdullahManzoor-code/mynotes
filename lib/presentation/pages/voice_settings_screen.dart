import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../core/services/language_service.dart';
import '../../core/services/voice_command_service.dart';
import '../../core/services/audio_feedback_service.dart';
import '../design_system/design_system.dart';
import '../widgets/language_picker.dart';
import '../bloc/voice_settings_bloc.dart';
import '../bloc/params/voice_settings_params.dart';

/// Voice and Speech Settings Screen
/// Refactored to StatelessWidget using VoiceSettingsBloc and Design System
class VoiceSettingsScreen extends StatelessWidget {
  const VoiceSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => VoiceSettingsBloc()..add(LoadVoiceSettingsEvent()),
      child: const _VoiceSettingsView(),
    );
  }
}

class _VoiceSettingsView extends StatelessWidget {
  const _VoiceSettingsView();

  Future<void> _changeLanguage(
    BuildContext context,
    String currentLocale,
  ) async {
    final feedbackService = AudioFeedbackService();
    await feedbackService.lightHaptic();

    final selectedLocale = await LanguagePicker.show(
      context,
      currentLocale: currentLocale,
    );

    if (selectedLocale != null && selectedLocale != currentLocale) {
      if (context.mounted) {
        context.read<VoiceSettingsBloc>().add(
          UpdateLocaleEvent(selectedLocale),
        );
        await feedbackService.successHaptic();

        final languageService = LanguageService();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Language changed to ${languageService.getLanguageName(selectedLocale)}',
            ),
            backgroundColor: AppColors.successColor,
          ),
        );
      }
    }
  }

  Future<void> _showVoiceCommandsHelp(BuildContext context) async {
    final feedbackService = AudioFeedbackService();
    await feedbackService.lightHaptic();

    final commandService = VoiceCommandService();
    final commands = commandService.getCommandDescriptions();

    if (!context.mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.7,
          decoration: BoxDecoration(
            color: AppColors.surface(context),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24.r),
              topRight: Radius.circular(24.r),
            ),
          ),
          child: Column(
            children: [
              AppSpacing.gapM,
              Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: AppColors.borderLight,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
              Padding(
                padding: AppSpacing.paddingAllL,
                child: Row(
                  children: [
                    Icon(
                      Icons.keyboard_voice_rounded,
                      color: AppColors.primaryColor,
                      size: 24.sp,
                    ),
                    AppSpacing.gapM,
                    Text(
                      'Voice Commands',
                      style: AppTypography.displaySmall(context),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  itemCount: commands.length,
                  itemBuilder: (context, index) {
                    final entry = commands.entries.elementAt(index);
                    return Container(
                      margin: EdgeInsets.only(bottom: 12.h),
                      padding: AppSpacing.paddingAllM,
                      decoration: BoxDecoration(
                        color: AppColors.lightSurface,
                        borderRadius: BorderRadius.circular(16.r),
                        border: Border.all(color: AppColors.borderLight),
                      ),
                      child: Text(
                        entry.value,
                        style: AppTypography.bodySmall(
                          context,
                          AppColors.secondaryText,
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

  Future<void> _resetSettings(BuildContext context) async {
    final feedbackService = AudioFeedbackService();
    await feedbackService.lightHaptic();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Reset Settings',
          style: AppTypography.displaySmall(context),
        ),
        content: Text(
          'Are you sure you want to reset all voice settings to defaults?',
          style: AppTypography.bodyMedium(context),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancel',
              style: AppTypography.button(context, AppColors.secondaryText),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'Reset',
              style: AppTypography.button(context, AppColors.errorColor),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      context.read<VoiceSettingsBloc>().add(ResetVoiceSettingsEvent());
      await feedbackService.successHaptic();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Settings reset to defaults'),
          backgroundColor: AppColors.successColor,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<VoiceSettingsBloc, VoiceSettingsState>(
      builder: (context, state) {
        if (state.params.isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final params = state.params;

        return Scaffold(
          backgroundColor: AppColors.background(context),
          appBar: _buildAppBar(context),
          body: ListView(
            padding: AppSpacing.paddingAllL,
            children: [
              _buildSectionHeader(
                context,
                'Language & Region',
                Icons.language_rounded,
              ),
              _buildLanguageTile(context, params.currentLocale),

              AppSpacing.gapXXXL,

              _buildSectionHeader(
                context,
                'Recognition Settings',
                Icons.tune_rounded,
              ),
              _buildSliderCard(
                context,
                'Confidence Threshold',
                'Min level to accept recognition',
                params.minConfidence,
                0.0,
                1.0,
                (val) => context.read<VoiceSettingsBloc>().add(
                  UpdateConfidenceEvent(val),
                ),
                '${(params.minConfidence * 100).toInt()}%',
                'Higher values = more accurate but may miss words',
              ),
              _buildSliderCard(
                context,
                'Recording Timeout',
                'Maximum duration for voice input',
                params.timeout.toDouble(),
                5.0,
                120.0,
                (val) => context.read<VoiceSettingsBloc>().add(
                  UpdateTimeoutEvent(val.toInt()),
                ),
                '${params.timeout}s',
                'Maximum duration for voice input',
              ),

              AppSpacing.gapXXXL,

              _buildSectionHeader(
                context,
                'Smart Features',
                Icons.auto_awesome_rounded,
              ),
              _buildSwitchTile(
                context,
                'Auto-Punctuation',
                'Automatically add punctuation marks',
                params.autoPunctuation,
                (value) => context.read<VoiceSettingsBloc>().add(
                  ToggleAutoPunctuationEvent(value),
                ),
              ),
              _buildSwitchTile(
                context,
                'Auto-Capitalize',
                'Capitalize first letter of sentences',
                params.autoCapitalize,
                (value) => context.read<VoiceSettingsBloc>().add(
                  ToggleAutoCapitalizeEvent(value),
                ),
              ),

              AppSpacing.gapXXXL,

              _buildSectionHeader(
                context,
                'Voice Commands',
                Icons.keyboard_voice_rounded,
              ),
              _buildSwitchTile(
                context,
                'Enable Voice Commands',
                'Recognize formatting and navigation commands',
                params.commandsEnabled,
                (value) => context.read<VoiceSettingsBloc>().add(
                  ToggleCommandsEvent(value),
                ),
              ),
              _buildActionTile(
                context,
                'View Available Commands',
                'See all voice commands you can use',
                Icons.help_outline_rounded,
                () => _showVoiceCommandsHelp(context),
              ),

              AppSpacing.gapXXXL,

              _buildSectionHeader(context, 'Feedback', Icons.vibration_rounded),
              _buildSwitchTile(
                context,
                'Haptic Feedback',
                'Vibrate on actions and recognition',
                params.hapticsEnabled,
                (value) => context.read<VoiceSettingsBloc>().add(
                  ToggleHapticsEvent(value),
                ),
              ),
              _buildSwitchTile(
                context,
                'Sound Feedback',
                'Play sounds for start/stop recording',
                params.soundFeedback,
                (value) => context.read<VoiceSettingsBloc>().add(
                  ToggleSoundFeedbackEvent(value),
                ),
              ),

              AppSpacing.gapXXXL,

              _buildSectionHeader(
                context,
                'Performance',
                Icons.battery_charging_full_rounded,
              ),
              _buildSwitchTile(
                context,
                'Battery Optimization',
                'Reduce recognition quality to save battery',
                params.batteryOptimization,
                (value) => context.read<VoiceSettingsBloc>().add(
                  ToggleBatteryOptimizationEvent(value),
                ),
              ),

              AppSpacing.gapXXXL,
            ],
          ),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios_new_rounded, size: 20.sp),
        onPressed: () => Navigator.pop(context),
      ),
      centerTitle: true,
      title: Text('Voice Settings', style: AppTypography.displaySmall(context)),
      actions: [
        IconButton(
          icon: Icon(Icons.restore_rounded, size: 22.sp),
          tooltip: 'Reset to Defaults',
          onPressed: () => _resetSettings(context),
        ),
        SizedBox(width: 8.w),
      ],
      flexibleSpace: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            color: AppColors.background(context).withOpacity(0.8),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context,
    String title,
    IconData icon,
  ) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: Row(
        children: [
          Icon(icon, size: 18.sp, color: AppColors.primaryColor),
          AppSpacing.gapM,
          Text(
            title.toUpperCase(),
            style: AppTypography.labelSmall(
              context,
              AppColors.secondaryText,
              FontWeight.bold,
            ).copyWith(letterSpacing: 1.2),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageTile(BuildContext context, String currentLocale) {
    final languageService = LanguageService();
    return Container(
      decoration: BoxDecoration(
        color: AppColors.lightSurface,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
        leading: Container(
          padding: EdgeInsets.all(10.r),
          decoration: BoxDecoration(
            color: AppColors.primary10,
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Icon(
            Icons.translate_rounded,
            color: AppColors.primaryColor,
            size: 22.sp,
          ),
        ),
        title: Text(
          'Speech Language',
          style: AppTypography.bodyMedium(context, null, FontWeight.w600),
        ),
        subtitle: Text(
          languageService.getLanguageName(currentLocale),
          style: AppTypography.bodySmall(context, AppColors.secondaryText),
        ),
        trailing: Icon(
          Icons.chevron_right_rounded,
          color: AppColors.secondaryText,
        ),
        onTap: () => _changeLanguage(context, currentLocale),
      ),
    );
  }

  Widget _buildActionTile(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
  ) {
    return Container(
      margin: EdgeInsets.only(top: 8.h),
      decoration: BoxDecoration(
        color: AppColors.lightSurface,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
        leading: Container(
          padding: EdgeInsets.all(10.r),
          decoration: BoxDecoration(
            color: AppColors.primary10,
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Icon(icon, color: AppColors.primaryColor, size: 22.sp),
        ),
        title: Text(
          title,
          style: AppTypography.bodyMedium(context, null, FontWeight.w600),
        ),
        subtitle: Text(
          subtitle,
          style: AppTypography.bodySmall(context, AppColors.secondaryText),
        ),
        trailing: Icon(
          Icons.chevron_right_rounded,
          color: AppColors.secondaryText,
        ),
        onTap: onTap,
      ),
    );
  }

  Widget _buildSliderCard(
    BuildContext context,
    String title,
    String subtitle,
    double value,
    double min,
    double max,
    ValueChanged<double> onChanged,
    String displayValue,
    String footer,
  ) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: AppSpacing.paddingAllL,
      decoration: BoxDecoration(
        color: AppColors.lightSurface,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTypography.bodyMedium(
                        context,
                        null,
                        FontWeight.w600,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: AppTypography.bodySmall(
                        context,
                        AppColors.secondaryText,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: AppColors.primary10,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  displayValue,
                  style: AppTypography.labelSmall(
                    context,
                    AppColors.primaryColor,
                    FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          AppSpacing.gapL,
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: AppColors.primaryColor,
              inactiveTrackColor: AppColors.primary10,
              thumbColor: AppColors.primaryColor,
              overlayColor: AppColors.primaryColor.withOpacity(0.1),
              trackHeight: 4.h,
            ),
            child: Slider(
              value: value,
              min: min,
              max: max,
              onChanged: onChanged,
            ),
          ),
          Text(
            footer,
            style: AppTypography.labelSmall(context, AppColors.secondaryText),
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchTile(
    BuildContext context,
    String title,
    String subtitle,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: AppColors.lightSurface,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 4.h),
        title: Text(
          title,
          style: AppTypography.bodyMedium(context, null, FontWeight.w600),
        ),
        subtitle: Text(
          subtitle,
          style: AppTypography.bodySmall(context, AppColors.secondaryText),
        ),
        trailing: Switch.adaptive(
          value: value,
          onChanged: onChanged,
          activeColor: AppColors.primaryColor,
        ),
      ),
    );
  }
}
