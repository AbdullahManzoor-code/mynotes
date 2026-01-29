import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'localization_event.dart';
part 'localization_state.dart';

class LocalizationBloc extends Bloc<LocalizationEvent, LocalizationState> {
  late SharedPreferences _prefs;
  String _currentLanguage = 'en';

  LocalizationBloc() : super(const LocalizationInitial()) {
    on<LoadLocalizationEvent>(_onLoadLocalization);
    on<ChangeLanguageEvent>(_onChangeLanguage);
    on<ResetLanguageEvent>(_onResetLanguage);
  }

  Future<void> _onLoadLocalization(
    LoadLocalizationEvent event,
    Emitter<LocalizationState> emit,
  ) async {
    try {
      _prefs = await SharedPreferences.getInstance();
      _currentLanguage = _prefs.getString('language') ?? 'en';
      emit(LocalizationLoaded(language: _currentLanguage));
    } catch (e) {
      emit(LocalizationError(message: 'Failed to load localization: $e'));
    }
  }

  Future<void> _onChangeLanguage(
    ChangeLanguageEvent event,
    Emitter<LocalizationState> emit,
  ) async {
    try {
      _prefs = await SharedPreferences.getInstance();
      await _prefs.setString('language', event.language);
      _currentLanguage = event.language;
      emit(LocalizationLoaded(language: _currentLanguage));
    } catch (e) {
      emit(LocalizationError(message: 'Failed to change language: $e'));
    }
  }

  Future<void> _onResetLanguage(
    ResetLanguageEvent event,
    Emitter<LocalizationState> emit,
  ) async {
    try {
      _prefs = await SharedPreferences.getInstance();
      await _prefs.remove('language');
      _currentLanguage = 'en';
      emit(LocalizationLoaded(language: _currentLanguage));
    } catch (e) {
      emit(LocalizationError(message: 'Failed to reset language: $e'));
    }
  }
}
