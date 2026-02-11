import 'dart:io';
import 'package:flutter/material.dart';
import 'package:pro_image_editor/pro_image_editor.dart';
import '../../domain/entities/media_item.dart';

class ImageEditorScreen extends StatelessWidget {
  final MediaItem mediaItem;
  final Function(String editedPath) onSave;

  const ImageEditorScreen({
    super.key,
    required this.mediaItem,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return ProImageEditor.file(
      File(mediaItem.filePath),
      callbacks: ProImageEditorCallbacks(
        onImageEditingComplete: (bytes) async {
          // Save the edited image to a temporary file
          final tempDir = Directory.systemTemp;
          final editedFile = File(
            '${tempDir.path}/edited_${DateTime.now().millisecondsSinceEpoch}.png',
          );
          await editedFile.writeAsBytes(bytes);

          onSave(editedFile.path);
          if (context.mounted) Navigator.pop(context);
        },
        onCloseEditor: (mode) => Navigator.pop(context),
      ),
      configs: const ProImageEditorConfigs(
        designMode: ImageEditorDesignMode.material,
      ),
    );
  }
}
