import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/theme_bloc.dart';
import '../bloc/theme_event.dart';
import '../bloc/theme_state.dart';

/// Widget for font size scaling settings
class FontSizeScalingPanel extends StatelessWidget {
  const FontSizeScalingPanel({super.key});

  static const Map<String, double> fontSizeOptions = {
    '80%': 0.8,
    '90%': 0.9,
    '100%': 1.0,
    '110%': 1.1,
    '120%': 1.2,
    '130%': 1.3,
    '140%': 1.4,
    '150%': 1.5,
  };

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Font Size Scaling',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),

            // Slider for continuous adjustment
            Column(
              children: [
                Slider(
                  value: state.fontSize,
                  min: 0.8,
                  max: 1.5,
                  divisions: 14,
                  label: '${(state.fontSize * 100).toStringAsFixed(0)}%',
                  onChanged: (value) {
                    context.read<ThemeBloc>().add(ChangeFontSizeEvent(value));
                  },
                ),
                Text(
                  'Current: ${(state.fontSize * 100).toStringAsFixed(0)}%',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Quick preset buttons
            Wrap(
              spacing: 8,
              children: fontSizeOptions.entries.map((entry) {
                final isSelected = (state.fontSize - entry.value).abs() < 0.01;
                return FilterChip(
                  label: Text(entry.key),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) {
                      context.read<ThemeBloc>().add(
                        ChangeFontSizeEvent(entry.value),
                      );
                    }
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // Preview text
            Text(
              'Preview Text',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontSize:
                    (Theme.of(context).textTheme.bodyMedium?.fontSize ?? 14) *
                    state.fontSize,
              ),
            ),
          ],
        );
      },
    );
  }
}
