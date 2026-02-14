part of 'localization_bloc.dart';

abstract class LocalizationState extends Equatable {
  const LocalizationState();

  @override
  List<Object?> get props => [];
}

class LocalizationInitial extends LocalizationState {
  const LocalizationInitial();
}

class LocalizationLoading extends LocalizationState {
  const LocalizationLoading();
}

class LocalizationLoaded extends LocalizationState {
  final String language;
  final List<String> supportedLanguages;

  const LocalizationLoaded({
    required this.language,
    this.supportedLanguages = const [
      'en',
      'es',
      'fr',
      'de',
      'it',
      'pt',
      'ja',
      'zh',
      'ar',
    ],
  });

  @override
  List<Object?> get props => [language, supportedLanguages];
}

class LocalizationChanged extends LocalizationState {
  final String language;
  final List<String> supportedLanguages;

  const LocalizationChanged({
    required this.language,
    this.supportedLanguages = const [
      'en',
      'es',
      'fr',
      'de',
      'it',
      'pt',
      'ja',
      'zh',
      'ar',
    ],
  });

  @override
  List<Object?> get props => [language, supportedLanguages];
}

class LocalizationError extends LocalizationState {
  final String message;

  const LocalizationError({required this.message});

  @override
  List<Object?> get props => [message];
}
