import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../design_system/design_system.dart';
import '../../core/services/theme_customization_service.dart';
import '../bloc/settings/settings_bloc.dart';
import '../bloc/params/settings_params.dart';
import '../../injection_container.dart' show getIt;

/// Font Settings Screen
/// Refactored to StatelessWidget using SettingsBloc and Design System
class FontSettingsScreen extends StatelessWidget {
  const FontSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: BlocProvider.of<SettingsBloc>(context),
      child: const _FontSettingsView(),
    );
  }
}

class _FontSettingsView extends StatelessWidget {
  const _FontSettingsView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_rounded,
            color: AppColors.darkText,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Font Settings',
          style: AppTypography.displayMedium(context),
        ),
        actions: [
          BlocBuilder<SettingsBloc, SettingsState>(
            builder: (context, state) {
              if (state is SettingsLoaded) {
                return TextButton(
                  onPressed: () => _resetToDefaults(context, state.params),
                  child: Text(
                    'Reset',
                    style: AppTypography.button(
                      context,
                      AppColors.primaryColor,
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: BlocBuilder<SettingsBloc, SettingsState>(
        builder: (context, state) {
          if (state is SettingsInitial || state is SettingsLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is SettingsLoaded) {
            final params = state.params;
            final selectedFont = AppFontFamily.values.firstWhere(
              (f) => f.displayName == params.fontFamily,
              orElse: () => AppFontFamily.system,
            );
            final selectedScale = params.fontScale;

            return SingleChildScrollView(
              padding: AppSpacing.paddingAllL,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Font Family Section
                  _buildSectionHeader(context, 'Font Family'),
                  _buildFontFamilyList(context, params, selectedFont),

                  AppSpacing.gapXXXL,

                  // Font Size Section
                  _buildSectionHeader(context, 'Font Size'),
                  _buildFontSizeList(
                    context,
                    params,
                    selectedFont,
                    selectedScale,
                  ),

                  AppSpacing.gapXXXL,

                  // Preview Section
                  _buildSectionHeader(context, 'Preview'),
                  _buildPreviewSection(context, selectedFont, selectedScale),
                ],
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: Text(
        title,
        style: AppTypography.labelSmall(
          context,
          AppColors.secondaryText,
          FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildFontFamilyList(
    BuildContext context,
    SettingsParams params,
    AppFontFamily selectedFont,
  ) {
    return Column(
      children: AppFontFamily.values.map((font) {
        return _buildFontFamilyOption(context, params, font, selectedFont);
      }).toList(),
    );
  }

  Widget _buildFontFamilyOption(
    BuildContext context,
    SettingsParams params,
    AppFontFamily font,
    AppFontFamily selectedFont,
  ) {
    final isSelected = font == selectedFont;

    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.primary10 : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: isSelected ? AppColors.primaryColor : AppColors.borderLight,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: ListTile(
        title: Text(
          font.displayName,
          style: font.getTextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w500,
            color: AppColors.darkText,
          ),
        ),
        subtitle: Text(
          'The quick brown fox jumps over the lazy dog',
          style: font.getTextStyle(
            fontSize: 14.sp,
            color: AppColors.secondaryText,
          ),
        ),
        trailing: isSelected
            ? Icon(Icons.check_circle_rounded, color: AppColors.primaryColor)
            : null,
        onTap: () => _updateFont(context, params, font),
      ),
    );
  }

  Widget _buildFontSizeList(
    BuildContext context,
    SettingsParams params,
    AppFontFamily selectedFont,
    double selectedScale,
  ) {
    return Column(
      children: FontSizeScale.values.map((scale) {
        return _buildFontSizeOption(
          context,
          params,
          scale,
          selectedFont,
          selectedScale,
        );
      }).toList(),
    );
  }

  Widget _buildFontSizeOption(
    BuildContext context,
    SettingsParams params,
    FontSizeScale scale,
    AppFontFamily selectedFont,
    double selectedScale,
  ) {
    final isSelected = (scale.scale - selectedScale).abs() < 0.01;

    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.primary10 : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: isSelected ? AppColors.primaryColor : AppColors.borderLight,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: ListTile(
        title: Text(
          scale.displayName,
          style: selectedFont.getTextStyle(
            fontSize: 16.sp * scale.scale,
            fontWeight: FontWeight.w500,
            color: AppColors.darkText,
          ),
        ),
        subtitle: Text(
          '${(scale.scale * 100).toInt()}% of normal size',
          style: selectedFont.getTextStyle(
            fontSize: 14.sp,
            color: AppColors.secondaryText,
          ),
        ),
        trailing: isSelected
            ? Icon(Icons.check_circle_rounded, color: AppColors.primaryColor)
            : null,
        onTap: () => _updateScale(context, params, scale),
      ),
    );
  }

  Widget _buildPreviewSection(
    BuildContext context,
    AppFontFamily selectedFont,
    double selectedScale,
  ) {
    return Container(
      padding: AppSpacing.paddingAllL,
      decoration: BoxDecoration(
        color: AppColors.lightSurface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Preview Text',
            style: selectedFont.getTextStyle(
              fontSize: 24.sp * selectedScale,
              fontWeight: FontWeight.bold,
              color: AppColors.darkText,
            ),
          ),
          AppSpacing.gapM,
          Text(
            'This is how your text will look with the current font settings. The quick brown fox jumps over the lazy dog.',
            style: selectedFont.getTextStyle(
              fontSize: 16.sp * selectedScale,
              color: AppColors.darkText,
              height: 1.5,
            ),
          ),
          AppSpacing.gapS,
          Text(
            'Small text example for readability testing.',
            style: selectedFont.getTextStyle(
              fontSize: 14.sp * selectedScale,
              color: AppColors.secondaryText,
            ),
          ),
        ],
      ),
    );
  }

  void _updateFont(
    BuildContext context,
    SettingsParams params,
    AppFontFamily font,
  ) {
    final newParams = params.copyWith(fontFamily: font.displayName);
    context.read<SettingsBloc>().add(UpdateSettingsEvent(newParams));
    AppTypography.updateFontSettings(font, params.fontScale);
    getIt<GlobalUiService>().showSuccess('Font changed to ${font.displayName}');
  }

  void _updateScale(
    BuildContext context,
    SettingsParams params,
    FontSizeScale scale,
  ) {
    final newParams = params.copyWith(fontScale: scale.scale);
    context.read<SettingsBloc>().add(UpdateSettingsEvent(newParams));
    final font = AppFontFamily.values.firstWhere(
      (f) => f.displayName == params.fontFamily,
      orElse: () => AppFontFamily.system,
    );
    AppTypography.updateFontSettings(font, scale.scale);
    getIt<GlobalUiService>().showSuccess(
      'Font size changed to ${scale.displayName}',
    );
  }

  void _resetToDefaults(BuildContext context, SettingsParams params) {
    final newParams = params.copyWith(
      fontFamily: 'System Default',
      fontScale: 1.0,
    );
    context.read<SettingsBloc>().add(UpdateSettingsEvent(newParams));
    AppTypography.updateFontSettings(AppFontFamily.system, 1.0);
    getIt<GlobalUiService>().showSuccess('Font settings reset to defaults');
  }
}

