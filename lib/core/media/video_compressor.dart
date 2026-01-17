import 'dart:io';
import 'package:path/path.dart' as p;

class VideoCompressor {
  static Future<String> compress(
    String inputPath, {
    int maxWidth = 1280,
    int fps = 30,
  }) async {
    try {
      final dir = p.dirname(inputPath);
      final ext = p.extension(inputPath);
      final nameWithoutExt = p.basename(inputPath).replaceAll(ext, '');
      final newPath = p.join(dir, '${nameWithoutExt}_compressed$ext');
      final file = File(inputPath);
      if (await file.exists()) {
        await file.copy(newPath);
      } else {
        final f = File(newPath);
        await f.create(recursive: true);
      }
      return newPath;
    } catch (e) {
      throw Exception('Video compression failed: $e');
    }
  }
}
