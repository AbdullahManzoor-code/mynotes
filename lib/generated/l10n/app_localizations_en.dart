// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'My Notes';

  @override
  String get appDescription => 'A comprehensive note-taking application';

  @override
  String get homeTitle => 'My Notes';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get newNoteButton => 'New Note';

  @override
  String get deleteButton => 'Delete';

  @override
  String get editButton => 'Edit';

  @override
  String get saveButton => 'Save';

  @override
  String get cancelButton => 'Cancel';

  @override
  String get shareButton => 'Share';

  @override
  String get searchButton => 'Search';

  @override
  String get backButton => 'Back';

  @override
  String get yesButton => 'Yes';

  @override
  String get noButton => 'No';

  @override
  String get okButton => 'OK';

  @override
  String get closeButton => 'Close';

  @override
  String get themeSettings => 'Theme';

  @override
  String get languageSettings => 'Language';

  @override
  String get accessibilitySettings => 'Accessibility';

  @override
  String get darkModeLabel => 'Dark Mode';

  @override
  String get lightModeLabel => 'Light Mode';

  @override
  String get systemModeLabel => 'System Default';

  @override
  String get fontSizeLabel => 'Font Size';

  @override
  String get primaryColorLabel => 'Primary Color';

  @override
  String get contrastLabel => 'High Contrast';

  @override
  String get screenReaderLabel => 'Screen Reader Support';

  @override
  String get emptyNotesMessage => 'No notes yet. Create your first note!';

  @override
  String get deleteConfirmation => 'Are you sure you want to delete this note?';

  @override
  String get unsavedChangesWarning =>
      'You have unsaved changes. Do you want to save them?';

  @override
  String get errorLoadingNotes => 'Error loading notes';

  @override
  String get errorSavingNote => 'Error saving note';

  @override
  String get successDeletedNote => 'Note deleted successfully';

  @override
  String get successSavedNote => 'Note saved successfully';

  @override
  String get successShareNote => 'Note shared successfully';

  @override
  String get noteTitleHint => 'Title';

  @override
  String get noteContentHint => 'Start typing...';

  @override
  String noteCreatedDate(String date) {
    return 'Created: $date';
  }

  @override
  String noteLastModified(String date) {
    return 'Last modified: $date';
  }

  @override
  String get aboutApp => 'About My Notes';

  @override
  String get version => 'Version';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get termsOfService => 'Terms of Service';

  @override
  String get feedbackButton => 'Send Feedback';

  @override
  String get noResultsFound => 'No results found';

  @override
  String get searchHint => 'Search notes...';

  @override
  String get sortBy => 'Sort by';

  @override
  String get filterBy => 'Filter by';

  @override
  String get allNotes => 'All Notes';

  @override
  String get pinnedNotes => 'Pinned Notes';

  @override
  String get archivedNotes => 'Archived Notes';

  @override
  String get deletedNotes => 'Deleted Notes';

  @override
  String get navigationHome => 'Home';

  @override
  String get navigationSearch => 'Search';

  @override
  String get navigationFavorites => 'Favorites';

  @override
  String get navigationSettings => 'Settings';

  @override
  String get confirmDeleteTitle => 'Delete Note?';

  @override
  String get confirmDeleteMessage => 'This action cannot be undone.';

  @override
  String get selectLanguage => 'Select Language';

  @override
  String get syncStatus => 'Sync Status';

  @override
  String get syncingNotes => 'Syncing...';

  @override
  String get syncComplete => 'Sync complete';

  @override
  String get offlineMode => 'Offline Mode';

  @override
  String get onlineMode => 'Online Mode';
}
