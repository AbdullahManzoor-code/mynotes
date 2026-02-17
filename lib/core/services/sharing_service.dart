import 'dart:io';
import 'package:share_plus/share_plus.dart';
import 'package:mynotes/core/services/app_logger.dart';

/// ════════════════════════════════════════════════════════════════════════════
/// PHASE 7: EXPORT & SHARING
/// Sharing Service - Handle sharing via email, social, etc.
/// ════════════════════════════════════════════════════════════════════════════

class SharingService {
  /// Share text via system share dialog
  Future<bool> shareText({required String text, String? subject}) async {
    try {
      AppLogger.i('Sharing text: ${text.length} chars');

      await Share.share(text, subject: subject);

      AppLogger.i('Text shared successfully');
      return true;
    } catch (e, stack) {
      AppLogger.e('Share text failed', e, stack);
      return false;
    }
  }

  /// Share file via system share dialog
  Future<bool> shareFile({required File file, String? text}) async {
    try {
      AppLogger.i('Sharing file: ${file.path}');

      await Share.shareXFiles([XFile(file.path)], text: text);

      AppLogger.i('File shared successfully');
      return true;
    } catch (e, stack) {
      AppLogger.e('Share file failed', e, stack);
      return false;
    }
  }

  /// Share multiple files
  Future<bool> shareMultipleFiles({
    required List<File> files,
    String? text,
  }) async {
    try {
      AppLogger.i('Sharing ${files.length} files');

      final xFiles = files.map((f) => XFile(f.path)).toList();

      await Share.shareXFiles(xFiles, text: text);

      AppLogger.i('Files shared successfully');
      return true;
    } catch (e, stack) {
      AppLogger.e('Share files failed', e, stack);
      return false;
    }
  }

  /// Share via email (native email client)
  Future<bool> shareViaEmail({
    required String email,
    required String subject,
    required String body,
    List<String>? ccEmails,
    List<String>? bccEmails,
  }) async {
    try {
      AppLogger.i('Sharing via email to: $email');

      final cc = ccEmails?.join(',') ?? '';
      final bcc = bccEmails?.join(',') ?? '';
      final mailto =
          'mailto:$email?subject=${Uri.encodeComponent(subject)}&body=${Uri.encodeComponent(body)}'
          '${cc.isNotEmpty ? '&cc=$cc' : ''}'
          '${bcc.isNotEmpty ? '&bcc=$bcc' : ''}';

      // In real app, use url_launcher to open mailto:
      AppLogger.i('Email sharing prepared: $mailto');
      return true;
    } catch (e, stack) {
      AppLogger.e('Share via email failed', e, stack);
      return false;
    }
  }

  /// Get shareable quote/text for social media
  String getShareableText({
    required String title,
    required String message,
    String? hashtags,
  }) {
    final text = StringBuffer();
    text.writeln('📝 $title');
    text.writeln();
    text.writeln(message);

    if (hashtags != null && hashtags.isNotEmpty) {
      text.writeln();
      text.writeln(hashtags);
    }

    text.writeln();
    text.writeln('Shared from MyNotes 📱');

    return text.toString();
  }

  /// Create shareable summary for analytics/stats
  String createShareableSummary({
    required String title,
    required Map<String, dynamic> stats,
  }) {
    final buffer = StringBuffer();
    buffer.writeln('📊 $title');
    buffer.writeln();

    stats.forEach((key, value) {
      buffer.writeln('$key: $value');
    });

    buffer.writeln();
    buffer.writeln('Keep tracking your productivity! 💪');
    buffer.writeln('#MyNotes #Productivity #FeelGood');

    return buffer.toString();
  }

  /// Create shareable reflection
  String createShareableReflection({
    required String title,
    required String content,
    String? mood,
  }) {
    final buffer = StringBuffer();
    buffer.writeln('✨ Reflection: $title');
    if (mood != null) {
      buffer.writeln('Mood: $mood');
    }
    buffer.writeln();
    buffer.writeln(content);
    buffer.writeln();
    buffer.writeln('Sharing my thoughts with MyNotes 📖');

    return buffer.toString();
  }

  /// Create shareable focus session summary
  String createShareableFocusSession({
    required String duration,
    required int completedPomodoros,
    String? goals,
  }) {
    final buffer = StringBuffer();
    buffer.writeln('⏱️ Focus Session Complete!');
    buffer.writeln();
    buffer.writeln('Duration: $duration');
    buffer.writeln('Completed Pomodoros: $completedPomodoros');
    if (goals != null && goals.isNotEmpty) {
      buffer.writeln('Goals: $goals');
    }
    buffer.writeln();
    buffer.writeln('Staying focused with MyNotes 💪🎯');
    buffer.writeln('#FocusSession #Pomodoro #Productivity');

    return buffer.toString();
  }
}

// Extension method for easy sharing from contexts
extension ShareableExtension on String {
  Future<bool> share() async {
    try {
      await Share.share(this);
      return true;
    } catch (e) {
      AppLogger.e('Critical error during share', e, StackTrace.current);
      return false;
    }
  }
}
