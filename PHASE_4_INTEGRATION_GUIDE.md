# Phase 4 Services - Integration Guide

**Quick Reference for Integrating Phase 4 Services into BLoCs and UI**

---

## 1. Quick Start

### Import Services

```dart
import 'package:mynotes/domain/services/media_filtering_service.dart';
import 'package:mynotes/domain/services/rule_evaluation_engine.dart';
import 'package:mynotes/domain/services/ai_suggestion_engine.dart';
import 'package:mynotes/domain/services/template_conversion_service.dart';
import 'package:mynotes/domain/services/advanced_search_ranking_service.dart';
```

### Create Service Instances

```dart
// All services use singleton pattern
final filtering = MediaFilteringService();
final rules = RuleEvaluationEngine();
final aiEngine = AISuggestionEngine();
final templates = TemplateConversionService();
final search = AdvancedSearchRankingService();
```

---

## 2. MediaFilteringService Integration

### In MediaGalleryBloc

```dart
class MediaGalleryBloc extends Bloc<MediaGalleryEvent, MediaGalleryState> {
  final MediaRepository _repository;
  final MediaFilteringService _filtering = MediaFilteringService();

  MediaGalleryBloc(this._repository) : super(MediaGalleryInitial()) {
    on<FilterMediaEvent>(_onFilterMedia);
    on<SearchMediaEvent>(_onSearchMedia);
    on<GetMediaAnalyticsEvent>(_onGetAnalytics);
  }

  Future<void> _onFilterMedia(
    FilterMediaEvent event,
    Emitter<MediaGalleryState> emit,
  ) async {
    try {
      emit(MediaGalleryLoading());
      
      final allMedia = await _repository.getAllMedia();
      
      final filtered = await _filtering.advancedFilter(
        mediaItems: allMedia,
        typeFilter: event.typeFilter,
        fromDate: event.fromDate,
        toDate: event.toDate,
        minSizeBytes: event.minSizeBytes,
        maxSizeBytes: event.maxSizeBytes,
        tags: event.tags,
        excludeArchived: true,
      );
      
      emit(MediaGalleryLoaded(mediaItems: filtered));
    } catch (e) {
      emit(MediaGalleryError(message: 'Filter failed: ${e.toString()}'));
    }
  }

  Future<void> _onSearchMedia(
    SearchMediaEvent event,
    Emitter<MediaGalleryState> emit,
  ) async {
    try {
      emit(MediaGalleryLoading());
      
      final allMedia = await _repository.getAllMedia();
      
      final results = await _filtering.smartSearch(
        allMedia,
        event.query,
        fuzzyMatch: true,
        boostRecent: true,
      );
      
      emit(MediaGalleryLoaded(mediaItems: results.map((r) => r).toList()));
    } catch (e) {
      emit(MediaGalleryError(message: 'Search failed: ${e.toString()}'));
    }
  }

  Future<void> _onGetAnalytics(
    GetMediaAnalyticsEvent event,
    Emitter<MediaGalleryState> emit,
  ) async {
    try {
      final allMedia = await _repository.getAllMedia();
      final analytics = await _filtering.getMediaAnalytics(allMedia);
      
      // Emit custom state with analytics
      emit(MediaGalleryAnalytics(analytics: analytics));
    } catch (e) {
      emit(MediaGalleryError(message: 'Analytics failed: ${e.toString()}'));
    }
  }
}
```

### Events to Add

```dart
class FilterMediaEvent extends MediaGalleryEvent {
  final String? typeFilter;
  final DateTime? fromDate;
  final DateTime? toDate;
  final int? minSizeBytes;
  final int? maxSizeBytes;
  final List<String>? tags;

  FilterMediaEvent({
    this.typeFilter,
    this.fromDate,
    this.toDate,
    this.minSizeBytes,
    this.maxSizeBytes,
    this.tags,
  });
}

class SearchMediaEvent extends MediaGalleryEvent {
  final String query;

  SearchMediaEvent(this.query);
}

class GetMediaAnalyticsEvent extends MediaGalleryEvent {}
```

---

## 3. RuleEvaluationEngine Integration

### In SmartCollectionsBloc

```dart
class SmartCollectionsBloc extends Bloc<SmartCollectionsEvent, SmartCollectionsState> {
  final SmartCollectionRepository _repository;
  final RuleEvaluationEngine _ruleEngine = RuleEvaluationEngine();

  SmartCollectionsBloc(this._repository) : super(SmartCollectionsInitial()) {
    on<CreateCollectionEvent>(_onCreateCollection);
    on<UpdateCollectionEvent>(_onUpdateCollection);
    on<ApplyRulesEvent>(_onApplyRules);
  }

  Future<void> _onApplyRules(
    ApplyRulesEvent event,
    Emitter<SmartCollectionsState> emit,
  ) async {
    try {
      emit(SmartCollectionsLoading());
      
      // Validate rules first
      final isValid = await _ruleEngine.validateRule(event.rule);
      if (!isValid) {
        throw Exception('Invalid rule syntax');
      }
      
      // Get all media and apply rules
      final allMedia = await _repository.getAllMedia();
      
      final filtered = await _ruleEngine.filterByRules(
        items: allMedia,
        rules: event.rules,
        logic: event.logic,
      );
      
      emit(SmartCollectionsLoaded(items: filtered));
    } catch (e) {
      emit(SmartCollectionsError(message: e.toString()));
    }
  }
}
```

### Using Complex Rules

```dart
// Build complex nested rules in UI
final complexRules = {
  'logic': 'AND',
  'rules': [
    {
      'field': 'type',
      'operator': 'equals',
      'value': 'image',
    },
  ],
  'groups': [
    {
      'logic': 'OR',
      'rules': [
        {
          'field': 'tags',
          'operator': 'contains',
          'value': 'vacation',
        },
        {
          'field': 'tags',
          'operator': 'contains',
          'value': 'holiday',
        },
      ],
    },
    {
      'logic': 'AND',
      'rules': [
        {
          'field': 'size',
          'operator': 'lessThan',
          'value': 5242880,
        },
      ],
    },
  ],
};

// Evaluate against items
final matches = await ruleEngine.evaluateComplexRules(
  item: mediaItem,
  ruleGroup: complexRules,
);
```

---

## 4. AISuggestionEngine Integration

### In SmartRemindersBloc

```dart
class SmartRemindersBloc extends Bloc<SmartRemindersEvent, SmartRemindersState> {
  final SmartReminderRepository _repository;
  final AISuggestionEngine _aiEngine = AISuggestionEngine();

  SmartRemindersBloc(this._repository) : super(SmartRemindersInitial()) {
    on<GetSuggestionsEvent>(_onGetSuggestions);
    on<GetRecommendationStrengthEvent>(_onGetRecommendationStrength);
  }

  Future<void> _onGetSuggestions(
    GetSuggestionsEvent event,
    Emitter<SmartRemindersState> emit,
  ) async {
    try {
      emit(SmartRemindersLoading());
      
      final reminderHistory = await _repository.getAllReminders();
      final mediaItems = await _repository.getAllMedia();
      
      final suggestions = await _aiEngine.generateSuggestions(
        reminderHistory: reminderHistory,
        mediaItems: mediaItems,
        maxSuggestions: 5,
      );
      
      emit(SuggestionsLoaded(suggestions: suggestions));
    } catch (e) {
      emit(SmartRemindersError(message: e.toString()));
    }
  }

  Future<void> _onGetRecommendationStrength(
    GetRecommendationStrengthEvent event,
    Emitter<SmartRemindersState> emit,
  ) async {
    try {
      final reminderHistory = await _repository.getAllReminders();
      
      final strength = await _aiEngine.getPersonalizedRecommendationStrength(
        reminderHistory: reminderHistory,
      );
      
      emit(RecommendationStrengthLoaded(strength: strength));
    } catch (e) {
      emit(SmartRemindersError(message: e.toString()));
    }
  }
}
```

### In UI (Display Suggestions)

```dart
@override
Widget build(BuildContext context) {
  return BlocBuilder<SmartRemindersBloc, SmartRemindersState>(
    builder: (context, state) {
      if (state is SuggestionsLoaded) {
        return ListView.builder(
          itemCount: state.suggestions.length,
          itemBuilder: (context, index) {
            final suggestion = state.suggestions[index];
            
            return Card(
              child: ListTile(
                title: Text(suggestion['description']),
                subtitle: Text(suggestion['recommendation']),
                trailing: Chip(
                  label: Text('${suggestion['confidence']}%'),
                  backgroundColor: _getConfidenceColor(
                    suggestion['confidence'],
                  ),
                ),
              ),
            );
          },
        );
      }
      return Container();
    },
  );
}

Color _getConfidenceColor(int confidence) {
  if (confidence >= 80) return Colors.green;
  if (confidence >= 60) return Colors.orange;
  return Colors.red;
}
```

---

## 5. TemplateConversionService Integration

### In ReminderTemplatesBloc

```dart
class ReminderTemplatesBloc extends Bloc<ReminderTemplatesEvent, ReminderTemplatesState> {
  final ReminderTemplateRepository _repository;
  final TemplateConversionService _templateService = TemplateConversionService();

  ReminderTemplatesBloc(this._repository) : super(ReminderTemplatesInitial()) {
    on<ConvertTemplateEvent>(_onConvertTemplate);
    on<ConvertRecurringTemplateEvent>(_onConvertRecurring);
    on<CreateTemplateFromReminderEvent>(_onCreateTemplate);
  }

  Future<void> _onConvertTemplate(
    ConvertTemplateEvent event,
    Emitter<ReminderTemplatesState> emit,
  ) async {
    try {
      emit(ReminderTemplatesLoading());
      
      final template = await _repository.getTemplate(event.templateId);
      
      final reminder = await _templateService.convertTemplateToReminder(
        template: template,
        overrides: event.overrides,
      );
      
      // Save the converted reminder
      await _repository.createReminder(reminder);
      
      emit(ReminderTemplatesLoaded());
    } catch (e) {
      emit(ReminderTemplatesError(message: e.toString()));
    }
  }

  Future<void> _onConvertRecurring(
    ConvertRecurringTemplateEvent event,
    Emitter<ReminderTemplatesState> emit,
  ) async {
    try {
      emit(ReminderTemplatesLoading());
      
      final template = await _repository.getTemplate(event.templateId);
      
      final result = await _templateService.convertToRecurringReminder(
        template: template,
        recurrencePattern: event.pattern,
        recurrenceCount: event.count,
        startDate: event.startDate,
      );
      
      // Save all reminders
      for (final reminder in result['reminders'] as List) {
        await _repository.createReminder(reminder);
      }
      
      emit(ReminderTemplatesLoaded());
    } catch (e) {
      emit(ReminderTemplatesError(message: e.toString()));
    }
  }

  Future<void> _onCreateTemplate(
    CreateTemplateFromReminderEvent event,
    Emitter<ReminderTemplatesState> emit,
  ) async {
    try {
      final reminder = await _repository.getReminder(event.reminderId);
      
      final template = await _templateService.createTemplateFromReminder(
        reminder: reminder,
        templateName: event.templateName,
        templateDescription: event.templateDescription,
      );
      
      // Save the template
      await _repository.createTemplate(template);
      
      emit(ReminderTemplatesLoaded());
    } catch (e) {
      emit(ReminderTemplatesError(message: e.toString()));
    }
  }
}
```

### In UI (Template Selection)

```dart
@override
Widget build(BuildContext context) {
  return Column(
    children: [
      DropdownButton<String>(
        hint: Text('Select Pattern'),
        items: [
          'daily',
          'weekly',
          'biweekly',
          'monthly',
          'yearly',
        ]
            .map((pattern) => DropdownMenuItem(
                  value: pattern,
                  child: Text(pattern),
                ))
            .toList(),
        onChanged: (value) {
          // Handle pattern selection
        },
      ),
      TextField(
        decoration: InputDecoration(
          labelText: 'Number of Occurrences',
        ),
        keyboardType: TextInputType.number,
      ),
      ElevatedButton(
        onPressed: () {
          context.read<ReminderTemplatesBloc>().add(
                ConvertRecurringTemplateEvent(
                  templateId: templateId,
                  pattern: selectedPattern,
                  count: int.parse(countController.text),
                ),
              );
        },
        child: Text('Create Recurring Reminders'),
      ),
    ],
  );
}
```

---

## 6. AdvancedSearchRankingService Integration

### In MediaGalleryBloc (Enhanced)

```dart
class MediaGalleryBloc extends Bloc<MediaGalleryEvent, MediaGalleryState> {
  final MediaRepository _repository;
  final AdvancedSearchRankingService _search = AdvancedSearchRankingService();

  MediaGalleryBloc(this._repository) : super(MediaGalleryInitial()) {
    on<AdvancedSearchEvent>(_onAdvancedSearch);
    on<GetSearchSuggestionsEvent>(_onGetSuggestions);
  }

  Future<void> _onAdvancedSearch(
    AdvancedSearchEvent event,
    Emitter<MediaGalleryState> emit,
  ) async {
    try {
      emit(MediaGalleryLoading());
      
      final allMedia = await _repository.getAllMedia();
      
      final results = await _search.advancedSearch(
        items: allMedia,
        query: event.query,
        filters: {
          'type': event.type,
          'fromDate': event.fromDate,
          'toDate': event.toDate,
          'category': event.category,
        },
        weightOverrides: {'customWeight': 1.0},
      );
      
      // Extract items from (item, score) tuples
      final items = results.map((r) => r.$1).toList();
      
      emit(MediaGalleryLoaded(mediaItems: items));
    } catch (e) {
      emit(MediaGalleryError(message: 'Search failed: ${e.toString()}'));
    }
  }

  Future<void> _onGetSuggestions(
    GetSearchSuggestionsEvent event,
    Emitter<MediaGalleryState> emit,
  ) async {
    try {
      final allMedia = await _repository.getAllMedia();
      
      final suggestions = await _search.getSearchSuggestions(
        items: allMedia,
        partialQuery: event.query,
        maxSuggestions: 5,
      );
      
      emit(SearchSuggestionsLoaded(suggestions: suggestions));
    } catch (e) {
      emit(MediaGalleryError(message: e.toString()));
    }
  }
}
```

### In UI (Search Bar with Autocomplete)

```dart
@override
Widget build(BuildContext context) {
  return Column(
    children: [
      TextField(
        onChanged: (value) {
          if (value.length > 2) {
            context.read<MediaGalleryBloc>().add(
                  GetSearchSuggestionsEvent(value),
                );
          }
        },
        decoration: InputDecoration(
          hintText: 'Search media...',
          prefixIcon: Icon(Icons.search),
        ),
      ),
      BlocBuilder<MediaGalleryBloc, MediaGalleryState>(
        builder: (context, state) {
          if (state is SearchSuggestionsLoaded) {
            return ListView.builder(
              itemCount: state.suggestions.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(state.suggestions[index]),
                  onTap: () {
                    // Perform search
                    context.read<MediaGalleryBloc>().add(
                          AdvancedSearchEvent(
                            query: state.suggestions[index],
                          ),
                        );
                  },
                );
              },
            );
          }
          return Container();
        },
      ),
    ],
  );
}
```

---

## 7. Common Patterns

### Error Handling Pattern

```dart
try {
  emit(StateLoading());
  
  final result = await service.operation(params);
  
  emit(StateLoaded(data: result));
} catch (e) {
  emit(StateError(
    message: 'Operation failed: ${e.toString()}',
  ));
}
```

### Batch Processing Pattern

```dart
try {
  final items = await repository.getItems();
  
  for (final item in items) {
    final processed = await service.process(item);
    await repository.save(processed);
  }
} catch (e) {
  // Handle error
}
```

### State Management Pattern

```dart
class MyState extends Equatable {
  final List<T> items;
  final bool isLoading;
  final String? error;

  MyState({
    this.items = const [],
    this.isLoading = false,
    this.error,
  });

  MyState copyWith({
    List<T>? items,
    bool? isLoading,
    String? error,
  }) {
    return MyState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [items, isLoading, error];
}
```

---

## 8. Testing Examples

### Unit Test

```dart
test('mediaFilteringService filters correctly', () async {
  final service = MediaFilteringService();
  final items = [
    {'id': '1', 'type': 'image', 'size': 1000000},
    {'id': '2', 'type': 'video', 'size': 5000000},
  ];

  final filtered = await service.advancedFilter(
    mediaItems: items,
    typeFilter: 'image',
    maxSizeBytes: 2000000,
  );

  expect(filtered.length, 1);
  expect(filtered[0]['type'], 'image');
});
```

### Integration Test

```dart
test('full search pipeline works', () async {
  final search = AdvancedSearchRankingService();
  final items = [
    {'id': '1', 'title': 'Family vacation photos', 'createdAt': '2024-01-15'},
    {'id': '2', 'title': 'Work meeting notes', 'createdAt': '2024-01-10'},
  ];

  final results = await search.advancedSearch(
    items: items,
    query: 'family vacation',
  );

  expect(results.isNotEmpty, true);
  expect(results.first.$1['title'], contains('vacation'));
});
```

---

## 9. Performance Tips

1. **Cache Results:** Store frequently accessed patterns
2. **Lazy Load:** Load data on demand
3. **Batch Operations:** Process multiple items at once
4. **Index Database:** Use proper database indexes
5. **Monitor Memory:** Use profiler for large datasets

---

## 10. Troubleshooting

### Common Issues

| Issue | Solution |
|-------|----------|
| Null pointer in service | Check null-safety in BLoC |
| Slow search | Limit result set, use pagination |
| Rule not matching | Validate rule syntax first |
| Memory leak | Dispose BLoCs properly |
| Suggestion spam | Increase confidence threshold |

---

## Quick Checklist

- [ ] Import all services
- [ ] Add event handlers to BLoCs
- [ ] Create new states if needed
- [ ] Handle errors in try-catch
- [ ] Test with sample data
- [ ] Verify database queries
- [ ] Optimize performance
- [ ] Add UI widgets
- [ ] Test in app

---

**Integration Complete!** All Phase 4 services are ready for integration into your BLoCs and UI.
