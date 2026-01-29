import 'package:get_it/get_it.dart';
import 'package:sqflite/sqflite.dart';
import 'package:mynotes/data/datasources/database_helper.dart';
import 'package:mynotes/data/datasources/local/media_local_datasource.dart';
import 'package:mynotes/data/datasources/local/media_local_datasource_impl.dart';
import 'package:mynotes/data/datasources/local/smart_collection_local_datasource.dart';
import 'package:mynotes/data/datasources/local/smart_collection_local_datasource_impl.dart';
import 'package:mynotes/data/datasources/local/smart_reminder_local_datasource.dart';
import 'package:mynotes/data/datasources/local/smart_reminder_local_datasource_impl.dart';
import 'package:mynotes/data/datasources/local/reminder_template_local_datasource.dart';
import 'package:mynotes/data/datasources/local/reminder_template_local_datasource_impl.dart';
import 'package:mynotes/domain/repositories/media_repository.dart';
import 'package:mynotes/domain/repositories/smart_collection_repository.dart';
import 'package:mynotes/domain/repositories/smart_reminder_repository.dart';
import 'package:mynotes/domain/repositories/reminder_template_repository.dart';
import 'package:mynotes/data/repositories/media_repository_impl_v2.dart';
import 'package:mynotes/data/repositories/smart_collection_repository_impl.dart';
import 'package:mynotes/data/repositories/smart_reminder_repository_impl.dart';
import 'package:mynotes/data/repositories/reminder_template_repository_impl.dart';
import 'package:mynotes/presentation/bloc/media_gallery_bloc.dart';
import 'package:mynotes/presentation/bloc/smart_collections_bloc.dart';
import 'package:mynotes/presentation/bloc/smart_reminders_bloc.dart';
import 'package:mynotes/presentation/bloc/reminder_templates_bloc.dart';

/// GetIt service locator instance
final getIt = GetIt.instance;

/// Initialize all dependencies for dependency injection
Future<void> setupServiceLocator() async {
  // ==================== Database ====================
  final database = await DatabaseHelper.instance.database;
  getIt.registerSingleton<Database>(database);

  // ==================== LocalDataSources ====================

  /// Media LocalDataSource
  getIt.registerSingleton<MediaLocalDataSource>(
    MediaLocalDataSourceImpl(database: getIt<Database>()),
  );

  /// Smart Collection LocalDataSource
  getIt.registerSingleton<SmartCollectionLocalDataSource>(
    SmartCollectionLocalDataSourceImpl(database: getIt<Database>()),
  );

  /// Smart Reminder LocalDataSource
  getIt.registerSingleton<SmartReminderLocalDataSource>(
    SmartReminderLocalDataSourceImpl(database: getIt<Database>()),
  );

  /// Reminder Template LocalDataSource
  getIt.registerSingleton<ReminderTemplateLocalDataSource>(
    ReminderTemplateLocalDataSourceImpl(database: getIt<Database>()),
  );

  // ==================== Repositories ====================

  /// Media Repository
  getIt.registerSingleton<MediaRepository>(
    MediaRepositoryImpl(localDataSource: getIt<MediaLocalDataSource>()),
  );

  /// Smart Collection Repository
  getIt.registerSingleton<SmartCollectionRepository>(
    SmartCollectionRepositoryImpl(
      localDataSource: getIt<SmartCollectionLocalDataSource>(),
    ),
  );

  /// Smart Reminder Repository
  getIt.registerSingleton<SmartReminderRepository>(
    SmartReminderRepositoryImpl(
      localDataSource: getIt<SmartReminderLocalDataSource>(),
    ),
  );

  /// Reminder Template Repository
  getIt.registerSingleton<ReminderTemplateRepository>(
    ReminderTemplateRepositoryImpl(
      localDataSource: getIt<ReminderTemplateLocalDataSource>(),
    ),
  );

  // ==================== BLoCs ====================

  /// Media Gallery BLoC
  getIt.registerSingleton<MediaGalleryBloc>(
    MediaGalleryBloc(mediaRepository: getIt<MediaRepository>()),
  );

  /// Smart Collections BLoC
  getIt.registerSingleton<SmartCollectionsBloc>(
    SmartCollectionsBloc(
      smartCollectionRepository: getIt<SmartCollectionRepository>(),
    ),
  );

  /// Smart Reminders BLoC
  getIt.registerSingleton<SmartRemindersBloc>(
    SmartRemindersBloc(
      smartReminderRepository: getIt<SmartReminderRepository>(),
    ),
  );

  /// Reminder Templates BLoC
  getIt.registerSingleton<ReminderTemplatesBloc>(
    ReminderTemplatesBloc(
      reminderTemplateRepository: getIt<ReminderTemplateRepository>(),
    ),
  );
}

/// Get registered BLoCs
/// Usage: Use in main.dart or MultiRepositoryProvider/MultiBlocProvider

/// Media Gallery BLoC getter
MediaGalleryBloc getMediaGalleryBloc() => getIt<MediaGalleryBloc>();

/// Smart Collections BLoC getter
SmartCollectionsBloc getSmartCollectionsBloc() => getIt<SmartCollectionsBloc>();

/// Smart Reminders BLoC getter
SmartRemindersBloc getSmartRemindersBloc() => getIt<SmartRemindersBloc>();

/// Reminder Templates BLoC getter
ReminderTemplatesBloc getReminderTemplatesBloc() =>
    getIt<ReminderTemplatesBloc>();

/// Get registered Repositories
/// Usage: Can use these directly if needed

/// Media Repository getter
MediaRepository getMediaRepository() => getIt<MediaRepository>();

/// Smart Collection Repository getter
SmartCollectionRepository getSmartCollectionRepository() =>
    getIt<SmartCollectionRepository>();

/// Smart Reminder Repository getter
SmartReminderRepository getSmartReminderRepository() =>
    getIt<SmartReminderRepository>();

/// Reminder Template Repository getter
ReminderTemplateRepository getReminderTemplateRepository() =>
    getIt<ReminderTemplateRepository>();
