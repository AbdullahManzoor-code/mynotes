// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => '我的笔记';

  @override
  String get appDescription => '一个全面的笔记应用程序';

  @override
  String get homeTitle => '我的笔记';

  @override
  String get settingsTitle => '设置';

  @override
  String get newNoteButton => '新建笔记';

  @override
  String get deleteButton => '删除';

  @override
  String get editButton => '编辑';

  @override
  String get saveButton => '保存';

  @override
  String get cancelButton => '取消';

  @override
  String get shareButton => '分享';

  @override
  String get searchButton => '搜索';

  @override
  String get backButton => '返回';

  @override
  String get yesButton => '是';

  @override
  String get noButton => '否';

  @override
  String get okButton => '确定';

  @override
  String get closeButton => '关闭';

  @override
  String get themeSettings => '主题';

  @override
  String get languageSettings => '语言';

  @override
  String get accessibilitySettings => '无障碍';

  @override
  String get darkModeLabel => '深色模式';

  @override
  String get lightModeLabel => '浅色模式';

  @override
  String get systemModeLabel => '系统默认';

  @override
  String get fontSizeLabel => '字体大小';

  @override
  String get primaryColorLabel => '主要颜色';

  @override
  String get contrastLabel => '高对比度';

  @override
  String get screenReaderLabel => '屏幕朗读器支持';

  @override
  String get emptyNotesMessage => '暂无笔记。创建您的第一条笔记!';

  @override
  String get deleteConfirmation => '确定要删除此笔记吗?';

  @override
  String get unsavedChangesWarning => '您有未保存的更改。要保存吗?';

  @override
  String get errorLoadingNotes => '加载笔记出错';

  @override
  String get errorSavingNote => '保存笔记出错';

  @override
  String get successDeletedNote => '笔记删除成功';

  @override
  String get successSavedNote => '笔记保存成功';

  @override
  String get successShareNote => '笔记分享成功';

  @override
  String get noteTitleHint => '标题';

  @override
  String get noteContentHint => '开始输入...';

  @override
  String noteCreatedDate(String date) {
    return '创建: $date';
  }

  @override
  String noteLastModified(String date) {
    return '最后修改: $date';
  }

  @override
  String get aboutApp => '关于我的笔记';

  @override
  String get version => '版本';

  @override
  String get privacyPolicy => '隐私政策';

  @override
  String get termsOfService => '服务条款';

  @override
  String get feedbackButton => '发送反馈';

  @override
  String get noResultsFound => '未找到结果';

  @override
  String get searchHint => '搜索笔记...';

  @override
  String get sortBy => '排序';

  @override
  String get filterBy => '筛选';

  @override
  String get allNotes => '所有笔记';

  @override
  String get pinnedNotes => '置顶笔记';

  @override
  String get archivedNotes => '归档笔记';

  @override
  String get deletedNotes => '已删除笔记';

  @override
  String get navigationHome => '首页';

  @override
  String get navigationSearch => '搜索';

  @override
  String get navigationFavorites => '收藏';

  @override
  String get navigationSettings => '设置';

  @override
  String get confirmDeleteTitle => '删除笔记?';

  @override
  String get confirmDeleteMessage => '此操作无法撤销。';

  @override
  String get selectLanguage => '选择语言';

  @override
  String get syncStatus => '同步状态';

  @override
  String get syncingNotes => '同步中...';

  @override
  String get syncComplete => '同步完成';

  @override
  String get offlineMode => '离线模式';

  @override
  String get onlineMode => '在线模式';
}
