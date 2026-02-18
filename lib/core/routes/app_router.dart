import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mynotes/domain/entities/note.dart';
import 'package:mynotes/presentation/bloc/note/note_bloc.dart' show NotesBloc;
import 'package:mynotes/presentation/bloc/note/note_event.dart'
    show LoadArchivedNotesEvent;
import 'package:mynotes/presentation/pages/enhanced_notes_list_screen.dart';
import 'package:mynotes/presentation/pages/enhanced_todos_list_screen_refactored.dart';
import 'package:mynotes/presentation/pages/search_filter_screen.dart'
    show SearchFilterScreen;
import 'package:mynotes/presentation/widgets/create_alarm_bottom_sheet.dart';
import 'package:mynotes/domain/entities/todo_item.dart';
import 'package:mynotes/presentation/pages/splash_screen.dart';
import 'package:mynotes/presentation/pages/onboarding_screen.dart';
import 'package:mynotes/presentation/pages/today_dashboard_screen.dart';
import 'package:mynotes/presentation/pages/main_home_screen.dart';
// import 'package:mynotes/presentation/pages/enhanced_notes_list_screen.dart';
import 'package:mynotes/presentation/pages/enhanced_note_editor_screen.dart';
import 'package:mynotes/presentation/pages/enhanced_reminders_list_screen.dart';
// import 'package:mynotes/presentation/screens/todos_screen_fixed.dart';
import 'package:mynotes/presentation/pages/todo_focus_screen.dart';
import 'package:mynotes/presentation/pages/advanced_todo_screen.dart';
import 'package:mynotes/presentation/pages/settings_screen.dart';
import 'package:mynotes/presentation/pages/analytics_dashboard_screen.dart';
import 'package:mynotes/presentation/pages/global_search_screen.dart';
// import 'package:mynotes/presentation/pages/search_filter_screen.dart';
import 'package:mynotes/presentation/pages/media_viewer_screen.dart';
import 'package:mynotes/presentation/pages/media_picker_screen.dart';
import 'package:mynotes/presentation/pages/audio_recorder_screen.dart';
import 'package:mynotes/presentation/pages/pdf_preview_screen.dart';
import 'package:mynotes/presentation/pages/biometric_lock_screen.dart';
import 'package:mynotes/presentation/pages/pin_setup_screen.dart';
import 'package:mynotes/presentation/pages/focus_session_screen.dart';
import 'package:mynotes/presentation/pages/focus_celebration_screen.dart';
import 'package:mynotes/presentation/pages/document_scan_screen.dart';
import 'package:mynotes/presentation/pages/drawing_canvas_screen.dart';
import 'package:mynotes/presentation/pages/backup_export_screen.dart';
import 'package:mynotes/presentation/pages/calendar_integration_screen.dart';
import 'package:mynotes/presentation/pages/voice_settings_screen.dart';
import 'package:mynotes/presentation/pages/font_settings_screen.dart';
import 'package:mynotes/presentation/pages/edit_daily_highlight_screen_new.dart';

import 'package:mynotes/presentation/pages/empty_state_notes_help_screen.dart';
import 'package:mynotes/presentation/pages/empty_state_todos_help_screen.dart';
import 'package:mynotes/presentation/pages/recurring_todo_schedule_screen.dart';
import 'package:mynotes/presentation/pages/ocr_text_extraction_screen.dart';
import 'package:mynotes/presentation/screens/reflection_home_screen.dart';
import 'package:mynotes/presentation/pages/home_widgets_screen.dart';
import 'package:mynotes/presentation/pages/integrated_features_screen.dart';
import 'package:mynotes/presentation/widgets/quick_add_bottom_sheet.dart';
import 'package:mynotes/presentation/widgets/global_command_palette.dart';
import 'package:mynotes/domain/entities/alarm.dart';
import 'app_routes.dart';
import 'package:mynotes/presentation/pages/media_filter_screen.dart';
import 'package:mynotes/presentation/pages/batch_4_media_organization_view.dart';
import 'package:mynotes/presentation/pages/batch_4_media_search_results.dart';
import 'package:mynotes/presentation/pages/media_analytics_dashboard.dart';
import 'package:mynotes/presentation/pages/batch_5_create_collection_wizard.dart';
import 'package:mynotes/presentation/pages/batch_5_rule_builder_screen.dart';
import 'package:mynotes/presentation/pages/batch_5_collection_details_screen.dart';
import 'package:mynotes/presentation/pages/batch_5_collection_management_screen.dart';
import 'package:mynotes/presentation/pages/batch_6_suggestion_recommendations_screen.dart';
import 'package:mynotes/presentation/pages/batch_6_reminder_patterns_dashboard.dart';
import 'package:mynotes/presentation/pages/batch_6_frequency_analytics_screen.dart';
import 'package:mynotes/presentation/pages/batch_6_engagement_metrics_screen.dart';
import 'package:mynotes/presentation/pages/batch_7_template_gallery_screen.dart';
import 'package:mynotes/presentation/pages/batch_7_template_editor_screen.dart';
import 'package:mynotes/presentation/pages/batch_8_advanced_search_screen.dart';
import 'package:mynotes/presentation/pages/batch_8_search_results_screen.dart';

// Missing Routes Imports
import 'package:mynotes/presentation/pages/archived_notes_screen.dart';
import 'package:mynotes/presentation/pages/smart_collections_screen.dart';
import 'package:mynotes/presentation/pages/smart_reminders_screen.dart';
import 'package:mynotes/presentation/pages/location_reminder_screen.dart';
import 'package:mynotes/presentation/pages/saved_locations_screen.dart';
import 'package:mynotes/presentation/pages/active_alarms_screen.dart';
import 'package:mynotes/presentation/pages/alarm_reschedule_screen.dart';
import 'package:mynotes/presentation/pages/snooze_confirmation_screen.dart';
import 'package:mynotes/presentation/pages/dismiss_confirmation_screen.dart';
import 'package:mynotes/presentation/pages/reminder_templates_screen.dart';
import 'package:mynotes/presentation/pages/full_media_gallery_screen.dart';
import 'package:mynotes/presentation/pages/video_trimming_screen.dart';
import 'package:mynotes/presentation/pages/advanced_settings_screen.dart';
import 'package:mynotes/presentation/pages/tag_management_screen.dart';
import 'package:mynotes/presentation/pages/pdf_annotation_screen.dart';
import 'package:mynotes/presentation/screens/answer_screen.dart';
import 'package:mynotes/presentation/screens/reflection_history_screen.dart';
import 'package:mynotes/presentation/screens/carousel_reflection_screen.dart';
import 'package:mynotes/presentation/screens/question_list_screen.dart';
import 'package:mynotes/presentation/pages/advanced_filters_screen.dart';
import 'package:mynotes/presentation/pages/search_operators_screen.dart';
import 'package:mynotes/presentation/pages/sort_customization_screen.dart';
import 'package:mynotes/presentation/pages/quick_add_confirmation_screen.dart';
import 'package:mynotes/presentation/pages/fixed_universal_quick_add_screen.dart';
import 'package:mynotes/presentation/pages/unified_items_screen.dart';
import 'package:mynotes/domain/entities/reflection_question.dart';
import 'package:mynotes/presentation/pages/daily_focus_highlight_screen.dart';
import 'package:mynotes/presentation/pages/export_options_screen.dart';

import 'package:mynotes/core/services/app_logger.dart';

class AppRouter {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    AppLogger.i('Navigating to route: ${settings.name}');
    switch (settings.name) {
      case AppRoutes.splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());

      case AppRoutes.onboarding:
        return MaterialPageRoute(builder: (_) => const OnboardingScreen());

      case AppRoutes.home:
        final args = settings.arguments;
        return MaterialPageRoute(
          builder: (_) => MainHomeScreen(initialIndex: args is int ? args : 0),
        );

      case AppRoutes.todayDashboard:
        return MaterialPageRoute(builder: (_) => const TodayDashboardScreen());

      case AppRoutes.mainHome:
        final args = settings.arguments;
        return MaterialPageRoute(
          builder: (_) => MainHomeScreen(initialIndex: args is int ? args : 0),
        );

      // ==================== Notes Module ====================
      case AppRoutes.notesList:
        return MaterialPageRoute(
          builder: (_) => const EnhancedNotesListScreen(),
        );

      case AppRoutes.noteEditor:
      case AppRoutes.advancedNoteEditor:
      case AppRoutes.markdownNoteEditor:
        final args = settings.arguments;
        if (args is Note) {
          return MaterialPageRoute(
            builder: (_) => EnhancedNoteEditorScreen(note: args),
          );
        } else if (args is Map<String, dynamic>) {
          return MaterialPageRoute(
            builder: (_) => EnhancedNoteEditorScreen(
              note: args['note'],
              template: args['template'],
              initialContent: args['initialContent'] ?? args['content'],
            ),
          );
        }
        return MaterialPageRoute(
          builder: (_) => const EnhancedNoteEditorScreen(),
        );

      case AppRoutes.archivedNotes:
        return MaterialPageRoute(
          builder: (context) {
            // Trigger load when navigating directly to Archive
            context.read<NotesBloc>().add(const LoadArchivedNotesEvent());
            return const ArchivedNotesScreen();
          },
        );

      // ==================== Smart Collections Module ====================
      case AppRoutes.smartCollections:
        return MaterialPageRoute(
          builder: (_) => const SmartCollectionsScreen(),
        );

      case AppRoutes.createCollection:
        return MaterialPageRoute(
          builder: (_) => const CreateSmartCollectionWizard(),
        );

      case AppRoutes.ruleBuilder:
        return MaterialPageRoute(builder: (_) => const RuleBuilderScreen());

      case AppRoutes.collectionDetails:
        final args = settings.arguments;
        return MaterialPageRoute(
          builder: (_) => CollectionDetailsScreen(
            collection: args is Map<String, dynamic> ? args : const {},
          ),
        );

      case AppRoutes.collectionManagement:
        return MaterialPageRoute(
          builder: (_) => const CollectionManagementScreen(),
        );

      // ==================== Media Module ====================
      case AppRoutes.mediaPicker:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => MediaPickerScreen(
            mediaType: args?['mediaType'] ?? 'all',
            multiSelect: args?['multiSelect'] ?? true,
            maxSelection: args?['maxSelection'] ?? 10,
          ),
        );

      case AppRoutes.audioRecorder:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => AudioRecorderScreen(noteId: args?['noteId']),
        );

      case AppRoutes.fullMediaGallery:
        return MaterialPageRoute(
          builder: (_) => const FullMediaGalleryScreen(),
        );

      case AppRoutes.videoTrimming:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => VideoTrimmingScreen(
            videoPath: args['videoPath'],
            videoTitle: args['videoTitle'] ?? 'Video',
          ),
        );

      case AppRoutes.mediaViewer:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => MediaViewerScreen(
            mediaItems: args['mediaItems'] ?? [],
            initialIndex: args['index'] ?? 0,
          ),
        );

      case AppRoutes.mediaFilter:
        return MaterialPageRoute(
          builder: (_) => const AdvancedMediaFilterScreen(),
        );

      case AppRoutes.mediaOrganization:
        return MaterialPageRoute(builder: (_) => const MediaOrganizationView());

      case AppRoutes.mediaSearchResults:
        final args = settings.arguments;
        return MaterialPageRoute(
          builder: (_) =>
              MediaSearchResultsScreen(query: args is String ? args : ''),
        );

      case AppRoutes.mediaAnalytics:
        return MaterialPageRoute(
          builder: (_) => const MediaAnalyticsDashboard(),
        );

      // ==================== Reminders Module ====================
      case AppRoutes.remindersList:
        return MaterialPageRoute(
          builder: (_) => const EnhancedRemindersListScreen(),
        );

      case AppRoutes.createReminder:
        return PageRouteBuilder(
          opaque: false,
          pageBuilder: (context, _, __) => const SizedBox(),
          transitionsBuilder: (context, _, __, child) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (context) => const CreateAlarmBottomSheet(),
              );
            });
            return child;
          },
        );

      case AppRoutes.editReminder:
        final args = settings.arguments;
        return PageRouteBuilder(
          opaque: false,
          pageBuilder: (context, _, __) => const SizedBox(),
          transitionsBuilder: (context, _, __, child) {
            if (args is Alarm) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) => CreateAlarmBottomSheet(alarm: args),
                );
              });
            }
            return child;
          },
        );

      case AppRoutes.calendarIntegration:
        return MaterialPageRoute(
          builder: (_) => const CalendarIntegrationScreen(),
        );

      case AppRoutes.smartReminders:
        return MaterialPageRoute(builder: (_) => const SmartRemindersScreen());

      case AppRoutes.locationReminder:
        return MaterialPageRoute(
          builder: (_) => const LocationReminderScreen(),
        );

      case AppRoutes.savedLocations:
        return MaterialPageRoute(builder: (_) => const SavedLocationsScreen());

      case AppRoutes.alarms:
        return MaterialPageRoute(
          builder: (_) => const EnhancedRemindersListScreen(),
        );

      case AppRoutes.activeAlarms:
        return MaterialPageRoute(builder: (_) => const ActiveAlarmsScreen());

      case AppRoutes.rescheduleAlarm:
        final alarm = settings.arguments;
        return MaterialPageRoute(
          builder: (_) => AlarmRescheduleScreen(alarm: alarm),
        );

      case AppRoutes.snoozeConfirmation:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => SnoozeConfirmationScreen(
            alarm: args['alarm'],
            snoozeUntil: args['snoozeUntil'],
            snoozeMinutes: args['snoozeMinutes'],
          ),
        );

      case AppRoutes.dismissConfirmation:
        final alarm = settings.arguments;
        return MaterialPageRoute(
          builder: (_) => DismissConfirmationScreen(alarm: alarm),
        );

      case AppRoutes.reminderTemplates:
        return MaterialPageRoute(
          builder: (_) => const ReminderTemplatesScreen(),
        );

      case AppRoutes.suggestionRecommendations:
        return MaterialPageRoute(
          builder: (_) => const SuggestionRecommendationsScreen(),
        );

      case AppRoutes.reminderPatterns:
        return MaterialPageRoute(
          builder: (_) => const ReminderPatternsDashboard(),
        );

      case AppRoutes.frequencyAnalytics:
        return MaterialPageRoute(
          builder: (_) => const FrequencyAnalyticsScreen(),
        );

      case AppRoutes.engagementMetrics:
        return MaterialPageRoute(
          builder: (_) => const EngagementMetricsScreen(),
        );

      case AppRoutes.locationReminderComingSoon:
        return MaterialPageRoute(
          builder: (_) => const LocationReminderScreen(),
        );

      // ==================== Todos Module ====================
      case AppRoutes.todosList:
        return MaterialPageRoute(
          builder: (_) => const EnhancedTodosListScreenRefactored(),
        );
      case AppRoutes.todoEditor:
        final args = settings.arguments;
        if (args is TodoItem) {
          return MaterialPageRoute(
            builder: (_) => AdvancedTodoScreen(todo: args),
          );
        }
        // For creating a new todo, use the route_generator's placeholder
        // This will be handled by route_generator.dart
        return MaterialPageRoute(builder: (_) => const Placeholder());

      case AppRoutes.todoFocus:
        final args = settings.arguments;
        if (args is Note) {
          return MaterialPageRoute(builder: (_) => TodoFocusScreen(note: args));
        }
        return _errorRoute();

      case AppRoutes.advancedTodo:
        final args = settings.arguments;
        if (args is TodoItem) {
          return MaterialPageRoute(
            builder: (_) => AdvancedTodoScreen(todo: args),
          );
        }
        return _errorRoute();

      case AppRoutes.recurringTodoSchedule:
        return MaterialPageRoute(
          builder: (_) => const RecurringTodoScheduleScreen(),
        );

      case AppRoutes.emptyStateTodosHelp:
        return MaterialPageRoute(
          builder: (_) => const EmptyStateTodosHelpScreen(),
        );

      // ==================== App Settings & Privacy ====================
      case AppRoutes.settings:
      case AppRoutes.appSettings:
        return MaterialPageRoute(builder: (_) => const SettingsScreen());

      case AppRoutes.advancedSettings:
        return MaterialPageRoute(
          builder: (_) => const AdvancedSettingsScreen(),
        );

      case AppRoutes.voiceSettings:
        return MaterialPageRoute(builder: (_) => const VoiceSettingsScreen());

      case AppRoutes.fontSettings:
        return MaterialPageRoute(builder: (_) => const FontSettingsScreen());

      case AppRoutes.tagManagement:
        return MaterialPageRoute(builder: (_) => const TagManagementScreen());

      case AppRoutes.biometricLock:
        return MaterialPageRoute(builder: (_) => const BiometricLockScreen());

      case AppRoutes.pinSetup:
        final args = settings.arguments as Map<String, dynamic>? ?? {};
        return MaterialPageRoute(
          builder: (_) => PinSetupScreen(
            isFirstSetup: args['isFirstSetup'] ?? false,
            isChanging: args['isChanging'] ?? false,
          ),
        );

      case AppRoutes.backupExport:
        return MaterialPageRoute(builder: (_) => const BackupExportScreen());

      case AppRoutes.exportOptions:
        final args = settings.arguments as Map<String, dynamic>? ?? {};
        return MaterialPageRoute(
          builder: (_) => ExportOptionsScreen(
            itemTitle: args['title'] as String?,
            itemContent: args['content'] as String?,
            tags: args['tags'] as List<String>?,
          ),
        );

      // ==================== Reflection Module ======================
      case AppRoutes.analytics:
        return MaterialPageRoute(
          builder: (_) => const AnalyticsDashboardScreen(),
        );

      case AppRoutes.reflection:
      case AppRoutes.reflectionHome:
        return MaterialPageRoute(builder: (_) => const ReflectionHomeScreen());

      case AppRoutes.reflectionAnswer:
        final args = settings.arguments;
        if (args is ReflectionQuestion) {
          return MaterialPageRoute(
            builder: (_) => AnswerScreen(question: args),
          );
        }
        return _errorRoute();

      case AppRoutes.reflectionHistory:
        return MaterialPageRoute(
          builder: (_) => const ReflectionHistoryScreen(),
        );

      case AppRoutes.reflectionCarousel:
        return MaterialPageRoute(
          builder: (_) => const CarouselReflectionScreen(),
        );

      case AppRoutes.reflectionQuestions:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => QuestionListScreen(
            category: args['category'] ?? 'general',
            categoryLabel: args['categoryLabel'] ?? 'General',
          ),
        );

      // ==================== Search Module ====================
      case AppRoutes.search:
      case AppRoutes.globalSearch:
        return MaterialPageRoute(builder: (_) => const GlobalSearchScreen());

      case AppRoutes.searchFilter:
        return MaterialPageRoute(builder: (_) => const SearchFilterScreen());

      case AppRoutes.advancedSearch:
        return MaterialPageRoute(builder: (_) => const AdvancedSearchScreen());

      case AppRoutes.searchResults:
        final args = settings.arguments;
        return MaterialPageRoute(
          builder: (_) =>
              SearchResultsScreen(searchQuery: args is String ? args : ''),
        );

      case AppRoutes.advancedFilters:
        return MaterialPageRoute(builder: (_) => const AdvancedFiltersScreen());

      case AppRoutes.searchOperators:
        return MaterialPageRoute(builder: (_) => const SearchOperatorsScreen());

      case AppRoutes.sortCustomization:
        return MaterialPageRoute(
          builder: (_) => const SortCustomizationScreen(),
        );

      // ==================== Focus & Productivity ====================
      case AppRoutes.focusSession:
        return MaterialPageRoute(builder: (_) => const FocusSessionScreen());

      case AppRoutes.focusCelebration:
        return MaterialPageRoute(
          builder: (_) => const FocusCelebrationScreen(),
        );

      case AppRoutes.dailyHighlightSummary:
        return MaterialPageRoute(
          builder: (_) => const DailyFocusHighlightScreen(),
        );

      case AppRoutes.editDailyHighlight:
        return MaterialPageRoute(
          builder: (_) => const EditDailyHighlightScreen(),
        );

      case AppRoutes.homeWidgets:
        return MaterialPageRoute(builder: (_) => const HomeWidgetsScreen());

      // ==================== Document & Scanning ====================
      case AppRoutes.documentScan:
        return MaterialPageRoute(builder: (_) => const DocumentScanScreen());

      case AppRoutes.drawingCanvas:
        return MaterialPageRoute(builder: (_) => const DrawingCanvasScreen());

      case AppRoutes.pdfAnnotation:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => PDFAnnotationScreen(
            pdfPath: args['pdfPath'],
            pdfTitle: args['pdfTitle'] ?? 'PDF Document',
          ),
        );

      case AppRoutes.pdfPreview:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => PdfPreviewScreen(note: args['note']),
        );

      case AppRoutes.ocrExtraction:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => OcrTextExtractionScreen(
            documentImagePath: args?['documentImagePath'],
            extractedText: args?['extractedText'],
          ),
        );

      // ==================== Quick Actions ====================
      case AppRoutes.quickAdd:
        final args = settings.arguments as BuildContext?;
        return PageRouteBuilder(
          pageBuilder: (context, animation, _) => Container(), // Placeholder
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            if (args != null) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                showModalBottomSheet(
                  context: args,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) => const QuickAddBottomSheet(),
                );
              });
            }
            return const SizedBox.shrink();
          },
        );

      case AppRoutes.commandPalette:
        final args = settings.arguments as BuildContext?;
        return PageRouteBuilder(
          pageBuilder: (context, animation, _) => Container(), // Placeholder
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            if (args != null) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                showGlobalCommandPalette(args);
              });
            }
            return const SizedBox.shrink();
          },
        );

      case AppRoutes.quickAddConfirmation:
        final args = settings.arguments as Map<String, dynamic>? ?? {};
        return MaterialPageRoute(
          builder: (_) => QuickAddConfirmationScreen(
            noteId: args['noteId'] as String? ?? '',
            title: args['title'] as String? ?? '',
            type: args['type'] as String? ?? 'note',
          ),
        );

      case AppRoutes.universalQuickAdd:
        return MaterialPageRoute(
          builder: (_) => const FixedUniversalQuickAddScreen(),
        );

      case AppRoutes.unifiedItems:
        return MaterialPageRoute(builder: (_) => const UnifiedItemsScreen());

      // ==================== Templates ====================
      case AppRoutes.templateGallery:
        return MaterialPageRoute(builder: (_) => const TemplateGalleryScreen());

      case AppRoutes.templateEditor:
        return MaterialPageRoute(builder: (_) => const TemplateEditorScreen());

      // ==================== Other ====================
      case AppRoutes.integratedFeatures:
        return MaterialPageRoute(
          builder: (_) => const IntegratedFeaturesScreen(),
        );

      case AppRoutes.emptyStateNotesHelp:
        return MaterialPageRoute(
          builder: (_) => const EmptyStateNotesHelpScreen(),
        );

      default:
        return _errorRoute();
    }
  }

  static Route<dynamic> _errorRoute() {
    AppLogger.e('Navigation error: Route not found.');
    return MaterialPageRoute(
      builder: (_) => Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: const Center(child: Text('Page not found')),
      ),
    );
  }
}
