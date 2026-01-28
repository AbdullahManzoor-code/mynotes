import 'package:shared_preferences/shared_preferences.dart';

/// Service for managing speech recognition languages
class LanguageService {
  static const String _languageKey = 'speech_language';
  static const String _defaultLanguage = 'en_US';

  /// Available languages for speech recognition
  static const Map<String, String> availableLanguages = {
    'en_US': 'English (US)',
    'en_GB': 'English (UK)',
    'es_ES': 'Spanish (Spain)',
    'es_MX': 'Spanish (Mexico)',
    'fr_FR': 'French (France)',
    'de_DE': 'German (Germany)',
    'it_IT': 'Italian (Italy)',
    'pt_BR': 'Portuguese (Brazil)',
    'pt_PT': 'Portuguese (Portugal)',
    'zh_CN': 'Chinese (Simplified)',
    'zh_TW': 'Chinese (Traditional)',
    'ja_JP': 'Japanese',
    'ko_KR': 'Korean',
    'ar_SA': 'Arabic (Saudi Arabia)',
    'hi_IN': 'Hindi (India)',
    'ru_RU': 'Russian',
    'tr_TR': 'Turkish',
    'nl_NL': 'Dutch',
    'pl_PL': 'Polish',
    'sv_SE': 'Swedish',
    'no_NO': 'Norwegian',
    'da_DK': 'Danish',
    'fi_FI': 'Finnish',
  };

  /// Get saved language preference
  Future<String> getSavedLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_languageKey) ?? _defaultLanguage;
  }

  /// Save language preference
  Future<void> saveLanguage(String localeId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, localeId);
  }

  /// Get language name from locale ID
  String getLanguageName(String localeId) {
    return availableLanguages[localeId] ?? 'Unknown';
  }

  /// Get all available languages as a list
  List<LanguageOption> getLanguageOptions() {
    return availableLanguages.entries
        .map(
          (entry) =>
              LanguageOption(localeId: entry.key, displayName: entry.value),
        )
        .toList();
  }

  /// Detect language from text (simple heuristic)
  String? detectLanguage(String text) {
    if (text.isEmpty) return null;

    // Simple character-based detection
    if (RegExp(r'[\u4e00-\u9fff]').hasMatch(text)) {
      return 'zh_CN'; // Chinese
    } else if (RegExp(r'[\u3040-\u309f\u30a0-\u30ff]').hasMatch(text)) {
      return 'ja_JP'; // Japanese
    } else if (RegExp(r'[\uac00-\ud7af]').hasMatch(text)) {
      return 'ko_KR'; // Korean
    } else if (RegExp(r'[\u0600-\u06ff]').hasMatch(text)) {
      return 'ar_SA'; // Arabic
    } else if (RegExp(r'[\u0400-\u04ff]').hasMatch(text)) {
      return 'ru_RU'; // Russian
    }

    // Default to English for Latin scripts
    return 'en_US';
  }

  /// Get popular languages (top 5)
  List<LanguageOption> getPopularLanguages() {
    return [
      LanguageOption(localeId: 'en_US', displayName: 'English (US)'),
      LanguageOption(localeId: 'es_ES', displayName: 'Spanish'),
      LanguageOption(localeId: 'fr_FR', displayName: 'French'),
      LanguageOption(localeId: 'de_DE', displayName: 'German'),
      LanguageOption(localeId: 'zh_CN', displayName: 'Chinese'),
    ];
  }

  /// Search languages by name
  List<LanguageOption> searchLanguages(String query) {
    if (query.isEmpty) return getLanguageOptions();

    final lowerQuery = query.toLowerCase();
    return availableLanguages.entries
        .where((entry) => entry.value.toLowerCase().contains(lowerQuery))
        .map(
          (entry) =>
              LanguageOption(localeId: entry.key, displayName: entry.value),
        )
        .toList();
  }
}

/// Language option model
class LanguageOption {
  final String localeId;
  final String displayName;

  LanguageOption({required this.localeId, required this.displayName});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LanguageOption &&
          runtimeType == other.runtimeType &&
          localeId == other.localeId;

  @override
  int get hashCode => localeId.hashCode;
}

