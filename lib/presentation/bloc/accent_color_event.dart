part of 'accent_color_bloc.dart';

abstract class AccentColorEvent extends Equatable {
  const AccentColorEvent();

  @override
  List<Object?> get props => [];
}

class LoadAccentColorEvent extends AccentColorEvent {
  const LoadAccentColorEvent();
}

class ChangeAccentColorEvent extends AccentColorEvent {
  final int colorValue;

  const ChangeAccentColorEvent(this.colorValue);

  @override
  List<Object?> get props => [colorValue];
}

class ResetAccentColorEvent extends AccentColorEvent {
  const ResetAccentColorEvent();
}
