import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:graphview/GraphView.dart';
import '../../../domain/repositories/note_repository.dart';
import '../../../domain/repositories/todo_repository.dart';
import '../../../domain/repositories/alarm_repository.dart';

// Events
abstract class GraphEvent extends Equatable {
  const GraphEvent();
  @override
  List<Object?> get props => [];
}

class LoadGraphData extends GraphEvent {}

// States
abstract class GraphState extends Equatable {
  const GraphState();
  @override
  List<Object?> get props => [];
}

class GraphInitial extends GraphState {}

class GraphLoading extends GraphState {}

class GraphLoaded extends GraphState {
  final Graph graph;
  final Map<Node, dynamic> nodeData;

  const GraphLoaded({required this.graph, required this.nodeData});

  @override
  List<Object?> get props => [graph, nodeData];
}

class GraphError extends GraphState {
  final String message;
  const GraphError({required this.message});
  @override
  List<Object?> get props => [message];
}

// BLoC
class GraphBloc extends Bloc<GraphEvent, GraphState> {
  final NoteRepository noteRepository;
  final TodoRepository todoRepository;
  final AlarmRepository alarmRepository;

  GraphBloc({
    required this.noteRepository,
    required this.todoRepository,
    required this.alarmRepository,
  }) : super(GraphInitial()) {
    on<LoadGraphData>(_onLoadGraphData);
  }

  Future<void> _onLoadGraphData(
    LoadGraphData event,
    Emitter<GraphState> emit,
  ) async {
    emit(GraphLoading());
    try {
      final graph = Graph()..isTree = false;
      final Map<String, Node> nodeMap = {};
      final Map<Node, dynamic> nodeData = {};

      final notes = await noteRepository.getAllNotes();
      final todos = await todoRepository.getTodos();
      final alarms = await alarmRepository.getAlarms();

      // 1. Add Note Nodes
      for (var note in notes) {
        final node = Node.Id(note.id);
        nodeMap[note.id] = node;
        nodeData[node] = note;
        graph.addNode(node);
      }

      // 2. Add Todo Nodes & Relationships
      for (var todo in todos) {
        final node = Node.Id(todo.id);
        nodeMap[todo.id] = node;
        nodeData[node] = todo;
        graph.addNode(node);

        // Edge from Note to its Todo
        if (todo.noteId != null && nodeMap.containsKey(todo.noteId)) {
          graph.addEdge(nodeMap[todo.noteId]!, node);
        }
      }

      // 3. Add Alarm Nodes & Relationships
      for (var alarm in alarms) {
        final node = Node.Id(alarm.id);
        nodeMap[alarm.id] = node;
        nodeData[node] = alarm;
        graph.addNode(node);

        // Edge from Note to its Alarm
        if (alarm.linkedNoteId != null &&
            nodeMap.containsKey(alarm.linkedNoteId)) {
          graph.addEdge(nodeMap[alarm.linkedNoteId]!, node);
        }
      }

      // 4. Create Inter-Note Wiki-style Edges
      for (var note in notes) {
        try {
          final outlinks = await noteRepository.getOutgoingLinks(note.id);
          final sourceNode = nodeMap[note.id];

          if (sourceNode != null) {
            for (var targetId in outlinks) {
              final targetNode = nodeMap[targetId];
              if (targetNode != null) {
                graph.addEdge(sourceNode, targetNode);
              }
            }
          }
        } catch (e) {
          debugPrint('Error loading links for note ${note.id}: $e');
        }
      }

      emit(GraphLoaded(graph: graph, nodeData: nodeData));
    } catch (e) {
      emit(GraphError(message: 'Failed to load graph data: $e'));
    }
  }
}
