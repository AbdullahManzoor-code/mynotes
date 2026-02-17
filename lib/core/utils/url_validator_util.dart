/// Centralized URL validation utility - single source of truth
class UrlValidatorUtil {
  /// Validate if a string is a valid URL
  static bool isValidUrl(String url) {
    if (url.isEmpty) return false;
    try {
      Uri.parse(url);
      return url.startsWith('http://') || url.startsWith('https://');
    } catch (e) {
      return false;
    }
  }

  /// Normalize URL by adding https:// if no scheme present
  static String normalizeUrl(String url) {
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      return 'https://$url';
    }
    return url;
  }

  /// Get display URL by extracting domain without www
  static String getDisplayUrl(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.host.replaceFirst('www.', '');
    } catch (e) {
      return 'Link';
    }
  }
}
