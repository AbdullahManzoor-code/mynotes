import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/media_item.dart';
import '../design_system/design_system.dart';
import '../bloc/text_editor/text_editor_bloc.dart';
import '../../injection_container.dart' show getIt;

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

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          getIt<TextEditorBloc>()
            ..add(LoadFileContentEvent(widget.mediaItem.filePath)),
      child: BlocListener<TextEditorBloc, TextEditorState>(
        listener: (context, state) {
          if (state is TextEditorLoaded) {
            _controller.text = state.content;
          } else if (state is TextEditorSaveSuccess) {
            widget.onSave(widget.mediaItem.filePath);
            if (mounted) Navigator.pop(context);
          } else if (state is TextEditorError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.errorMessage ?? 'Editor error')),
            );
          }
        },
        child: BlocBuilder<TextEditorBloc, TextEditorState>(
          builder: (context, state) {
            final isLoading = state.isLoading;

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
                  IconButton(
                    icon: const Icon(Icons.save),
                    onPressed: state.isSaving
                        ? null
                        : () {
                            context.read<TextEditorBloc>().add(
                              SaveFileEvent(
                                filePath: widget.mediaItem.filePath,
                                content: _controller.text,
                              ),
                            );
                          },
                  ),
                ],
              ),
              body: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : Padding(
                      padding: EdgeInsets.all(16.w),
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
                        onChanged: (value) {
                          context.read<TextEditorBloc>().add(
                            UpdateContentEvent(value),
                          );
                        },
                      ),
                    ),
            );
          },
        ),
      ),
    );
  }
}
