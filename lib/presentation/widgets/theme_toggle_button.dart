import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/constants/app_colors.dart';
import '../bloc/theme/theme_bloc.dart';
import '../bloc/theme/theme_event.dart';
import '../bloc/theme/theme_state.dart';

/// A simple icon button to toggle between light and dark themes
/// Can be added to any AppBar or toolbar
class ThemeToggleButton extends StatelessWidget {
  const ThemeToggleButton({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, state) {
        return IconButton(
          icon: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (child, animation) {
              return RotationTransition(
                turns: animation,
                child: FadeTransition(opacity: animation, child: child),
              );
            },
            child: Icon(
              state.isDarkMode ? Icons.light_mode : Icons.dark_mode,
              key: ValueKey(state.isDarkMode),
              color: state.isDarkMode
                  ? AppColors.primaryDark
                  : AppColors.primaryLight,
            ),
          ),
          tooltip: state.isDarkMode
              ? 'Switch to Light Mode'
              : 'Switch to Dark Mode',
          onPressed: () {
            context.read<ThemeBloc>().add(
              UpdateThemeEvent.toggleDarkMode(state.params),
            );
          },
        );
      },
    );
  }
}

