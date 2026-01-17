import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'core/constants/app_constants.dart';
import 'core/themes/app_theme.dart';
import 'core/services/clipboard_service.dart';
import 'data/datasources/local_database.dart';
import 'data/repositories/note_repository_impl.dart';
import 'data/repositories/media_repository_impl.dart';
import 'domain/repositories/note_repository.dart';
import 'domain/repositories/media_repository.dart';
import 'presentation/bloc/media_bloc.dart';
import 'presentation/bloc/note_bloc.dart';
import 'presentation/bloc/theme_bloc.dart';
import 'presentation/bloc/theme_event.dart';
import 'presentation/bloc/theme_state.dart';
import 'presentation/pages/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize database factory for Windows/Linux/Mac desktop
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  // Initialize database
  final database = NotesDatabase();

  runApp(MyNotesApp(database: database));
}

class MyNotesApp extends StatelessWidget {
  final NotesDatabase database;
  final ClipboardService _clipboardService = ClipboardService();

  MyNotesApp({Key? key, required this.database}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // Provide repositories
        RepositoryProvider<NoteRepository>(
          create: (context) => NoteRepositoryImpl(database: database),
        ),
        RepositoryProvider<MediaRepository>(
          create: (context) => MediaRepositoryImpl(database: database),
        ),
        // Provide services
        RepositoryProvider<ClipboardService>(
          create: (context) => _clipboardService,
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
      ],
      child: BlocBuilder<ThemeBloc, ThemeState>(
        builder: (context, themeState) {
          return ScreenUtilInit(
            designSize: const Size(375, 812),
            minTextAdapt: true,
            splitScreenMode: true,
            builder: (context, child) {
              return MaterialApp(
                title: AppConstants.appName,
                debugShowCheckedModeBanner: false,
                theme: AppTheme.lightTheme,
                darkTheme: AppTheme.darkTheme,
                themeMode: themeState.themeMode,
                home: SplashScreen(clipboardService: _clipboardService),
              );
            },
          );
        },
      ),
    );
  }
}
