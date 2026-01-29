import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mynotes/presentation/bloc/smart_reminders_bloc.dart';
import 'package:mynotes/domain/services/ai_suggestion_engine.dart';

/// Suggestion Recommendations - Batch 6, Screen 1
class SuggestionRecommendationsScreen extends StatefulWidget {
  const SuggestionRecommendationsScreen({Key? key}) : super(key: key);

  @override
  State<SuggestionRecommendationsScreen> createState() =>
      _SuggestionRecommendationsScreenState();
}

class _SuggestionRecommendationsScreenState
    extends State<SuggestionRecommendationsScreen> {
  final _aiEngine = AISuggestionEngine();
  late Future<List<Map<String, dynamic>>> _suggestionsFuture;

  @override
  void initState() {
    super.initState();
    _loadSuggestions();
  }

  void _loadSuggestions() {
    final state = context.read<SmartRemindersBloc>().state;
    if (state is SmartRemindersLoaded) {
      _suggestionsFuture = _aiEngine.generateSuggestions(
        reminderHistory: state.reminders,
        mediaItems: const [],
        maxSuggestions: 5,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Suggestions for You'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _loadSuggestions();
              });
            },
          ),
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _suggestionsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final suggestions = snapshot.data ?? [];

          if (suggestions.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.lightbulb_outline, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text('No suggestions yet'),
                  const SizedBox(height: 8),
                  Text(
                    'Use the app more to get personalized suggestions',
                    style: Theme.of(context).textTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: suggestions.length,
            itemBuilder: (context, index) {
              final suggestion = suggestions[index];
              return _buildSuggestionCard(suggestion);
            },
          );
        },
      ),
    );
  }

  Widget _buildSuggestionCard(Map<String, dynamic> suggestion) {
    final type = suggestion['type'] as String? ?? 'unknown';
    final confidence = suggestion['confidence'] as int? ?? 0;
    final color = _getTypeColor(type);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    type.toUpperCase(),
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                Spacer(),
                Row(
                  children: [
                    Icon(Icons.star, size: 16, color: Colors.orange),
                    const SizedBox(width: 4),
                    Text(
                      '$confidence%',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Description
            Text(
              suggestion['description'] ?? '',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),

            // Recommendation
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.lightbulb, size: 20, color: color),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      suggestion['recommendation'] ?? '',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Action Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    // Dismiss suggestion
                  },
                  child: Text('Dismiss'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    _handleSuggestion(suggestion);
                  },
                  child: Text('Accept'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'timing':
        return Colors.blue;
      case 'content':
        return Colors.green;
      case 'frequency':
        return Colors.orange;
      case 'media':
        return Colors.purple;
      case 'engagement':
        return Colors.pink;
      default:
        return Colors.grey;
    }
  }

  void _handleSuggestion(Map<String, dynamic> suggestion) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Suggestion accepted!'),
        action: SnackBarAction(label: 'Undo', onPressed: () {}),
      ),
    );
  }
}

