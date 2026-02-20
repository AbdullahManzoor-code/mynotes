// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Mis Notas';

  @override
  String get appDescription => 'Una aplicación completa para tomar notas';

  @override
  String get homeTitle => 'Mis Notas';

  @override
  String get settingsTitle => 'Configuración';

  @override
  String get newNoteButton => 'Nueva Nota';

  @override
  String get deleteButton => 'Eliminar';

  @override
  String get editButton => 'Editar';

  @override
  String get saveButton => 'Guardar';

  @override
  String get cancelButton => 'Cancelar';

  @override
  String get shareButton => 'Compartir';

  @override
  String get searchButton => 'Buscar';

  @override
  String get backButton => 'Atrás';

  @override
  String get yesButton => 'Sí';

  @override
  String get noButton => 'No';

  @override
  String get okButton => 'Aceptar';

  @override
  String get closeButton => 'Cerrar';

  @override
  String get themeSettings => 'Tema';

  @override
  String get languageSettings => 'Idioma';

  @override
  String get accessibilitySettings => 'Accesibilidad';

  @override
  String get darkModeLabel => 'Modo Oscuro';

  @override
  String get lightModeLabel => 'Modo Claro';

  @override
  String get systemModeLabel => 'Por Defecto del Sistema';

  @override
  String get fontSizeLabel => 'Tamaño de Fuente';

  @override
  String get primaryColorLabel => 'Color Primario';

  @override
  String get contrastLabel => 'Contraste Alto';

  @override
  String get screenReaderLabel => 'Soporte de Lector de Pantalla';

  @override
  String get emptyNotesMessage => 'Sin notas aún. ¡Crea tu primera nota!';

  @override
  String get deleteConfirmation =>
      '¿Estás seguro de que deseas eliminar esta nota?';

  @override
  String get unsavedChangesWarning =>
      'Tienes cambios sin guardar. ¿Deseas guardarlos?';

  @override
  String get errorLoadingNotes => 'Error al cargar notas';

  @override
  String get errorSavingNote => 'Error al guardar la nota';

  @override
  String get successDeletedNote => 'Nota eliminada correctamente';

  @override
  String get successSavedNote => 'Nota guardada correctamente';

  @override
  String get successShareNote => 'Nota compartida correctamente';

  @override
  String get noteTitleHint => 'Título';

  @override
  String get noteContentHint => 'Comienza a escribir...';

  @override
  String noteCreatedDate(String date) {
    return 'Creada: $date';
  }

  @override
  String noteLastModified(String date) {
    return 'Última modificación: $date';
  }

  @override
  String get aboutApp => 'Acerca de Mis Notas';

  @override
  String get version => 'Versión';

  @override
  String get privacyPolicy => 'Política de Privacidad';

  @override
  String get termsOfService => 'Términos de Servicio';

  @override
  String get feedbackButton => 'Enviar Comentarios';

  @override
  String get noResultsFound => 'No se encontraron resultados';

  @override
  String get searchHint => 'Buscar notas...';

  @override
  String get sortBy => 'Ordenar por';

  @override
  String get filterBy => 'Filtrar por';

  @override
  String get allNotes => 'Todas las Notas';

  @override
  String get pinnedNotes => 'Notas Fijadas';

  @override
  String get archivedNotes => 'Notas Archivadas';

  @override
  String get deletedNotes => 'Notas Eliminadas';

  @override
  String get navigationHome => 'Inicio';

  @override
  String get navigationSearch => 'Buscar';

  @override
  String get navigationFavorites => 'Favoritos';

  @override
  String get navigationSettings => 'Configuración';

  @override
  String get confirmDeleteTitle => '¿Eliminar Nota?';

  @override
  String get confirmDeleteMessage => 'Esta acción no se puede deshacer.';

  @override
  String get selectLanguage => 'Seleccionar Idioma';

  @override
  String get syncStatus => 'Estado de Sincronización';

  @override
  String get syncingNotes => 'Sincronizando...';

  @override
  String get syncComplete => 'Sincronización completada';

  @override
  String get offlineMode => 'Modo Sin Conexión';

  @override
  String get onlineMode => 'Modo En Línea';
}
