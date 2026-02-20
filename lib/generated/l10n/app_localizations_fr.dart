// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'Mes Notes';

  @override
  String get appDescription => 'Une application complète de prise de notes';

  @override
  String get homeTitle => 'Mes Notes';

  @override
  String get settingsTitle => 'Paramètres';

  @override
  String get newNoteButton => 'Nouvelle Note';

  @override
  String get deleteButton => 'Supprimer';

  @override
  String get editButton => 'Modifier';

  @override
  String get saveButton => 'Enregistrer';

  @override
  String get cancelButton => 'Annuler';

  @override
  String get shareButton => 'Partager';

  @override
  String get searchButton => 'Rechercher';

  @override
  String get backButton => 'Retour';

  @override
  String get yesButton => 'Oui';

  @override
  String get noButton => 'Non';

  @override
  String get okButton => 'D\'accord';

  @override
  String get closeButton => 'Fermer';

  @override
  String get themeSettings => 'Thème';

  @override
  String get languageSettings => 'Langue';

  @override
  String get accessibilitySettings => 'Accessibilité';

  @override
  String get darkModeLabel => 'Mode Sombre';

  @override
  String get lightModeLabel => 'Mode Clair';

  @override
  String get systemModeLabel => 'Paramètre Système';

  @override
  String get fontSizeLabel => 'Taille de Police';

  @override
  String get primaryColorLabel => 'Couleur Primaire';

  @override
  String get contrastLabel => 'Contraste Élevé';

  @override
  String get screenReaderLabel => 'Support du Lecteur d\'Écran';

  @override
  String get emptyNotesMessage =>
      'Aucune note pour le moment. Créez votre première note!';

  @override
  String get deleteConfirmation =>
      'Êtes-vous sûr de vouloir supprimer cette note?';

  @override
  String get unsavedChangesWarning =>
      'Vous avez des modifications non enregistrées. Voulez-vous les enregistrer?';

  @override
  String get errorLoadingNotes => 'Erreur lors du chargement des notes';

  @override
  String get errorSavingNote => 'Erreur lors de l\'enregistrement de la note';

  @override
  String get successDeletedNote => 'Note supprimée avec succès';

  @override
  String get successSavedNote => 'Note enregistrée avec succès';

  @override
  String get successShareNote => 'Note partagée avec succès';

  @override
  String get noteTitleHint => 'Titre';

  @override
  String get noteContentHint => 'Commencez à taper...';

  @override
  String noteCreatedDate(String date) {
    return 'Créée: $date';
  }

  @override
  String noteLastModified(String date) {
    return 'Dernière modification: $date';
  }

  @override
  String get aboutApp => 'À Propos de Mes Notes';

  @override
  String get version => 'Version';

  @override
  String get privacyPolicy => 'Politique de Confidentialité';

  @override
  String get termsOfService => 'Conditions d\'Utilisation';

  @override
  String get feedbackButton => 'Envoyer des Commentaires';

  @override
  String get noResultsFound => 'Aucun résultat trouvé';

  @override
  String get searchHint => 'Rechercher des notes...';

  @override
  String get sortBy => 'Trier par';

  @override
  String get filterBy => 'Filtrer par';

  @override
  String get allNotes => 'Toutes les Notes';

  @override
  String get pinnedNotes => 'Notes Épinglées';

  @override
  String get archivedNotes => 'Notes Archivées';

  @override
  String get deletedNotes => 'Notes Supprimées';

  @override
  String get navigationHome => 'Accueil';

  @override
  String get navigationSearch => 'Rechercher';

  @override
  String get navigationFavorites => 'Favoris';

  @override
  String get navigationSettings => 'Paramètres';

  @override
  String get confirmDeleteTitle => 'Supprimer la Note?';

  @override
  String get confirmDeleteMessage => 'Cette action ne peut pas être annulée.';

  @override
  String get selectLanguage => 'Sélectionnez la Langue';

  @override
  String get syncStatus => 'État de la Synchronisation';

  @override
  String get syncingNotes => 'Synchronisation...';

  @override
  String get syncComplete => 'Synchronisation terminée';

  @override
  String get offlineMode => 'Mode Hors Ligne';

  @override
  String get onlineMode => 'Mode En Ligne';
}
