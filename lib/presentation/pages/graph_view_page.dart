import 'package:flutter/material.dart';
import 'package:graphview/GraphView.dart';
import '../../domain/entities/note.dart';
import '../../domain/repositories/note_repository.dart';
import '../../data/datasources/local_database.dart';
import '../../data/repositories/note_repository_impl.dart';
import '../design_system/app_colors.dart';
import '../design_system/app_typography.dart';

class GraphViewPage extends StatefulWidget {
  const GraphViewPage({super.key});

  @override
  State<GraphViewPage> createState() => _GraphViewPageState();
}

class _GraphViewPageState extends State<GraphViewPage> {
  final Graph graph = Graph()..isTree = false;
  Algorithm? builder;
  bool _isLoading = true;
  final NoteRepository _noteRepository = NoteRepositoryImpl(
    database: NotesDatabase(),
  );
  Map<String, Node> _nodeMap = {};
  Map<Node, Note> _noteData = {};

  @override
  void initState() {
    super.initState();
    // Use FruchtermanReingoldAlgorithm for force-directed layout
    builder = FruchtermanReingoldAlgorithm(FruchtermanReingoldConfiguration());
    _loadGraphData();
  }

  Future<void> _loadGraphData() async {
    setState(() => _isLoading = true);
    try {
      final notes = await _noteRepository.getAllNotes();

      // Create Nodes
      for (var note in notes) {
        final node = Node.Id(note.id);
        _nodeMap[note.id] = node;
        _noteData[node] = note;
        graph.addNode(node);
      }

      // Create Edges
      for (var note in notes) {
        try {
          final outlinks = await _noteRepository.getOutgoingLinks(note.id);
          final sourceNode = _nodeMap[note.id];

          if (sourceNode != null) {
            for (var targetId in outlinks) {
              final targetNode = _nodeMap[targetId];
              if (targetNode != null) {
                // Check if edge already exists to avoid duplicates if generic graph doesn't handle it?
                // GraphView handles it usually.
                graph.addEdge(sourceNode, targetNode);
              }
            }
          }
        } catch (e) {
          debugPrint('Error loading links for note ${note.id}: $e');
        }
      }
    } catch (e) {
      debugPrint('Error loading graph: $e');
    }

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Knowledge Graph',
          style: AppTypography.heading3(
            context,
            AppColors.textPrimary(context),
          ),
        ),
        backgroundColor: AppColors.surface(context),
        iconTheme: IconThemeData(color: AppColors.textPrimary(context)),
        elevation: 0,
      ),
      backgroundColor: AppColors.background(context),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : graph.nodeCount() == 0
          ? Center(
              child: Text(
                'No notes to visualize.\nCreate notes or add [[links]] to see the graph.',
                textAlign: TextAlign.center,
                style: AppTypography.body1(
                  context,
                  AppColors.textSecondary(context),
                ),
              ),
            )
          : InteractiveViewer(
              constrained: false,
              boundaryMargin: const EdgeInsets.all(100),
              minScale: 0.01,
              maxScale: 5.6,
              child: GraphView(
                graph: graph,
                algorithm:
                    builder ??
                    FruchtermanReingoldAlgorithm(
                      FruchtermanReingoldConfiguration(),
                    ),
                paint: Paint()
                  ..color = AppColors.primary
                  ..strokeWidth = 1
                  ..style = PaintingStyle.stroke,
                builder: (Node node) {
                  final note = _noteData[node];
                  return GestureDetector(
                    onTap: () {
                      if (note != null) {
                        // Navigate to note editor safely
                        // For now we just print to avoid errors if not fully implemented
                        debugPrint('Clicked on note: ${note.title}');
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.surface(context),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.primary, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.grey400.withOpacity(0.5),
                            blurRadius: 4,
                            offset: const Offset(2, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        note?.title ?? '?',
                        style: AppTypography.body2(
                          context,
                          AppColors.textPrimary(context),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
