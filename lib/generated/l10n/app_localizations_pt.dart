// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appTitle => 'Minhas Notas';

  @override
  String get appDescription => 'Um aplicativo completo para tomar notas';

  @override
  String get homeTitle => 'Minhas Notas';

  @override
  String get settingsTitle => 'Configurações';

  @override
  String get newNoteButton => 'Nova Nota';

  @override
  String get deleteButton => 'Deletar';

  @override
  String get editButton => 'Editar';

  @override
  String get saveButton => 'Salvar';

  @override
  String get cancelButton => 'Cancelar';

  @override
  String get shareButton => 'Compartilhar';

  @override
  String get searchButton => 'Pesquisar';

  @override
  String get backButton => 'Voltar';

  @override
  String get yesButton => 'Sim';

  @override
  String get noButton => 'Não';

  @override
  String get okButton => 'OK';

  @override
  String get closeButton => 'Fechar';

  @override
  String get themeSettings => 'Tema';

  @override
  String get languageSettings => 'Idioma';

  @override
  String get accessibilitySettings => 'Acessibilidade';

  @override
  String get darkModeLabel => 'Modo Escuro';

  @override
  String get lightModeLabel => 'Modo Claro';

  @override
  String get systemModeLabel => 'Configuração do Sistema';

  @override
  String get fontSizeLabel => 'Tamanho da Fonte';

  @override
  String get primaryColorLabel => 'Cor Primária';

  @override
  String get contrastLabel => 'Alto Contraste';

  @override
  String get screenReaderLabel => 'Suporte a Leitor de Tela';

  @override
  String get emptyNotesMessage => 'Nenhuma nota ainda. Crie sua primeira nota!';

  @override
  String get deleteConfirmation =>
      'Tem certeza de que deseja deletar esta nota?';

  @override
  String get unsavedChangesWarning =>
      'Você tem alterações não salvas. Deseja salvá-las?';

  @override
  String get errorLoadingNotes => 'Erro ao carregar notas';

  @override
  String get errorSavingNote => 'Erro ao salvar a nota';

  @override
  String get successDeletedNote => 'Nota deletada com sucesso';

  @override
  String get successSavedNote => 'Nota salva com sucesso';

  @override
  String get successShareNote => 'Nota compartilhada com sucesso';

  @override
  String get noteTitleHint => 'Título';

  @override
  String get noteContentHint => 'Comece a digitar...';

  @override
  String noteCreatedDate(String date) {
    return 'Criada: $date';
  }

  @override
  String noteLastModified(String date) {
    return 'Última alteração: $date';
  }

  @override
  String get aboutApp => 'Sobre Minhas Notas';

  @override
  String get version => 'Versão';

  @override
  String get privacyPolicy => 'Política de Privacidade';

  @override
  String get termsOfService => 'Termos de Serviço';

  @override
  String get feedbackButton => 'Enviar Feedback';

  @override
  String get noResultsFound => 'Nenhum resultado encontrado';

  @override
  String get searchHint => 'Pesquisar notas...';

  @override
  String get sortBy => 'Ordenar por';

  @override
  String get filterBy => 'Filtrar por';

  @override
  String get allNotes => 'Todas as Notas';

  @override
  String get pinnedNotes => 'Notas Fixadas';

  @override
  String get archivedNotes => 'Notas Arquivadas';

  @override
  String get deletedNotes => 'Notas Deletadas';

  @override
  String get navigationHome => 'Início';

  @override
  String get navigationSearch => 'Pesquisar';

  @override
  String get navigationFavorites => 'Favoritos';

  @override
  String get navigationSettings => 'Configurações';

  @override
  String get confirmDeleteTitle => 'Deletar Nota?';

  @override
  String get confirmDeleteMessage => 'Essa ação não pode ser desfeita.';

  @override
  String get selectLanguage => 'Selecionar Idioma';

  @override
  String get syncStatus => 'Status de Sincronização';

  @override
  String get syncingNotes => 'Sincronizando...';

  @override
  String get syncComplete => 'Sincronização concluída';

  @override
  String get offlineMode => 'Modo Offline';

  @override
  String get onlineMode => 'Modo Online';
}
