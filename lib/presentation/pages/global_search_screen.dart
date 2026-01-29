import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mynotes/presentation/bloc/todos_bloc.dart';
import '../../domain/entities/note.dart';
import '../../domain/entities/todo_item.dart';
import '../../domain/repositories/note_repository.dart';

/// Global search results screen
class GlobalSearchScreen extends StatefulWidget {
  const GlobalSearchScreen({Key? key}) : super(key: key);

  @override
  State<GlobalSearchScreen> createState() => _GlobalSearchScreenState();
}

class _GlobalSearchScreenState extends State<GlobalSearchScreen> {
  late TextEditingController _searchController;
  List<Note> _searchedNotes = [];
  List<TodoItem> _searchedTodos = [];
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _searchController.addListener(_performSearch);
  }

  void _performSearch() async {
    final query = _searchController.text.trim();

    if (query.isEmpty) {
      setState(() {
        _searchedNotes = [];
        _searchedTodos = [];
        _isSearching = false;
      });
      return;
    }

    setState(() {
      _isSearching = true;
    });

    try {
      // Get repository from context
      final noteRepo = context.read<NoteRepository>();

      // Search notes
      final notes = await noteRepo.searchNotes(query);

      // Search todos (would need TodoRepository)
      // For now, filtering in-memory
      final todosState = context.read<TodosBloc>().state;
      final allTodos = todosState is TodosLoaded
          ? (todosState as TodosLoaded).allTodos
          : <TodoItem>[];

      final todos = allTodos
          .where((t) => t.text.toLowerCase().contains(query.toLowerCase()))
          .toList();

      setState(() {
        _searchedNotes = notes;
        _searchedTodos = todos;
        _isSearching = false;
      });
    } catch (e) {
      print('Search error: $e');
      setState(() {
        _isSearching = false;
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Global Search'), elevation: 0),
      body: Column(
        children: [
          // Search Input
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search notes, todos, reminders...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              autofocus: true,
            ),
          ),

          // Loading indicator
          if (_isSearching)
            const Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(),
            ),

          // Results
          if (!_isSearching && _searchController.text.isNotEmpty)
            Expanded(
              child: _searchedNotes.isEmpty && _searchedTodos.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.search_off,
                            size: 64,
                            color: Colors.grey,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No results for "${_searchController.text}"',
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ],
                      ),
                    )
                  : ListView(
                      children: [
                        // Notes section
                        if (_searchedNotes.isNotEmpty) ...[
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                            child: Text(
                              'Notes (${_searchedNotes.length})',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ),
                          ..._searchedNotes.map(
                            (note) => ListTile(
                              leading: const Icon(Icons.note),
                              title: Text(note.title),
                              subtitle: Text(
                                note.content.length > 100
                                    ? '${note.content.substring(0, 100)}...'
                                    : note.content,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              onTap: () {
                                Navigator.pop(context, note);
                              },
                            ),
                          ),
                        ],

                        // Todos section
                        if (_searchedTodos.isNotEmpty) ...[
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                            child: Text(
                              'Todos (${_searchedTodos.length})',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ),
                          ..._searchedTodos.map(
                            (todo) => ListTile(
                              leading: const Icon(Icons.check_circle_outline),
                              title: Text(todo.text),
                              trailing: Checkbox(
                                value: todo.isCompleted,
                                onChanged: null,
                              ),
                              onTap: () {
                                Navigator.pop(context, todo);
                              },
                            ),
                          ),
                        ],
                      ],
                    ),
            ),
        ],
      ),
    );
  }
}
