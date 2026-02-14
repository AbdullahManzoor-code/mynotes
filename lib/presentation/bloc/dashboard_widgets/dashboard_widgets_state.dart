part of 'dashboard_widgets_bloc.dart';

abstract class DashboardWidgetsState extends Equatable {
  const DashboardWidgetsState();

  @override
  List<Object?> get props => [];
}

class DashboardWidgetsInitial extends DashboardWidgetsState {
  const DashboardWidgetsInitial();
}

class DashboardWidgetsLoading extends DashboardWidgetsState {
  const DashboardWidgetsLoading();
}

class DashboardWidgetsLoaded extends DashboardWidgetsState {
  final List<DashboardWidget> widgets;

  const DashboardWidgetsLoaded({required this.widgets});

  @override
  List<Object?> get props => [widgets];
}

class WidgetAdded extends DashboardWidgetsState {
  final DashboardWidget widget;

  const WidgetAdded({required this.widget});

  @override
  List<Object?> get props => [widget];
}

class WidgetRemoved extends DashboardWidgetsState {
  final String widgetId;

  const WidgetRemoved({required this.widgetId});

  @override
  List<Object?> get props => [widgetId];
}

class WidgetsReordered extends DashboardWidgetsState {
  final List<String> widgetIds;

  const WidgetsReordered({required this.widgetIds});

  @override
  List<Object?> get props => [widgetIds];
}

class WidgetPropertiesUpdated extends DashboardWidgetsState {
  final String widgetId;

  const WidgetPropertiesUpdated({required this.widgetId});

  @override
  List<Object?> get props => [widgetId];
}

class DashboardWidgetsError extends DashboardWidgetsState {
  final String message;

  const DashboardWidgetsError(this.message);

  @override
  List<Object?> get props => [message];
}
