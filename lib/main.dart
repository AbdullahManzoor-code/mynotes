import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'core/routes/app_routes.dart';
import 'core/routes/app_router.dart';
import 'core/notifications/notification_service.dart';
import 'core/services/clipboard_service.dart';
import 'core/constants/app_constants.dart';
import 'core/themes/app_theme.dart';

import 'domain/repositories/note_repository.dart';
import 'domain/repositories/media_repository.dart';
import 'domain/repositories/reflection_repository.dart';

import 'data/datasources/local_database.dart';
import 'data/repositories/note_repository_impl.dart';
import 'data/repositories/media_repository_impl.dart';
import 'data/repositories/reflection_repository_impl.dart';

import 'presentation/bloc/theme_bloc.dart';
import 'presentation/bloc/theme_event.dart';
import 'presentation/bloc/theme_state.dart';
import 'presentation/bloc/note_bloc.dart';
import 'presentation/bloc/media_bloc.dart';
import 'presentation/bloc/reflection_bloc.dart';
import 'presentation/bloc/alarm_bloc.dart';
import 'presentation/bloc/todo_bloc.dart';
import 'presentation/bloc/todos_bloc.dart';
import 'presentation/widgets/global_error_handler_listener.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize database factory ONLY for desktop platforms (Windows/Linux/Mac)
  if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  // Initialize database
  final database = NotesDatabase();

  // Initialize notification service
  final notificationService = NotificationService();
  await notificationService.init();

  runApp(
    MyNotesApp(database: database, notificationService: notificationService),
  );
}

class MyNotesApp extends StatelessWidget {
  final NotesDatabase database;
  final NotificationService notificationService;
  final ClipboardService _clipboardService = ClipboardService();

  MyNotesApp({
    super.key,
    required this.database,
    required this.notificationService,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // Provide repositories and services
        RepositoryProvider<NoteRepository>(
          create: (context) => NoteRepositoryImpl(database: database),
        ),
        RepositoryProvider<MediaRepository>(
          create: (context) => MediaRepositoryImpl(database: database),
        ),
        RepositoryProvider<ReflectionRepository>(
          create: (context) => ReflectionRepositoryImpl(database),
        ),
        RepositoryProvider<ClipboardService>(
          create: (context) => _clipboardService,
        ),
        RepositoryProvider<NotificationService>(
          create: (context) => notificationService,
        ),

        // Provide BLoCs
        BlocProvider<ThemeBloc>(
          create: (context) => ThemeBloc()..add(const LoadThemeEvent()),
        ),
        BlocProvider<NotesBloc>(
          create: (context) =>
              NotesBloc(noteRepository: context.read<NoteRepository>()),
        ),
        BlocProvider<MediaBloc>(
          create: (context) =>
              MediaBloc(repository: context.read<MediaRepository>()),
        ),
        BlocProvider<ReflectionBloc>(
          create: (context) =>
              ReflectionBloc(repository: context.read<ReflectionRepository>()),
        ),
        BlocProvider<AlarmBloc>(
          create: (context) => AlarmBloc(
            noteRepository: context.read<NoteRepository>(),
            notificationService: context.read<NotificationService>(),
          ),
        ),
        BlocProvider<TodoBloc>(
          create: (context) =>
              TodoBloc(noteRepository: context.read<NoteRepository>()),
        ),
        BlocProvider<TodosBloc>(
          create: (context) => TodosBloc()..add(LoadTodos()),
        ),
      ],
      child: BlocBuilder<ThemeBloc, ThemeState>(
        builder: (context, themeState) {
          return ScreenUtilInit(
            designSize: const Size(375, 812),
            minTextAdapt: true,
            splitScreenMode: true,
            builder: (context, child) {
              return _TextScalingWrapper(
                child: GlobalErrorHandlerListener(
                  child: MaterialApp(
                    title: AppConstants.appName,
                    debugShowCheckedModeBanner: false,
                    theme: AppTheme.lightTheme,
                    darkTheme: AppTheme.darkTheme,
                    themeMode: themeState.themeMode,
                    initialRoute: AppRoutes.splash,
                    onGenerateRoute: AppRouter.onGenerateRoute,
                    // Accessibility features
                    showSemanticsDebugger: false,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

/// Wrapper widget to support text scaling up to 200%
class _TextScalingWrapper extends StatelessWidget {
  final Widget child;

  const _TextScalingWrapper({required this.child});

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(
        textScaleFactor: MediaQuery.of(context).textScaleFactor > 2.0
            ? 2.0
            : MediaQuery.of(context).textScaleFactor,
      ),
      child: child,
    );
  }
}
