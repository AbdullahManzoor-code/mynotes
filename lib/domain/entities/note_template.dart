import 'package:equatable/equatable.dart';

/// Note Template Types
enum NoteTemplateType {
  blank,
  meeting,
  journal,
  recipe,
  todoList,
  project,
  studyNotes,
  travelPlan,
  bookSummary,
  ideaBrainstorm;

  String get displayName {
    switch (this) {
      case NoteTemplateType.blank:
        return 'Blank Note';
      case NoteTemplateType.meeting:
        return 'Meeting Notes';
      case NoteTemplateType.journal:
        return 'Daily Journal';
      case NoteTemplateType.recipe:
        return 'Recipe';
      case NoteTemplateType.todoList:
        return 'To-Do List';
      case NoteTemplateType.project:
        return 'Project Plan';
      case NoteTemplateType.studyNotes:
        return 'Study Notes';
      case NoteTemplateType.travelPlan:
        return 'Travel Plan';
      case NoteTemplateType.bookSummary:
        return 'Book Summary';
      case NoteTemplateType.ideaBrainstorm:
        return 'Idea Brainstorm';
    }
  }

  String get icon {
    switch (this) {
      case NoteTemplateType.blank:
        return '📄';
      case NoteTemplateType.meeting:
        return '🤝';
      case NoteTemplateType.journal:
        return '📖';
      case NoteTemplateType.recipe:
        return '🍳';
      case NoteTemplateType.todoList:
        return '✅';
      case NoteTemplateType.project:
        return '📊';
      case NoteTemplateType.studyNotes:
        return '📚';
      case NoteTemplateType.travelPlan:
        return '✈️';
      case NoteTemplateType.bookSummary:
        return '📕';
      case NoteTemplateType.ideaBrainstorm:
        return '💡';
    }
  }

  String get template {
    switch (this) {
      case NoteTemplateType.blank:
        return '';
      case NoteTemplateType.meeting:
        return '''# Meeting Notes

**Date:** ${DateTime.now().toString().split(' ')[0]}
**Attendees:** 
**Agenda:**

## Discussion Points
- 

## Action Items
- [ ] 

## Decisions Made
- 

## Next Steps
- ''';
      case NoteTemplateType.journal:
        return '''# Daily Journal - ${DateTime.now().toString().split(' ')[0]}

## How I'm Feeling Today
😊

## What Happened Today
- 

## Grateful For
- 

## Tomorrow's Goals
- ''';
      case NoteTemplateType.recipe:
        return '''# Recipe Name

**Prep Time:** 
**Cook Time:** 
**Servings:** 

## Ingredients
- 

## Instructions
1. 

## Notes
- ''';
      case NoteTemplateType.todoList:
        return '''# To-Do List

## High Priority
- [ ] 

## Medium Priority
- [ ] 

## Low Priority
- [ ] 

## Completed
- [x] ''';
      case NoteTemplateType.project:
        return '''# Project: [Name]

## Overview
**Goal:** 
**Deadline:** 
**Status:** 🟡 In Progress

## Milestones
- [ ] Phase 1: 
- [ ] Phase 2: 
- [ ] Phase 3: 

## Resources Needed
- 

## Team Members
- 

## Notes
- ''';
      case NoteTemplateType.studyNotes:
        return '''# [Subject] - Study Notes

**Chapter/Topic:** 
**Date:** ${DateTime.now().toString().split(' ')[0]}

## Key Concepts
- 

## Important Formulas/Facts
- 

## Examples
1. 

## Questions to Review
- [ ] 

## Summary
''';
      case NoteTemplateType.travelPlan:
        return '''# Travel Plan - [Destination]

**Dates:** 
**Budget:** 

## Itinerary
### Day 1
- 

### Day 2
- 

## Bookings
- [ ] Flight
- [ ] Hotel
- [ ] Activities

## Packing List
- [ ] 

## Important Contacts
- ''';
      case NoteTemplateType.bookSummary:
        return '''# Book Summary: [Title]

**Author:** 
**Genre:** 
**Rating:** ⭐⭐⭐⭐⭐

## Main Themes
- 

## Key Takeaways
1. 

## Favorite Quotes
> 

## My Thoughts
''';
      case NoteTemplateType.ideaBrainstorm:
        return '''# Idea Brainstorm

**Topic:** 
**Date:** ${DateTime.now().toString().split(' ')[0]}

## Initial Thoughts
- 

## Pros
✅ 

## Cons
❌ 

## Action Steps
- [ ] 

## Resources
- ''';
    }
  }
}

/// Note Template Entity
class NoteTemplate extends Equatable {
  final String id;
  final String name;
  final NoteTemplateType type;
  final String content;
  final String icon;
  final DateTime createdAt;

  const NoteTemplate({
    required this.id,
    required this.name,
    required this.type,
    required this.content,
    required this.icon,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, name, type, content, icon, createdAt];

  factory NoteTemplate.fromType(NoteTemplateType type) {
    return NoteTemplate(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: type.displayName,
      type: type,
      content: type.template,
      icon: type.icon,
      createdAt: DateTime.now(),
    );
  }

  NoteTemplate copyWith({
    String? id,
    String? name,
    NoteTemplateType? type,
    String? content,
    String? icon,
    DateTime? createdAt,
  }) {
    return NoteTemplate(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      content: content ?? this.content,
      icon: icon ?? this.icon,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

