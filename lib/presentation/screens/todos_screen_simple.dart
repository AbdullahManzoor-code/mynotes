import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mynotes/presentation/pages/enhanced_todos_list_screen_refactored.dart';
import 'package:mynotes/presentation/bloc/todos/todos_bloc.dart';
import '../../injection_container.dart' show getIt;
import 'package:mynotes/core/services/app_logger.dart';

/// Unified Todos Screen
/// Wrapper around EnhancedTodosListScreenRefactored with TodosBloc provider.
/// Single entry point for todo list functionality.
class TodosScreen extends StatelessWidget {
  const TodosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    AppLogger.i('TodosScreen: Building unified todos screen');
    return BlocProvider<TodosBloc>(
      create: (context) => getIt<TodosBloc>(),
      child: const EnhancedTodosListScreenRefactored(),
    );
  }
}



