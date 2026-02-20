// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get appTitle => 'マイノート';

  @override
  String get appDescription => '包括的なノートテイキングアプリケーション';

  @override
  String get homeTitle => 'マイノート';

  @override
  String get settingsTitle => '設定';

  @override
  String get newNoteButton => '新規ノート';

  @override
  String get deleteButton => '削除';

  @override
  String get editButton => '編集';

  @override
  String get saveButton => '保存';

  @override
  String get cancelButton => 'キャンセル';

  @override
  String get shareButton => '共有';

  @override
  String get searchButton => '検索';

  @override
  String get backButton => '戻る';

  @override
  String get yesButton => 'はい';

  @override
  String get noButton => 'いいえ';

  @override
  String get okButton => 'OK';

  @override
  String get closeButton => '閉じる';

  @override
  String get themeSettings => 'テーマ';

  @override
  String get languageSettings => '言語';

  @override
  String get accessibilitySettings => 'アクセシビリティ';

  @override
  String get darkModeLabel => 'ダークモード';

  @override
  String get lightModeLabel => 'ライトモード';

  @override
  String get systemModeLabel => 'システムデフォルト';

  @override
  String get fontSizeLabel => 'フォントサイズ';

  @override
  String get primaryColorLabel => 'プライマリカラー';

  @override
  String get contrastLabel => '高コントラスト';

  @override
  String get screenReaderLabel => 'スクリーンリーダーサポート';

  @override
  String get emptyNotesMessage => 'ノートはまだありません。最初のノートを作成してください!';

  @override
  String get deleteConfirmation => 'このノートを削除してもよろしいですか?';

  @override
  String get unsavedChangesWarning => '保存されていない変更があります。保存しますか?';

  @override
  String get errorLoadingNotes => 'ノートの読み込みエラー';

  @override
  String get errorSavingNote => 'ノートの保存エラー';

  @override
  String get successDeletedNote => 'ノートが正常に削除されました';

  @override
  String get successSavedNote => 'ノートが正常に保存されました';

  @override
  String get successShareNote => 'ノートが正常に共有されました';

  @override
  String get noteTitleHint => 'タイトル';

  @override
  String get noteContentHint => '入力を開始してください...';

  @override
  String noteCreatedDate(String date) {
    return '作成: $date';
  }

  @override
  String noteLastModified(String date) {
    return '最終更新: $date';
  }

  @override
  String get aboutApp => 'マイノートについて';

  @override
  String get version => 'バージョン';

  @override
  String get privacyPolicy => 'プライバシーポリシー';

  @override
  String get termsOfService => '利用規約';

  @override
  String get feedbackButton => 'フィードバックを送信';

  @override
  String get noResultsFound => '結果が見つかりません';

  @override
  String get searchHint => 'ノートを検索...';

  @override
  String get sortBy => '並べ替え';

  @override
  String get filterBy => 'フィルター';

  @override
  String get allNotes => 'すべてのノート';

  @override
  String get pinnedNotes => 'ピン留めされたノート';

  @override
  String get archivedNotes => 'アーカイブされたノート';

  @override
  String get deletedNotes => '削除されたノート';

  @override
  String get navigationHome => 'ホーム';

  @override
  String get navigationSearch => '検索';

  @override
  String get navigationFavorites => 'お気に入り';

  @override
  String get navigationSettings => '設定';

  @override
  String get confirmDeleteTitle => 'ノートを削除しますか?';

  @override
  String get confirmDeleteMessage => 'このアクションは元に戻すことができません。';

  @override
  String get selectLanguage => '言語を選択';

  @override
  String get syncStatus => '同期ステータス';

  @override
  String get syncingNotes => '同期中...';

  @override
  String get syncComplete => '同期が完了しました';

  @override
  String get offlineMode => 'オフラインモード';

  @override
  String get onlineMode => 'オンラインモード';
}
