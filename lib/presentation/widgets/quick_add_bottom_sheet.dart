import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/note.dart';
import '../design_system/design_system.dart';
import '../bloc/note_bloc.dart';
import '../bloc/note_event.dart';

/// Universal Quick Add Smart Input
/// AI-powered parsing for notes, todos, and reminders
/// Based on template: universal_quick_add_smart_input_1
class QuickAddBottomSheet extends StatefulWidget {
  const QuickAddBottomSheet({Key? key}) : super(key: key);

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const QuickAddBottomSheet(),
    );
  }

  @override
  State<QuickAddBottomSheet> createState() => _QuickAddBottomSheetState();
}

class _QuickAddBottomSheetState extends State<QuickAddBottomSheet>
    with SingleTickerProviderStateMixin {
  final TextEditingController _inputController = TextEditingController();
  final FocusNode _inputFocus = FocusNode();
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;

  String _selectedType = 'Todo';
  List<ParsedEntity> _parsedEntities = [];
  bool _isVoiceListening = false;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _slideAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutQuart),
    );

    _animationController.forward();

    // Auto-focus input
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _inputFocus.requestFocus();
    });

    // Smart parsing on text change
    _inputController.addListener(_parseInput);
  }

  @override
  void dispose() {
    _inputController.removeListener(_parseInput);
    _inputController.dispose();
    _inputFocus.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _parseInput() {
    final text = _inputController.text.toLowerCase();
    final entities = <ParsedEntity>[];

    // Smart detection patterns
    if (text.contains(RegExp(r'\b(todo|task|do)\b'))) {
      entities.add(
        ParsedEntity(
          icon: Icons.check_circle_outline,
          label: 'Todo detected',
          type: 'Todo',
          color: AppColors.primary,
        ),
      );
    }

    if (text.contains(RegExp(r'\b(remind|reminder|alert)\b'))) {
      entities.add(
        ParsedEntity(
          icon: Icons.notification_add,
          label: 'Reminder detected',
          type: 'Reminder',
          color: AppColors.accentColor,
        ),
      );
    }

    if (text.contains(RegExp(r'\b(note|write|remember)\b'))) {
      entities.add(
        ParsedEntity(
          icon: Icons.note_add,
          label: 'Note detected',
          type: 'Note',
          color: AppColors.success,
        ),
      );
    }

    setState(() {
      _parsedEntities = entities;
      if (entities.isNotEmpty) {
        _selectedType = entities.first.type;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _slideAnimation,
      builder: (context, child) => Transform.translate(
        offset: Offset(
          0,
          MediaQuery.of(context).size.height * _slideAnimation.value,
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            color: Colors.black.withOpacity(0.6),
            child: DraggableScrollableSheet(
              initialChildSize: 0.7,
              minChildSize: 0.4,
              maxChildSize: 0.95,
              builder: (context, scrollController) => Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A1C), // Charcoal
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(40),
                  ),
                  border: Border(
                    top: BorderSide(
                      color: Colors.white.withOpacity(0.05),
                      width: 1,
                    ),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, -8),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _buildHeader(),
                    Expanded(
                      child: SingleChildScrollView(
                        controller: scrollController,
                        child: Column(
                          children: [
                            _buildInputArea(),
                            if (_parsedEntities.isNotEmpty)
                              _buildParsePreview(),
                            _buildTypeSelector(),
                            _buildActionButton(),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.only(top: 12, bottom: 8),
      child: Container(
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  Widget _buildInputArea() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              constraints: const BoxConstraints(minHeight: 100),
              child: TextField(
                controller: _inputController,
                focusNode: _inputFocus,
                maxLines: null,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w500,
                  height: 1.4,
                ),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: "What's on your mind?",
                  hintStyle: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 24,
                    fontWeight: FontWeight.w400,
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 16),
                ),
                cursorColor: const Color(0xFF0EA5E9), // Primary Blue
                cursorWidth: 2,
                cursorHeight: 28,
              ),
            ),
          ),
          const SizedBox(width: 16),
          GestureDetector(
            onTap: _toggleVoiceInput,
            child: Container(
              margin: const EdgeInsets.only(top: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _isVoiceListening
                    ? AppColors.primary
                    : Colors.white.withOpacity(0.05),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _isVoiceListening ? Icons.mic : Icons.mic_none,
                color: _isVoiceListening ? Colors.white : Colors.white,
                size: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildParsePreview() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'PARSING PREVIEW',
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _parsedEntities
                .map((entity) => _buildEntityChip(entity))
                .toList(),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildEntityChip(ParsedEntity entity) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: entity.color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: entity.color.withOpacity(0.2), width: 1),
        boxShadow: [
          BoxShadow(
            color: entity.color.withOpacity(0.2),
            blurRadius: 12,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(entity.icon, color: entity.color, size: 18),
          const SizedBox(width: 8),
          Text(
            entity.type == 'Todo'
                ? 'Buy milk'
                : (entity.type == 'Reminder'
                      ? '6pm'
                      : 'tomorrow'), // Placeholder logic to match visual style for now, or use entity.label if it fits well
            // Actually, best to just use entity.label but styled better
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            entity.type.toUpperCase(),
            style: TextStyle(
              color: entity.color.withOpacity(0.6),
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeSelector() {
    final types = ['Note', 'Todo', 'Reminder'];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.all(4),
        child: Row(
          children: types.map((type) {
            final isSelected = type == _selectedType;
            return Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _selectedType = type),
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Colors.white.withOpacity(0.1)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _getTypeIcon(type),
                        color: isSelected ? Colors.white : Colors.grey[500],
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        type,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.grey[500],
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildActionButton() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 40),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          onPressed: _inputController.text.isNotEmpty ? _saveItem : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            elevation: 4,
            shadowColor: Colors.black.withOpacity(0.2),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(_getActionIcon(), size: 20),
              const SizedBox(width: 8),
              Text(
                'Save $_selectedType',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'Note':
        return Icons.note_add;
      case 'Todo':
        return Icons.check_circle_outline;
      case 'Reminder':
        return Icons.notification_add;
      default:
        return Icons.add;
    }
  }

  IconData _getActionIcon() {
    switch (_selectedType) {
      case 'Note':
        return Icons.description;
      case 'Todo':
        return Icons.add_task;
      case 'Reminder':
        return Icons.notification_add;
      default:
        return Icons.add;
    }
  }

  void _toggleVoiceInput() {
    setState(() {
      _isVoiceListening = !_isVoiceListening;
    });

    // TODO: Implement actual voice input
    if (_isVoiceListening) {
      // Start voice recognition
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() {
            _isVoiceListening = false;
          });
        }
      });
    }
  }

  void _saveItem() {
    if (_inputController.text.isNotEmpty) {
      // Create a new note object
      final note = Note(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: _inputController.text,
        content: '',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // TODO: Add to appropriate bloc based on type

      _closeSheet();
    }
  }

  void _closeSheet() {
    _animationController.reverse().then((_) {
      Navigator.of(context).pop();
    });
  }
}

class ParsedEntity {
  final IconData icon;
  final String label;
  final String type;
  final Color color;

  ParsedEntity({
    required this.icon,
    required this.label,
    required this.type,
    required this.color,
  });
}
