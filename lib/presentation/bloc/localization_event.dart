part of 'localization_bloc.dart';

abstract class LocalizationEvent extends Equatable {
  const LocalizationEvent();

  @override
  List<Object?> get props => [];
}

class LoadLocalizationEvent extends LocalizationEvent {
  const LoadLocalizationEvent();
}

class ChangeLanguageEvent extends LocalizationEvent {
  final String language;

  const ChangeLanguageEvent(this.language);

  @override
  List<Object?> get props => [language];
}

class ResetLanguageEvent extends LocalizationEvent {
  const ResetLanguageEvent();
}
