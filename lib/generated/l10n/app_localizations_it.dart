// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get appTitle => 'Le Mie Note';

  @override
  String get appDescription => 'Un\'applicazione completa per prendere note';

  @override
  String get homeTitle => 'Le Mie Note';

  @override
  String get settingsTitle => 'Impostazioni';

  @override
  String get newNoteButton => 'Nuova Nota';

  @override
  String get deleteButton => 'Elimina';

  @override
  String get editButton => 'Modifica';

  @override
  String get saveButton => 'Salva';

  @override
  String get cancelButton => 'Annulla';

  @override
  String get shareButton => 'Condividi';

  @override
  String get searchButton => 'Cerca';

  @override
  String get backButton => 'Indietro';

  @override
  String get yesButton => 'Sì';

  @override
  String get noButton => 'No';

  @override
  String get okButton => 'OK';

  @override
  String get closeButton => 'Chiudi';

  @override
  String get themeSettings => 'Tema';

  @override
  String get languageSettings => 'Lingua';

  @override
  String get accessibilitySettings => 'Accessibilità';

  @override
  String get darkModeLabel => 'Modalità Scura';

  @override
  String get lightModeLabel => 'Modalità Chiara';

  @override
  String get systemModeLabel => 'Impostazione di Sistema';

  @override
  String get fontSizeLabel => 'Dimensione Carattere';

  @override
  String get primaryColorLabel => 'Colore Primario';

  @override
  String get contrastLabel => 'Contrasto Alto';

  @override
  String get screenReaderLabel => 'Supporto Lettore Schermo';

  @override
  String get emptyNotesMessage =>
      'Nessuna nota per il momento. Crea la tua prima nota!';

  @override
  String get deleteConfirmation => 'Sei sicuro di voler eliminare questa nota?';

  @override
  String get unsavedChangesWarning =>
      'Hai modifiche non salvate. Vuoi salvarle?';

  @override
  String get errorLoadingNotes => 'Errore nel caricamento delle note';

  @override
  String get errorSavingNote => 'Errore nel salvataggio della nota';

  @override
  String get successDeletedNote => 'Nota eliminata con successo';

  @override
  String get successSavedNote => 'Nota salvata con successo';

  @override
  String get successShareNote => 'Nota condivisa con successo';

  @override
  String get noteTitleHint => 'Titolo';

  @override
  String get noteContentHint => 'Inizia a digitare...';

  @override
  String noteCreatedDate(String date) {
    return 'Creata: $date';
  }

  @override
  String noteLastModified(String date) {
    return 'Ultima modifica: $date';
  }

  @override
  String get aboutApp => 'Informazioni su Le Mie Note';

  @override
  String get version => 'Versione';

  @override
  String get privacyPolicy => 'Politica sulla Privacy';

  @override
  String get termsOfService => 'Condizioni di Servizio';

  @override
  String get feedbackButton => 'Invia Feedback';

  @override
  String get noResultsFound => 'Nessun risultato trovato';

  @override
  String get searchHint => 'Cerca note...';

  @override
  String get sortBy => 'Ordina per';

  @override
  String get filterBy => 'Filtra per';

  @override
  String get allNotes => 'Tutte le Note';

  @override
  String get pinnedNotes => 'Note Fissate';

  @override
  String get archivedNotes => 'Note Archiviate';

  @override
  String get deletedNotes => 'Note Eliminate';

  @override
  String get navigationHome => 'Home';

  @override
  String get navigationSearch => 'Cerca';

  @override
  String get navigationFavorites => 'Preferiti';

  @override
  String get navigationSettings => 'Impostazioni';

  @override
  String get confirmDeleteTitle => 'Elimina Nota?';

  @override
  String get confirmDeleteMessage => 'Questa azione non può essere annullata.';

  @override
  String get selectLanguage => 'Seleziona Lingua';

  @override
  String get syncStatus => 'Stato Sincronizzazione';

  @override
  String get syncingNotes => 'Sincronizzazione in corso...';

  @override
  String get syncComplete => 'Sincronizzazione completata';

  @override
  String get offlineMode => 'Modalità Offline';

  @override
  String get onlineMode => 'Modalità Online';
}
