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
      titlePlaceholder: 'Journal - ${DateTime.now().toString().split(' ')[0]}',
      contentPlaceholder: '''## Today's Reflection

### Morning Thoughts
What am I thinking about today?
- 

### Afternoon Review
What happened during the day?
- 

### Evening Reflections
What went well today?
- 

What could be improved?
- 

### Gratitude (3 things)
1. I'm grateful for...
2. I'm grateful for...
3. I'm grateful for...

### Tomorrow's Focus
What's my priority for tomorrow?
- 

### Mood/Energy Level
Morning: ☀️ | Afternoon: 🌤️ | Evening: 🌙
''',
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
    NoteTemplate(
      name: 'Weekly Goals',
      description: 'Plan and track weekly objectives',
      titlePlaceholder: 'Week of ${DateTime.now().toString().split(' ')[0]}',
      contentPlaceholder: '''## Weekly Goals

### Priority Goals
1. [Goal] - Why it matters:
2. [Goal] - Why it matters:
3. [Goal] - Why it matters:

### Work
- [ ] Task 1
- [ ] Task 2
- [ ] Task 3

### Personal
- [ ] Task 1
- [ ] Task 2
- [ ] Task 3

### Health & Wellness
- [ ] Task 1
- [ ] Task 2

### Progress Notes
- What went well:
- Challenges faced:
- Lessons learned:

### Next Week's Focus
- ''',
      icon: 'goals',
      category: 'Planning',
      createdAt: DateTime.now(),
    ),
    NoteTemplate(
      name: 'Study Notes',
      description: 'Organize learning materials',
      titlePlaceholder: '[Subject] - [Topic]',
      contentPlaceholder: '''## Study Notes

### Key Concepts
1. **Concept:** Definition:
2. **Concept:** Definition:
3. **Concept:** Definition:

### Important Details
- Point 1: Explanation
- Point 2: Explanation
- Point 3: Explanation

### Examples & Applications
Example 1:
- Scenario:
- Solution:

Example 2:
- Scenario:
- Solution:

### Questions to Review
- Q: A:
- Q: A:

### Practice Problems
Problem 1: [Solution]
Problem 2: [Solution]

### Summary
Main takeaway: ''',
      icon: 'study',
      category: 'Learning',
      createdAt: DateTime.now(),
    ),
    NoteTemplate(
      name: 'Fitness Tracker',
      description: 'Log workouts and progress',
      titlePlaceholder:
          'Fitness Log - ${DateTime.now().toString().split(' ')[0]}',
      contentPlaceholder: '''## Workout Log

### Today's Workout
**Date:** 
**Duration:** 
**Type:** (Cardio/Strength/Flexibility/Other)

### Exercise Details
1. Exercise: 
   - Sets × Reps: 
   - Weight: 
   - Notes: 

2. Exercise: 
   - Sets × Reps: 
   - Weight: 
   - Notes: 

3. Exercise: 
   - Sets × Reps: 
   - Weight: 
   - Notes: 

### Vitals
- Heart Rate: bpm
- Energy Level: 1-10
- How I Felt: 

### Goals Progress
- Weekly Goal: 
- Current Status: 
- On Track? Yes/No

### Notes & Improvements
- What went well:
- What to improve:
''',
      icon: 'fitness',
      category: 'Personal',
      createdAt: DateTime.now(),
    ),
    NoteTemplate(
      name: 'Interview Prep',
      description: 'Prepare for interviews',
      titlePlaceholder: '[Company] - [Position]',
      contentPlaceholder: '''## Interview Preparation

### Company Research
- Company Name: 
- Industry: 
- Mission/Vision: 
- Recent News: 
- Company Culture: 

### Position Details
- Job Title: 
- Key Responsibilities: 
- Required Skills: 
- Growth Opportunities: 

### About You
- Relevant Experience: 
- Key Achievements: 
- Skills Match: 
- Why This Role: 

### Common Questions Prep
Q: Tell me about yourself
A: 

Q: Why do you want this job?
A: 

Q: What's your biggest strength?
A: 

Q: What's your biggest weakness?
A: 

### Questions to Ask
- ?
- ?
- ?

### Interview Details
- Date/Time: 
- Location: 
- Interviewer(s): 
- Dress Code: 
''',
      icon: 'interview',
      category: 'Work',
      createdAt: DateTime.now(),
    ),
    NoteTemplate(
      name: 'Book Notes',
      description: 'Capture key insights from books',
      titlePlaceholder: '[Book Title] by [Author]',
      contentPlaceholder: '''## Book Notes

### Book Info
- Title: 
- Author: 
- Published: 
- Pages: 
- Genre: 

### Overall Impression
Rating: ⭐⭐⭐⭐⭐

Summary in one sentence: 

### Main Themes
1. Theme & Explanation:
2. Theme & Explanation:
3. Theme & Explanation:

### Key Takeaways
1. Insight: Why it matters:
2. Insight: Why it matters:
3. Insight: Why it matters:

### Favorite Quotes
> "Quote" - Page X

> "Quote" - Page X

### How It Changed My Thinking
- Before: 
- After: 

### Practical Applications
How I can apply this:
- 
- 

### Character/Concept Analysis
- Important Character: Role & Impact:

### Questions for Discussion
- ?
- ?
''',
      icon: 'book',
      category: 'Learning',
      createdAt: DateTime.now(),
    ),
    NoteTemplate(
      name: 'Team Standup',
      description: 'Daily team sync notes',
      titlePlaceholder:
          'Team Standup - ${DateTime.now().toString().split(' ')[0]}',
      contentPlaceholder: '''## Daily Standup

**Date:** 
**Attendees:** 

### What I Completed Yesterday
- [ ] Task 1
- [ ] Task 2
- [ ] Task 3

### What I'm Working On Today
- [ ] Task 1
- [ ] Task 2
- [ ] Task 3

### Blockers/Challenges
- Issue: Impact: Solution:
- Issue: Impact: Solution:

### Team Updates
- [Team Member]: Status:
- [Team Member]: Status:
- [Team Member]: Status:

### Announcements
- 

### Next Steps
- 

### Action Items
- [ ] Item Owner: Deadline:
- [ ] Item Owner: Deadline:
''',
      icon: 'meeting',
      category: 'Work',
      createdAt: DateTime.now(),
    ),
    NoteTemplate(
      name: 'Budget Plan',
      description: 'Track income and expenses',
      titlePlaceholder: 'Budget - ${DateTime.now().toString().split(' ')[0]}',
      contentPlaceholder: '''## Budget Planner

### Income
- Source 1: ₹
- Source 2: ₹
**Total Income:** ₹

### Fixed Expenses
- Rent/Mortgage: ₹
- Insurance: ₹
- Utilities: ₹
- Loan Payments: ₹
**Subtotal:** ₹

### Variable Expenses
- Groceries: ₹
- Transportation: ₹
- Entertainment: ₹
- Dining Out: ₹
- Shopping: ₹
**Subtotal:** ₹

### Savings
- Emergency Fund: ₹
- Investment: ₹
- Goals: ₹
**Subtotal:** ₹

### Summary
- Total Income: ₹
- Total Expenses: ₹
- Remaining: ₹

### Financial Goals
- Short Term: 
- Long Term: 
''',
      icon: 'budget',
      category: 'Planning',
      createdAt: DateTime.now(),
    ),
    NoteTemplate(
      name: 'Personal SWOT',
      description: 'Analyze your strengths and weaknesses',
      titlePlaceholder: '[Your Name] - Personal SWOT Analysis',
      contentPlaceholder: '''## Personal SWOT Analysis

### Strengths
What am I good at?
- 
- 
- 

Unique qualities?
- 
- 

Natural talents?
- 

### Weaknesses
What could I improve?
- 
- 
- 

Where do I lack skills?
- 
- 

### Opportunities
What external opportunities exist?
- New Skills to Learn:
- Industries/Fields:
- Resources Available:
- Connections I Could Make:

### Threats
What could hinder my progress?
- Market/Industry Changes:
- Skill Gaps:
- Competition:
- Personal Challenges:

### Action Plan
Based on this analysis:
1. How can I leverage my strengths?
2. How can I address my weaknesses?
3. Which opportunities should I pursue?
4. How can I mitigate threats?

### Success Metrics
How will I measure progress?
- 
- 
''',
      icon: 'analysis',
      category: 'Personal',
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

        // Template grid - Large cards
        GridView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 0.85,
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

  const _TemplateCard({required this.template, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 3,
        child: Material(
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.note_outlined,
                      size: 40,
                      color: Colors.blue.shade600,
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 12),
                        Text(
                          template.name,
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 8),
                        Text(
                          template.description,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                fontSize: 13,
                                color: Colors.grey.shade700,
                              ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Chip(
                    label: Text(
                      template.category,
                      style: TextStyle(fontSize: 12),
                    ),
                    backgroundColor: Colors.blue.shade100,
                    avatar: Icon(Icons.label, size: 16),
                  ),
                ],
              ),
            ),
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
