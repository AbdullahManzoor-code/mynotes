import 'package:flutter/material.dart';
import '../../injection_container.dart' show getIt;
import '../../core/services/global_ui_service.dart';

/// Custom reflection question entity (REF-003)
class CustomQuestion {
  final String id;
  final String question;
  final String category;
  final String? description;
  final bool isDailyPrompt;
  final DateTime createdAt;
  bool isActive;

  CustomQuestion({
    required this.id,
    required this.question,
    required this.category,
    this.description,
    this.isDailyPrompt = false,
    required this.createdAt,
    this.isActive = true,
  });

  CustomQuestion copyWith({
    String? id,
    String? question,
    String? category,
    String? description,
    bool? isDailyPrompt,
    DateTime? createdAt,
    bool? isActive,
  }) {
    return CustomQuestion(
      id: id ?? this.id,
      question: question ?? this.question,
      category: category ?? this.category,
      description: description ?? this.description,
      isDailyPrompt: isDailyPrompt ?? this.isDailyPrompt,
      createdAt: createdAt ?? this.createdAt,
      isActive: isActive ?? this.isActive,
    );
  }
}

/// Custom question creator widget
class CustomQuestionCreatorWidget extends StatefulWidget {
  final ValueChanged<CustomQuestion> onQuestionCreated;
  final CustomQuestion? initialQuestion;

  const CustomQuestionCreatorWidget({
    Key? key,
    required this.onQuestionCreated,
    this.initialQuestion,
  }) : super(key: key);

  @override
  State<CustomQuestionCreatorWidget> createState() =>
      _CustomQuestionCreatorWidgetState();
}

class _CustomQuestionCreatorWidgetState
    extends State<CustomQuestionCreatorWidget> {
  late TextEditingController _questionController;
  late TextEditingController _descriptionController;
  late String _selectedCategory;
  bool _isDailyPrompt = false;

  static const List<String> categories = [
    'Personal',
    'Growth',
    'Health',
    'Work',
    'Relationships',
    'Creativity',
    'Goals',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    _questionController = TextEditingController(
      text: widget.initialQuestion?.question ?? '',
    );
    _descriptionController = TextEditingController(
      text: widget.initialQuestion?.description ?? '',
    );
    _selectedCategory = widget.initialQuestion?.category ?? 'Personal';
    _isDailyPrompt = widget.initialQuestion?.isDailyPrompt ?? false;
  }

  @override
  void dispose() {
    _questionController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _createQuestion() {
    if (_questionController.text.trim().isEmpty) {
      getIt<GlobalUiService>().showWarning('Please enter a question');
      return;
    }

    final question = CustomQuestion(
      id: widget.initialQuestion?.id ?? DateTime.now().toString(),
      question: _questionController.text.trim(),
      category: _selectedCategory,
      description: _descriptionController.text.trim().isNotEmpty
          ? _descriptionController.text.trim()
          : null,
      isDailyPrompt: _isDailyPrompt,
      createdAt: widget.initialQuestion?.createdAt ?? DateTime.now(),
    );

    widget.onQuestionCreated(question);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Header
          Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Create Custom Question',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                IconButton(
                  icon: Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          // Content
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Question field
                Text(
                  'Question',
                  style: Theme.of(context).textTheme.labelMedium,
                ),
                SizedBox(height: 8),
                TextField(
                  controller: _questionController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: 'What would you like to ask yourself?',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                SizedBox(height: 16),
                // Category selector
                Text(
                  'Category',
                  style: Theme.of(context).textTheme.labelMedium,
                ),
                SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  items: categories
                      .map(
                        (cat) => DropdownMenuItem(value: cat, child: Text(cat)),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _selectedCategory = value);
                    }
                  },
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                SizedBox(height: 16),
                // Description field
                Text(
                  'Description (Optional)',
                  style: Theme.of(context).textTheme.labelMedium,
                ),
                SizedBox(height: 8),
                TextField(
                  controller: _descriptionController,
                  maxLines: 2,
                  decoration: InputDecoration(
                    hintText: 'Add context or tips for this question...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                SizedBox(height: 16),
                // Daily prompt toggle
                CheckboxListTile(
                  title: Text('Use as Daily Prompt'),
                  subtitle: Text(
                    'Send this question as a daily notification reminder',
                  ),
                  value: _isDailyPrompt,
                  onChanged: (value) {
                    setState(() => _isDailyPrompt = value ?? false);
                  },
                  controlAffinity: ListTileControlAffinity.leading,
                ),
                SizedBox(height: 24),
                // Save button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: Icon(Icons.save),
                    label: Text('Save Question'),
                    onPressed: _createQuestion,
                  ),
                ),
                SizedBox(height: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Daily prompt widget (REF-005)
class DailyPromptWidget extends StatelessWidget {
  final CustomQuestion prompt;
  final VoidCallback? onAnswerTap;

  const DailyPromptWidget({Key? key, required this.prompt, this.onAnswerTap})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Daily Prompt',
                        style: Theme.of(
                          context,
                        ).textTheme.labelSmall?.copyWith(color: Colors.grey),
                      ),
                      SizedBox(height: 4),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.amber.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          prompt.category,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.amber[800],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.favorite_outline, color: Colors.amber),
              ],
            ),
            SizedBox(height: 12),
            Text(
              prompt.question,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            if (prompt.description != null) ...[
              SizedBox(height: 8),
              Text(
                prompt.description!,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
              ),
            ],
            SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: Icon(Icons.edit_note),
                label: Text('Reflect'),
                onPressed: onAnswerTap,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Custom questions list widget
class CustomQuestionsListWidget extends StatelessWidget {
  final List<CustomQuestion> questions;
  final ValueChanged<CustomQuestion> onQuestionToggle;
  final ValueChanged<CustomQuestion> onQuestionDelete;
  final VoidCallback? onAddQuestion;

  const CustomQuestionsListWidget({
    Key? key,
    required this.questions,
    required this.onQuestionToggle,
    required this.onQuestionDelete,
    this.onAddQuestion,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final activeQuestions = questions.where((q) => q.isActive).toList();

    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Custom Questions',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (onAddQuestion != null)
                  IconButton(
                    icon: Icon(Icons.add_circle_outline),
                    onPressed: onAddQuestion,
                  ),
              ],
            ),
            if (activeQuestions.isEmpty)
              Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: Text(
                    'No custom questions yet',
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
                  ),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: activeQuestions.length,
                separatorBuilder: (_, __) => Divider(),
                itemBuilder: (context, index) {
                  final question = activeQuestions[index];
                  return _buildQuestionTile(context, question);
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionTile(BuildContext context, CustomQuestion question) {
    return Dismissible(
      key: Key(question.id),
      background: Container(
        color: Colors.red.withOpacity(0.2),
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 16),
        child: Icon(Icons.delete_outline, color: Colors.red),
      ),
      onDismissed: (_) => onQuestionDelete(question),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      question.question,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 4),
                    Wrap(
                      spacing: 8,
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            question.category,
                            style: TextStyle(fontSize: 11, color: Colors.blue),
                          ),
                        ),
                        if (question.isDailyPrompt)
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.amber.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.notifications,
                                  size: 10,
                                  color: Colors.amber,
                                ),
                                SizedBox(width: 2),
                                Text(
                                  'Daily',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.amber[800],
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              Checkbox(
                value: question.isActive,
                onChanged: (_) => onQuestionToggle(question),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
