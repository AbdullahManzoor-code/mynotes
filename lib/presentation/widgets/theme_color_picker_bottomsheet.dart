import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mynotes/presentation/design_system/app_typography.dart';
import 'package:mynotes/presentation/design_system/design_system.dart';
import '../bloc/theme/theme_bloc.dart';
import '../bloc/theme/theme_event.dart';

/// Theme color picker bottom sheet for customizing app primary color
/// Uses ThemeBloc for state management
class ThemeColorPickerBottomSheet extends StatelessWidget {
  final Color initialColor;
  final Function(Color) onColorSelected;

  const ThemeColorPickerBottomSheet({
    super.key,
    required this.initialColor,
    required this.onColorSelected,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.85,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      builder: (context, scrollController) => StatefulBuilder(
        builder: (context, setState) {
          Color selectedColor = initialColor;

          return Container(
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
            ),
            child: Column(
              children: [
                // Handle bar
                Padding(
                  padding: EdgeInsets.only(top: 12.h),
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.grey.shade700
                          : Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),

                // Header
                Padding(
                  padding: EdgeInsets.all(20.w),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Theme Color',
                        style: AppTypography.titleLarge(context),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),

                // Color Picker
                Expanded(
                  child: SingleChildScrollView(
                    controller: scrollController,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Select a color for your app theme',
                            style: AppTypography.bodySmall(
                              context,
                              isDark
                                  ? Colors.grey.shade400
                                  : Colors.grey.shade600,
                            ),
                          ),
                          SizedBox(height: 20.h),
                          ColorPicker(
                            color: selectedColor,
                            onColorChanged: (Color color) {
                              setState(() => selectedColor = color);
                            },
                            width: 40,
                            height: 40,
                            borderRadius: 8,
                            spacing: 8,
                            runSpacing: 8,
                            wheelDiameter: 165,
                            heading: Text(
                              'Select color',
                              style: AppTypography.bodyMedium(context),
                            ),
                            subheading: Text(
                              'Select color shade',
                              style: AppTypography.bodySmall(context),
                            ),
                            wheelSquarePadding: 4,
                            enableOpacity: false,
                            showColorCode: true,
                            colorCodeHasColor: true,
                            pickersEnabled: const <ColorPickerType, bool>{
                              ColorPickerType.both: false,
                              ColorPickerType.primary: true,
                              ColorPickerType.accent: true,
                              ColorPickerType.bw: false,
                              ColorPickerType.custom: true,
                              ColorPickerType.wheel: true,
                            },
                          ),
                          SizedBox(height: 20.h),

                          // Preview
                          Text(
                            'Preview',
                            style: AppTypography.bodyMedium(context),
                          ),
                          SizedBox(height: 12.h),
                          Container(
                            padding: EdgeInsets.all(16.w),
                            decoration: BoxDecoration(
                              color: selectedColor.withOpacity(0.1),
                              border: Border.all(
                                color: selectedColor.withOpacity(0.5),
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              children: [
                                // Button preview
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: selectedColor,
                                  ),
                                  onPressed: () {},
                                  child: const Text('Sample Button'),
                                ),
                                SizedBox(height: 12.h),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Container(
                                      width: 60,
                                      height: 60,
                                      decoration: BoxDecoration(
                                        color: selectedColor,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    Text(
                                      _colorToHex(selectedColor),
                                      style: AppTypography.bodyMedium(context),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Action buttons
                Padding(
                  padding: EdgeInsets.all(20.w),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(
                            'Cancel',
                            style: AppTypography.labelMedium(context),
                          ),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            // Update via ThemeBloc
                            final themeBloc = context.read<ThemeBloc>();
                            final currentParams = themeBloc.state.params;

                            themeBloc.add(
                              UpdateThemeEvent.changeColor(
                                currentParams,
                                selectedColor,
                              ),
                            );

                            onColorSelected(selectedColor);
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('✅ Theme color updated!'),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          },
                          child: Text(
                            'Apply',
                            style: AppTypography.labelMedium(
                              context,
                            ).copyWith(color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  String _colorToHex(Color color) {
    return '#${color.value.toRadixString(16).padLeft(8, '0').toUpperCase()}';
  }
}

/// Compact color picker button for settings
class ColorPickerButton extends StatelessWidget {
  final Color currentColor;
  final Function(Color) onColorChanged;
  final String label;

  const ColorPickerButton({
    super.key,
    required this.currentColor,
    required this.onColorChanged,
    this.label = 'Theme Color',
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: currentColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: currentColor.withOpacity(0.5), width: 2),
        ),
      ),
      title: Text(label),
      subtitle: Text(
        _colorToHex(currentColor),
        style: AppTypography.bodySmall(context),
      ),
      trailing: const Icon(Icons.edit),
      onTap: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) => ThemeColorPickerBottomSheet(
            initialColor: currentColor,
            onColorSelected: onColorChanged,
          ),
        );
      },
    );
  }

  String _colorToHex(Color color) {
    return '#${color.value.toRadixString(16).padLeft(8, '0').toUpperCase()}';
  }
}


