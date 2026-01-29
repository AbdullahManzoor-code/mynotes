import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

part 'dashboard_widgets_event.dart';
part 'dashboard_widgets_state.dart';

/// Dashboard Widgets BLoC for customizable dashboard
/// Allows adding, removing, and reordering widgets
class DashboardWidgetsBloc extends Bloc<DashboardWidgetsEvent, DashboardWidgetsState> {
  final List<DashboardWidget> _widgets = [];
  static const String _widgetsKey = 'dashboard_widgets';

  DashboardWidgetsBloc() : super(const DashboardWidgetsInitial()) {
    on<LoadDashboardWidgetsEvent>(_onLoadWidgets);
    on<AddWidgetEvent>(_onAddWidget);
    on<RemoveWidgetEvent>(_onRemoveWidget);
    on<ReorderWidgetsEvent>(_onReorderWidgets);
    on<UpdateWidgetPropertiesEvent>(_onUpdateWidgetProperties);
  }

  Future<void> _onLoadWidgets(
    LoadDashboardWidgetsEvent event,
    Emitter<DashboardWidgetsState> emit,
  ) async {
    try {
      emit(const DashboardWidgetsLoading());

      final prefs = await SharedPreferences.getInstance();
      final widgetsJson = prefs.getString(_widgetsKey);

      if (widgetsJson != null) {
        final decoded = jsonDecode(widgetsJson) as List;
        _widgets.clear();
        _widgets.addAll(
          decoded.map((w) => DashboardWidget.fromJson(w as Map<String, dynamic>)),
        );
      } else {
        // Default widgets
        _widgets.addAll([
          DashboardWidget(id: '1', type: 'daily_highlight', order: 0),
          DashboardWidget(id: '2', type: 'upcoming_reminders', order: 1),
          DashboardWidget(id: '3', type: 'progress_ring', order: 2),
          DashboardWidget(id: '4', type: 'quick_stats', order: 3),
        ]);
        await _saveWidgets();
      }

      emit(DashboardWidgetsLoaded(widgets: _widgets));
    } catch (e) {
      emit(DashboardWidgetsError(e.toString()));
    }
  }

  Future<void> _onAddWidget(
    AddWidgetEvent event,
    Emitter<DashboardWidgetsState> emit,
  ) async {
    try {
      emit(const DashboardWidgetsLoading());

      final widget = DashboardWidget(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        type: event.widgetType,
        order: _widgets.length,
      );

      _widgets.add(widget);
      await _saveWidgets();

      emit(WidgetAdded(widget: widget));
    } catch (e) {
      emit(DashboardWidgetsError(e.toString()));
    }
  }

  Future<void> _onRemoveWidget(
    RemoveWidgetEvent event,
    Emitter<DashboardWidgetsState> emit,
  ) async {
    try {
      emit(const DashboardWidgetsLoading());

      _widgets.removeWhere((w) => w.id == event.widgetId);
      await _saveWidgets();

      emit(WidgetRemoved(widgetId: event.widgetId));
    } catch (e) {
      emit(DashboardWidgetsError(e.toString()));
    }
  }

  Future<void> _onReorderWidgets(
    ReorderWidgetsEvent event,
    Emitter<DashboardWidgetsState> emit,
  ) async {
    try {
      emit(const DashboardWidgetsLoading());

      for (int i = 0; i < event.widgetIds.length; i++) {
        final index = _widgets.indexWhere((w) => w.id == event.widgetIds[i]);
        if (index >= 0) {
          _widgets[index] = _widgets[index].copyWith(order: i);
        }
      }

      await _saveWidgets();
      emit(WidgetsReordered(widgetIds: event.widgetIds));
    } catch (e) {
      emit(DashboardWidgetsError(e.toString()));
    }
  }

  Future<void> _onUpdateWidgetProperties(
    UpdateWidgetPropertiesEvent event,
    Emitter<DashboardWidgetsState> emit,
  ) async {
    try {
      emit(const DashboardWidgetsLoading());

      final index = _widgets.indexWhere((w) => w.id == event.widgetId);
      if (index >= 0) {
        _widgets[index] = _widgets[index].copyWith(
          properties: event.properties,
        );
        await _saveWidgets();
        emit(WidgetPropertiesUpdated(widgetId: event.widgetId));
      }
    } catch (e) {
      emit(DashboardWidgetsError(e.toString()));
    }
  }

  Future<void> _saveWidgets() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_widgetsKey, jsonEncode(_widgets));
  }
}

class DashboardWidget extends Equatable {
  final String id;
  final String type;
  final int order;
  final bool enabled;
  final Map<String, dynamic>? properties;

  const DashboardWidget({
    required this.id,
    required this.type,
    required this.order,
    this.enabled = true,
    this.properties,
  });

  DashboardWidget copyWith({
    String? id,
    String? type,
    int? order,
    bool? enabled,
    Map<String, dynamic>? properties,
  }) {
    return DashboardWidget(
      id: id ?? this.id,
      type: type ?? this.type,
      order: order ?? this.order,
      enabled: enabled ?? this.enabled,
      properties: properties ?? this.properties,
    );
  }

  factory DashboardWidget.fromJson(Map<String, dynamic> json) {
    return DashboardWidget(
      id: json['id'] as String,
      type: json['type'] as String,
      order: json['order'] as int? ?? 0,
      enabled: json['enabled'] as bool? ?? true,
      properties: json['properties'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'order': order,
      'enabled': enabled,
      'properties': properties,
    };
  }

  @override
  List<Object?> get props => [id, type, order, enabled, properties];
}
