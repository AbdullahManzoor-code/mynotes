import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/repositories/stats_repository.dart';
import '../../domain/entities/focus_session.dart';
import '../widgets/universal_item_card.dart';

part 'analytics_event.dart';
part 'analytics_state.dart';

class AnalyticsBloc extends Bloc<AnalyticsEvent, AnalyticsState> {
  final StatsRepository repository;

  AnalyticsBloc({required this.repository}) : super(const AnalyticsInitial()) {
    on<LoadAnalyticsEvent>(_onLoadAnalytics);
    on<RefreshAnalyticsEvent>(_onRefreshAnalytics);
    on<RecordFocusSessionEvent>(_onRecordFocusSession);

    // Legacy mapping
    on<LoadMoodAnalyticsEvent>((event, emit) async {
      emit(const MoodAnalyticsLoaded({'General': 1}));
    });
  }

  Future<void> _onLoadAnalytics(
    LoadAnalyticsEvent event,
    Emitter<AnalyticsState> emit,
  ) async {
    emit(const AnalyticsLoading());
    await _fetchAndEmitStats(emit);
  }

  Future<void> _onRefreshAnalytics(
    RefreshAnalyticsEvent event,
    Emitter<AnalyticsState> emit,
  ) async {
    await _fetchAndEmitStats(emit);
  }

  Future<void> _onRecordFocusSession(
    RecordFocusSessionEvent event,
    Emitter<AnalyticsState> emit,
  ) async {
    try {
      await repository.saveFocusSession(event.session);
      await _fetchAndEmitStats(emit);
    } catch (e) {
      emit(AnalyticsError(e.toString()));
    }
  }

  Future<void> _fetchAndEmitStats(Emitter<AnalyticsState> emit) async {
    try {
      final results = await Future.wait([
        repository.getItemCounts(),
        repository.getWeeklyActivity(),
        repository.getCategoryBreakdown(),
        repository.getProductivityInsights(),
        repository.getCurrentStreak(),
        repository.getRecentItems(),
        repository.getOverdueReminders(),
        repository.getDailyHighlights(),
      ]);

      final recentItemsRaw = results[5] as List<Map<String, dynamic>>;
      final overdueItemsRaw = results[6] as List<Map<String, dynamic>>;
      final highlights = results[7] as List<String>;

      emit(
        AnalyticsLoaded(
          itemCounts: results[0] as Map<String, int>,
          weeklyActivity: results[1] as Map<String, double>,
          categoryBreakdown: results[2] as List<Map<String, dynamic>>,
          productivityInsights: results[3] as Map<String, dynamic>,
          streak: results[4] as int,
          recentItems: recentItemsRaw
              .map((m) => UniversalItem.fromMap(m))
              .toList(),
          overdueItems: overdueItemsRaw
              .map((m) => UniversalItem.fromMap(m))
              .toList(),
          dailyHighlights: highlights,
        ),
      );
    } catch (e) {
      emit(AnalyticsError('Failed to load analytics: ${e.toString()}'));
    }
  }
}
