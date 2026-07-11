/// Normalizes SkyLearn media and API asset URLs.
class ApiUrlHelper {
  static const String siteBase = 'https://skylearn.runasp.net';
  static const String apiBase = 'https://skylearn.runasp.net/api/';

  static String? resolveMediaUrl(String? url) {
    if (url == null) return null;

    final trimmed = url.trim();
    if (trimmed.isEmpty || trimmed == 'null' || trimmed.startsWith('assets/')) {
      return null;
    }

    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      return _normalizeSlashes(trimmed);
    }

    var path = trimmed.startsWith('/') ? trimmed : '/$trimmed';

    return _normalizeSlashes('$siteBase$path');
  }

  static String _fixUploadsInAbsoluteUrl(String url) {
    return url.replaceAll('/api/uploads/', '/uploads/');
  }

  static String _normalizeSlashes(String url) {
    final schemeMatch = RegExp(r'^([a-zA-Z][\w+.-]*:)//').firstMatch(url);
    if (schemeMatch == null) return url.replaceAll(RegExp(r'/+'), '/');

    final scheme = schemeMatch.group(1)!;
    final rest = url.substring(schemeMatch.end);
    final normalizedRest = rest.replaceAll(RegExp(r'/+'), '/');
    return '$scheme//$normalizedRest';
  }
}
