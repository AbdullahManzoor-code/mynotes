import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart';
import 'package:mynotes/presentation/design_system/app_typography.dart';

/// Theme color picker bottom sheet for customizing app primary color
class ThemeColorPickerBottomSheet extends StatefulWidget {
  final Color initialColor;
  final Function(Color) onColorSelected;

  const ThemeColorPickerBottomSheet({
    Key? key,
    required this.initialColor,
    required this.onColorSelected,
  }) : super(key: key);

  @override
  State<ThemeColorPickerBottomSheet> createState() =>
      _ThemeColorPickerBottomSheetState();
}

class _ThemeColorPickerBottomSheetState
    extends State<ThemeColorPickerBottomSheet> {
  late Color _selectedColor;

  @override
  void initState() {
    super.initState();
    _selectedColor = widget.initialColor;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.85,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      builder: (context, scrollController) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            // Handle bar
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Header
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Theme Color', style: AppTypography.titleLarge(context)),
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
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Select a color for your app theme',
                        style: AppTypography.bodySmall(
                          context,
                          isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 20),
                      ColorPicker(
                        color: _selectedColor,
                        onColorChanged: (Color color) {
                          setState(() => _selectedColor = color);
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
                      const SizedBox(height: 20),

                      // Preview
                      Text('Preview', style: AppTypography.bodyMedium(context)),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: _selectedColor.withOpacity(0.1),
                          border: Border.all(
                            color: _selectedColor.withOpacity(0.5),
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            // Button preview
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _selectedColor,
                              ),
                              onPressed: () {},
                              child: const Text('Sample Button'),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Container(
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    color: _selectedColor,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                Text(
                                  _colorToHex(_selectedColor),
                                  style: AppTypography.bodyMedium(context),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),

            // Action buttons
            Padding(
              padding: const EdgeInsets.all(20),
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
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        widget.onColorSelected(_selectedColor);
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('✅ Theme color updated!'),
                            duration: const Duration(seconds: 2),
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
    Key? key,
    required this.currentColor,
    required this.onColorChanged,
    this.label = 'Theme Color',
  }) : super(key: key);

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
