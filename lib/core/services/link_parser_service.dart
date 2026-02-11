// OPTIONAL FEATURE: Knowledge Graph & Linking (may be removed)
import 'package:flutter/foundation.dart';

class LinkParserService {
  /// Regex to find [[Wiki Links]]
  /// Matches [[Content]] where Content is anything except ]
  static final RegExp _wikiLinkRegex = RegExp(r'\[\[([^\]]+)\]\]');

  /// Extract all wiki-links from content
  List<String> extractLinks(String content) {
    if (content.isEmpty) return [];

    final matches = _wikiLinkRegex.allMatches(content);
    return matches
        .map((m) => m.group(1)?.trim())
        .where((s) => s != null && s.isNotEmpty)
        .cast<String>()
        .toList();
  }

  /// Check if content contains any wiki-links
  bool hasLinks(String content) {
    return _wikiLinkRegex.hasMatch(content);
  }
}
