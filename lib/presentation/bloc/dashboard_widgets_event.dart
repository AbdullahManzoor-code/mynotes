part of 'dashboard_widgets_bloc.dart';

abstract class DashboardWidgetsEvent extends Equatable {
  const DashboardWidgetsEvent();

  @override
  List<Object?> get props => [];
}

class LoadDashboardWidgetsEvent extends DashboardWidgetsEvent {
  const LoadDashboardWidgetsEvent();
}

class AddWidgetEvent extends DashboardWidgetsEvent {
  final String widgetType;

  const AddWidgetEvent(this.widgetType);

  @override
  List<Object?> get props => [widgetType];
}

class RemoveWidgetEvent extends DashboardWidgetsEvent {
  final String widgetId;

  const RemoveWidgetEvent(this.widgetId);

  @override
  List<Object?> get props => [widgetId];
}

class ReorderWidgetsEvent extends DashboardWidgetsEvent {
  final List<String> widgetIds;

  const ReorderWidgetsEvent(this.widgetIds);

  @override
  List<Object?> get props => [widgetIds];
}

class UpdateWidgetPropertiesEvent extends DashboardWidgetsEvent {
  final String widgetId;
  final Map<String, dynamic> properties;

  const UpdateWidgetPropertiesEvent(this.widgetId, this.properties);

  @override
  List<Object?> get props => [widgetId, properties];
}
