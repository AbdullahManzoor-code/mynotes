import 'package:flutter/material.dart';

/// Color palette for notes
class NoteColorPalette {
  static const Map<String, Color> colors = {
    'white': Color(0xFFFFFFFF),
    'yellow': Color(0xFFFFF9C4),
    'orange': Color(0xFFFFE0B2),
    'pink': Color(0xFFF8BBD0),
    'purple': Color(0xFFE1BEE7),
    'blue': Color(0xFFC5CAE9),
    'cyan': Color(0x00b3e5fc),
    'green': Color(0xFFC8E6C9),
  };

  static const List<String> colorNames = [
    'white',
    'yellow',
    'orange',
    'pink',
    'purple',
    'blue',
    'cyan',
    'green',
  ];

  static Color getColor(String? colorName) {
    if (colorName == null || colorName.isEmpty) {
      return colors['white']!;
    }
    return colors[colorName] ?? colors['white']!;
  }

  static String getColorName(Color color) {
    for (final entry in colors.entries) {
      if (entry.value == color) {
        return entry.key;
      }
    }
    return 'white';
  }
}

/// Widget for selecting note color
class NoteColorPicker extends StatelessWidget {
  final String? currentColor;
  final Function(String) onColorSelected;
  final String? noteId; // For batch updates

  const NoteColorPicker({
    super.key,
    this.currentColor,
    required this.onColorSelected,
    this.noteId,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Note Color', style: Theme.of(context).textTheme.titleSmall),
        SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: NoteColorPalette.colorNames.map((colorName) {
            final color = NoteColorPalette.colors[colorName]!;
            final isSelected = currentColor == colorName;

            return GestureDetector(
              onTap: () => onColorSelected(colorName),
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color,
                  border: Border.all(
                    color: isSelected
                        ? Theme.of(context).colorScheme.primary
                        : Colors.grey.shade300,
                    width: isSelected ? 3 : 2,
                  ),
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: Theme.of(
                              context,
                            ).colorScheme.primary.withOpacity(0.5),
                            blurRadius: 8,
                            spreadRadius: 2,
                          ),
                        ]
                      : null,
                ),
                child: isSelected
                    ? Icon(Icons.check, color: _getTextColor(color), size: 24)
                    : null,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  /// Get appropriate text color based on background
  Color _getTextColor(Color backgroundColor) {
    // Calculate luminance
    final luminance =
        (0.299 * backgroundColor.red +
            0.587 * backgroundColor.green +
            0.114 * backgroundColor.blue) /
        255;

    return luminance > 0.5 ? Colors.black : Colors.white;
  }
}

/// Bottom sheet for color selection
class NoteColorBottomSheet extends StatelessWidget {
  final String? currentColor;
  final Function(String) onColorSelected;

  const NoteColorBottomSheet({
    super.key,
    this.currentColor,
    required this.onColorSelected,
  });

  static void show(
    BuildContext context,
    String? currentColor,
    Function(String) onColorSelected,
  ) {
    showModalBottomSheet(
      context: context,
      builder: (context) => NoteColorBottomSheet(
        currentColor: currentColor,
        onColorSelected: (color) {
          onColorSelected(color);
          Navigator.pop(context);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Select Note Color',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          SizedBox(height: 24),
          NoteColorPicker(
            currentColor: currentColor,
            onColorSelected: onColorSelected,
          ),
          SizedBox(height: 24),
        ],
      ),
    );
  }
}
