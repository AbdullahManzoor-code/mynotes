part of 'accent_color_bloc.dart';

abstract class AccentColorState extends Equatable {
  const AccentColorState();

  @override
  List<Object?> get props => [];
}

class AccentColorInitial extends AccentColorState {
  const AccentColorInitial();
}

class AccentColorLoading extends AccentColorState {
  const AccentColorLoading();
}

class AccentColorLoaded extends AccentColorState {
  final int colorValue;
  final String colorName;

  const AccentColorLoaded({required this.colorValue, required this.colorName});

  @override
  List<Object?> get props => [colorValue, colorName];
}

class AccentColorChanged extends AccentColorState {
  final int colorValue;
  final String colorName;

  const AccentColorChanged({required this.colorValue, required this.colorName});

  @override
  List<Object?> get props => [colorValue, colorName];
}

class AccentColorError extends AccentColorState {
  final String message;

  const AccentColorError(this.message);

  @override
  List<Object?> get props => [message];
}
