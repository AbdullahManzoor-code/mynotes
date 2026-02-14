import 'package:flutter/material.dart';

/// Note template entity
class NoteTemplate {
  final int? id;
  final String name;
  final String description;
  final String titlePlaceholder;
  final String contentPlaceholder;
  final String icon;
  final String category;
  final DateTime createdAt;

  NoteTemplate({
    this.id,
    required this.name,
    required this.description,
    required this.titlePlaceholder,
    required this.contentPlaceholder,
    required this.icon,
    required this.category,
    required this.createdAt,
  });

  NoteTemplate copyWith({
    int? id,
    String? name,
    String? description,
    String? titlePlaceholder,
    String? contentPlaceholder,
    String? icon,
    String? category,
    DateTime? createdAt,
  }) {
    return NoteTemplate(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      titlePlaceholder: titlePlaceholder ?? this.titlePlaceholder,
      contentPlaceholder: contentPlaceholder ?? this.contentPlaceholder,
      icon: icon ?? this.icon,
      category: category ?? this.category,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

/// Built-in note templates
class NoteTemplates {
  static final List<NoteTemplate> builtIn = [
    NoteTemplate(
      name: 'Daily Journal',
      description: 'Personal reflection and daily thoughts',
      titlePlaceholder: 'Date: ${DateTime.now()}',
      contentPlaceholder: '''Today's reflection:

Morning thoughts:
- 

Afternoon:
- 

Evening reflections:
- 

Gratitude (3 things):
1. 
2. 
3. 

Tomorrow's focus:
- ''',
      icon: 'diary',
      category: 'Personal',
      createdAt: DateTime.now(),
    ),
    NoteTemplate(
      name: 'Meeting Notes',
      description: 'Structure for capturing meeting details',
      titlePlaceholder: 'Meeting: [Topic] - [Date]',
      contentPlaceholder: '''Attendees:
- 

Agenda:
1. 
2. 
3. 

Discussion Points:
- 

Action Items:
- 
- 
- 

Follow-ups:
- 

Date of Next Meeting: ''',
      icon: 'meeting',
      category: 'Work',
      createdAt: DateTime.now(),
    ),
    NoteTemplate(
      name: 'Recipe',
      description: 'Organize recipes with ingredients and steps',
      titlePlaceholder: '[Dish Name]',
      contentPlaceholder: '''Cuisine: 
Prep Time: 
Cook Time: 
Servings: 

Ingredients:
- 

Instructions:
1. 
2. 
3. 

Tips & Notes:
- ''',
      icon: 'recipe',
      category: 'Recipes',
      createdAt: DateTime.now(),
    ),
    NoteTemplate(
      name: 'Book Review',
      description: 'Review and notes on books you\'ve read',
      titlePlaceholder: '[Book Title] by [Author]',
      contentPlaceholder: '''Rating: ⭐ / 5

Summary:


Key Takeaways:
1. 
2. 
3. 

Favorite Quotes:
- 

Thoughts & Reflections:


Would I recommend? 

Similar Books:
- ''',
      icon: 'book',
      category: 'Learning',
      createdAt: DateTime.now(),
    ),
    NoteTemplate(
      name: 'Project Plan',
      description: 'Organize project goals and timeline',
      titlePlaceholder: '[Project Name]',
      contentPlaceholder: '''Objective:


Key Deliverables:
1. 
2. 
3. 

Timeline:
- Start Date: 
- End Date: 
- Milestones: 

Team Members:
- 

Resources Needed:
- 

Risks & Mitigation:
- 

Success Criteria:
- ''',
      icon: 'project',
      category: 'Work',
      createdAt: DateTime.now(),
    ),
    NoteTemplate(
      name: 'Travel Plan',
      description: 'Plan your trips with destinations and details',
      titlePlaceholder: '[Destination] - [Dates]',
      contentPlaceholder: '''Duration: 
Budget: 

Flights:
- Departure: 
- Return: 

Accommodation:
- Hotel/Hostel: 
- Address: 

Attractions:
1. 
2. 
3. 

Restaurants to Try:
- 

Packing List:
- 

Important Contacts:
- ''',
      icon: 'travel',
      category: 'Personal',
      createdAt: DateTime.now(),
    ),
    NoteTemplate(
      name: 'Brainstorm',
      description: 'Free-form idea generation',
      titlePlaceholder: '[Topic/Idea]',
      contentPlaceholder: '''Initial Thoughts:
- 
- 
- 

Variations:
- 
- 
- 

Pros:
- 
- 

Cons:
- 
- 

Next Steps:
- ''',
      icon: 'lightbulb',
      category: 'Creativity',
      createdAt: DateTime.now(),
    ),
    NoteTemplate(
      name: 'Habit Tracker',
      description: 'Monitor daily habits',
      titlePlaceholder: 'Habit Tracking - Week of [Date]',
      contentPlaceholder: '''Habit 1: 
Mon | Tue | Wed | Thu | Fri | Sat | Sun
[ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ]

Habit 2: 
Mon | Tue | Wed | Thu | Fri | Sat | Sun
[ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ]

Habit 3: 
Mon | Tue | Wed | Thu | Fri | Sat | Sun
[ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ]

Notes:
- ''',
      icon: 'habit',
      category: 'Personal',
      createdAt: DateTime.now(),
    ),
    NoteTemplate(
      name: 'Checklist',
      description: 'General purpose checklist',
      titlePlaceholder: '[Checklist Name]',
      contentPlaceholder: '''[ ] Item 1
[ ] Item 2
[ ] Item 3
[ ] Item 4
[ ] Item 5
[ ] Item 6
[ ] Item 7
[ ] Item 8

Notes:
- ''',
      icon: 'checklist',
      category: 'General',
      createdAt: DateTime.now(),
    ),
    NoteTemplate(
      name: 'Decision Matrix',
      description: 'Analyze options systematically',
      titlePlaceholder: '[Decision Topic]',
      contentPlaceholder: '''Options to Consider:
1. 
2. 
3. 

Criteria:
1. (Weight: %)
2. (Weight: %)
3. (Weight: %)

Scoring (1-10):
Option 1: Score
Option 2: Score
Option 3: Score

Analysis:
- Pros: 
- Cons: 

Recommendation: ''',
      icon: 'decision',
      category: 'Planning',
      createdAt: DateTime.now(),
    ),
  ];

  static NoteTemplate getTemplate(String name) {
    try {
      return builtIn.firstWhere((t) => t.name == name);
    } catch (e) {
      return builtIn.first;
    }
  }

  static List<NoteTemplate> getByCategory(String category) {
    return builtIn.where((t) => t.category == category).toList();
  }

  static List<String> getCategories() {
    final categories = <String>{};
    for (final template in builtIn) {
      categories.add(template.category);
    }
    return categories.toList()..sort();
  }
}

/// Template selection widget
class TemplateSelector extends StatefulWidget {
  final Function(NoteTemplate) onTemplateSelected;
  final VoidCallback? onCancel;

  const TemplateSelector({
    super.key,
    required this.onTemplateSelected,
    this.onCancel,
  });

  @override
  State<TemplateSelector> createState() => _TemplateSelectorState();
}

class _TemplateSelectorState extends State<TemplateSelector> {
  String _selectedCategory = 'All';
  late List<NoteTemplate> _filteredTemplates;

  @override
  void initState() {
    super.initState();
    _updateFiltered();
  }

  void _updateFiltered() {
    if (_selectedCategory == 'All') {
      _filteredTemplates = NoteTemplates.builtIn;
    } else {
      _filteredTemplates = NoteTemplates.getByCategory(_selectedCategory);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Select Template',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            if (widget.onCancel != null)
              IconButton(icon: Icon(Icons.close), onPressed: widget.onCancel),
          ],
        ),

        SizedBox(height: 16),

        // Category filter
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              ChoiceChip(
                label: Text('All'),
                selected: _selectedCategory == 'All',
                onSelected: (selected) {
                  setState(() {
                    _selectedCategory = 'All';
                    _updateFiltered();
                  });
                },
              ),
              SizedBox(width: 8),
              ...NoteTemplates.getCategories().map((category) {
                return Padding(
                  padding: EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(category),
                    selected: _selectedCategory == category,
                    onSelected: (selected) {
                      setState(() {
                        _selectedCategory = category;
                        _updateFiltered();
                      });
                    },
                  ),
                );
              }),
            ],
          ),
        ),

        SizedBox(height: 16),

        // Template grid
        GridView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
          ),
          itemCount: _filteredTemplates.length,
          itemBuilder: (context, index) {
            final template = _filteredTemplates[index];
            return _TemplateCard(
              template: template,
              onTap: () => widget.onTemplateSelected(template),
            );
          },
        ),
      ],
    );
  }
}

/// Template card widget
class _TemplateCard extends StatelessWidget {
  final NoteTemplate template;
  final VoidCallback onTap;

  const _TemplateCard({super.key, required this.template, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        child: Padding(
          padding: EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.note_outlined, size: 32),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    template.name,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4),
                  Text(
                    template.description,
                    style: Theme.of(context).textTheme.labelSmall,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Template preview dialog
class TemplatePreviewDialog extends StatelessWidget {
  final NoteTemplate template;

  const TemplatePreviewDialog({super.key, required this.template});

  static void show(BuildContext context, NoteTemplate template) {
    showDialog(
      context: context,
      builder: (context) => TemplatePreviewDialog(template: template),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(template.name),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              template.description,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            SizedBox(height: 16),
            Text('Preview:', style: Theme.of(context).textTheme.labelMedium),
            SizedBox(height: 8),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    template.titlePlaceholder,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    template.contentPlaceholder,
                    style: Theme.of(context).textTheme.bodySmall,
                    maxLines: 10,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Close'),
        ),
      ],
    );
  }
}
