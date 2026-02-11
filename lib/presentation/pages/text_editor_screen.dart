import 'dart:io';
import 'package:flutter/material.dart';
import '../../domain/entities/media_item.dart';
import '../design_system/design_system.dart';

class SimpleTextEditorScreen extends StatefulWidget {
  final MediaItem mediaItem;
  final Function(String editedPath) onSave;

  const SimpleTextEditorScreen({
    super.key,
    required this.mediaItem,
    required this.onSave,
  });

  @override
  State<SimpleTextEditorScreen> createState() => _SimpleTextEditorScreenState();
}

class _SimpleTextEditorScreenState extends State<SimpleTextEditorScreen> {
  late TextEditingController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _loadFileContent();
  }

  Future<void> _loadFileContent() async {
    try {
      final file = File(widget.mediaItem.filePath);
      if (await file.exists()) {
        final content = await file.readAsString();
        _controller.text = content;
      }
    } catch (e) {
      // Handle error
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _saveFile() async {
    try {
      final file = File(widget.mediaItem.filePath);
      await file.writeAsString(_controller.text);
      widget.onSave(widget.mediaItem.filePath);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Failed to save file')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.mediaItem.name,
          style: AppTypography.heading3(
            context,
            AppColors.textPrimary(context),
          ),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.save), onPressed: _saveFile),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _controller,
                maxLines: null,
                expands: true,
                style: AppTypography.bodyLarge(
                  context,
                  AppColors.textPrimary(context),
                ),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Start writing...',
                ),
              ),
            ),
    );
  }
}
