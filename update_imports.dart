import 'dart:io';

void main() {
  final rootPath = 'f:\\GitHub\\mynotes\\lib\\presentation\\bloc';
  final dir = Directory(rootPath);
  if (!dir.existsSync()) return;

  dir.listSync(recursive: true).forEach((entity) {
    if (entity is File && entity.path.endsWith('.dart')) {
      final absolutePath = entity.absolute.path;
      final relativeFromBloc = absolutePath.substring(dir.absolute.path.length);
      final parts = relativeFromBloc
          .split(Platform.pathSeparator)
          .where((s) => s.isNotEmpty)
          .toList();

      int depth = parts.length - 1; // Number of subfolders inside bloc/
      if (depth < 1) return;

      String content = entity.readAsStringSync();
      String originalContent = content;

      // Base prefix for lib/ (from bloc/ it's ../../../)
      // For each level of depth, we add one more ../
      String libPrefix = '../' * (depth + 2);

      // Re-map internal imports
      // If we see "../../core/" it was originally "../core/" or similar.
      // We want to use absolute package imports where possible for stability,
      // but let's just fix the relative ones for now.

      content = content.replaceAll(
        RegExp(r"import '\.\./\.\./\.\./core/"),
        "import '$libPrefix" + "core/",
      );
      content = content.replaceAll(
        RegExp(r"import '\.\./\.\./\.\./domain/"),
        "import '$libPrefix" + "domain/",
      );
      content = content.replaceAll(
        RegExp(r"import '\.\./\.\./\.\./data/"),
        "import '$libPrefix" + "data/",
      );
      content = content.replaceAll(
        RegExp(r"import '\.\./\.\./\.\./presentation/"),
        "import '$libPrefix" + "presentation/",
      );

      // Also handle the case where they only had 2 levels of ../
      content = content.replaceAll(
        RegExp(r"import '\.\./\.\./core/"),
        "import '$libPrefix" + "core/",
      );
      content = content.replaceAll(
        RegExp(r"import '\.\./\.\./domain/"),
        "import '$libPrefix" + "domain/",
      );
      content = content.replaceAll(
        RegExp(r"import '\.\./\.\./data/"),
        "import '$libPrefix" + "data/",
      );
      content = content.replaceAll(
        RegExp(r"import '\.\./\.\./presentation/"),
        "import '$libPrefix" + "presentation/",
      );

      if (content != originalContent) {
        entity.writeAsStringSync(content);
        print('Updated BLoC: $absolutePath (depth $depth)');
      }
    }
  });
}
