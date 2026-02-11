import 'package:flutter/material.dart';

import 'package:mynotes/presentation/design_system/design_system.dart';

class CommandPaletteWidget extends StatefulWidget {
  final Function(String) onQueryChanged;
  final VoidCallback onClear;
  final TextEditingController controller;
  final VoidCallback? onFilterPressed;

  const CommandPaletteWidget({
    super.key,
    required this.onQueryChanged,
    required this.onClear,
    required this.controller,
    this.onFilterPressed,
  });

  @override
  State<CommandPaletteWidget> createState() => _CommandPaletteWidgetState();
}

class _CommandPaletteWidgetState extends State<CommandPaletteWidget> {
  bool _isCommandMode = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    final text = widget.controller.text;
    if (text.startsWith('/') || text.startsWith('>')) {
      if (!_isCommandMode) {
        setState(() => _isCommandMode = true);
      }
    } else {
      if (_isCommandMode) {
        setState(() => _isCommandMode = false);
      }
    }
    widget.onQueryChanged(text);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, 4),
            blurRadius: 10,
          ),
        ],
      ),
      child: TextField(
        controller: widget.controller,
        autofocus: true,
        style: AppTypography.body1(context, AppColors.textPrimary(context)),
        decoration: InputDecoration(
          hintText: _isCommandMode
              ? 'Type a command...'
              : 'Search or type "/" for commands...',
          prefixIcon: Icon(
            _isCommandMode ? Icons.terminal : Icons.search,
            color: _isCommandMode
                ? AppColors.primary
                : AppColors.textSecondary(context),
          ),
          suffixIcon: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.controller.text.isNotEmpty)
                IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    widget.controller.clear();
                    widget.onClear();
                  },
                ),
              if (!_isCommandMode && widget.onFilterPressed != null)
                IconButton(
                  icon: const Icon(Icons.tune),
                  onPressed: widget.onFilterPressed,
                  color: AppColors.primary,
                ),
              if (widget.controller.text.isEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                  child: Text(
                    '⌘K',
                    style: TextStyle(
                      color: AppColors.textSecondary(context),
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
            ],
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: _isCommandMode ? AppColors.primary : AppColors.borderLight,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: _isCommandMode ? AppColors.primary : AppColors.primary,
              width: 2,
            ),
          ),
          filled: true,
          fillColor: AppColors.background(context),
        ),
      ),
    );
  }
}
