import 'package:equatable/equatable.dart';
import 'package:mynotes/presentation/bloc/params/theme_params.dart';

class ThemeState extends Equatable {
  final ThemeParams params;

  const ThemeState({required this.params});

  bool get isDarkMode => params.isDarkMode;
  String get themeMode => params.isDarkMode ? 'dark' : 'light';
  double get fontSize => params.fontSize;

  @override
  List<Object?> get props => [params];
}
