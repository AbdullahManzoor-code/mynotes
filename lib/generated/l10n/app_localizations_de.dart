// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appTitle => 'Meine Notizen';

  @override
  String get appDescription => 'Eine umfassende Notizen-Anwendung';

  @override
  String get homeTitle => 'Meine Notizen';

  @override
  String get settingsTitle => 'Einstellungen';

  @override
  String get newNoteButton => 'Neue Notiz';

  @override
  String get deleteButton => 'Löschen';

  @override
  String get editButton => 'Bearbeiten';

  @override
  String get saveButton => 'Speichern';

  @override
  String get cancelButton => 'Abbrechen';

  @override
  String get shareButton => 'Teilen';

  @override
  String get searchButton => 'Suchen';

  @override
  String get backButton => 'Zurück';

  @override
  String get yesButton => 'Ja';

  @override
  String get noButton => 'Nein';

  @override
  String get okButton => 'OK';

  @override
  String get closeButton => 'Schließen';

  @override
  String get themeSettings => 'Design';

  @override
  String get languageSettings => 'Sprache';

  @override
  String get accessibilitySettings => 'Barrierefreiheit';

  @override
  String get darkModeLabel => 'Dunkler Modus';

  @override
  String get lightModeLabel => 'Heller Modus';

  @override
  String get systemModeLabel => 'Systemeinstellung';

  @override
  String get fontSizeLabel => 'Schriftgröße';

  @override
  String get primaryColorLabel => 'Primärfarbe';

  @override
  String get contrastLabel => 'Hoher Kontrast';

  @override
  String get screenReaderLabel => 'Bildschirmlesegerät-Unterstützung';

  @override
  String get emptyNotesMessage =>
      'Keine Notizen vorhanden. Erstellen Sie Ihre erste Notiz!';

  @override
  String get deleteConfirmation => 'Möchten Sie diese Notiz wirklich löschen?';

  @override
  String get unsavedChangesWarning =>
      'Sie haben ungespeicherte Änderungen. Möchten Sie diese speichern?';

  @override
  String get errorLoadingNotes => 'Fehler beim Laden von Notizen';

  @override
  String get errorSavingNote => 'Fehler beim Speichern der Notiz';

  @override
  String get successDeletedNote => 'Notiz erfolgreich gelöscht';

  @override
  String get successSavedNote => 'Notiz erfolgreich gespeichert';

  @override
  String get successShareNote => 'Notiz erfolgreich geteilt';

  @override
  String get noteTitleHint => 'Titel';

  @override
  String get noteContentHint => 'Beginnen Sie zu tippen...';

  @override
  String noteCreatedDate(String date) {
    return 'Erstellt: $date';
  }

  @override
  String noteLastModified(String date) {
    return 'Zuletzt bearbeitet: $date';
  }

  @override
  String get aboutApp => 'Über Meine Notizen';

  @override
  String get version => 'Version';

  @override
  String get privacyPolicy => 'Datenschutzrichtlinie';

  @override
  String get termsOfService => 'Nutzungsbedingungen';

  @override
  String get feedbackButton => 'Feedback geben';

  @override
  String get noResultsFound => 'Keine Ergebnisse gefunden';

  @override
  String get searchHint => 'Notizen durchsuchen...';

  @override
  String get sortBy => 'Sortieren nach';

  @override
  String get filterBy => 'Filtern nach';

  @override
  String get allNotes => 'Alle Notizen';

  @override
  String get pinnedNotes => 'Angeheftete Notizen';

  @override
  String get archivedNotes => 'Archivierte Notizen';

  @override
  String get deletedNotes => 'Gelöschte Notizen';

  @override
  String get navigationHome => 'Startseite';

  @override
  String get navigationSearch => 'Suchen';

  @override
  String get navigationFavorites => 'Favoriten';

  @override
  String get navigationSettings => 'Einstellungen';

  @override
  String get confirmDeleteTitle => 'Notiz löschen?';

  @override
  String get confirmDeleteMessage =>
      'Diese Aktion kann nicht rückgängig gemacht werden.';

  @override
  String get selectLanguage => 'Sprache wählen';

  @override
  String get syncStatus => 'Synchronisierungsstatus';

  @override
  String get syncingNotes => 'Synchronisierung läuft...';

  @override
  String get syncComplete => 'Synchronisierung abgeschlossen';

  @override
  String get offlineMode => 'Offline-Modus';

  @override
  String get onlineMode => 'Online-Modus';
}
