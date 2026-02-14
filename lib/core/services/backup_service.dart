import 'dart:io';
import 'package:archive/archive_io.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sqflite/sqflite.dart';

enum BackupType { full, dataOnly, mediaOnly }

class BackupService {
  static const String _dbName = 'notes.db';
  static const String _backupFileName = 'mynotes_backup.zip';

  /// Calculate the size of the database and media files
  static Future<Map<String, double>> getBackupStats() async {
    double dbSize = 0;
    double mediaSize = 0;

    // DB Size
    final dbPath = p.join(await getDatabasesPath(), _dbName);
    final dbFile = File(dbPath);
    if (await dbFile.exists()) {
      dbSize = (await dbFile.length()) / (1024 * 1024); // MB
    }

    // Media Size
    final docsDir = await getApplicationDocumentsDirectory();
    final mediaDir = Directory(docsDir.path);
    if (await mediaDir.exists()) {
      await for (final file in mediaDir.list(recursive: true)) {
        if (file is File) {
          final ext = p.extension(file.path).toLowerCase();
          if (['.jpg', '.png', '.mp4', '.m4a', '.aac', '.pdf'].contains(ext)) {
            mediaSize += (await file.length()) / (1024 * 1024); // MB
          }
        }
      }
    }

    return {'db': dbSize, 'media': mediaSize, 'total': dbSize + mediaSize};
  }

  /// Get total count of media files
  static Future<int> getMediaCount() async {
    int count = 0;
    final docsDir = await getApplicationDocumentsDirectory();
    final mediaDir = Directory(docsDir.path);
    if (await mediaDir.exists()) {
      await for (final file in mediaDir.list(recursive: true)) {
        if (file is File) {
          final ext = p.extension(file.path).toLowerCase();
          if (['.jpg', '.png', '.mp4', '.m4a', '.aac', '.pdf'].contains(ext)) {
            count++;
          }
        }
      }
    }
    return count;
  }

  /// Create a zip backup and return the file path
  static Future<String?> createBackup(BackupType type) async {
    try {
      final encoder = ZipFileEncoder();
      final tempDir = await getTemporaryDirectory();
      final backupPath = p.join(tempDir.path, _backupFileName);

      encoder.create(backupPath);

      // Add DB if requested
      if (type == BackupType.full || type == BackupType.dataOnly) {
        final dbPath = p.join(await getDatabasesPath(), _dbName);
        final dbFile = File(dbPath);
        if (await dbFile.exists()) {
          encoder.addFile(dbFile);
        }
      }

      // Add Media if requested
      if (type == BackupType.full || type == BackupType.mediaOnly) {
        final docsDir = await getApplicationDocumentsDirectory();
        final mediaDir = Directory(docsDir.path);
        if (await mediaDir.exists()) {
          await for (final file in mediaDir.list(recursive: true)) {
            if (file is File) {
              final ext = p.extension(file.path).toLowerCase();
              if ([
                '.jpg',
                '.png',
                '.mp4',
                '.m4a',
                '.aac',
                '.pdf',
              ].contains(ext)) {
                // Keep relative path structure if possible or just flatten
                encoder.addFile(file);
              }
            }
          }
        }
      }

      encoder.close();
      return backupPath;
    } catch (e) {
      print('Backup Error: $e');
      return null;
    }
  }

  /// Share the backup file
  static Future<void> shareBackup(String filePath) async {
    await Share.shareXFiles(
      [XFile(filePath)],
      subject: 'MyNotes Backup',
      text: 'Here is my MyNotes application backup.',
    );
  }

  /// Clear temporary files and cached media
  static Future<void> clearCache() async {
    try {
      final tempDir = await getTemporaryDirectory();
      if (await tempDir.exists()) {
        await for (final entity in tempDir.list()) {
          if (entity is File) {
            await entity.delete();
          } else if (entity is Directory) {
            await entity.delete(recursive: true);
          }
        }
      }
    } catch (e) {
      print('Clear Cache Error: $e');
    }
  }

  /// Import backup from zip file
  static Future<bool> importBackup(String zipPath, {bool merge = true}) async {
    try {
      final bytes = await File(zipPath).readAsBytes();
      final archive = ZipDecoder().decodeBytes(bytes);

      for (final file in archive) {
        if (file.isFile) {
          final data = file.content as List<int>;
          if (file.name == _dbName) {
            final dbPath = p.join(await getDatabasesPath(), _dbName);
            if (!merge) {
              await File(dbPath).writeAsBytes(data);
            } else {
              // Merge logic would be more complex, needing a secondary DB or custom SQL
              // For now, let's just replace if not merging, or ignore if merging (placeholder)
            }
          } else {
            // Media files
            final docsDir = await getApplicationDocumentsDirectory();
            final filePath = p.join(docsDir.path, file.name);
            await File(filePath).create(recursive: true);
            await File(filePath).writeAsBytes(data);
          }
        }
      }
      return true;
    } catch (e) {
      print('Import Error: $e');
      return false;
    }
  }
}
